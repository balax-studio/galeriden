import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/dealership_model.dart';

class DashboardGameTimeCard extends StatelessWidget {
  final DealershipModel game;

  const DashboardGameTimeCard({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final pendingInTransit = game.pendingOrders.where((o) => !o.isInstalled).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/history'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.surfaceBorderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded, color: p.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OYUN TAKVİMİ — GÜN ${game.currentDay}',
                      style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pendingInTransit.isEmpty
                          ? 'Teslimat bekleyen parça yok — Atölye hazır.'
                          : '${pendingInTransit.length} Parça Kargoda / İşlemde (${pendingInTransit.first.remainingSeconds}s Kalan)',
                      style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.primaryColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
