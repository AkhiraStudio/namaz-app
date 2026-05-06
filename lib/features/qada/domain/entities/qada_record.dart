import 'package:equatable/equatable.dart';
import '../../../prayer/domain/entities/prayer_record.dart';

/// Enregistrement d'une prière de rattrapage effectuée.
class QadaRecord extends Equatable {
  final String id;
  final PrayerName prayerName;
  final DateTime performedAt;
  final bool isFromRecentMissed; // true = flux récent, false = flux long terme

  const QadaRecord({
    required this.id,
    required this.prayerName,
    required this.performedAt,
    this.isFromRecentMissed = false,
  });

  @override
  List<Object?> get props => [id, prayerName, performedAt, isFromRecentMissed];
}
