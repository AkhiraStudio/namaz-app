import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LanguagePickerWidget extends StatelessWidget {
  final String selectedLanguageCode;
  final ValueChanged<String> onChanged;

  const LanguagePickerWidget({
    super.key,
    required this.selectedLanguageCode,
    required this.onChanged,
  });

  static const List<_LangOption> _languages = [
    _LangOption(code: 'fr', label: 'Français', flag: '🇫🇷'),
    _LangOption(code: 'en', label: 'English', flag: '🇬🇧'),
    _LangOption(code: 'ar', label: 'العربية', flag: '🇸🇦'),
    _LangOption(code: 'zh', label: '中文', flag: '🇨🇳'),
    _LangOption(code: 'de', label: 'Deutsch', flag: '🇩🇪'),
    _LangOption(code: 'es', label: 'Español', flag: '🇪🇸'),
    _LangOption(code: 'it', label: 'Italiano', flag: '🇮🇹'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _languages.map((lang) {
        final isSelected = lang.code == selectedLanguageCode;
        return GestureDetector(
          onTap: () => onChanged(lang.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.deepPurple : AppColors.creamBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.deepPurple : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  lang.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LangOption {
  final String code;
  final String label;
  final String flag;
  const _LangOption({required this.code, required this.label, required this.flag});
}
