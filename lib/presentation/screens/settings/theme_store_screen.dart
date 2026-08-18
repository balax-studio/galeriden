import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/blueprint_grid_background.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class ThemeStoreScreen extends ConsumerWidget {
  const ThemeStoreScreen({super.key});

  Widget _buildColorDot(Color color, bool isDark, {double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 1.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette ?? themeState.activePalette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: isDark ? p.backgroundColor : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'TEMA & GÖRÜNÜM MAĞAZASI',
      ),
      body: BlueprintGridBackground(
        patternType: p.id == 'toksik_asit_cyber'
            ? BlueprintPatternType.cyberGrid
            : BlueprintPatternType.blueprintGrid,
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Balance Header
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? p.surfaceColor : Colors.white,
              borderColor: isDark ? p.surfaceBorderColor : const Color(0xFF0F172A),
              borderRadius: 14,
              showBlueprintGrid: true,
              patternType: BlueprintPatternType.dots,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TEMA MAĞAZASI BAKİYESİ',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sermayeni veya ücretsiz reklam ödüllerini kullanarak özel temaları aç.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? p.textPrimaryColor : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalBadge(
                    text: CurrencyFormatter.formatShort(game.balance),
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 12,
                    showHardShadow: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Active Theme Live Preview Box
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: p.surfaceColor,
              borderColor: p.primaryColor,
              borderWidth: 2.5,
              borderRadius: 14,
              showBlueprintGrid: true,
              patternType: p.id == 'toksik_asit_cyber'
                  ? BlueprintPatternType.cyberGrid
                  : BlueprintPatternType.blueprintGrid,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AKTİF TEMA ÖNİZLEMESİ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: p.primaryColor,
                        ),
                      ),
                      NeoBrutalBadge(
                        text: p.name.toUpperCase(),
                        backgroundColor: p.primaryColor,
                        textColor: Colors.black,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: p.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.surfaceBorderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VİTRİN KARTI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: p.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'BMW 3.20d • 2021',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: p.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: p.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.surfaceBorderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ÖNE ÇIKAN BUTON',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: p.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₺1.450.000',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: p.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Theme List Header
            const Text(
              'MEVCUT TEMA PALETLERİ',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),

            // 4. Palette Cards
            ...themeState.availablePalettes.map((palette) {
              final isActive = palette.id == themeState.activePalette.id;
              final isAbsurd = palette.id == 'toksik_asit_cyber';
              final isExotic = palette.id == 'egzotik_neo_pop';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: isActive
                      ? (isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9))
                      : (isDark ? palette.surfaceColor : Colors.white),
                  borderColor: isActive
                      ? palette.primaryColor
                      : (isDark ? palette.surfaceBorderColor : const Color(0xFF0F172A)),
                  borderWidth: isActive ? 2.5 : 1.8,
                  borderRadius: 12,
                  child: Row(
                    children: [
                      // Palette Swatch preview
                      Column(
                        children: [
                          Row(
                            children: [
                              _buildColorDot(palette.primaryColor, isDark),
                              const SizedBox(width: 4),
                              _buildColorDot(palette.secondaryColor, isDark),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildColorDot(palette.backgroundColor, isDark),
                              const SizedBox(width: 4),
                              _buildColorDot(palette.surfaceColor, isDark),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    palette.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAbsurd) ...[
                                  const SizedBox(width: 4),
                                  const NeoBrutalBadge(
                                    text: 'ABSÜRT',
                                    backgroundColor: AppColors.hotMagenta,
                                    textColor: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ],
                                if (isExotic) ...[
                                  const SizedBox(width: 4),
                                  const NeoBrutalBadge(
                                    text: 'EGZOTİK',
                                    backgroundColor: Color(0xFFFF5EAE),
                                    textColor: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              palette.price == 0
                                  ? (palette.isUnlocked ? 'Açık • Ücretsiz' : 'Reklamla Ücretsiz Açılır')
                                  : (palette.isUnlocked
                                      ? 'Satın Alındı'
                                      : (palette.isAdUnlockable
                                          ? 'Reklamla Ücretsiz veya ${CurrencyFormatter.formatShort(palette.price.toDouble())}'
                                          : 'Fiyat: ${CurrencyFormatter.formatShort(palette.price.toDouble())}')),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        const NeoBrutalBadge(
                          text: 'AKTİF',
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        )
                      else if (palette.isUnlocked)
                        NeoBrutalButton(
                          label: 'KULLAN',
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          onPressed: () {
                            ref.read(themeProvider.notifier).selectPalette(palette.id);
                          },
                        )
                      else if (palette.isAdUnlockable)
                        NeoBrutalButton(
                          label: 'REKLAMLA AÇ',
                          icon: Icons.play_circle_filled_rounded,
                          backgroundColor: isExotic ? const Color(0xFFFF5EAE) : (isAbsurd ? AppColors.hotMagenta : AppColors.brutalGreen),
                          textColor: Colors.white,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            AdService.instance.showRewardedAd(
                              onRewardEarned: () {
                                ref.read(themeProvider.notifier).unlockPaletteViaAd(palette.id);
                                NotificationService.showSuccess(
                                  context,
                                  'Reklam Ödülü: ${palette.name} Paleti Başarıyla Açıldı ve Aktif Edildi!',
                                );
                              },
                            );
                          },
                        )
                      else
                        NeoBrutalButton(
                          label: 'SATIN AL',
                          backgroundColor: AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          onPressed: () {
                            final success =
                                ref.read(themeProvider.notifier).unlockPalette(palette.id, game.balance);
                            if (success) {
                              ref.read(gameProvider.notifier).deductBalance(palette.price.toDouble());
                              NotificationService.showSuccess(
                                  context, '${palette.name} Paleti Açıldı ve Aktif Edildi!');
                            } else {
                              NotificationService.showError(context, 'Yetersiz Sermaye!');
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
      ),
    );
  }
}
