import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/qibla_datasource.dart';
import '../../data/repositories_impl/qibla_repository_impl.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/usecases/get_qibla_direction_usecase.dart';
import '../../../../core/providers/core_providers.dart';

final qiblaDataSourceProvider = Provider<QiblaDataSource>((ref) =>
    QiblaDataSourceImpl(
      locationService: ref.read(locationServiceProvider),
    ));

final qiblaRepositoryProvider = Provider((ref) => QiblaRepositoryImpl(
      dataSource: ref.read(qiblaDataSourceProvider),
    ));

final getQiblaDirectionUseCaseProvider = Provider(
  (ref) => GetQiblaDirectionUseCase(ref.read(qiblaRepositoryProvider)),
);

/// Stream de la direction Qibla, mis à jour en continu par la boussole.
final qiblaDirectionProvider = StreamProvider<QiblaDirection>((ref) {
  try {
    final useCase = ref.read(getQiblaDirectionUseCaseProvider);
    return useCase().map((either) => either.fold(
          (failure) => throw Exception(failure.message),
          (direction) => direction,
        ));
  } catch (e, st) {
    return Stream.error(e, st);
  }
});
