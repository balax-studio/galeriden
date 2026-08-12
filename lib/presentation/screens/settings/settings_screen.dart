import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AYARLAR VE BİLGİLER'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Koyu Tema (Dark Mode)', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                  subtitle: const Text('Quiet Luxury 2026 Derin Siyah Paleti'),
                  value: isDark,
                  activeTrackColor: AppColors.primaryAmber,
                  onChanged: (_) {
                    ref.read(settingsProvider.notifier).toggleThemeMode();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('Ses Efektleri', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                  subtitle: const Text('Motor ve buton tıklama sesleri'),
                  value: settings.isAudioEnabled,
                  activeTrackColor: AppColors.primaryAmber,
                  onChanged: (_) {
                    ref.read(settingsProvider.notifier).toggleAudio();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Dil Seçeneği', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                  subtitle: Text(settings.languageCode == 'tr' ? 'Türkçe (TR)' : 'English (EN)'),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    items: const [
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(settingsProvider.notifier).setLanguage(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Optional Rewarded Ad Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.primaryAmber),
                      const SizedBox(width: 8),
                      Text('ÖDÜLLÜ VİDEO İZLE (OPSİYONEL)', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Oyunda zorunlu reklam yoktur. İstediğin zaman video izleyerek galeri sermayene ₺25.000 destek ekleyebilirsin.', style: AppTypography.bodyMedium(isDark)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Text('Ödüllü Video İzle (₺25.000 Ödül)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        foregroundColor: AppColors.backgroundDark,
                      ),
                      onPressed: () {
                        ref.read(gameProvider.notifier).claimAdReward(25000.0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tebrikler! ₺25.000 galeri desteği sermayene eklendi.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Danger Zone Reset Button
          Card(
            child: ListTile(
              title: const Text('Tüm İlerlemeyi Sıfırla', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
              subtitle: const Text('Oyunu başlangıç durumuna (₺50.000 sermaye) döndürür.'),
              trailing: const Icon(Icons.delete_forever, color: AppColors.errorRed),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sıfırlama Onayı'),
                    content: const Text('Tüm garajınız ve birikiminiz sıfırlanacaktır. Emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
                      TextButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).resetGame();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Sıfırla', style: TextStyle(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              '${GameConstants.appName} v${GameConstants.appVersion}\nClean Architecture + Riverpod + Hive',
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
