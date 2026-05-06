import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class PostPrayerChecklistWidget extends StatefulWidget {
  final String prayerName;
  const PostPrayerChecklistWidget({super.key, required this.prayerName});

  @override
  State<PostPrayerChecklistWidget> createState() =>
      _PostPrayerChecklistWidgetState();
}

class _PostPrayerChecklistWidgetState extends State<PostPrayerChecklistWidget> {
  int _subhanaAllahCount = 0;
  int _alhamdulillahCount = 0;
  int _allahuAkbarCount = 0;

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    final box = Hive.box<int>(HiveBoxNames.adhkarProgress);
    final today = _todayKey();
    final p = widget.prayerName;
    setState(() {
      _subhanaAllahCount = box.get('tasbeeh_${p}_subhan_$today', defaultValue: 0)!;
      _alhamdulillahCount = box.get('tasbeeh_${p}_hamd_$today', defaultValue: 0)!;
      _allahuAkbarCount = box.get('tasbeeh_${p}_akbar_$today', defaultValue: 0)!;
    });
  }

  void _save() {
    final box = Hive.box<int>(HiveBoxNames.adhkarProgress);
    final today = _todayKey();
    final p = widget.prayerName;
    box.put('tasbeeh_${p}_subhan_$today', _subhanaAllahCount);
    box.put('tasbeeh_${p}_hamd_$today', _alhamdulillahCount);
    box.put('tasbeeh_${p}_akbar_$today', _allahuAkbarCount);

    if (_subhanaAllahCount >= AppConstants.tasbeehCount &&
        _alhamdulillahCount >= AppConstants.tasbeehCount &&
        _allahuAkbarCount >= AppConstants.tasbeehCount) {
      Hive.box<bool>(HiveBoxNames.tasbeehCompletions).put('${p}_$today', true);
    }
  }

  void _increment(int current, ValueChanged<int> onChanged) {
    if (current < AppConstants.tasbeehCount) {
      onChanged(current + 1);
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.postPrayerTasbihTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        _TasbeehCounter(
          label: l.subhanaAllahLabel,
          arabicText: 'سُبْحَانَ اللهِ',
          count: _subhanaAllahCount,
          onTap: () => setState(() => _increment(
              _subhanaAllahCount, (v) => _subhanaAllahCount = v)),
        ),
        const SizedBox(height: 12),
        _TasbeehCounter(
          label: l.alhamdulillahLabel,
          arabicText: 'الْحَمْدُ لِلَّهِ',
          count: _alhamdulillahCount,
          onTap: () => setState(() => _increment(
              _alhamdulillahCount, (v) => _alhamdulillahCount = v)),
        ),
        const SizedBox(height: 12),
        _TasbeehCounter(
          label: l.allahuAkbarLabel,
          arabicText: 'اللهُ أَكْبَر',
          count: _allahuAkbarCount,
          onTap: () => setState(() => _increment(
              _allahuAkbarCount, (v) => _allahuAkbarCount = v)),
        ),
      ],
    );
  }
}

class _TasbeehCounter extends StatelessWidget {
  final String label;
  final String arabicText;
  final int count;
  final VoidCallback onTap;

  const _TasbeehCounter({
    required this.label,
    required this.arabicText,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = count >= AppConstants.tasbeehCount;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isComplete
              ? AppColors.prayerEarly.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isComplete ? AppColors.prayerEarly : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(arabicText,
                      style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: AppColors.deepPurple)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(
              '$count/${AppConstants.tasbeehCount}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isComplete ? AppColors.prayerEarly : AppColors.deepPurple,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isComplete
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isComplete ? AppColors.prayerEarly : AppColors.lightPurple,
            ),
          ],
        ),
      ),
    );
  }
}
