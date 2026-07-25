import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';

abstract class HomeRepo {
  Future<Either<Failure, List<BannerNewsModel>>> getBannerNews();
  Future<Either<Failure, List<VendorModel>>> getVendors();
}
