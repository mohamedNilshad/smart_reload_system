import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateProfile({required String userId, required bool isEmailChanged, required String fullName, required String phoneNumber, required String email, required String nic});
  Future<void> updatePassword({required String password});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth});

  @override
  Future<void> updateProfile({required String userId, required bool isEmailChanged, required String fullName, required String phoneNumber, required String email, required String nic}) async {
    try {

      await firestore.collection('users').doc(userId).update({
        'fullName': fullName,
        // 'phoneNumber': phoneNumber,
        // 'email': email,
        'nic': nic,
      });

    } on FirebaseException catch (e) {
      throw ServerException('Firebase error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {

      final user = firebaseAuth.currentUser;
      final userId = user?.uid;
      if (userId == null) throw ServerException('User not authenticated');
      await user?.updatePassword(password);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }
}
