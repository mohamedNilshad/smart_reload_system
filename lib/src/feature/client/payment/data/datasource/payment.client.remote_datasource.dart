import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';

abstract class PaymentClientRemoteDataSource {
  Future<PaymentEntity> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  });
  Future<List<PackageRequestModel>> fetchPayables({required String clientVendorId});
}

class PaymentClientRemoteDataSourceImpl implements PaymentClientRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PaymentClientRemoteDataSourceImpl({
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

  @override
  Future<List<PackageRequestModel>> fetchPayables({required String clientVendorId}) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final payableSnapshot = await firestore
          .collection('requested_packages')
          .where('clientVendorId', isEqualTo: clientVendorId)
          .where('paymentId', isNull: true)
          .get();

      return payableSnapshot.docs.map((doc) => PackageRequestModel.fromJson(doc.data(), id: doc.id)).toList();

    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch payables details');
    } catch (e) {
      throw ServerException('An error occurred while fetching payables details');
    }
  }
}
