import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';

class InvoicePdfData extends Equatable {
  final VendorModel vendor;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final List<PackageRequestModel> requests;
  final String serviceCharge;
  final String currency;

  const InvoicePdfData({
    required this.vendor,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.requests,
    this.serviceCharge = "0+0",
    this.currency = 'Rs. ',
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor.toJsonEnc(),
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'requests': requests.map((e) => e.toJsonEnc()).toList(),
      'serviceCharge': serviceCharge,
      'currency': currency,
    };
  }

  /// Amount for one line: the request's own amount, else the package price.
  static double amountOf(PackageRequestModel r) =>
      r.amount ?? r.packageModel?.packagePrice ?? 0;

  double get subtotal => requests.fold<double>(0, (sum, r) => sum + amountOf(r));

  /// Subtotal + service charge + balance carried over from the last payment.
  double get total => subtotal + calCommission +  - (vendor.currentPaymentBalance ?? 0.0);

  double get calCommission => (subtotal/100 ) * getCommissionPercentage;

  double get getCommissionPercentage {
    final vCom = double.parse(serviceCharge.split("+")[0]);
    final aCom = double.parse(serviceCharge.split("+")[1]);
    return vCom+aCom;
  }

  @override
  List<Object?> get props => [
    vendor,
    clientName,
    clientPhone,
    clientEmail,
    requests,
    serviceCharge,
    vendor.lastPaidAmount,
    vendor.lastPaidDate,
    vendor.currentPaymentBalance,
    currency,
  ];
}