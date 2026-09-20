import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VendorModel extends Equatable {
  final String clientVendorId;
  final String vendorId;
  final String vendorName;
  final String vendorEmail;
  final String vendorPhone;
  final int connectionCount;
  final DateTime? lastPaidDate;
  final double? lastPaidAmount;
  final double? currentPaymentBalance;

  const VendorModel({
    required this.clientVendorId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorEmail,
    required this.vendorPhone,
    required this.connectionCount,
    this.lastPaidDate,
    this.lastPaidAmount,
    this.currentPaymentBalance,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return VendorModel(
      clientVendorId: id!,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      vendorEmail: json['vendorEmail'] as String,
      vendorPhone: json['vendorPhone'] as String,
      connectionCount: json['connectionCount'] as int,
      lastPaidDate: (json['lastPaidDate'] as Timestamp?)?.toDate(),
      lastPaidAmount: json['lastPaidAmount'] as double?,
      currentPaymentBalance: json['currentPaymentBalance'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorEmail': vendorEmail,
      'vendorPhone': vendorPhone,
      'connectionCount': connectionCount,
      'lastPaidDate': lastPaidDate,
      'lastPaidAmount': lastPaidAmount,
      'currentPaymentBalance': currentPaymentBalance,
    };
  }

  @override
  List<Object?> get props => [clientVendorId, vendorId, vendorName, vendorEmail, vendorPhone, connectionCount, lastPaidDate, lastPaidAmount, currentPaymentBalance];
}
