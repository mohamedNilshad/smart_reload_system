import 'package:equatable/equatable.dart';

/// One package request joined with its connection and package, flattened to
/// what the reports need.
class ReportRowEntity extends Equatable {
  final String id;
  final String connectionId;
  final String connectionName;
  final String connectionNumber;
  final String serviceProvider;
  final String packageName;
  final DateTime requestDate;

  /// The request's own amount, falling back to the package price.
  final double amount;
  final bool isPaid;
  final DateTime? expireDate;

  const ReportRowEntity({
    required this.id,
    required this.connectionId,
    required this.connectionName,
    required this.connectionNumber,
    required this.serviceProvider,
    required this.packageName,
    required this.requestDate,
    required this.amount,
    required this.isPaid,
    this.expireDate,
  });

  @override
  List<Object?> get props => [
        id,
        connectionId,
        connectionName,
        connectionNumber,
        serviceProvider,
        packageName,
        requestDate,
        amount,
        isPaid,
        expireDate,
      ];
}
