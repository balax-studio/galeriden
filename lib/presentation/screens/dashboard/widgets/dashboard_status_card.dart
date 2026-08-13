import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../widgets/app_animated_counter.dart';
import '../../../widgets/app_glass_container.dart';
import '../../../widgets/app_vector_icons.dart';

class DashboardStatusCard extends StatelessWidget {
  final DealershipModel game;

  const DashboardStatusCard({
    super.key,
    required this.game,
  });

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall(isDark)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return AppGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Hoş Geldin, ${game.playerName}!',
                  style: AppTypography.labelSmall(p.isDark).copyWith(
                    fontWeight: FontWeight.bold,
                    color: p.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VectorIconWidget(type: game.logoEmblemId, color: p.primaryColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    game.dealershipName,
                    style: AppTypography.labelSmall(p.isDark).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'MEVCUT SERMAYE',
            style: AppTypography.labelSmall(p.isDark),
          ),
          const SizedBox(height: 8),
          AppAnimatedCounter(
            value: game.balance,
            style: AppTypography.moneyLarge(p.isDark),
          ),
          const SizedBox(height: 20),
          Divider(color: p.surfaceBorderColor, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  'Garaj Kapasitesi',
                  '${game.ownedCars.length} / ${game.maxGarageSlots}',
                  p.isDark,
                ),
              ),
              Expanded(
                child: _buildStat(
                  'Toplam Kâr',
                  CurrencyFormatter.formatShort(game.totalProfit),
                  p.isDark,
                ),
              ),
              Expanded(
                child: _buildStat(
                  'Satılan Araç',
                  '${game.carsSold} Adet',
                  p.isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
