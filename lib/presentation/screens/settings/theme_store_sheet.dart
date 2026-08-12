import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../providers/theme_provider.dart';

class ThemeStoreSheet extends ConsumerWidget {
  const ThemeStoreSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final game = ref.watch(gameProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TEMA VE GÖRÜNÜM MAĞAZASI', style: AppTypography.titleLarge(p.isDark)),
              IconButton(
                icon: Icon(Icons.close, color: p.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
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
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
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
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: palette.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Aktif', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      else if (palette.isUnlocked)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            ref.read(themeProvider.notifier).selectPalette(palette.id);
                          },
                          child: const Text('Kullan'),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: game.balance < palette.price
                              ? null
                              : () {
                                  final success = ref.read(themeProvider.notifier).unlockPalette(palette.id, game.balance);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${palette.name} teması satın alındı ve aktifleştirildi!')),
                                    );
                                  }
                                },
                          child: const Text('Satın Al'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
    );
  }
}
