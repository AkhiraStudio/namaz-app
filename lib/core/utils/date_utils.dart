/// Utilitaires pour la manipulation des dates dans l'application.
class AppDateUtils {
  AppDateUtils._();

  /// Retourne true si deux DateTime sont le même jour calendaire.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Retourne le nombre de jours entre deux dates (valeur absolue).
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays.abs();
  }

  /// Retourne le début de la journée (00:00:00) pour une date donnée.
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Retourne la fin de la journée (23:59:59) pour une date donnée.
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Formate une durée en compte à rebours HH:mm:ss.
  static String formatCountdown(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Retourne une description relative de la date (aujourd'hui, hier, etc.).
  static String relativeDay(DateTime date, {String locale = 'fr'}) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return locale == 'fr' ? "Aujourd'hui" : 'Today';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return locale == 'fr' ? 'Hier' : 'Yesterday';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
