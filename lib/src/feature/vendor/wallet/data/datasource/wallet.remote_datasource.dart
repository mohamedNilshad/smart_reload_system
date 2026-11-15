import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/commission_withdrew_history.entity.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

abstract class WalletRemoteDataSource {
  Future<double> getWalletSummary();
  Future<List<ComWithdrawHistoryEntity>> getHistory();
  Future<bool> addWithdrawal({
    required double withdrewAmount,
    required double totalAmount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  WalletRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<double> getWalletSummary() async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final commissionSnapshot = await firestore
          .collection('commission')
          .where('vendorId', isEqualTo: userId)
          .limit(1)
          .get();

      double totalCommission = 0.0;
      if (commissionSnapshot.docs.isNotEmpty) {
        final commissionData = commissionSnapshot.docs.first.data();
        totalCommission = (commissionData['comAmount'] as num?)?.toDouble() ?? 0.0;
      }

      // totalCommission
      return totalCommission;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.getWalletSummary',
        stackTrace: st,
      );
      throw ServerException('Failed to fetch wallet summary');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.getWalletSummary',
        stackTrace: st,
      );
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Unable to load wallet summary');
    }
  }


  @override
  Future<List<ComWithdrawHistoryEntity>> getHistory() async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final snapshot = await firestore
          .collection('commission_withdrew_history')
          .where('vendorId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();


      return snapshot.docs.map((doc) => ComWithdrawHistoryEntity.fromFirestore (doc)).toList();
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.getHistory',
        stackTrace: st,
      );
      throw ServerException('Failed to fetch withdrawal history');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.getHistory',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to load withdrawal history');
    }
  }

  @override
  Future<bool> addWithdrawal({
    required double withdrewAmount,
    required double totalAmount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      await firestore.collection('commission_withdrew_history').add({
        'vendorId': userId,
        'withdrewAmount': withdrewAmount,
        'totalAmount': totalAmount,
        'date': Timestamp.fromDate(DateTime.now()),
        'bankName': bankName,
        'accountHolder': accountHolder,
        'accountNumber': accountNumber,
        'status': 'pending',
      });

      final query = await firestore
          .collection('commission')
          .where('vendorId', isEqualTo: userId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.update({
          'comAmount': 0.0,
          'modifyDate': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.addWithdrawal',
        stackTrace: st,
      );
      throw ServerException('Failed to add withdrawal record');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'WalletRemoteDataSourceImpl.addWithdrawal',
        stackTrace: st,
      );
      if (e is ServerException) rethrow;
      throw ServerException('Unable to submit withdrawal');
    }
  }
}
