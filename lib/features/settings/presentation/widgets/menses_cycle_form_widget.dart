import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class MensesCycleFormWidget extends StatefulWidget {
  final int initialCycleDays;
  final int initialDurationDays;
  final void Function(int cycle, int duration) onSave;

  const MensesCycleFormWidget({
    super.key,
    required this.initialCycleDays,
    required this.initialDurationDays,
    required this.onSave,
  });

  @override
  State<MensesCycleFormWidget> createState() => _MensesCycleFormWidgetState();
}

class _MensesCycleFormWidgetState extends State<MensesCycleFormWidget> {
  late int _cycleDays;
  late int _durationDays;

  @override
  void initState() {
    super.initState();
    _cycleDays = widget.initialCycleDays;
    _durationDays = widget.initialDurationDays;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.cycleDurationDisplay(_cycleDays),
              style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: _cycleDays.toDouble(),
            min: 20,
            max: 40,
            divisions: 20,
            label: '$_cycleDays j',
            activeColor: AppColors.deepPurple,
            onChanged: (v) => setState(() => _cycleDays = v.round()),
          ),
          Text(l.menstruationDurationDisplay(_durationDays),
              style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: _durationDays.toDouble(),
            min: 3,
            max: 15,
            divisions: 12,
            label: '$_durationDays j',
            activeColor: AppColors.deepPurple,
            onChanged: (v) => setState(() => _durationDays = v.round()),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_cycleDays, _durationDays),
              child: Text(l.saveButton),
            ),
          ),
        ],
      ),
    );
  }
}
