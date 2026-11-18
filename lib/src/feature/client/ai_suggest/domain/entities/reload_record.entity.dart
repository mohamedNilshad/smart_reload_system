import 'package:equatable/equatable.dart';

/// One past reload on a connection: a package, or a plain amount top-up
/// (no package).
class ReloadRecordEntity extends Equatable {
  final DateTime requestDate;
  final double amount;
  final String? packageId;
  final String? packageName;
  final String? packageType;

  /// Null for amount reloads or when the package validity can't be read.
  final double? validityDays;
  final DateTime? activatedDate;
  final DateTime? expireDate;

  const ReloadRecordEntity({
    required this.requestDate,
    required this.amount,
    this.packageId,
    this.packageName,
    this.packageType,
    this.validityDays,
    this.activatedDate,
    this.expireDate,
  });

  bool get isPackage => packageId != null;

  @override
  List<Object?> get props => [
        requestDate,
        amount,
        packageId,
        packageName,
        packageType,
        validityDays,
        activatedDate,
        expireDate,
      ];
}
