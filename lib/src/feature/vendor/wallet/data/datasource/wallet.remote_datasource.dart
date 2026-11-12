import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/wallet_summary.entity.dart';

abstract class WalletRemoteDataSource {
  Future<WalletSummaryEntity> getWalletSummary();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  WalletRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<WalletSummaryEntity> getWalletSummary() async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final vendorClientsSnapshot = await firestore
          .collection('client_vendor')
          .where('vendorId', isEqualTo: userId)
          .get();

      double totalBalance = 0.0;
      int activeClients = 0;
      double totalPaid = 0.0;

      for (final doc in vendorClientsSnapshot.docs) {
        final data = doc.data();
        final payable = (data['totalPayable'] as num?)?.toDouble() ?? 0.0;
        final lastPaid = (data['lastPaidAmount'] as num?)?.toDouble() ?? 0.0;
        totalBalance += payable;
        totalPaid += lastPaid;
        if ((data['connectionCount'] as int? ?? 0) > 0) {
          activeClients++;
        }
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

      final paidInvoicesSnapshot = await firestore
          .collection('payment_details')
          .where('clientVendorId', isEqualTo: userId)
          .get();

      final paidInvoices = paidInvoicesSnapshot.docs.length;
      // totalCommission
      return WalletSummaryEntity(
        vendorId: userId,
        currentBalance: totalBalance,
        totalPaid: totalPaid,
        totalCommission: totalCommission,
        activeClients: activeClients,
        paidInvoices: paidInvoices,
      );
    } on FirebaseException catch (_) {
      throw ServerException('Failed to fetch wallet summary');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Unable to load wallet summary');
    }
  }
}
