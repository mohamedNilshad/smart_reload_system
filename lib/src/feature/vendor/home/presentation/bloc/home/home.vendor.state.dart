import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/banner_news.model.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/model/client.model.dart';

abstract class HomeVendorState extends Equatable {
  const HomeVendorState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeVendorState {
  const HomeInitial();
}

class HomeLoading extends HomeVendorState {
  const HomeLoading();
}

class HomeSuccess extends HomeVendorState {
  final List<BannerNewsModel> bannerNews;
  final Map<String, dynamic> data;

  const HomeSuccess({
    required this.bannerNews,
    required this.data,
  });

  @override
  List<Object?> get props => [bannerNews, data];
}

class HomeFailure extends HomeVendorState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
