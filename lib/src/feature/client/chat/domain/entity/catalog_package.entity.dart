import 'package:equatable/equatable.dart';

/// A package from the shared catalog. This is public shop data only, so it is
/// safe to give to the AI model; no client information is ever included.
class CatalogPackageEntity extends Equatable {
  final String provider;
  final String telecomType;
  final String packageType;
  final String name;
  final String description;
  final double price;
  final double validity;
  final String validityUnit;

  const CatalogPackageEntity({
    required this.provider,
    required this.telecomType,
    required this.packageType,
    required this.name,
    required this.description,
    required this.price,
    required this.validity,
    required this.validityUnit,
  });

  @override
  List<Object?> get props => [
        provider,
        telecomType,
        packageType,
        name,
        description,
        price,
        validity,
        validityUnit,
      ];
}
