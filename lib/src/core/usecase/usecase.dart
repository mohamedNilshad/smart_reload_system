import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
