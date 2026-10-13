import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_banner_news.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/get_clients.usecase.dart';
import 'home.vendor.event.dart';
import 'home.vendor.state.dart';

class HomeVendorBloc extends Bloc<HomeVendorEvent, HomeVendorState> {
  final GetBannerNewsUseCase getBannerNewsUseCase;
  final GetClientsUseCase getClientsUseCase;


  HomeVendorBloc({
    required this.getBannerNewsUseCase,
    required this.getClientsUseCase,
  }) : super(const HomeInitial()) {
    on<HomeDataRequested>(_onHomeDataRequested);
    on<HomeDataReset>(_onHomeDataReset);
  }


  Future<void> _onHomeDataRequested(HomeDataRequested event, Emitter<HomeVendorState> emit) async {
    emit(const HomeLoading());
    
    final bannerNewsResult = await getBannerNewsUseCase();

    final clientsResult = await getClientsUseCase();

    bannerNewsResult.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (bannerNews) {
        clientsResult.fold(
          (failure) => emit(HomeFailure(failure.message)),
          (client) => emit(HomeSuccess(
            bannerNews: bannerNews,
            data: client,
          )),
        );
      },
    );
  }

  Future<void> _onHomeDataReset(HomeDataReset event, Emitter<HomeVendorState> emit) async {
    emit(const HomeInitial());
  }


}
