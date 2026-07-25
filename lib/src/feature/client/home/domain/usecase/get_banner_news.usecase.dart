import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class GetBannerNewsUseCase {
  final HomeRepo repo;

  GetBannerNewsUseCase(this.repo);

  Future<Either<Failure, List<BannerNewsModel>>> call() {
    return repo.getBannerNews();
  }
}
