import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  '${player.gameName}#${player.tagLine}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Rank row
                Row(
                  children: [
                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _tierColor(player.tier),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _tierAbbrev(player.tier),
                        style: const TextStyle(
                                fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${player.tier} ${player.leaguePoints} LP',
                      style: const TextStyle(
                            fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // WL row
                Row(
                  children: [
                    Text(
                      '${player.wins}W ${player.losses}L',
                      style: const TextStyle(
                            fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '·',
                      style: TextStyle(
                            fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.winRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                            fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _tierColor(String tier) {
    return switch (tier.toUpperCase()) {
      'CHALLENGER' => const Color(0xFFDC2626),
      'GRANDMASTER' => const Color(0xFFDC2626),
      'MASTER' => const Color(0xFFA855F7),
      'DIAMOND' => const Color(0xFF3B82F6),
      'EMERALD' => const Color(0xFF22C55E),
      'PLATINUM' => const Color(0xFF06B6D4),
      'GOLD' => const Color(0xFFF59E0B),
      'SILVER' => const Color(0xFF7A8599),
      'BRONZE' => const Color(0xFFCD7F32),
      'IRON' => const Color(0xFF3D4654),
      _ => AppColors.textSecondary,
    };
  }

  static String _tierAbbrev(String tier) {
    return switch (tier.toUpperCase()) {
      'CHALLENGER' => 'CH',
      'GRANDMASTER' => 'GM',
      'MASTER' => 'MA',
      'DIAMOND' => 'DI',
      'EMERALD' => 'EM',
      'PLATINUM' => 'PL',
      'GOLD' => 'GO',
      'SILVER' => 'SI',
      'BRONZE' => 'BR',
      'IRON' => 'IR',
      _ => tier.substring(0, 2).toUpperCase(),
    };
  }
}
