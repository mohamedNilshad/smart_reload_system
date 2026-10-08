import 'dart:async';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:smart_reload_system/src/core/constants/constant.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

abstract class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> startOneTimePayment({
    required String orderId,
    required double amount,
    required String itemDescription,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  // TODO: move these out of source and into --dart-define / a secrets file
  // that's gitignored — see security note below.
  static const _merchantId = merchantId;
  static const _merchantSecret = merchantSecret;
  static const _notifyUrl = 'https://your-backend.example.com/payhere/notify1fg';
  static const _isSandbox = true; // flip to false for production

  @override
  Future<Map<String, dynamic>> startOneTimePayment({
    required String orderId,
    required double amount,
    required String itemDescription,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
  }) async {
    final completer = Completer<String>();

    final paymentObject = {
      "sandbox": _isSandbox,
      "merchant_id": _merchantId,
      "merchant_secret": _merchantSecret,
      "notify_url": _notifyUrl,
      "order_id": orderId,
      "items": itemDescription,
      "amount": amount.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "country": "Sri Lanka",
    };

    try{
      PayHere.startPayment(
        paymentObject,
            (paymentId) {
          if (!completer.isCompleted) {
            completer.complete(paymentId);
          }
        },
            (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              ServerException(error),
            );
          }
        },
            () {
          if (!completer.isCompleted) {
            completer.completeError(
              ServerException('Payment was cancelled.'),
            );
          }
        },
      );

      final paymentId = await completer.future;
      return {
        'paymentId': paymentId,
        'paymentDate': DateTime.now().toIso8601String(),
      };
    }catch(e, st){
      ErrorLogger.log(
        e,
        location: 'PaymentRemoteDataSourceImpl.startOneTimePayment',
        stackTrace: st,
      );
      throw ServerException(e.toString());
    }
  }
}
