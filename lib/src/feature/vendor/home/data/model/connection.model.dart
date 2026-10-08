import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionModel extends Equatable {
  final String? id;
  final String clientVendorId;
  final String connectionName;
  final String connectionNumber;
  final DateTime? lastReloadDate;
  final String? billingType;
  final String? serviceProvider;
  final String connectionCategory;
  final String connectionType;
  final bool status;
  final bool isActive;

  const ConnectionModel({
    this.id,
    required this.clientVendorId,
    required this.connectionName,
    required this.connectionNumber,
    this.lastReloadDate,
    this.billingType,
    this.serviceProvider,
    required this.connectionCategory,
    required this.connectionType,
    this.status = false,
    this.isActive = true,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ConnectionModel(
      id: id ?? '',
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionCategory: json['connectionCategory'] as String? ?? '',
      connectionType: json['connectionType'] as String? ?? '',
      connectionName: json['connectionName'] as String? ?? '',
      connectionNumber: json['connectionNumber'] as String? ?? '',
      lastReloadDate: (json['lastReloadDate'] as Timestamp?)?.toDate(),
      billingType: json['billingType'] as String?,
      serviceProvider: json['serviceProvider'] as String?,
      status: json['status'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'connectionCategory': connectionCategory,
      'connectionType': connectionType,
      'connectionName': connectionName,
      'connectionNumber': connectionNumber,
      'lastReloadDate': lastReloadDate,
      'billingType': billingType,
      'serviceProvider': serviceProvider,
      'status': status,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toJsonEnc() {
    return {
      'id': id,
      'clientVendorId': clientVendorId,
      'connectionCategory': connectionCategory,
      'connectionType': connectionType,
      'connectionName': connectionName,
      'connectionNumber': connectionNumber,
      'lastReloadDate': lastReloadDate?.toIso8601String(),
      'billingType': billingType,
      'serviceProvider': serviceProvider,
      'status': status,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    clientVendorId,
    connectionCategory,
    connectionType,
    connectionName,
    connectionNumber,
    lastReloadDate,
    billingType,
    serviceProvider,
    status,
    isActive,
  ];
}
