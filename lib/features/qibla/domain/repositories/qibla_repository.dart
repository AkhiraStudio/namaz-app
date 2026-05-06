import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/qibla_direction.dart';

abstract class QiblaRepository {
  Stream<Either<Failure, QiblaDirection>> getQiblaDirectionStream();
}
