import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PackageRequestModel extends Equatable {
  final String clientVendorId;
  final String connectionId;
  final String? packageDetailsId;
  final DateTime requestDate;
  final double? amount;

  final DateTime? activatedDate;
  final DateTime? expireDate;
  final bool? isPaid;
  final DateTime? paidDate;
  final String? paymentId;

  const PackageRequestModel({
    required this.clientVendorId,
    required this.connectionId,
    required this.requestDate,
    this.packageDetailsId,
    this.amount,

    this.isPaid,
    this.activatedDate,
    this.expireDate,
    this.paidDate,
    this.paymentId,
  });

  factory PackageRequestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PackageRequestModel(
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionId: json['connectionId'] as String? ?? '',
      packageDetailsId: json['packageDetailsId'] as String? ?? '',
      amount: json['amount'] as double?,
      requestDate: (json['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: json['isPaid'] as bool? ?? false,
      activatedDate: (json['activatedDate'] as Timestamp?)?.toDate(),
      expireDate: (json['expireDate'] as Timestamp?)?.toDate(),
      paidDate: (json['paidDate'] as Timestamp?)?.toDate(),
      paymentId: (json['paymentId'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'connectionId': connectionId,
      'packageDetailsId': packageDetailsId,
      'amount': amount,
      'requestDate': Timestamp.fromDate(requestDate),
      'isPaid': isPaid,
      'activatedDate': (activatedDate != null) ? Timestamp.fromDate(activatedDate!) : null,
      'expireDate': (expireDate != null) ? Timestamp.fromDate(expireDate!) : null,
      'paidDate': (paidDate != null) ? Timestamp.fromDate(paidDate!) : null,
      'paymentId': paymentId,
    };
  }

  @override
  List<Object?> get props => [
    clientVendorId,
    connectionId,
    packageDetailsId,
    amount,
    requestDate,
    isPaid,
    activatedDate,
    expireDate,
    paidDate,
    paymentId,
  ];
}
