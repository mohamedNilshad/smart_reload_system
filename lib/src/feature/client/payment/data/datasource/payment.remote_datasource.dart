import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentEntity> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PaymentRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<PaymentEntity> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  }) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final docRef = await firestore.collection('payments').add({
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'status': 'pending',
        'paymentMethod': paymentMethod,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;

      return PaymentEntity(
        id: doc.id,
        userId: userId,
        amount: amount,
        currency: currency,
        status: data['status'] ?? 'pending',
        paymentMethod: paymentMethod,
        description: description,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: null,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
