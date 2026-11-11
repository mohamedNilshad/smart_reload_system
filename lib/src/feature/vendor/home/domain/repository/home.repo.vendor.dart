import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class HomeRepoV {
  Future<Either<Failure, List<BannerNewsModel>>> getBannerNews();
  Future<Either<Failure, Map<String, dynamic>>> getClients();

  Future<Either<Failure, List<ConnectionModel>>> getConnections(String clientVendorId);
  Future<Either<Failure, bool>> requestPackage(PackageRequestModel packageRequestModel);
  Future<Either<Failure, bool>> activatePackageRequest(PackageRequestModel packageRequestModel);
  Future<Either<Failure, bool>> addNewConnection(ConnectionModel connectionModel);
  Future<Either<Failure, List<PackageModel>>> getPackages(String type, String serviceProvider);
  Future<Either<Failure, List<PackageRequestModel>>> getActivatedPackages(String connectionId);

  Stream<Map<String, dynamic>> watchPackageRequests(String vendorId);
}
