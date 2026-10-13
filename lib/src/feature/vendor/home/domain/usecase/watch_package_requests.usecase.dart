import 'package:smart_reload_system/src/feature/vendor/home/domain/repository/home.repo.vendor.dart';

class WatchPackageRequestsUseCase {
  final HomeRepoV repo;
  WatchPackageRequestsUseCase(this.repo);

  Stream<Map<String, dynamic>> call(String vendorId) {
    return repo.watchPackageRequests(vendorId);
  }
}