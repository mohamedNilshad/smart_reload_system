import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeDataRequested extends HomeEvent {
  const HomeDataRequested();
}

class HomeDataReset extends HomeEvent {
  const HomeDataReset();
}
