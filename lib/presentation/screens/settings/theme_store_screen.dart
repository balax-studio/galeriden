import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../providers/theme_provider.dart';

class ThemeStoreScreen extends ConsumerWidget {
  const ThemeStoreScreen({super.key});

  Widget _buildColorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final game = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEMA VE GÖRÜNÜM MAĞAZASI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galeri sermayeni kullanarak özel tema paletlerinin kilidini açabilirsin.',
              style: AppTypography.bodyMedium(p.isDark),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mevcut Sermaye:', style: AppTypography.labelSmall(p.isDark)),
                Text(CurrencyFormatter.formatShort(game.balance), style: AppTypography.moneyMedium(p.isDark)),
              ],
            ),
            const SizedBox(height: 20),

            // Palettes List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: themeState.availablePalettes.length,
              itemBuilder: (context, index) {
                final palette = themeState.availablePalettes[index];
                final isActive = themeState.activePalette.id == palette.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? palette.primaryColor : palette.surfaceBorderColor,
                      width: isActive ? 2.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Palette Color Circles Preview
                      Row(
                        children: [
                          _buildColorDot(palette.primaryColor),
                          const SizedBox(width: 4),
                          _buildColorDot(palette.secondaryColor),
                          const SizedBox(width: 4),
                          _buildColorDot(palette.backgroundColor),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(palette.name, style: TextStyle(color: palette.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              palette.price == 0
                                  ? 'Ücretsiz'
                                  : (palette.isUnlocked ? 'Satın Alındı' : 'Fiyat: ${CurrencyFormatter.formatShort(palette.price.toDouble())}'),
                              style: TextStyle(color: palette.textSecondaryColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? palette.primaryColor
                              : (palette.isUnlocked ? palette.surfaceBorderColor : palette.primaryColor),
                          foregroundColor: isActive ? Colors.black : Colors.white,
                        ),
                        onPressed: isActive
                            ? null
                            : () {
                                if (palette.isUnlocked) {
                                  ref.read(themeProvider.notifier).selectPalette(palette.id);
                                } else {
                                  final success = ref.read(themeProvider.notifier).unlockPalette(palette.id, game.balance);
                                  if (success) {
                                    ref.read(gameProvider.notifier).deductBalance(palette.price.toDouble());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${palette.name} Paleti Açıldı ve Aktif Edildi!')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Yetersiz Sermaye!')),
                                    );
                                  }
                                }
                              },
                        child: Text(isActive ? 'Aktif' : (palette.isUnlocked ? 'Kullan' : 'Satın Al')),
                      ),
                    ],
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
