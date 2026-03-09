# Profile Improvements & Champions Tab Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix Overview tab UI issues (WR overflow, role names, champion headers) and implement a new Champions tab with expandable champion rows showing detailed stats.

**Architecture:** Expand the existing `PlayerChampion` entity to hold all backend fields. Add tab switching state to `PlayerProfilePage` (convert to StatefulWidget). Create `ChampionsContent` widget with role filter + sort chips and `ExpandableChampionRow` widget using `AnimatedCrossFade` for expand/collapse animation.

**Tech Stack:** Flutter, flutter_bloc, Equatable, CachedNetworkImage, Dio

**Design Reference:** `docs/pencil.dev/pencil-new.pen` — screens `Screen/PlayerProfile` (Overview) and `Screen/ChampionsTab` (Champions)

**Typography Convention:** `AppTheme.dark` sets `fontFamily: 'JetBrainsMono'` globally (line 10 of `app_theme.dart`). All `TextStyle` in new code MUST omit `fontFamily` — the theme provides it. Task 9 migrates existing widgets to follow this convention.

---

### Task 1: Fix WR overflow in GeneralStatsRow

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/general_stats_row.dart`

**Step 1: Update the WR card to remove % from value and show it in the label**

Change the WR `_StatCard` (line 20-24) from:
```dart
_StatCard(
  value: '${summary.winRate.toStringAsFixed(1)}%',
  label: 'WR',
  valueColor: AppColors.accent,
),
```
To:
```dart
_StatCard(
  value: summary.winRate.toStringAsFixed(1),
  label: 'WR%',
  valueColor: AppColors.accent,
),
```

**Step 2: Verify visually**

Run: `flutter run --debug`
Expected: WR card shows "55.6" without overflow, label says "WR%"

**Step 3: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/general_stats_row.dart
git commit -m "fix: remove % from WR value to prevent card overflow"
```

---

### Task 2: Fix role name display (MIDDLE → MID)

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/role_distribution_card.dart`

**Step 1: Add role name mapping helper**

Add this static method to `RoleDistributionCard`:
```dart
static String _shortRoleName(String role) {
  const map = {
    'MIDDLE': 'MID',
    'JUNGLE': 'JGL',
    'BOTTOM': 'BOT',
    'UTILITY': 'SUP',
  };
  return map[role] ?? role;
}
```

**Step 2: Apply mapping in the role label**

Change line 35 from:
```dart
role.role,
```
To:
```dart
_shortRoleName(role.role),
```

**Step 3: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/role_distribution_card.dart
git commit -m "fix: abbreviate role names (MIDDLE→MID, JUNGLE→JGL, etc)"
```

---

