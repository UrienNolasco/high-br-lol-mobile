import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_champion.dart';

class TopChampionsCard extends StatelessWidget {
  const TopChampionsCard({super.key, required this.champions});

  final List<PlayerChampion> champions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'CHAMPION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'GAMES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 48,
                  child: Text(
                    'WR%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 4),
          // Champions list
          ...champions.map((champ) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Champion icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: champ.imageUrl,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 28,
                      height: 28,
                      color: AppColors.bgTertiary,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 28,
                      height: 28,
                      color: AppColors.bgTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name
                Expanded(
                  child: Text(
                    champ.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Games
                SizedBox(
                  width: 40,
                  child: Text(
                    '${champ.games}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // WR
                SizedBox(
                  width: 48,
                  child: Text(
                    '${champ.winRate.toStringAsFixed(1)}%',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _wrColor(champ.winRate),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        ],
      ),
    );
  }

  static Color _wrColor(double wr) {
    if (wr >= 55) return AppColors.accent;
    if (wr >= 50) return const Color(0xFF60A5FA);
    if (wr >= 45) return AppColors.textPrimary;
    return AppColors.loss;
  }
}
