import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionModel extends Equatable {
  final String id;
  final String conNumber;
  final String conName;
  final String conType;
  final String? conPlan;
  final bool status;
  final DateTime lastDate;
  final String clientVendorId;

  const ConnectionModel({
    required this.id,
    required this.conNumber,
    required this.conName,
    required this.conType,
    this.conPlan,
    required this.status,
    required this.lastDate,
    required this.clientVendorId,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ConnectionModel(
      id: id ?? json['id'] as String? ?? '',
      conNumber: json['connectionNo'] as String? ?? '',
      conName: json['connectionName'] as String? ?? '',
      conType: json['type'] as String? ?? '',
      conPlan: json['plan'] as String?,
      status: json['status'] as bool? ?? false,
      lastDate: (json['lastReloadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientVendorId: json['clientVendorId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conNumber': conNumber,
      'conName': conName,
      'conType': conType,
      'conPlan': conPlan,
      'status': status,
      'lastDate': Timestamp.fromDate(lastDate),
      'clientVendorId': clientVendorId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        conNumber,
        conName,
        conType,
        conPlan,
        status,
        lastDate,
        clientVendorId,
      ];
}
