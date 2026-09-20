import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
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
          .where('activatedDate', isNull: false)
          .get();

      final List<PackageRequestModel> packages = [];
      final Map<String, PackageModel> packageCache = {};
      final Map<String, ConnectionModel> connectionCache = {};

      for (final doc in payableSnapshot.docs) {
        final data = doc.data();

        final packageDetailsId = data['packageDetailsId'];
        final connectionId = data['connectionId'];

        ///fetch package details
        if (packageDetailsId != null) {
          PackageModel? packageDetails = packageCache[packageDetailsId];

          if (packageDetails == null) {
            final packageSnapshot = await firestore
                .collection('package_details')
                .doc(packageDetailsId)
                .get();

            if (packageSnapshot.exists && packageSnapshot.data() != null) {
              packageDetails = PackageModel.fromJson(
                packageSnapshot.data()!,
                id: packageSnapshot.id,
              );

              packageCache[packageDetailsId] = packageDetails;
            }
          }

          data['packageModel'] = packageDetails;
        }

        ///fetch connection details
        if (connectionId != null) {
          ConnectionModel? connectionDetails = connectionCache[connectionId];

          if (connectionDetails == null) {
            final connectionSnapshot = await firestore
                .collection('connections')
                .doc(connectionId)
                .get();

            if (connectionSnapshot.exists && connectionSnapshot.data() != null) {
              connectionDetails = ConnectionModel.fromJson(
                connectionSnapshot.data()!,
                id: connectionSnapshot.id,
              );

              connectionCache[connectionId] = connectionDetails;
            }
          }

          data['connectionModel'] = connectionDetails;
        }

        packages.add(
          PackageRequestModel.fromJson(
            data,
            id: doc.id,
          ),
        );
      }

      return packages;

    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch payables details');
    } catch (e) {
      throw ServerException('An error occurred while fetching payables details');
    }
  }
}
