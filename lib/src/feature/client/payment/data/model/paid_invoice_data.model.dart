import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';

class PaidInvoiceDataModel extends Equatable {
  final String? id;
  final String clientVendorId;
  final double paidAmount;
  final InvoicePdfData invoiceData;
  final DateTime invoiceDate;

  const PaidInvoiceDataModel({
    this.id,
    required this.clientVendorId,
    required this.paidAmount,
    required this.invoiceData,
    required this.invoiceDate,
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'clientVendorId': clientVendorId,
  //     'paidAmount': paidAmount,
  //     'invoiceData': invoiceData.toJson(),
  //     'invoiceDate': invoiceDate.toIso8601String(),
  //   };
  // }

  factory PaidInvoiceDataModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PaidInvoiceDataModel(
      id: id,
      invoiceData: json['invoiceData'] as InvoicePdfData,
      clientVendorId: json['clientVendorId'] as String? ?? '',
      paidAmount: json['paidAmount'] as double? ?? 0.0,
      invoiceDate: (json['invoiceDate'] as Timestamp?)!.toDate(),
      // invoiceDate: DateTime.parse(json['invoiceDate']),
    );
  }



  @override
  List<Object?> get props => [
    clientVendorId,
    paidAmount,
    invoiceData,
    invoiceDate,
  ];
}