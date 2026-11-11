import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';

class PackageRequestModel extends Equatable {
  final String? id;
  final String? clientVendorId;
  final String? connectionId;
  final ConnectionModel? connectionModel;
  final String? packageDetailsId;
  final PackageModel? packageModel;
  final DateTime? requestDate;
  final double? amount;
  final DateTime? activatedDate;
  final DateTime? expireDate;
  final bool? isPaid;
  final DateTime? paidDate;
  final String? paymentId;
  final String? vendorId;

  const PackageRequestModel({
    this.id,
    this.clientVendorId,
    this.connectionId,
    this.requestDate,
    this.packageDetailsId,
    this.packageModel,
    this.connectionModel,
    this.amount,
    this.isPaid,
    this.activatedDate,
    this.expireDate,
    this.paidDate,
    this.paymentId,
    this.vendorId,
  });

  factory PackageRequestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PackageRequestModel(
      id: id,
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionId: json['connectionId'] as String? ?? '',
      packageDetailsId: json['packageDetailsId'] as String? ?? '',
      packageModel: json['packageModel'] as PackageModel?,
      connectionModel: json['connectionModel'] as ConnectionModel?,
      amount: json['amount'] as double?,
      requestDate: (json['requestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: json['isPaid'] as bool? ?? false,
      activatedDate: (json['activatedDate'] as Timestamp?)?.toDate(),
      expireDate: (json['expireDate'] as Timestamp?)?.toDate(),
      paidDate: (json['paidDate'] as Timestamp?)?.toDate(),
      paymentId: (json['paymentId'] as String?),
      vendorId: (json['vendorId'] as String?),
    );
  }

  factory PackageRequestModel.fromJsonEnc(Map<String, dynamic> json, {String? id}) {
    return PackageRequestModel(
      id: id,
      clientVendorId: json['clientVendorId'] as String? ?? '',
      connectionId: json['connectionId'] as String? ?? '',
      packageDetailsId: json['packageDetailsId'] as String? ?? '',
      packageModel: json['packageModel'] == null ? null : PackageModel.fromJson(json['packageModel']),
      connectionModel: ConnectionModel.fromJson(json['connectionModel']),
      amount: json['amount'] as double?,
      requestDate: DateTime.parse(json['requestDate']),
      isPaid: json['isPaid'] as bool? ?? false,
      activatedDate: json['activatedDate'] == null ? null : DateTime.parse(json['activatedDate']),
      expireDate: json['expireDate'] == null ? null : DateTime.parse(json['expireDate']),
      paidDate: json['paidDate'] == null ? null : DateTime.parse(json['paidDate']),
      paymentId: (json['paymentId'] as String?),
      vendorId: (json['vendorId'] as String?),
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
      vendorId: vendorId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientVendorId': clientVendorId,
      'connectionId': connectionId,
      'packageDetailsId': packageDetailsId,
      'amount': amount,
      'requestDate': requestDate != null ? Timestamp.fromDate(requestDate!) : null,
      'isPaid': isPaid,
      'activatedDate': (activatedDate != null) ? Timestamp.fromDate(activatedDate!) : null,
      'expireDate': (expireDate != null) ? Timestamp.fromDate(expireDate!) : null,
      'paidDate': (paidDate != null) ? Timestamp.fromDate(paidDate!) : null,
      'paymentId': paymentId,
      'vendorId': vendorId,
    };
  }

  Map<String, dynamic> toJsonEnc() {
    return {
      'id': id,
      'clientVendorId': clientVendorId,
      'connectionId': connectionId,
      'packageDetailsId': packageDetailsId,
      'amount': amount,
      'requestDate': requestDate?.toIso8601String(),
      'isPaid': isPaid,
      'activatedDate': (activatedDate != null) ? (activatedDate!).toIso8601String() : null,
      'expireDate': (expireDate != null) ? (expireDate!).toIso8601String() : null,
      'paidDate': (paidDate != null) ? (paidDate!).toIso8601String() : null,
      'paymentId': paymentId,
      'connectionModel': connectionModel?.toJsonEnc(),
      'packageModel': packageModel?.toJsonEnc(),
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
