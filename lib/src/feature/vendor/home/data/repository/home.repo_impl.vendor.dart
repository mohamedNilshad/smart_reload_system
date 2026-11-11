import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/datasource/home.remote_datasource.vendor.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/repository/home.repo.vendor.dart';

class HomeRepoVImpl implements HomeRepoV {
  final HomeRemoteDataSourceV remoteDataSource;

  HomeRepoVImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BannerNewsModel>>> getBannerNews() async {
    try {
      final result = await remoteDataSource.getBannerNews();

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getClients() async {
    try {
      final result = await remoteDataSource.getClients();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Stream<Map<String, dynamic>> watchPackageRequests(String vendorId) {
    return remoteDataSource.watchPackageRequests(vendorId);
  }

  @override
  Future<Either<Failure, List<ConnectionModel>>> getConnections(
      String clientVendorId) async {
    try {
      final result = await remoteDataSource.getConnections(clientVendorId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPackage(PackageRequestModel packageRequestModel) async {
    try {
      final result = await remoteDataSource.requestPackage(packageRequestModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> activatePackageRequest(PackageRequestModel packageRequestModel) async {
    try {
      final result = await remoteDataSource.activatePackageRequest(packageRequestModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> addNewConnection(ConnectionModel connectionModel) async {
    try {
      final result = await remoteDataSource.addNewConnection(connectionModel);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PackageModel>>> getPackages(String type, String serviceProvider) async {
    try {
      final result = await remoteDataSource.getPackages(type, serviceProvider);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PackageRequestModel>>> getActivatedPackages(String connectionId) async {
    try {
      final result = await remoteDataSource.getActivatedPackages(connectionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
