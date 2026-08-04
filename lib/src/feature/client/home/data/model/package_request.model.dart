import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PackageRequestModel extends Equatable {
  final String clientVendorId;
  final String connectionId;
  final String? packageDetailsId;
  final DateTime date;
  final double? amount;

  const PackageRequestModel({
    required this.clientVendorId,
    required this.connectionId,
    this.packageDetailsId,
    required this.date,
    this.amount,
  });

  factory PackageRequestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PackageRequestModel(
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionId: json['connectionId'] as String? ?? '',
      packageDetailsId: json['packageDetailsId'] as String? ?? '',
      amount: json['amount'] as double?,
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'connectionId': connectionId,
      'packageDetailsId': packageDetailsId,
      'amount': amount,
      'date': Timestamp.fromDate(date),

    };
  }

  @override
  List<Object?> get props => [
    clientVendorId,
    connectionId,
    packageDetailsId,
    amount,
    date,
  ];
}