### Task 3: Add header to TopChampionsCard

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/top_champions_card.dart`

**Step 1: Add a header row above the champions list**

Inside the `Column` (line 20), add a header row as the first child, before the `.map()`:
```dart
child: Column(
  children: [
    // Header row
    Padding(
      padding: const EdgeInsets.only(left: 38, right: 4, bottom: 6),
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
          Text(
            'G',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: Text(
              'WR%',
              textAlign: TextAlign.right,
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
```

**Step 2: Close the spread properly**

Ensure the `Column.children` list uses `...champions.map(...)` (spread) instead of wrapping in a separate list.

**Step 3: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/top_champions_card.dart
git commit -m "feat: add CHAMPION/G/WR% header to top champions table"
```

---

### Task 4: Expand PlayerChampion entity with full backend fields

**Files:**
- Modify: `lib/features/player_profile/domain/entities/player_champion.dart`
- Modify: `lib/features/player_profile/data/models/player_champion_model.dart`

**Step 1: Add all backend fields to the entity**

Replace `lib/features/player_profile/domain/entities/player_champion.dart`:
```dart
import 'package:equatable/equatable.dart';

class PlayerChampion extends Equatable {
  const PlayerChampion({
    required this.name,
    required this.games,
    required this.winRate,
    required this.iconId,
    required this.imageUrl,
    required this.wins,
    required this.losses,
    required this.avgKda,
    required this.avgCspm,
    required this.avgDpm,
    required this.avgGpm,
    required this.avgVisionScore,
    required this.avgCsd15,
    required this.avgGd15,
    required this.avgXpd15,
    required this.roleDistribution,
  });

  final String name;
  final int games;
  final double winRate;
  final int iconId;
  final String imageUrl;
  final int wins;
  final int losses;
  final double avgKda;
  final double avgCspm;
  final double avgDpm;
  final double avgGpm;
  final double avgVisionScore;
  final double avgCsd15;
  final double avgGd15;
  final double avgXpd15;
  final Map<String, int> roleDistribution;

  String get primaryRole {
    if (roleDistribution.isEmpty) return '';
    return roleDistribution.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        name, games, winRate, iconId, imageUrl,
        wins, losses, avgKda, avgCspm, avgDpm,
        avgGpm, avgVisionScore, avgCsd15, avgGd15,
        avgXpd15, roleDistribution,
      ];
}
```

**Step 2: Update the model's fromJson**

Replace `lib/features/player_profile/data/models/player_champion_model.dart`:
```dart
import '../../domain/entities/player_champion.dart';

class PlayerChampionModel extends PlayerChampion {
  const PlayerChampionModel({
    required super.name,
    required super.games,
    required super.winRate,
    required super.iconId,
    required super.imageUrl,
    required super.wins,
    required super.losses,
    required super.avgKda,
    required super.avgCspm,
    required super.avgDpm,
    required super.avgGpm,
    required super.avgVisionScore,
    required super.avgCsd15,
    required super.avgGd15,
    required super.avgXpd15,
    required super.roleDistribution,
  });

  factory PlayerChampionModel.fromJson(Map<String, dynamic> json) {
    final roleMap = (json['roleDistribution'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
        {};
    return PlayerChampionModel(
      name: json['championName'] as String,
      games: json['gamesPlayed'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      iconId: json['championId'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      avgKda: (json['avgKda'] as num).toDouble(),
      avgCspm: (json['avgCspm'] as num).toDouble(),
      avgDpm: (json['avgDpm'] as num).toDouble(),
      avgGpm: (json['avgGpm'] as num).toDouble(),
      avgVisionScore: (json['avgVisionScore'] as num).toDouble(),
      avgCsd15: (json['avgCsd15'] as num).toDouble(),
      avgGd15: (json['avgGd15'] as num).toDouble(),
      avgXpd15: (json['avgXpd15'] as num).toDouble(),
      roleDistribution: roleMap,
    );
  }
}
```

**Step 3: Verify compilation**

Run: `flutter analyze`
Expected: No errors

**Step 4: Commit**
```bash
git add lib/features/player_profile/domain/entities/player_champion.dart lib/features/player_profile/data/models/player_champion_model.dart
git commit -m "feat: expand PlayerChampion entity with full backend stats"
```

---

### Task 5: Add tab switching to PlayerProfilePage

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/profile_tabs.dart`
- Modify: `lib/features/player_profile/presentation/pages/player_profile_page.dart`

**Step 1: Add onTap callback to ProfileTabs**

Update `ProfileTabs` to accept an `onTap` callback:
```dart
class ProfileTabs extends StatelessWidget {
  const ProfileTabs({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

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
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
        
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
            ),
          );
        }),
      ),
    );
  }
}
```

**Step 2: Convert _PlayerProfileView to StatefulWidget and add tab switching**

In `player_profile_page.dart`, convert `_PlayerProfileView` from `StatelessWidget` to `StatefulWidget`. Add a `_selectedTab` state variable. Swap the body `Expanded` to switch content based on `_selectedTab`:

```dart
class _PlayerProfileView extends StatefulWidget {
  const _PlayerProfileView();

  @override
  State<_PlayerProfileView> createState() => _PlayerProfileViewState();
}

class _PlayerProfileViewState extends State<_PlayerProfileView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ... back row stays the same ...
            // ... header BlocBuilder stays the same ...
            // Tabs — update to use callback
            ProfileTabs(
              selectedIndex: _selectedTab,
              onTap: (index) => setState(() => _selectedTab = index),
            ),
            // Body — switch content based on selected tab
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
          builder: (context, state) {
            if (state is OverviewLoading) return const LoadingIndicator();
            if (state is OverviewError) {
              return ErrorDisplay(message: state.message);
            }
            if (state is OverviewLoaded) {
              return OverviewContent(data: state.data);
            }
            return const SizedBox.shrink();
          },
        );
      case 1:
        return BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
          builder: (context, state) {
            if (state is OverviewLoading) return const LoadingIndicator();
            if (state is OverviewError) {
              return ErrorDisplay(message: state.message);
            }
            if (state is OverviewLoaded) {
              return ChampionsContent(champions: state.data.champions);
            }
            return const SizedBox.shrink();
          },
        );
      default:
        return const Center(
          child: Text(
            'Em breve',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        );
    }
  }
}
```

Import `ChampionsContent` at the top (will be created in Task 7).

**Step 3: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/profile_tabs.dart lib/features/player_profile/presentation/pages/player_profile_page.dart
git commit -m "feat: add tab switching to player profile page"
```

---

