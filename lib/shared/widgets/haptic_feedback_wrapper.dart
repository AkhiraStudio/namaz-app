import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enveloppe un widget avec un retour haptique léger au tap.
class HapticFeedbackWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticFeedbackType feedbackType;

  const HapticFeedbackWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.feedbackType = HapticFeedbackType.lightImpact,
  });

  Future<void> _triggerHaptic() async {
    switch (feedbackType) {
      case HapticFeedbackType.lightImpact:
        await HapticFeedback.lightImpact();
      case HapticFeedbackType.mediumImpact:
        await HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavyImpact:
        await HapticFeedback.heavyImpact();
      case HapticFeedbackType.selectionClick:
        await HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              _triggerHaptic();
              onTap!();
            }
          : null,
      child: child,
    );
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}
