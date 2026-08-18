import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                          'Sermayeni kullanarak özel tema paletlerinin kilidini aç.',
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: p.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Canlı renk uyumu test ediliyor',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeoBrutalButton(
                        label: 'TEST ET',
                        appliedLabel: 'TEST EDİLDİ',
                        icon: Icons.touch_app_rounded,
                        backgroundColor: p.secondaryColor,
                        textColor: Colors.white,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          NotificationService.showSuccess(
                            context,
                            '${p.name} buton stili ve dokunsal geri bildirimi test edildi! 🎨',
                          );
                        },
                      ),
                    ],
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
                color: isDark ? p.textPrimaryColor : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Palettes List
            ...themeState.availablePalettes.map((palette) {
              final isActive = themeState.activePalette.id == palette.id;
              final isAbsurd = palette.id == 'toksik_asit_cyber';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? (isActive ? p.surfaceColor : const Color(0xFF141721)) : Colors.white,
                  borderColor: isActive
                      ? (isAbsurd ? AppColors.toxicLime : AppColors.brutalYellow)
                      : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
                  borderWidth: isActive ? 2.5 : 2.0,
                  borderRadius: 14,
                  showBlueprintGrid: isAbsurd,
                  patternType: BlueprintPatternType.cyberGrid,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          _buildColorDot(palette.primaryColor, isDark),
                          const SizedBox(width: 4),
                          _buildColorDot(palette.secondaryColor, isDark),
                          const SizedBox(width: 4),
                          _buildColorDot(palette.backgroundColor, isDark),
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
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              palette.price == 0
                                  ? 'Ücretsiz Varsayılan'
                                  : (palette.isUnlocked
                                      ? 'Satın Alındı'
                                      : 'Fiyat: ${CurrencyFormatter.formatShort(palette.price.toDouble())}'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      NeoBrutalButton(
                        label: isActive ? 'AKTİF' : (palette.isUnlocked ? 'KULLAN' : 'SATIN AL'),
                        backgroundColor: isActive
                            ? (isAbsurd ? AppColors.toxicLime : AppColors.brutalYellow)
                            : (palette.isUnlocked
                                ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                                : (isAbsurd ? AppColors.hotMagenta : AppColors.brutalGreen)),
                        textColor: isActive
                            ? Colors.black
                            : (palette.isUnlocked ? (isDark ? Colors.white : Colors.black) : (isAbsurd ? Colors.white : Colors.black)),
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        onPressed: isActive
                            ? null
                            : () {
                                if (palette.isUnlocked) {
                                  ref.read(themeProvider.notifier).selectPalette(palette.id);
                                } else {
                                  final success =
                                      ref.read(themeProvider.notifier).unlockPalette(palette.id, game.balance);
                                  if (success) {
                                    ref.read(gameProvider.notifier).deductBalance(palette.price.toDouble());
                                    NotificationService.showSuccess(
                                        context, '${palette.name} Paleti Açıldı ve Aktif Edildi!');
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
      ),
    );
  }
}
