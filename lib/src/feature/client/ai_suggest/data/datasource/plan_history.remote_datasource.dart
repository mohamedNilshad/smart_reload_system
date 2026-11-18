import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/candidate_package.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/connection_info.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_suggestion_input.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/reload_record.entity.dart';
import 'package:smart_reload_system/src/core/services/validity_days.service.dart';

// TODO: match these names to your Firestore schema.
const _requestsCollection = 'requested_packages';
const _connectionsCollection = 'connections';
const _packagesCollection = 'package_details';

/// How many days of history to read, and the most requests to load.
const _historyDays = 90;
const _historyLimit = 100;
const _candidateLimit = 60;

/// Reads one connection's reload history and the packages its provider sells.
class PlanHistoryRemoteDataSource {
  PlanHistoryRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<PlanSuggestionInputEntity> load({
    required String connectionId,
    required DateTime now,
  }) async {
    try {
      final connectionDoc =
          await _db.collection(_connectionsCollection).doc(connectionId).get();
      final c = connectionDoc.data();
      if (c == null) throw ServerException('Connection not found');

      final connection = ConnectionInfoEntity(
        id: connectionId,
        serviceProvider: _text(c['serviceProvider']),
        connectionCategory: _text(c['connectionCategory']),
        connectionType: _text(c['connectionType']),
        billingType: _text(c['billingType']),
      );

      final since = DateTime(now.year, now.month, now.day - _historyDays);
      // Needs a composite index: connectionId (asc) + requestDate (asc).
      // The first run prints an error with a link that creates it.
      final requests = await _db
          .collection(_requestsCollection)
          .where('connectionId', isEqualTo: connectionId)
          .where('requestDate', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('requestDate')
          .limit(_historyLimit)
          .get();

      final packageIds = <String>{
        for (final doc in requests.docs)
          if (_hasId(doc.data()['packageDetailsId']))
            doc.data()['packageDetailsId'] as String,
      };

      final historyPackagesFuture = _getByIds(_packagesCollection, packageIds);
      final candidatesFuture = _loadCandidates(connection.serviceProvider);
      final historyPackages = await historyPackagesFuture;
      final candidates = await candidatesFuture;

      final history = <ReloadRecordEntity>[];
      for (final doc in requests.docs) {
        final d = doc.data();
        final requestDate = _toDate(d['requestDate']);
        if (requestDate == null) continue;

        // Amount reloads have no packageDetailsId; only package reloads do.
        final packageId = _hasId(d['packageDetailsId'])
            ? d['packageDetailsId'] as String
            : null;
        final package = packageId == null
            ? const <String, dynamic>{}
            : (historyPackages[packageId] ?? const <String, dynamic>{});

        final amount = _toDouble(d['amount']) ?? _toDouble(package['packagePrice']) ?? 0;
        if (amount <= 0) continue;

        history.add(
          ReloadRecordEntity(
            requestDate: requestDate,
            amount: amount,
            packageId: packageId,
            packageName: packageId == null
                ? null
                : (_textOrNull(package['packageName']) ?? 'Unknown package'),
            packageType: _textOrNull(package['packageType']),
            validityDays: packageId == null
                ? null
                : validityInDays(
                    _toDouble(package['packageValidity']),
                    package['validityPeriod'] as String?,
                  ),
            activatedDate: _toDate(d['activatedDate']),
            expireDate: _toDate(d['expireDate']),
          ),
        );
      }

      return PlanSuggestionInputEntity(
        connection: connection,
        history: history,
        candidates: candidates,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Could not load your reload history');
    }
  }

  Future<List<CandidatePackageEntity>> _loadCandidates(String provider) async {
    if (provider.isEmpty) return const [];

    // TODO: if packages are scoped to a vendor or telecom type in your data,
    // add that filter here.
    final snap = await _db
        .collection(_packagesCollection)
        .where('serviceProvider', isEqualTo: provider)
        .limit(_candidateLimit)
        .get();

    final out = <CandidatePackageEntity>[];
    for (final doc in snap.docs) {
      final d = doc.data();
      final price = _toDouble(d['packagePrice']);
      final days = validityInDays(
        _toDouble(d['packageValidity']),
        d['validityPeriod'] as String?,
      );
      if (price == null || price <= 0 || days == null || days <= 0) continue;

      out.add(
        CandidatePackageEntity(
          id: doc.id,
          name: _textOrNull(d['packageName']) ?? 'Package',
          serviceProvider: provider,
          packageType: _text(d['packageType']),
          description: _text(d['packageDescription']),
          price: price,
          validityDays: days,
        ),
      );
    }
    return out;
  }

  /// Loads documents by id in chunks (Firestore `whereIn` allows 30 values).
  Future<Map<String, Map<String, dynamic>>> _getByIds(
    String collection,
    Set<String> ids,
  ) async {
    final list = ids.where((id) => id.trim().isNotEmpty).toList();
    if (list.isEmpty) return {};

    final futures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
    for (var i = 0; i < list.length; i += 30) {
      final end = i + 30 > list.length ? list.length : i + 30;
      futures.add(
        _db
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

  String _text(dynamic v) => v is String ? v.trim() : '';

  String? _textOrNull(dynamic v) {
    final s = _text(v);
    return s.isEmpty ? null : s;
  }

  DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  double? _toDouble(dynamic v) => v is num ? v.toDouble() : null;
}
