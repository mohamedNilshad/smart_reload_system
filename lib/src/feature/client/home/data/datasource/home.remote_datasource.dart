import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:flutter/foundation.dart';
import 'package:smart_reload_system/src/core/data/model/device_info.model.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/services/notification.service.dart';
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerNewsModel>> getBannerNews();
  Future<List<VendorModel>> getVendors();
  Future<List<ConnectionModel>> getConnections(String clientVendorId);
  Future<bool> requestPackage(PackageRequestModel packageRequestModel, String clientName);
  Future<bool> addNewConnection(ConnectionModel connectionModel);
  Future<List<PackageModel>> getPackages(String type, String serviceProvider);
  Future<List<PackageRequestModel>> getActivatedPackages(String connectionId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final db.FirebaseDatabase database;

  HomeRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.database,
  });

  @override
  Future<List<BannerNewsModel>> getBannerNews() async {
    try {
      final snapshot = await firestore
          .collection('banner_news')
          .where('status', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => BannerNewsModel.fromJson(doc.data(), id: doc.id))
          .toList();

    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getBannerNews',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch banner news');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getBannerNews',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching banner news');
    }
  }

  @override
  Future<List<VendorModel>> getVendors() async {
    try {
      User currentUser = _getCurrentUser();
      final clientId = currentUser.uid;

      // Step 1: Fetch vendorId and connectionCount from client_vendor collection
      final clientVendorSnapshot = await firestore
          .collection('client_vendor')
          .where('clientId', isEqualTo: clientId)
          .get();

      final vendors = <VendorModel>[];

      // Step 2: For each vendor, fetch vendorName from users collection
      for (final doc in clientVendorSnapshot.docs) {
        final data = doc.data();
        final vendorId = data['vendorId'] as String?;
        final connectionCount = data['connectionCount'] as int? ?? 0;

        if (vendorId != null) {
          try {
            final userDoc = await firestore.collection('users').doc(vendorId).get();
            if (userDoc.exists) {
              final vendorName = userDoc['fullName'] as String? ?? 'Unknown';
              final vendorEmail = userDoc['email'] as String? ?? '';
              final vendorPhone = userDoc['phoneNumber'] as String? ?? 'Unknown';
              final lastPaidDate = (data['lastPaidDate'] as Timestamp?)?.toDate();
              final lastPaidAmount = data['lastPaidAmount'] as double?;
              final currentPaymentBalance = data['currentPaymentBalance'] as double?;
              vendors.add(
                VendorModel(
                  clientVendorId: doc.id,
                  vendorId: vendorId,
                  vendorName: vendorName,
                  vendorEmail: vendorEmail,
                  vendorPhone: vendorPhone,
                  connectionCount: connectionCount,
                  currentPaymentBalance: (currentPaymentBalance == null) ? 0.0: -currentPaymentBalance,
                  lastPaidAmount: lastPaidAmount,
                  lastPaidDate: lastPaidDate,
                ),
              );
            }
          } catch (e) {
            // Skip this vendor if user data fetch fails
            continue;
          }
        }
      }

      return vendors;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getVendors',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch vendors');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getVendors',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching vendors');
    }
  }

  @override
  Future<List<ConnectionModel>> getConnections(String clientVendorId) async {
    try {
      final connectionSnapshot = await firestore
          .collection('connections')
          .where('clientVendorId', isEqualTo: clientVendorId)
          .get();


      return connectionSnapshot.docs.map((doc) => ConnectionModel.fromJson(doc.data(), id: doc.id)).toList();

    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getConnections',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch connections');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getConnections',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching connections');
    }
  }

  @override
  Future<bool> requestPackage(PackageRequestModel packageRequestModel, String clientName) async {
    try {

      // await firestore.collection("requested_packages").add(packageRequestModel.toJson());
      final docRef = await firestore.collection("requested_packages").add(packageRequestModel.toJson());
      final String documentId = docRef.id;


      await database.ref('package_requests/${packageRequestModel.vendorId}/$documentId').update({
        'clientVendorId': packageRequestModel.clientVendorId,
        'status': true,
        'onUpdate': DateTime.now().toIso8601String(),
      });

      ///send push notification

      final tokenSnapshot = await firestore
          .collection('device_info')
          .where('userId', isEqualTo: packageRequestModel.vendorId)
          .get();


      List<DeviceInfoModel> tokens = tokenSnapshot.docs.map((doc) => DeviceInfoModel.fromJson(doc.data())).toList();

      String? packageName = packageRequestModel.packageModel?.packageName;
      if(packageName == null){
        packageName = "";
      }else{
        packageName = "for $packageName.";
      }
      String amount = HelperFunctions.formatCurrency(packageRequestModel.amount);


      String notifyBody = "$clientName has requested a reload $packageName Amount: $amount.";
      debugPrint("Notify Body: $notifyBody");

      for(var item in tokens){
        await NotificationService.sendPushMessage(
          item.fcmToken,
          "New Reload Request",
          notifyBody,
        );
      }


      return true;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.requestPackage',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch connections');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.requestPackage',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching connections');
    }
  }

  @override
  Future<bool> addNewConnection(ConnectionModel connectionModel) async {
    try {

      await firestore.collection("connections").add(connectionModel.toJson());
      //send push notification
      return true;
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.addNewConnection',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to add connections');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.addNewConnection',
        stackTrace: st,
      );
      throw Exception('An error occurred while adding connections');
    }
  }

  @override
  Future<List<PackageModel>> getPackages(String type, String serviceProvider) async {
    try {

      final packageSnapshot = await firestore
          .collection('package_details')
          .where('telecomType', isEqualTo: type)
          .where('serviceProvider', isEqualTo: serviceProvider)
          .get();

      return packageSnapshot.docs.map((doc) => PackageModel.fromJson(doc.data(), id: doc.id)).toList();

    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getPackages',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch packages');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getPackages',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching packages');
    }
  }


  @override
  Future<List<PackageRequestModel>> getActivatedPackages(String connectionId) async {
    try {

      final actPackagesSnapshot = await firestore
          .collection('requested_packages')
          .where('connectionId', isEqualTo: connectionId)
          // .where('activatedDate', isNull: false)
          .get();

      List<PackageRequestModel> apList = actPackagesSnapshot.docs.map((doc) => PackageRequestModel.fromJson(doc.data(), id: doc.id)).toList();

      for(int i = 0; i < apList.length; i++){
        if(apList[i].packageDetailsId == null || apList[i].packageDetailsId!.isEmpty){
          continue;
        }
        final packageSnapshot = await firestore.collection('package_details').doc(apList[i].packageDetailsId).get();
        final data = PackageModel.fromJson(packageSnapshot.data()!, id: packageSnapshot.id);
        apList[i] = apList[i].copyWith(newPackageModel: data);
      }

      return apList;

    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getActivatedPackages',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch activated packages');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getActivatedPackages',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching activated packages');
    }
  }

  User _getCurrentUser(){
    try{
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException('User not authenticated');
      }
      return currentUser;

    }catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl._getCurrentUser',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching current user');
    }
  }

}
