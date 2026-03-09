import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/overview_data.dart';
import 'general_stats_row.dart';
import 'role_distribution_card.dart';
import 'top_champions_card.dart';

class OverviewContent extends StatelessWidget {
  const OverviewContent({super.key, required this.data});

  final OverviewData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Gerais
          _sectionLabel('STATS GERAIS'),
          const SizedBox(height: 8),
          GeneralStatsRow(summary: data.summary),
          const SizedBox(height: 16),
          // Role Distribution
          _sectionLabel('DISTRIBUICAO DE ROLES'),
          const SizedBox(height: 8),
          RoleDistributionCard(roles: data.roles),
          const SizedBox(height: 16),
          // Top Champions
          _sectionLabel('TOP CHAMPIONS'),
          const SizedBox(height: 8),
          TopChampionsCard(champions: data.champions),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 2,
      ),
    );
  }
}
