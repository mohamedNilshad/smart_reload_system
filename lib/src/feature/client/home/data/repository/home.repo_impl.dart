import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/datasource/home.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepoImpl({required this.remoteDataSource});

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
  Future<Either<Failure, List<VendorModel>>> getVendors() async {
    try {
      final result = await remoteDataSource.getVendors();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
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
}
