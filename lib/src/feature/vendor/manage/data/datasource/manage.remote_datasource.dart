import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/services/encryption.service.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/model/bank_details.vendor.model.dart';

abstract class ManageRemoteDataSource {
  Future<List<BankDetailsModel>> getVendorBankInfo();
  Future<BankDetailsModel> addNewBankInfo({required BankDetailsModel bankDetails});
  Future<bool> removeBankInfo({required String bankDetailsId});
}

class ManageRemoteDataSourceImpl implements ManageRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ManageRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth});

  @override
  Future<List<BankDetailsModel>> getVendorBankInfo() async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final snapshot = await firestore
          .collection('vendor_bank_info')
          .where('vendorId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final bankInfoList = <BankDetailsModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final encBankData = await EncryptionService().decryptData(data['data']);
        final bankData = BankDetailsModel.fromJson(encBankData, id: doc.id);
        bankInfoList.add(bankData);
      }

      return bankInfoList;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.getVendorBankInfo',
        stackTrace: st,
      );
      throw ServerException('Failed to fetch vendor bank info');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.getVendorBankInfo',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to load vendor bank info');
    }
  }

  @override
  Future<BankDetailsModel> addNewBankInfo({required BankDetailsModel bankDetails}) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }
      final encryptionService = EncryptionService();
      final data = await encryptionService.encryptData(bankDetails.toJson());

      final docRef = await firestore.collection('vendor_bank_info').add(
        {
          "vendorId": userId,
          "data" : data,
          "updatedAt": FieldValue.serverTimestamp(),
          "isDeleted": false,
        }
      );
      return bankDetails.copyWith(id: docRef.id);
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.addNewBankInfo',
        stackTrace: st,
      );
      throw ServerException('Failed to create bank info');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.addNewBankInfo',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to create bank info');
    }
  }

  @override
  Future<bool> removeBankInfo({required String bankDetailsId}) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      await firestore.collection('vendor_bank_info').doc(bankDetailsId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.removeBankInfo',
        stackTrace: st,
      );
      throw ServerException('Failed to remove bank info');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'ManageRemoteDataSourceImpl.removeBankInfo',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to remove bank info');
    }
  }
}
