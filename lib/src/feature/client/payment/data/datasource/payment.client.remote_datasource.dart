import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/services/encryption.service.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/model/paid_invoice_data.model.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

abstract class PaymentClientRemoteDataSource {
  Future<bool> createPayment({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required InvoicePdfData invoiceData,
  });
  Future<Map<String, dynamic>> fetchPayables({required String clientVendorId});
  Future<List<PaidInvoiceDataModel>> fetchPaidInvoices({required String clientVendorId});
}

class PaymentClientRemoteDataSourceImpl implements PaymentClientRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  PaymentClientRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<bool> createPayment({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required InvoicePdfData invoiceData,
  }) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      ///client_vendor update
      await firestore.collection('client_vendor').doc(clientVendorId).update({
        'currentPaymentBalance': 0.0,//value can change in vendor side
        'lastPaidAmount': lastPaidAmount,
        'lastPaidDate': Timestamp.fromDate(lastPaidDate)
      });

      ///commission update
      final comSnapshot = await firestore
          .collection('commission')
          .where('vendorId', isEqualTo: vendorId)
          .limit(1)
          .get();

      if (comSnapshot.docs.isNotEmpty) {
        // Existing vendor commission
        await comSnapshot.docs.first.reference.update({
          'comAmount': FieldValue.increment(vendorComAmount),
          'modifyDate': Timestamp.fromDate(lastPaidDate),
        });
      } else {
        // New vendor commission
        await firestore.collection('commission').add({
          'vendorId': vendorId,
          'comAmount': vendorComAmount,
          'modifyDate': Timestamp.fromDate(lastPaidDate),
        });
      }

      ///commission_history
      await firestore.collection('commission_history').add({
        'clientVendorId': clientVendorId,
        'comAmount': vendorComAmount,
        'date': Timestamp.fromDate(lastPaidDate),
        'totalAmount': lastPaidAmount
      });

      ///add invoice data
      final encryptionService = EncryptionService();
      final encryptedInvoice = await encryptionService.encryptData(
        invoiceData.toJson(),
      );

      final countSnapshot = await firestore.collection('invoice_data').count().get();

      final count = (countSnapshot.count ?? 0) + 1;
      final invoiceNo = "INV-${count.toString().padLeft(4, '0')}";

      final docInvoiceRef = await firestore.collection('invoice_data').add({
        'invoiceNo': invoiceNo,
        'clientVendorId': clientVendorId,
        'invoiceDate': Timestamp.fromDate(lastPaidDate),
        'paidAmount': lastPaidAmount,
        'data': encryptedInvoice,
      });


      String invoiceId= docInvoiceRef.id;
      ///payment_details
      final docPayRef = await firestore.collection('payment_details').add({
        'clientVendorId': clientVendorId,
        'paidDate': Timestamp.fromDate(lastPaidDate),
        'paidAmount': lastPaidAmount,
        'invoiceId': invoiceId,
        'paymentRefNumber': paymentRefNumber
      });

      final payDoc = await docPayRef.get();


      ///requested_packages
      final rPackageBatch = firestore.batch();

      for (var rId in reqPackageIdList) {
        final docRef = firestore
            .collection('requested_packages')
            .doc(rId);

        rPackageBatch.update(docRef, {
          'isPaid': true,
          'paymentId': payDoc.id,
          'paidDate': lastPaidDate
        });
      }

      await rPackageBatch.commit();

      return true;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.processPayment',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Firebase error occurred');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.processPayment',
        stackTrace: st,
      );
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> fetchPayables({required String clientVendorId}) async {
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

      final serviceChargeSnapshot = await firestore
          .collection('system_config')
          .doc("commissionPercentage")
          .get();
      String serviceChargeValue = "0+0";
      if (serviceChargeSnapshot.exists) {
        final serviceChargeData = serviceChargeSnapshot.data();
        if (serviceChargeData != null && serviceChargeData.containsKey('percentage')) {
          serviceChargeValue = serviceChargeData['percentage'];
        }
      }

      return {
        'packages': packages,
        'serviceCharge': serviceChargeValue,
      };

    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.fetchPayablesDetails',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch payables details');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.fetchPayablesDetails',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching payables details');
    }
  }


  @override
  Future<List<PaidInvoiceDataModel>> fetchPaidInvoices({required String clientVendorId}) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) {
        throw ServerException('User not authenticated');
      }

      final List<PaidInvoiceDataModel> paidInvoices = [];
      final List<String> clientVendorIdList = [];

      final clientVendorIdSnapshot = await firestore
          .collection('client_vendor')
          .where('clientId', isEqualTo: userId)
          .get();

      for (final doc in clientVendorIdSnapshot.docs) {
        clientVendorIdList.add(doc.id);
      }

      final paidInvoicesSnapshot = await firestore
          .collection('invoice_data')
          .where('clientVendorId', whereIn: clientVendorIdList)
          .orderBy('invoiceDate', descending: true)
          .get();


      for (final doc in paidInvoicesSnapshot.docs) {
        final data = doc.data();
        final encInvoiceData = await EncryptionService().decryptData(data['data']);

        data['invoiceData'] = InvoicePdfData.fromJson(encInvoiceData);
        final invoiceData = PaidInvoiceDataModel.fromJson(data, id: doc.id);
        paidInvoices.add(invoiceData);
      }

      return paidInvoices;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.fetchPaidInvoices',
        stackTrace: st,
      );

      throw ServerException(e.message ?? 'Failed to fetch paid invoices');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'PaymentClientRemoteDataSourceImpl.fetchPaidInvoices',
        stackTrace: st,
      );

      throw ServerException('An error occurred while fetching paid invoices');
    }
  }
}
