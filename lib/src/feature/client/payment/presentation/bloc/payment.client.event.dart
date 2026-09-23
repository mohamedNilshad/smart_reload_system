import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';

abstract class PaymentClientEvent extends Equatable {
  const PaymentClientEvent();

  @override
  List<Object?> get props => [];
}

class FetchPayableDetails extends PaymentClientEvent {
  final String clientVendorId;
  const FetchPayableDetails({required this.clientVendorId});

  @override
  List<Object?> get props => [clientVendorId];
}

class CreatePayment extends PaymentClientEvent {
  final String clientVendorId;
  final double lastPaidAmount;
  final DateTime lastPaidDate;
  final List<String> reqPackageIdList;
  final String vendorId;
  final double vendorComAmount;
  final String paymentRefNumber;
  final InvoicePdfData invoiceData;

  const CreatePayment({
    required this.clientVendorId,
    required this.lastPaidAmount,
    required this.lastPaidDate,
    required this.reqPackageIdList,
    required this.vendorId,
    required this.vendorComAmount,
    required this.paymentRefNumber,
    required this.invoiceData,
  });

  @override
  List<Object?> get props => [clientVendorId, lastPaidAmount, lastPaidDate, reqPackageIdList, vendorId, vendorComAmount, paymentRefNumber, invoiceData];
}

class PaymentReset extends PaymentClientEvent {
  const PaymentReset();
}
