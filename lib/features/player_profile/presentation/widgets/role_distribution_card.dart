import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_role.dart';

class RoleDistributionCard extends StatelessWidget {
  const RoleDistributionCard({super.key, required this.roles});

  final List<PlayerRole> roles;

  @override
  Widget build(BuildContext context) {
    final maxGames = roles.isNotEmpty
        ? roles.map((r) => r.games).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: roles.map((role) {
          final barFraction = maxGames > 0 ? role.games / maxGames : 0.0;
          return Padding(
            padding: EdgeInsets.only(
              bottom: role == roles.last ? 0 : 8,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    role.role,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 16,
                            width: constraints.maxWidth * barFraction,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(
                                alpha: 0.3 + 0.7 * barFraction,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${role.games}  ${role.winRate.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
