import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_banner_news.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_vendors.usecase.dart';
import 'home.event.dart';
import 'home.state.dart';

/// HomeBloc is an app-level singleton that persists for the entire session.
/// Screens using this bloc should dispatch HomeDataReset in initState or handle
/// stale success/failure states via BlocListener (one-time side effects) rather
/// than BlocBuilder (persistent rendering) to avoid showing old data on re-entry.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetBannerNewsUseCase getBannerNewsUseCase;
  final GetVendorsUseCase getVendorsUseCase;

  HomeBloc({
    required this.getBannerNewsUseCase,
    required this.getVendorsUseCase,
  }) : super(const HomeInitial()) {
    on<HomeDataRequested>(_onHomeDataRequested);
    on<HomeDataReset>(_onHomeDataReset);
  }

  Future<void> _onHomeDataRequested(
    HomeDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    
    final bannerNewsResult = await getBannerNewsUseCase();

    final vendorsResult = await getVendorsUseCase();

    bannerNewsResult.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (bannerNews) {
        vendorsResult.fold(
          (failure) => emit(HomeFailure(failure.message)),
          (vendors) => emit(HomeSuccess(
            bannerNews: bannerNews,
            vendors: vendors,
          )),
        );
      },
    );
  }

  Future<void> _onHomeDataReset(
    HomeDataReset event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeInitial());
  }
}
