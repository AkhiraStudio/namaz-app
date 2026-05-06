import 'package:flutter/material.dart';

class WeeklyDotsRow extends StatelessWidget {
  final List<bool> completion; // 7 bools, lundi → dimanche
  final Color activeColor;

  const WeeklyDotsRow({
    super.key,
    required this.completion,
    required this.activeColor,
  });

  static const _labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=lundi … 6=dimanche

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final done = i < completion.length && completion[i];
        final isFuture = i > todayIndex;
        final isToday = i == todayIndex;

        final Color circleColor;
        final Color borderColor;
        final Widget? icon;

        if (isFuture) {
          circleColor = Colors.transparent;
          borderColor = cs.outlineVariant.withValues(alpha: 0.4);
          icon = null;
        } else if (done) {
          circleColor = activeColor;
          borderColor = activeColor;
          icon = const Icon(Icons.check_rounded, size: 13, color: Colors.white);
        } else {
          circleColor = Colors.transparent;
          borderColor = cs.outlineVariant;
          icon = null;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? activeColor : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: Border.all(
                  color: borderColor,
                  width: isToday && !done ? 2 : 1.5,
                ),
              ),
              child: Center(child: icon),
            ),
          ],
        );
      }),
    );
  }
}
