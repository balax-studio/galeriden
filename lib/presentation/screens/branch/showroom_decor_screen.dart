import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

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
      description: 'Lüks showroom atmosferi vererek vitrindeki araçların parlamasını sağlar.',
      cost: 25000,
      reputationBonus: 5.0,
      icon: Icons.light_mode_rounded,
      color: AppColors.brutalYellow,
    ),
    DecorUpgradeOption(
      id: 'decor_granite_floor',
      title: 'İtalyan Mermer & Parlak Granit Zemin',
      description: 'Yansımalı parlak zemin döşemesi ile müşteri ikna gücünü artırır.',
      cost: 45000,
      reputationBonus: 8.0,
      icon: Icons.grid_view_rounded,
      color: Color(0xFF06B6D4),
    ),
    DecorUpgradeOption(
      id: 'decor_vip_lounge',
      title: 'VIP Kahve Lounge & Barista İstasyonu',
      description: 'Satış görüşmesi sırasında müşterilere özel espresso servisi alanı.',
      cost: 65000,
      reputationBonus: 12.0,
      icon: Icons.coffee_rounded,
      color: Color(0xFFA855F7),
    ),
    DecorUpgradeOption(
      id: 'decor_security_cctv',
      title: 'Akıllı Güvenlik & CCTV Kamera Ağı',
      description: '7/24 gece görüşlü güvenlik kameraları ile araç sigorta maliyetini düşürür.',
      cost: 35000,
      reputationBonus: 6.0,
      icon: Icons.security_rounded,
      color: AppColors.brutalGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'SHOWROOM DEKORASYON & MİMARİ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Header Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LÜKS GALERİ MİMARİSİ',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Showroomu üst düzey mimari konseptlerle yenileyerek itibarını ve müşteri ilgisini artır.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'MİMARİ GELİŞTİRME SEÇENEKLERİ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Options List
          ..._decorOptions.map((item) {
            final isPurchased = game.unlockedDecorIds.contains(item.id);
            final canAfford = game.balance >= item.cost;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isPurchased
                    ? AppColors.brutalGreen
                    : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isPurchased ? AppColors.brutalGreen : item.color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                ),
                                child: Icon(
                                  isPurchased ? Icons.check_circle_rounded : item.icon,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPurchased)
                          const NeoBrutalBadge(
                            text: 'AKTİF',
                            icon: Icons.check_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else
                          NeoBrutalBadge(
                            text: '+${item.reputationBonus.toStringAsFixed(1)} İtibar',
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPurchased ? 'İNŞA EDİLDİ' : CurrencyFormatter.formatShort(item.cost),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isPurchased ? const Color(0xFF64748B) : AppColors.brutalGreen,
                          ),
                        ),
                        NeoBrutalButton(
                          label: isPurchased
                              ? 'İNŞA EDİLDİ'
                              : (canAfford ? 'İNŞA ET' : 'YETERSİZ BAKİYE'),
                          icon: isPurchased
                              ? Icons.check_circle_rounded
                              : (canAfford ? Icons.architecture_rounded : Icons.lock_rounded),
                          backgroundColor: isPurchased
                              ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                              : (canAfford ? item.color : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))),
                          textColor: isPurchased
                              ? (isDark ? Colors.white54 : Colors.black54)
                              : (canAfford ? Colors.black : const Color(0xFF64748B)),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          onPressed: isPurchased
                              ? null
                              : () {
                                  if (!canAfford) {
                                    NotificationService.showError(context, 'Yetersiz Bakiye!');
                                    return;
                                  }

                                  final success = ref.read(gameProvider.notifier).purchaseShowroomDecor(
                                        decorId: item.id,
                                        cost: item.cost,
                                        reputationBonus: item.reputationBonus,
                                      );

                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      '${item.title} İnşa Edildi! Galeri İtibarı Artırıldı.',
                                    );
                                  } else {
                                    NotificationService.showError(context, 'Bu geliştirme zaten yapılmış veya yetersiz bakiye!');
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
