import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:flutter/foundation.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/model/client.model.dart';

abstract class HomeRemoteDataSourceV {
  Future<List<BannerNewsModel>> getBannerNews();
  Future<Map<String, dynamic>> getClients();

  Future<List<ConnectionModel>> getConnections(String clientVendorId);
  Future<bool> requestPackage(PackageRequestModel packageRequestModel);
  Future<bool> addNewConnection(ConnectionModel connectionModel);
  Future<List<PackageModel>> getPackages(String type, String serviceProvider);
  Future<List<PackageRequestModel>> getActivatedPackages(String connectionId);

  Stream<Map<String, dynamic>> watchPackageRequests(String vendorId);
}

class HomeRemoteDataSourceVImpl implements HomeRemoteDataSourceV {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final db.FirebaseDatabase database;

  HomeRemoteDataSourceVImpl({required this.firestore, required this.firebaseAuth, required this.database});

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
        location: 'HomeRemoteDataSourceVImpl.getBannerNews',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch banner news');

    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceVImpl.getBannerNews',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching banner news');
    }
  }

  @override
  Future<Map<String, dynamic>> getClients() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException('User not authenticated');
      }

      final vendorId = currentUser.uid;

      // Step 1: Fetch vendorId and connectionCount from client_vendor collection
      final clientVendorSnapshot = await firestore
          .collection('client_vendor')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      final List<ClientModel> clients = [];


      // Step 2: For each vendor, fetch vendorName from users collection
      for (final doc in clientVendorSnapshot.docs) {

        final data = doc.data();
        final clientId = data['clientId'] as String?;
        final connectionCount = data['connectionCount'] as int? ?? 0;

        if (clientId != null) {
          try {
            final userDoc = await firestore.collection('users').doc(clientId).get();
            if (userDoc.exists) {

              final clientName = userDoc['fullName'] as String? ?? 'Unknown';
              final clientEmail = userDoc['email'] as String? ?? '';
              final clientPhone = userDoc['phoneNumber'] as String? ?? 'Unknown';
              final lastPaidDate = (data['lastPaidDate'] as Timestamp?)?.toDate();
              final lastPaidAmount = data['lastPaidAmount'] as double?;
              final totalPayable = data['totalPayable'] as double?;
              clients.add(
                ClientModel(
                  clientVendorId: doc.id,
                  clientId: clientId,
                  clientName: clientName,
                  clientEmail: clientEmail,
                  clientPhone: clientPhone,
                  connectionCount: connectionCount,
                  totalPayable: (totalPayable == null) ? 0.0: totalPayable,
                  lastPaidAmount: lastPaidAmount,
                  lastPaidDate: lastPaidDate,
                ),
              );
            }
          } catch (e, st) {
            // Skip this vendor if user data fetch fails
            ErrorLogger.log(
              e,
              location: 'HomeRemoteDataSourceImpl.getClients',
              stackTrace: st,
            );
            continue;
          }
        }
      }

      // Step 3: Fetch package requests from Realtime Database
      final snapshot = await database.ref('package_requests/$vendorId').get();

      final value = snapshot.value;
      Map<String, dynamic> packageRequests = {};

      if (value is! Map) {
        packageRequests = <String, dynamic>{};
      } else {
        packageRequests = Map<String, dynamic>.from(value);
      }

      return {
        'clients' :clients,
        'packageRequests' : packageRequests
      };
    } on FirebaseException catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getClients',
        stackTrace: st,
      );
      throw ServerException(e.message ?? 'Failed to fetch clients');
    } catch (e, st) {
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.getClients',
        stackTrace: st,
      );
      throw Exception('An error occurred while fetching clients');
    }
  }

  @override
  Stream<Map<String, dynamic>> watchPackageRequests(String vendorId) {
    try{
      return database.ref('package_requests/$vendorId').onValue.asyncMap((event) async {
        debugPrint("Package Request Data Changed: ${event.snapshot.value}");
        final value = event.snapshot.value;

        if (value is! Map) {
          return <String, dynamic>{};
        }

        return Map<String, dynamic>.from(value);
      });

    }catch(e, st){
      ErrorLogger.log(
        e,
        location: 'AuthRemoteDataSourceImpl.watchUser',
        stackTrace: st,
      );
      throw Exception('An unexpected error occurred: $e');
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
  Future<bool> requestPackage(PackageRequestModel packageRequestModel) async {
    try {

      await firestore.collection("requested_packages").add(packageRequestModel.toJson());
      //send push notification
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

}
