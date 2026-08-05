import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login({required String phoneNumber, required String password});
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  });

  Future<void> reauthenticate(String password);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Stream<UserEntity?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  static const _collection = 'users';

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

  @override
  Future<UserEntity> login({required String phoneNumber, required String password}) async {
    try {
      final lookup = await firestore.collection('phone_lookup').doc(phoneNumber).get();

      if (!lookup.exists) {
        throw ServerException('Phone number not found');
      }

      final email = lookup['email'];

      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await firestore.collection(_collection).doc(credential.user!.uid).get();

      String? token = await HelperFunctions.getFCMToken();

      await FirebaseFirestore.instance.collection(_collection).doc(credential.user!.uid).update({"token":token});

      return UserEntity.fromJson(doc.data()!);
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final existing = await firestore.collection('phone_lookup').where('email', isEqualTo: email).get();

      if (existing.docs.isEmpty) {
        throw ServerException('Email not found');
      }
      await firebaseAuth.sendPasswordResetEmail(email: email);

    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    }
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  }) async {
    try {
      final existing = await firestore.collection('phone_lookup').doc(phoneNumber).get();

      if (existing.exists) {
        throw ServerException('This phone number is already registered.');
      }

      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await HelperFunctions.getFCMToken();

      final user = UserEntity(
        uid: credential.user!.uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        nic: nic,
        role: 'client',
        token: token,
      );

      await firestore.collection(_collection).doc(user.uid).set(user.toJson());
      await firestore.collection('phone_lookup').doc(phoneNumber).set({'email': email});

      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw ServerException('No authenticated user found.');
      }
      final credential = fb.EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseError(e)); // 'wrong-password' already mapped
    }
  }

  @override
  Future<void> logout() async => firebaseAuth.signOut();

  // @override
  // Stream<UserEntity?> get authStateChanges {
  //   return firebaseAuth.authStateChanges().asyncMap((fbUser) async {
  //     if (fbUser == null) return null;
  //     final doc = await firestore.collection(_collection).doc(fbUser.uid).get();
  //     if (!doc.exists) return null; // profile missing/deleted — treat as logged out
  //     return UserEntity.fromJson(doc.data()!);
  //   });
  // }

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) return Stream.value(null);

      // Switch to a real-time Firestore listener on the user's doc.
      // This fires immediately with current data, then again on ANY
      // field change (fullName, nic, phone, etc.).

      return firestore
          .collection(_collection)
          .doc(fbUser.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserEntity.fromJson(doc.data()!) : null);
    });
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-not-found':
        return 'No account found.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}