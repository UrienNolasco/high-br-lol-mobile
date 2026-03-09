import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_champion.dart';
import 'expandable_champion_row.dart';

class ChampionsContent extends StatefulWidget {
  const ChampionsContent({super.key, required this.champions});

  final List<PlayerChampion> champions;

  @override
  State<ChampionsContent> createState() => _ChampionsContentState();
}

class _ChampionsContentState extends State<ChampionsContent> {
  String _selectedRole = 'ALL';
  String _sortBy = 'games';

  static const _roles = ['ALL', 'TOP', 'JGL', 'MID', 'BOT', 'SUP'];

  static const _roleBackendMap = {
    'JGL': 'JUNGLE',
    'MID': 'MIDDLE',
    'BOT': 'BOTTOM',
    'SUP': 'UTILITY',
  };

  List<PlayerChampion> get _filteredAndSorted {
    var list = widget.champions.toList();

    // Filter by role
    if (_selectedRole != 'ALL') {
      final backendRole = _roleBackendMap[_selectedRole] ?? _selectedRole;
      list = list.where((c) => c.roleDistribution.containsKey(backendRole)).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'games':
        list.sort((a, b) => b.games.compareTo(a.games));
      case 'winRate':
        list.sort((a, b) => b.winRate.compareTo(a.winRate));
      case 'kda':
        list.sort((a, b) => b.avgKda.compareTo(a.avgKda));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final champions = _filteredAndSorted;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _roles.map((role) {
                final isActive = role == _selectedRole;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Sort chips
          Row(
            children: [
              _SortChip(
                label: 'Games',
                isActive: _sortBy == 'games',
                onTap: () => setState(() => _sortBy = 'games'),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Win Rate',
                isActive: _sortBy == 'winRate',
                onTap: () => setState(() => _sortBy = 'winRate'),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'KDA',
                isActive: _sortBy == 'kda',
                onTap: () => setState(() => _sortBy = 'kda'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Champion list
          ...List.generate(champions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpandableChampionRow(
                champion: champions[index],
                rank: index + 1,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
