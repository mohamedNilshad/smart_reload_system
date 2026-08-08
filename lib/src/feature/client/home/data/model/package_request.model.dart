import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';

class PackageRequestModel extends Equatable {
  final String? id;
  final String clientVendorId;
  final String connectionId;
  final String? packageDetailsId;
  final PackageModel? packageModel;
  final DateTime requestDate;
  final double? amount;
  final DateTime? activatedDate;
  final DateTime? expireDate;
  final bool? isPaid;
  final DateTime? paidDate;
  final String? paymentId;

  const PackageRequestModel({
    this.id,
    required this.clientVendorId,
    required this.connectionId,
    required this.requestDate,
    this.packageDetailsId,
    this.packageModel,
    this.amount,
    this.isPaid,
    this.activatedDate,
    this.expireDate,
    this.paidDate,
    this.paymentId,
  });

  factory PackageRequestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PackageRequestModel(
      id: id,
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionId: json['connectionId'] as String? ?? '',
      packageDetailsId: json['packageDetailsId'] as String? ?? '',
      packageModel: json['packageModel'] as PackageModel?,
      amount: json['amount'] as double?,
      requestDate: (json['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: json['isPaid'] as bool? ?? false,
      activatedDate: (json['activatedDate'] as Timestamp?)?.toDate(),
      expireDate: (json['expireDate'] as Timestamp?)?.toDate(),
      paidDate: (json['paidDate'] as Timestamp?)?.toDate(),
      paymentId: (json['paymentId'] as String?),
    );
  }

  PackageRequestModel copyWith({PackageModel? newPackageModel}) {
    return PackageRequestModel(
      id: id,
      clientVendorId: clientVendorId,
      connectionId: connectionId,
      packageDetailsId: packageDetailsId,
      packageModel: newPackageModel ?? packageModel,
      amount: amount,
      requestDate: requestDate,
      isPaid: isPaid,
      activatedDate:activatedDate,
      expireDate: expireDate,
      paidDate: paidDate,
      paymentId: paymentId,
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
    id,
    clientVendorId,
    connectionId,
    packageDetailsId,
    packageModel,
    amount,
    requestDate,
    isPaid,
    activatedDate,
    expireDate,
    paidDate,
    paymentId,
  ];
}
