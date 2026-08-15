import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class ThemeStoreScreen extends ConsumerWidget {
  const ThemeStoreScreen({super.key});

  Widget _buildColorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'TEMA & GÖRÜNÜM MAĞAZASI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Balance Header
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEMA MAĞAZASI BAKİYESİ',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sermayeni kullanarak özel tema paletlerinin kilidini aç.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: CurrencyFormatter.formatShort(game.balance),
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'MEVCUT TEMA PALETLERİ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Palettes List
          ...themeState.availablePalettes.map((palette) {
            final isActive = themeState.activePalette.id == palette.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isActive ? AppColors.brutalYellow : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderWidth: isActive ? 2.5 : 1.5,
                borderRadius: 14,
                child: Row(
                  children: [
                    Row(
                      children: [
                        _buildColorDot(palette.primaryColor),
                        const SizedBox(width: 4),
                        _buildColorDot(palette.secondaryColor),
                        const SizedBox(width: 4),
                        _buildColorDot(palette.backgroundColor),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            palette.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            palette.price == 0
                                ? 'Ücretsiz Varsayılan'
                                : (palette.isUnlocked ? 'Satın Alındı' : 'Fiyat: ${CurrencyFormatter.formatShort(palette.price.toDouble())}'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    NeoBrutalButton(
                      label: isActive ? 'AKTİF' : (palette.isUnlocked ? 'KULLAN' : 'SATIN AL'),
                      backgroundColor: isActive
                          ? AppColors.brutalYellow
                          : (palette.isUnlocked ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)) : AppColors.brutalGreen),
                      textColor: isActive ? Colors.black : (palette.isUnlocked ? (isDark ? Colors.white : Colors.black) : Colors.black),
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      onPressed: isActive
                          ? null
                          : () {
                              if (palette.isUnlocked) {
                                ref.read(themeProvider.notifier).selectPalette(palette.id);
                              } else {
                                final success = ref.read(themeProvider.notifier).unlockPalette(palette.id, game.balance);
                                if (success) {
                                  ref.read(gameProvider.notifier).deductBalance(palette.price.toDouble());
                                  NotificationService.showSuccess(context, '${palette.name} Paleti Açıldı ve Aktif Edildi!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz Sermaye!');
                                }
                              }
                            },
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
