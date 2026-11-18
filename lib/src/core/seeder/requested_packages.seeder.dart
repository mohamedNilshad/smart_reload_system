import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// DEV ONLY. Inserts dummy `requested_packages` documents for testing the
/// AI plan suggestions and the vendor reports. Remove it before release.
///
/// Dates are relative to "now", so the data always falls inside the last
/// ~90 days. Every document has an id starting with `dummy_`, so running
/// [seed] again overwrites the same documents and [deleteSeeded] removes
/// them without touching real data.
///
/// As requested, `isPaid` is false and `paidDate` / `paymentId` are null on
/// every document, and `packageDetailsId` is null for Utility and TV
/// connections and for amount reloads.
class RequestedPackagesSeeder {
  RequestedPackagesSeeder({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _collection = 'requested_packages';
  static const _idPrefix = 'dummy_';
  static const _vendorId = 'M5kLOOhQoqSdCIGrp0TKexliopi2'; // Phone Shop1

  // Connections (id, clientVendorId) from your `connections` collection.
  static const _myMob = _Conn('REspbf9rY3Y4gyYVOrO3', '7EZNImXLRjBTd57942EI');
  static const _myPhone = _Conn('hcZnXbKsGUIQzqDkFpyx', 'rkCCxuj26HKOf33X67Ht');
  static const _myWifi = _Conn('2bHAJ67wYFiqtnWiRwSh', 'rkCCxuj26HKOf33X67Ht');
  static const _homeWater = _Conn('MBdt0qFviL1aTXDtzYx3', 'rkCCxuj26HKOf33X67Ht');
  static const _homeElectricity = _Conn('yvhfzLuVGjBzlIEAn57s', 'rkCCxuj26HKOf33X67Ht');
  static const _dtv = _Conn('vgA4SaLiRo1b4V3p6IRH', 'rkCCxuj26HKOf33X67Ht');

  // Packages (id, price, validity in days) from your `package_details`.
  static const _gb1Daily = _Pkg('fStqKCuPBikPZPvaWEK8', 99, 1); // 1GB Anytime
  static const _gb10 = _Pkg('u0B8IwZYvC4fhHVcqvZL', 599, 14); // 10GB Anytime
  static const _voice500 = _Pkg('cIyry1VTvmnO9hW3eXQO', 499, 30); // 500 Minutes Voice
  static const _wifi50 = _Pkg('3dZuheAJ1XrhyEpHkf1U', 1499, 30); // 50GB Home Broadband
  static const _wifiUnlimited = _Pkg('zBzFM4fFFT7xxr9xaCRi', 3990, 30); // Unlimited Home Lite

  /// Writes the dummy documents. Returns how many were written.
  Future<int> seed({DateTime? now}) async {
    final entries = _build(now ?? DateTime.now());
    for (var i = 0; i < entries.length; i += 400) {
      final batch = _db.batch();
      for (final e in entries.skip(i).take(400)) {
        batch.set(_db.collection(_collection).doc(e.key), e.value);
      }
      await batch.commit();
    }
    return entries.length;
  }

  /// Deletes every document whose id starts with `dummy_`. Returns the count.
  Future<int> deleteSeeded() async {
    final snap = await _db
        .collection(_collection)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: _idPrefix)
        .where(FieldPath.documentId, isLessThan: '$_idPrefix\uf8ff')
        .get();

    for (var i = 0; i < snap.docs.length; i += 400) {
      final batch = _db.batch();
      for (final doc in snap.docs.skip(i).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    return snap.docs.length;
  }

  // ------------------------------------------------------------------- data

  List<MapEntry<String, Map<String, dynamic>>> _build(DateTime now) {
    final rows = <Map<String, dynamic>>[];

    void add(
      _Conn conn,
      int daysAgo, {
      _Pkg? pkg,
      double? amount,
      int hour = 18,
      int minute = 0,
      bool cancel = false,
      bool deleted = false,
    }) {
      rows.add(
        _doc(
          conn: conn,
          at: _at(now, daysAgo, hour, minute),
          pkg: pkg,
          amount: amount,
          isCancel: cancel,
          isDelete: deleted,
        ),
      );
    }

    // A fixed seed keeps the pattern the same on every run.
    final random = Random(42);

    // 1) "My mob": buys the 1-day 1GB pack on most days. A 10GB or 20GB pack
    //    would be far cheaper, so the AI should find a big saving here.
    for (final d in [88, 74]) {
      add(_myMob, d, pkg: _gb10, hour: 12);
    }
    for (var d = 60; d >= 0; d--) {
      if (d > 0 && random.nextDouble() < 0.35) continue; // skips ~1 day in 3
      add(
        _myMob,
        d,
        pkg: _gb1Daily,
        hour: 17 + random.nextInt(5),
        minute: random.nextInt(60),
      );
    }
    add(_myMob, 41, amount: 200, hour: 10); // amount reloads (no package)
    add(_myMob, 27, amount: 300, hour: 10);
    add(_myMob, 9, amount: 150, hour: 10);

    // 2) "My Phone": 14-day 10GB pack renewed every ~17 days, so about 3 days
    //    a cycle without a package. A 30-day pack would fix that.
    for (final d in [80, 63, 46, 29, 12]) {
      add(_myPhone, d, pkg: _gb10, hour: 9 + (d % 5));
    }
    add(_myPhone, 40, pkg: _voice500, hour: 11);
    add(_myPhone, 20, amount: 150, hour: 15);

    // 3) "My Wifi": the same 30-day broadband pack every ~31 days. Already a
    //    sensible habit, so the AI should be unsure there is a better plan.
    for (final d in [88, 57, 26]) {
      add(_myWifi, d, pkg: _wifi50, hour: 20);
    }

    // 4) Utility and TV connections: amount reloads only (no package).
    add(_homeWater, 91, amount: 1275, hour: 14);
    add(_homeWater, 61, amount: 1180, hour: 14);
    add(_homeWater, 31, amount: 1350, hour: 14);
    add(_homeWater, 1, amount: 1000, hour: 19, minute: 35); // like your sample

    add(_homeElectricity, 93, amount: 3850, hour: 16);
    add(_homeElectricity, 63, amount: 4120, hour: 16);
    add(_homeElectricity, 33, amount: 5200, hour: 16);
    add(_homeElectricity, 3, amount: 4675, hour: 16);

    add(_dtv, 76, amount: 1800, hour: 13);
    add(_dtv, 46, amount: 1500, hour: 13);
    add(_dtv, 16, amount: 1500, hour: 13);

    // 5) Cancelled / deleted requests. Reports and AI must ignore these:
    //    if Sales includes Rs. 99, 3,990 or 9,999 too much, a filter is missing.
    add(_myMob, 5, pkg: _gb1Daily, hour: 19, minute: 10, cancel: true);
    add(_myWifi, 15, pkg: _wifiUnlimited, hour: 21, cancel: true);
    add(_homeElectricity, 10, amount: 9999, hour: 11, deleted: true);

    return [
      for (var i = 0; i < rows.length; i++)
        MapEntry('$_idPrefix${(i + 1).toString().padLeft(3, '0')}', rows[i]),
    ];
  }

  /// A moment [daysAgo] days back at [hour]:[minute], never in the future.
  DateTime _at(DateTime now, int daysAgo, int hour, int minute) {
    final t = DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
    return t.isAfter(now) ? now.subtract(const Duration(minutes: 5)) : t;
  }

  Map<String, dynamic> _doc({
    required _Conn conn,
    required DateTime at,
    _Pkg? pkg,
    double? amount,
    required bool isCancel,
    required bool isDelete,
  }) {
    return {
      // Activated the moment it is requested, like your sample document.
      'activatedDate': Timestamp.fromDate(at),
      'amount': (amount ?? pkg!.price).toDouble(),
      'clientVendorId': conn.clientVendorId,
      'connectionId': conn.id,
      'expireDate':
          pkg == null ? null : Timestamp.fromDate(at.add(Duration(days: pkg.days))),
      'isCancel': isCancel,
      'isDelete': isDelete,
      'isPaid': false,
      'packageDetailsId': pkg?.id,
      'paidDate': null,
      'paymentId': null,
      'requestDate': Timestamp.fromDate(at),
      'vendorId': _vendorId,
    };
  }
}

class _Conn {
  final String id;
  final String clientVendorId;
  const _Conn(this.id, this.clientVendorId);
}

class _Pkg {
  final String id;
  final double price;
  final int days;
  const _Pkg(this.id, this.price, this.days);
}
