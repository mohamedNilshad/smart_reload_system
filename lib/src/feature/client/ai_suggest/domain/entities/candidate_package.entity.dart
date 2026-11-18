import 'package:equatable/equatable.dart';

/// A package the customer could switch to.
class CandidatePackageEntity extends Equatable {
  final String id;
  final String name;
  final String serviceProvider;
  final String packageType;
  final String description;
  final double price;

  /// Always > 0 (packages without a readable validity are dropped).
  final double validityDays;

  const CandidatePackageEntity({
    required this.id,
    required this.name,
    required this.serviceProvider,
    required this.packageType,
    required this.description,
    required this.price,
    required this.validityDays,
  });

  double get costPerDay => price / validityDays;

  @override
  List<Object?> get props =>
      [id, name, serviceProvider, packageType, description, price, validityDays];
}
