import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_row.entity.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

abstract class VendorReportsRemoteDataSource {
  Future<List<ReportRowEntity>> fetchRows({required String vendorId, required DateTime from, required DateTime to, required DateTime now});
}



class VendorReportsRemoteDataSourceImpl implements VendorReportsRemoteDataSource {
  final _requestsCollection = 'requested_packages';
  final _connectionsCollection = 'connections';
  final  _packagesCollection = 'package_details';

  final _vendorIdField = 'vendorId';
  final _amountReloadLabel = 'Amount reload';
  /// How far back to look so a recent renewal is seen when working out which
  /// connections are really about to expire.
  final _renewalLookbackDays = 45;
  final  _expiryHorizonDays = 7;

  final FirebaseFirestore firestore;

  VendorReportsRemoteDataSourceImpl({required this.firestore});


  /// Returns the union of:
  ///  * requests made in [from, to) (the caller passes the previous period
  ///    too, so growth can be compared),
  ///  * recent requests (renewal lookback),
  ///  * every unpaid request, and
  ///  * requests expiring within the next week.
  /// De-duplicated by request id.
  @override
  Future<List<ReportRowEntity>> fetchRows({required String vendorId, required DateTime from, required DateTime to, required DateTime now}) async {
    try {
      final today = DateTime(now.year, now.month, now.day);
      final recentStart =
      DateTime(today.year, today.month, today.day - _renewalLookbackDays);
      final recentEnd = DateTime(today.year, today.month, today.day + 1);
      final recentAlreadyCovered = !from.isAfter(recentStart) && !to.isBefore(recentEnd);

      final snapshots = await Future.wait([
        _byDate(vendorId, 'requestDate', from, to),
        if (!recentAlreadyCovered)
          _byDate(vendorId, 'requestDate', recentStart, recentEnd),
        firestore
            .collection(_requestsCollection)
            .where(_vendorIdField, isEqualTo: vendorId)
            .where('isPaid', isEqualTo: false)
            .get(),
        _byDate(
          vendorId,
          'expireDate',
          today,
          DateTime(today.year, today.month, today.day + _expiryHorizonDays + 1),
        ),
      ]);

      final requests = <String, Map<String, dynamic>>{};
      for (final snap in snapshots) {
        for (final doc in snap.docs) {
          requests[doc.id] = doc.data();
        }
      }

      final connectionIds = <String>{
        for (final d in requests.values)
          if (d['connectionId'] is String) d['connectionId'] as String,
      };
      final packageIds = <String>{
        for (final d in requests.values)
          if (d['packageDetailsId'] is String) d['packageDetailsId'] as String,
      };

      final lookups = await Future.wait([
        _getByIds(_connectionsCollection, connectionIds),
        _getByIds(_packagesCollection, packageIds),
      ]);
      final connections = lookups[0];
      final packages = lookups[1];

      final rows = <ReportRowEntity>[];
      requests.forEach((id, d) {
        final requestDate = _toDate(d['requestDate']);
        if (requestDate == null) return;

        final connection =
            connections[d['connectionId']] ?? const <String, dynamic>{};
        final package =
            packages[d['packageDetailsId']] ?? const <String, dynamic>{};

        rows.add(
          ReportRowEntity(
            id: id,
            connectionId: (d['connectionId'] as String?) ?? '',
            connectionName: (connection['connectionName'] as String?) ?? '-',
            connectionNumber: (connection['connectionNumber'] as String?) ?? '-',
            // Amount reloads have no package, so take the provider from the
            // connection instead.
            serviceProvider: (package['serviceProvider'] as String?) ??
                (connection['serviceProvider'] as String?) ??
                'Unknown',
            packageName: _hasId(d['packageDetailsId'])
                ? ((package['packageName'] as String?) ?? 'Unknown')
                : _amountReloadLabel,
            requestDate: requestDate,
            amount: _toDouble(d['amount']) ?? _toDouble(package['packagePrice']) ?? 0,
            isPaid: d['isPaid'] == true,
            expireDate: _toDate(d['expireDate']),
          ),
        );
      });
      return rows;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'VendorReportsRemoteDataSourceImpl.fetchRows',
        stackTrace: st,
      );
      throw ServerException('Failed to fetch report info');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'VendorReportsRemoteDataSourceImpl.fetchRows',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to load report info');
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _byDate(String vendorId, String field, DateTime start, DateTime end) {
    return firestore
        .collection(_requestsCollection)
        .where(_vendorIdField, isEqualTo: vendorId)
        .where(field, isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where(field, isLessThan: Timestamp.fromDate(end))
        .get();
  }

  /// Loads documents by id in chunks (Firestore `whereIn` allows 30 values).
  Future<Map<String, Map<String, dynamic>>> _getByIds(String collection, Set<String> ids) async {
    // Amount reloads have no packageDetailsId (null or blank), and Firestore
    // rejects an empty string in a documentId query, so skip those.
    final list = ids.where((id) => id.trim().isNotEmpty).toList();
    if (list.isEmpty) return {};
    final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (var i = 0; i < list.length; i += 30) {
      final end = i + 30 > list.length ? list.length : i + 30;
      futures.add(
        firestore
            .collection(collection)
            .where(FieldPath.documentId, whereIn: list.sublist(i, end))
            .get(),
      );
    }
    final snaps = await Future.wait(futures);
    return {
      for (final s in snaps)
        for (final d in s.docs) d.id: d.data(),
    };
  }

  bool _hasId(dynamic v) => v is String && v.trim().isNotEmpty;

  DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  double? _toDouble(dynamic v) => v is num ? v.toDouble() : null;
}