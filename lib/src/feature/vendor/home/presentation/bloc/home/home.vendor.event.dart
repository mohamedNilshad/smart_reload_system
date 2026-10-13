import 'package:equatable/equatable.dart';

abstract class HomeVendorEvent extends Equatable {
  const HomeVendorEvent();

  @override
  List<Object?> get props => [];
}

class HomeDataRequested extends HomeVendorEvent {
  const HomeDataRequested();
}

class HomeDataReset extends HomeVendorEvent {
  const HomeDataReset();
}
