import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.selectedCode,
    required this.onChanged,
  });

  static const List<({String code, String label, String flag, bool available})> _languages = [
    (code: 'fr', label: 'Français', flag: '🇫🇷', available: true),
    (code: 'en', label: 'English', flag: '🇬🇧', available: true),
    (code: 'ar', label: 'العربية', flag: '🇸🇦', available: false),
    (code: 'de', label: 'Deutsch', flag: '🇩🇪', available: false),
    (code: 'es', label: 'Español', flag: '🇪🇸', available: false),
    (code: 'it', label: 'Italiano', flag: '🇮🇹', available: false),
    (code: 'zh', label: '中文', flag: '🇨🇳', available: false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: _languages.map((lang) {
        final isSelected = lang.code == selectedCode;
        final disabled = !lang.available;
        return Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: ListTile(
            onTap: disabled ? null : () => onChanged(lang.code),
            leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
            title: Text(lang.label),
            trailing: isSelected
                ? const Icon(Icons.check_rounded, color: AppColors.deepPurple)
                : disabled
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.outlineVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Bientôt',
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      )
                    : null,
            selected: isSelected,
            selectedColor: AppColors.deepPurple,
          ),
        );
      }).toList(),
    );
  }
}
