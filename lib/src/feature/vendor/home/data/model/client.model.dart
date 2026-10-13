import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ClientModel extends Equatable {
  final String clientVendorId;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final int connectionCount;
  final DateTime? lastPaidDate;
  final double? lastPaidAmount;
  final double? totalPayable;

  const ClientModel({
    required this.clientVendorId,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.connectionCount,
    this.lastPaidDate,
    this.lastPaidAmount,
    this.totalPayable,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ClientModel(
      clientVendorId: id ?? "",
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      clientEmail: json['clientEmail'] as String,
      clientPhone: json['clientPhone'] as String,
      connectionCount: json['connectionCount'] as int,
      lastPaidDate: (json['lastPaidDate'] as Timestamp?)?.toDate(),
      lastPaidAmount: json['lastPaidAmount'] as double?,
      totalPayable: json['totalPayable'] as double?,
    );
  }

  factory ClientModel.fromJsonEnc(Map<String, dynamic> json, {String? id}) {
    return ClientModel(
      clientVendorId: id ?? "",
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      clientEmail: json['clientEmail'] as String,
      clientPhone: json['clientPhone'] as String,
      connectionCount: json['connectionCount'] as int,
      lastPaidDate: DateTime.parse(json['lastPaidDate']),
      lastPaidAmount: json['lastPaidAmount'] as double?,
      totalPayable: json['totalPayable'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'connectionCount': connectionCount,
      'lastPaidDate': lastPaidDate,
      'lastPaidAmount': lastPaidAmount,
      'totalPayable': totalPayable,
    };
  }

  Map<String, dynamic> toJsonEnc() {
    return {
      'clientVendorId': clientVendorId,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'connectionCount': connectionCount,
      'lastPaidDate': lastPaidDate?.toIso8601String(),
      'lastPaidAmount': lastPaidAmount,
      'totalPayable': totalPayable,
    };
  }

  @override
  List<Object?> get props => [clientVendorId, clientId, clientName, clientEmail, clientPhone, connectionCount, lastPaidDate, lastPaidAmount, totalPayable];
}
