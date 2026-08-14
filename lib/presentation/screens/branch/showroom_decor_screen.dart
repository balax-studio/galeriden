import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

class DecorUpgradeOption {
  final String id;
  final String title;
  final String description;
  final double cost;
  final double reputationBonus;
  final IconData icon;
  final Color color;

  const DecorUpgradeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.reputationBonus,
    required this.icon,
    required this.color,
  });
}

class ShowroomDecorScreen extends ConsumerStatefulWidget {
  const ShowroomDecorScreen({super.key});

  @override
  ConsumerState<ShowroomDecorScreen> createState() => _ShowroomDecorScreenState();
}

class _ShowroomDecorScreenState extends ConsumerState<ShowroomDecorScreen> {
  final List<DecorUpgradeOption> _decorOptions = const [
    DecorUpgradeOption(
      id: 'decor_led_grid',
      title: 'Tavan Lazer LED Aydınlatma Izgarası',
      description: 'Lüks showroom havası vererek vitrindeki araçların parlamasını sağlar.',
      cost: 25000,
      reputationBonus: 5.0,
      icon: Icons.light_mode_rounded,
      color: Colors.amber,
    ),
    DecorUpgradeOption(
      id: 'decor_granite_floor',
      title: 'İtalyan Mermer & Parlak Granit Zemin',
      description: 'Yansımalı parlak zemin döşemesi ile müşteri ikna gücünü artırır.',
      cost: 45000,
      reputationBonus: 8.0,
      icon: Icons.grid_view_rounded,
      color: Colors.cyanAccent,
    ),
    DecorUpgradeOption(
      id: 'decor_vip_lounge',
      title: 'VIP Kahve Lounge & Barista İstasyonu',
      description: 'Satış görüşmesi sırasında müşterilere özel espresso servisi alanı.',
      cost: 65000,
      reputationBonus: 12.0,
      icon: Icons.coffee_rounded,
      color: Colors.purpleAccent,
    ),
    DecorUpgradeOption(
      id: 'decor_security_cctv',
      title: 'Akıllı Güvenlik & CCTV Kamera Ağı',
      description: '7/24 gece görüşlü güvenlik kameraları ile araç sigorta maliyetini düşürür.',
      cost: 35000,
      reputationBonus: 6.0,
      icon: Icons.security_rounded,
      color: Colors.greenAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SHOWROOM DEKORASYON & MİMARİ',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            AppGlassContainer(
              padding: const EdgeInsets.all(18),
              borderColor: Colors.cyanAccent.withValues(alpha: 0.5),
              glowColor: Colors.cyanAccent.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.cyanAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lüks Galeri Mimarisi', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Galerini üst düzey mimari konseptlerle yenileyerek müşteri itibar skorunu yükselt.',
                          style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('DEKORASYON VE MİMARİ Mimariler', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _decorOptions.length,
              itemBuilder: (context, index) {
                final item = _decorOptions[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppDoubleBezelCard(
                    accentColor: item.color,
                    outerRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.icon, color: item.color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                                  Text(
                                    'İtibar Katkısı: +${item.reputationBonus.toStringAsFixed(1)} Puan',
                                    style: TextStyle(color: p.successColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(item.description, style: AppTypography.bodyMedium(p.isDark)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ücret: ₺${CurrencyFormatter.formatShort(item.cost)}',
                              style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                            ),
                            AppTactileButton(
                              onPressed: () {
                                if (game.balance < item.cost) {
                                  NotificationService.showError(context, 'Yetersiz Bakiye!');
                                  return;
                                }

                                ref.read(gameProvider.notifier).deductBalance(item.cost);
                                NotificationService.showSuccess(context, '${item.title} İnşa Edildi! Galeri İtibarı Artırıldı.');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Yenile / İnşa Et',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
