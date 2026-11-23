import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/feature/client/chat/domain/entity/catalog_package.entity.dart';

const _packagesCollection = 'package_details';

/// The most packages given to the assistant. More just costs tokens.
const _maxPackages = 80;

/// Loads the shared package list for the assistant. The list is cached in
/// memory, so opening the assistant again doesn't read Firestore again.
class AssistantCatalogRemoteDataSource {
  AssistantCatalogRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _ttl = Duration(hours: 6);

  List<CatalogPackageEntity>? _cache;
  DateTime? _cachedAt;

  /// Never throws: if the list can't be loaded the assistant still works, it
  /// just can't quote package prices.
  Future<List<CatalogPackageEntity>> load() async {
    final cached = _cache;
    final at = _cachedAt;
    if (cached != null && at != null && DateTime.now().difference(at) < _ttl) {
      return cached;
    }

    try {
      final snap = await _db.collection(_packagesCollection).limit(_maxPackages).get();
      final out = <CatalogPackageEntity>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final price = _toDouble(d['packagePrice']);
        final validity = _toDouble(d['packageValidity']);
        final name = _text(d['packageName']);
        if (price == null || price <= 0 || validity == null || validity <= 0) continue;
        if (name.isEmpty) continue;

        out.add(
          CatalogPackageEntity(
            provider: _text(d['serviceProvider']),
            telecomType: _text(d['telecomType']),
            packageType: _text(d['packageType']),
            name: name,
            description: _text(d['packageDescription']),
            price: price,
            validity: validity,
            validityUnit: _text(d['validityPeriod']),
          ),
        );
      }
      _cache = out;
      _cachedAt = DateTime.now();
      return out;
    } on FirebaseException {
      return cached ?? const [];
    }
  }

  String _text(dynamic v) => v is String ? v.trim() : '';

  double? _toDouble(dynamic v) => v is num ? v.toDouble() : null;
}
