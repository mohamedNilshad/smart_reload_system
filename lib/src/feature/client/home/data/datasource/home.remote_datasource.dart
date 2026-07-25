import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerNewsModel>> getBannerNews();
  Future<List<VendorModel>> getVendors();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  HomeRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
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

    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch banner news');
    } catch (e) {
      throw ServerException('An error occurred while fetching banner news');
    }
  }

  @override
  Future<List<VendorModel>> getVendors() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException('User not authenticated');
      }

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
            final userDoc =
                await firestore.collection('users').doc(vendorId).get();
            if (userDoc.exists) {
              final vendorName = userDoc['fullName'] as String? ?? 'Unknown';
              vendors.add(
                VendorModel(
                  clientVendorId: doc.id,
                  vendorId: vendorId,
                  vendorName: vendorName,
                  connectionCount: connectionCount,
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
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch vendors');
    } catch (e) {
      throw ServerException('An error occurred while fetching vendors');
    }
  }
}