### Task 6: Create ExpandableChampionRow widget

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/expandable_champion_row.dart`

**Step 1: Create the widget**

This widget shows the champion header (icon, name, role, WR, games, chevron). When tapped, it expands to show detailed stats using `AnimatedCrossFade`.

```dart
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
              placeholder: (_, __) => Container(
                width: 36, height: 36, color: AppColors.bgTertiary,
              ),
              errorWidget: (_, __, ___) => Container(
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
```

**Step 2: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/expandable_champion_row.dart
git commit -m "feat: create ExpandableChampionRow widget with detailed stats"
```

---

### Task 7: Create ChampionsContent widget

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/champions_content.dart`

**Step 1: Create the widget with role filter, sort chips, and champion list**

```dart
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
            fontFamily: 'JetBrainsMono',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Add import in player_profile_page.dart**

Add to imports:
```dart
import '../widgets/champions_content.dart';
```

**Step 3: Commit**
```bash
git add lib/features/player_profile/presentation/widgets/champions_content.dart lib/features/player_profile/presentation/pages/player_profile_page.dart
git commit -m "feat: create ChampionsContent widget with filters and sorting"
```

---

### Task 8: Migrate all widgets to use theme font (remove hardcoded fontFamily)

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/general_stats_row.dart` (2 occurrences)
- Modify: `lib/features/player_profile/presentation/widgets/role_distribution_card.dart` (2 occurrences)
- Modify: `lib/features/player_profile/presentation/widgets/top_champions_card.dart` (3 occurrences)
- Modify: `lib/features/player_profile/presentation/widgets/overview_content.dart` (1 occurrence)
- Modify: `lib/features/player_profile/presentation/widgets/profile_header.dart` (6 occurrences)
- Modify: `lib/features/player_profile/presentation/widgets/profile_tabs.dart` (1 occurrence)
- Modify: `lib/features/player_profile/presentation/widgets/processing_banner.dart` (1 occurrence)
- Modify: `lib/features/player_profile/presentation/pages/player_profile_page.dart` (1 occurrence)
- Modify: `lib/features/player_search/presentation/widgets/recent_search_row.dart` (1 occurrence)
- Modify: `lib/features/player_search/presentation/pages/processing_status_page.dart` (2 occurrences)

**Step 1: Remove all `fontFamily: 'JetBrainsMono'` from TextStyles in widget files**

`AppTheme.dark` already sets `fontFamily: 'JetBrainsMono'` globally (line 10 of `app_theme.dart`), so all `TextStyle` objects inherit it automatically. Remove every `fontFamily: 'JetBrainsMono',` line from the 10 files listed above.

Do NOT modify:
- `lib/core/theme/app_theme.dart` (this is the source of truth)
- `lib/core/theme/app_typography.dart` (this defines reusable styles)

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors. Removing `fontFamily` has zero runtime impact since the theme provides it.

**Step 3: Visually verify**

Run: `flutter run --debug`
Expected: All text still renders in JetBrains Mono. No visual changes.

**Step 4: Commit**
```bash
git add -A
git commit -m "refactor: remove hardcoded fontFamily from all widgets, use theme default"
```

---

### Task 9: Clean up debug prints

**Files:**
- Modify: `lib/features/player_profile/presentation/bloc/player_profile_bloc.dart`
- Modify: `lib/features/player_profile/presentation/bloc/player_overview_bloc.dart`

**Step 1: Remove debug print statements from both BLoCs**

In `player_profile_bloc.dart`, remove (lines 40-41):
```dart
      print('DEBUG PlayerProfileBloc: erro → $e');
      print('DEBUG PlayerProfileBloc: stack → $stack');
```

In `player_overview_bloc.dart`, remove (lines 30-31):
```dart
      print('DEBUG PlayerOverviewBloc: erro → $e');
      print('DEBUG PlayerOverviewBloc: stack → $stack');
```

**Step 2: Commit**
```bash
git add lib/features/player_profile/presentation/bloc/player_profile_bloc.dart lib/features/player_profile/presentation/bloc/player_overview_bloc.dart
git commit -m "chore: remove temporary debug print statements"
```

---

### Task 10: Final verification

**Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

**Step 2: Run app and test**

Run: `flutter run --debug`

Test checklist:
- [ ] Overview tab: WR card shows value without overflow
- [ ] Overview tab: Roles show MID/JGL/BOT/SUP instead of MIDDLE/JUNGLE/etc
- [ ] Overview tab: Top Champions table has CHAMPION/G/WR% header
- [ ] Tab switching works (Overview, Champions, placeholder for others)
- [ ] Champions tab: Role filter pills filter the list
- [ ] Champions tab: Sort chips change ordering
- [ ] Champions tab: Tapping a row expands it with detailed stats
- [ ] Champions tab: Tapping an expanded row collapses it
- [ ] Champions tab: Early game stats show red for negative values, green for positive

**Step 3: Final commit**
```bash
git commit -m "feat: complete profile improvements and champions tab"
```
