import 'package:equatable/equatable.dart';

/// The few connection fields the advisor needs. No name or phone number, so
/// nothing personal is ever sent to the AI model.
class ConnectionInfoEntity extends Equatable {
  final String id;
  final String serviceProvider;
  final String connectionCategory;
  final String connectionType;
  final String billingType;

  const ConnectionInfoEntity({
    required this.id,
    this.serviceProvider = '',
    this.connectionCategory = '',
    this.connectionType = '',
    this.billingType = '',
  });

  @override
  List<Object?> get props =>
      [id, serviceProvider, connectionCategory, connectionType, billingType];
}
