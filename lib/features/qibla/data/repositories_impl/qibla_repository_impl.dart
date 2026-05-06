import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/repositories/qibla_repository.dart';
import '../datasources/qibla_datasource.dart';

class QiblaRepositoryImpl implements QiblaRepository {
  final QiblaDataSource _dataSource;
  const QiblaRepositoryImpl({required QiblaDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<Either<Failure, QiblaDirection>> getQiblaDirectionStream() async* {
    try {
      await for (final data in _dataSource.getQiblaStream()) {
        yield Right(QiblaDirection(
          angle: data.qiblaAngle,
          compassHeading: data.compassHeading,
          isCalibrated: data.isCalibrated,
        ));
      }
    } on LocationException catch (e) {
      yield Left(LocationFailure(message: e.message));
    } on PermissionException catch (e) {
      yield Left(PermissionFailure(message: e.message));
    }
  }
}
