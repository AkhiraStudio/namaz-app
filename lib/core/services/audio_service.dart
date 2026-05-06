import 'package:just_audio/just_audio.dart';

/// Noms des prières pour résoudre l'asset audio de l'adhan.
enum AdhanPrayer { fajr, dhuhr, asr, maghrib, isha }

/// Service audio pour la lecture de l'adhan et des adhkars.
///
/// Utilise [just_audio]. Doit être disposé quand il n'est plus nécessaire.
abstract class AudioService {
  /// Joue l'adhan correspondant à la prière donnée.
  Future<void> playAdhan(AdhanPrayer prayer);

  /// Joue un fichier audio d'adhkar (par nom de fichier, sans extension).
  Future<void> playAdhkar(String name);

  /// Stoppe la lecture en cours.
  Future<void> stop();

  /// Libère les ressources audio.
  Future<void> dispose();
}

class AudioServiceImpl implements AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Résout le chemin asset de l'adhan selon la prière.
  static String _adhanAsset(AdhanPrayer prayer) {
    return switch (prayer) {
      AdhanPrayer.fajr => 'assets/audio/adhan/adhan_fajr.mp3',
      AdhanPrayer.dhuhr => 'assets/audio/adhan/adhan_standard.mp3',
      AdhanPrayer.asr => 'assets/audio/adhan/adhan_standard.mp3',
      AdhanPrayer.maghrib => 'assets/audio/adhan/adhan_standard.mp3',
      AdhanPrayer.isha => 'assets/audio/adhan/adhan_standard.mp3',
    };
  }

  @override
  Future<void> playAdhan(AdhanPrayer prayer) async {
    try {
      await _player.stop();
      await _player.setAsset(_adhanAsset(prayer));
      await _player.play();
    } catch (_) {
      // Audio non bloquant : si le fichier est absent, on ignore silencieusement.
    }
  }

  @override
  Future<void> playAdhkar(String name) async {
    try {
      await _player.stop();
      await _player.setAsset('assets/audio/adhkar/$name.mp3');
      await _player.play();
    } catch (_) {
      // Idem : non bloquant.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
