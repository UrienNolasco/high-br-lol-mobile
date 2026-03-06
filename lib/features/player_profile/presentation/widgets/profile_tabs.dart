import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const _tabs = ['Overview', 'Champions', 'Matches', 'Atividade'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = index == selectedIndex;
          return Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: isActive ? AppColors.accent : Colors.transparent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
