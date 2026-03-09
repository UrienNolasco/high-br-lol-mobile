import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_champion.dart';

class ExpandableChampionRow extends StatefulWidget {
  const ExpandableChampionRow({
    super.key,
    required this.champion,
    required this.rank,
  });

  final PlayerChampion champion;
  final int rank;

  @override
  State<ExpandableChampionRow> createState() => _ExpandableChampionRowState();
}

class _ExpandableChampionRowState extends State<ExpandableChampionRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final champ = widget.champion;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildHeader(champ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _buildDetails(champ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PlayerChampion champ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 20,
            child: Text(
              '${widget.rank}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: champ.imageUrl,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 36, height: 36, color: AppColors.bgTertiary,
              ),
              errorWidget: (_, _, _) => Container(
                width: 36, height: 36, color: AppColors.bgTertiary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  champ.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _shortRole(champ.primaryRole),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // WR + Games
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${champ.winRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _wrColor(champ.winRate),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${champ.games} games',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Chevron
          Icon(
            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(PlayerChampion champ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Record
              Row(
                children: [
                  Text(
                    '${champ.wins}W',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.win,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '/',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${champ.losses}L',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.loss,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Stats row 1
              Row(
                children: [
                  _MiniStat(label: 'KDA', value: champ.avgKda.toStringAsFixed(2)),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'CS/m', value: champ.avgCspm.toStringAsFixed(1)),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'DPM', value: champ.avgDpm.toStringAsFixed(0)),
                ],
              ),
              const SizedBox(height: 6),
              // Stats row 2
              Row(
                children: [
                  _MiniStat(label: 'GPM', value: champ.avgGpm.toStringAsFixed(0)),
                  const SizedBox(width: 6),
                  _MiniStat(label: 'VISION', value: champ.avgVisionScore.toStringAsFixed(1)),
                  const SizedBox(width: 6),
                  _MiniStat(
                    label: 'ROLE',
                    value: _shortRole(champ.primaryRole),
                    valueColor: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Early game label
              const Text(
                'EARLY GAME @15',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              // Early game stats
              Row(
                children: [
                  _MiniStat(
                    label: 'CSD',
                    value: champ.avgCsd15.toStringAsFixed(1),
                    valueColor: champ.avgCsd15 >= 0 ? AppColors.win : AppColors.loss,
                  ),
                  const SizedBox(width: 6),
                  _MiniStat(
                    label: 'GD',
                    value: champ.avgGd15.toStringAsFixed(0),
                    valueColor: champ.avgGd15 >= 0 ? AppColors.win : AppColors.loss,
                  ),
                  const SizedBox(width: 6),
                  _MiniStat(
                    label: 'XPD',
                    value: champ.avgXpd15.toStringAsFixed(0),
                    valueColor: champ.avgXpd15 >= 0 ? AppColors.win : AppColors.loss,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _shortRole(String role) {
    const map = {
      'MIDDLE': 'MID',
      'JUNGLE': 'JGL',
      'BOTTOM': 'BOT',
      'UTILITY': 'SUP',
    };
    return map[role] ?? role;
  }

  static Color _wrColor(double wr) {
    if (wr >= 55) return AppColors.win;
    if (wr >= 50) return const Color(0xFF60A5FA);
    if (wr >= 45) return AppColors.textPrimary;
    return AppColors.loss;
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
