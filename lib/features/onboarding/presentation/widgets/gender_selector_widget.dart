import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class GenderSelectorWidget extends StatelessWidget {
  final UserGender? selectedGender;
  final ValueChanged<UserGender> onChanged;

  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderCard(
            label: 'Homme',
            icon: Icons.man_rounded,
            gender: UserGender.male,
            isSelected: selectedGender == UserGender.male,
            onTap: () => onChanged(UserGender.male),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GenderCard(
            label: 'Femme',
            icon: Icons.woman_rounded,
            gender: UserGender.female,
            isSelected: selectedGender == UserGender.female,
            onTap: () => onChanged(UserGender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final UserGender gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.deepPurple
              : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.deepPurple : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
