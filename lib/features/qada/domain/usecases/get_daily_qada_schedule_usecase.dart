import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/prayer_constants.dart';
import '../repositories/qada_repository.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

/// Retourne la liste des prières à rattraper pour aujourd'hui.
/// Format : liste de [PrayerName] répétés selon l'objectif quotidien.
class GetDailyQadaScheduleUseCase {
  final QadaRepository _repository;
  const GetDailyQadaScheduleUseCase(this._repository);

  Future<Either<Failure, List<PrayerName>>> call(int dailyPrayerTarget) async {
    final progressResult = await _repository.getProgress();
    return progressResult.fold(Left.new, (progress) {
      if (progress.remaining == 0) return const Right([]);

      final daysToMakeUp = (dailyPrayerTarget / PrayerConstants.prayersPerDay)
          .ceil()
          .clamp(1, 10);

      final schedule = <PrayerName>[];
      for (int day = 0; day < daysToMakeUp; day++) {
        for (final name in PrayerName.values) {
          if (schedule.length < dailyPrayerTarget) {
            schedule.add(name);
          }
        }
      }
      return Right(schedule);
    });
  }
}
