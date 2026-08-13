import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_vector_icons.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AYARLAR VE BİLGİLER'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Dealership Identity Customization Card
          Card(
            child: ListTile(
              leading: VectorIconWidget(type: game.logoEmblemId, color: p.primaryColor, size: 26),
              title: Text('GALERİ VE PROFİL KİMLİĞİ', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
              subtitle: Text('${game.dealershipName} (${game.playerName})', style: AppTypography.labelSmall(p.isDark)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 22),
              onTap: () => context.push('/dealership-identity'),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Store Entry Button
          Card(
            child: ListTile(
              leading: VectorIconWidget(type: 'theme_store', color: p.primaryColor, size: 26),
              title: Text('TEMA VE GÖRÜNÜM MAĞAZASI', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
              subtitle: Text('Aktif Tema: ${p.name}', style: AppTypography.labelSmall(p.isDark)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 22),
              onTap: () => context.push('/theme-store'),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Ses Efektleri', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                  subtitle: const Text('Motor ve buton tıklama sesleri'),
                  value: settings.isAudioEnabled,
                  activeTrackColor: p.primaryColor,
                  onChanged: (_) {
                    ref.read(settingsProvider.notifier).toggleAudio();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Dil Seçeneği', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                  subtitle: Text(settings.languageCode == 'tr' ? 'Türkçe (TR)' : 'English (EN)'),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    dropdownColor: p.surfaceColor,
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
                      VectorIconWidget(type: 'streak', color: p.primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text('ÖDÜLLÜ VİDEO İZLE (OPSİYONEL)', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Oyunda zorunlu reklam yoktur. İstediğin zaman video izleyerek galeri sermayene ₺25.000 destek ekleyebilirsin.', style: AppTypography.bodyMedium(p.isDark)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Text('Ödüllü Video İzle (₺25.000 Ödül)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
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
              title: Text('Tüm İlerlemeyi Sıfırla', style: TextStyle(color: p.errorColor, fontWeight: FontWeight.bold)),
              subtitle: const Text('Oyunu başlangıç durumuna (₺50.000 sermaye) döndürür.'),
              trailing: Icon(Icons.delete_forever, color: p.errorColor),
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
                        child: Text('Sıfırla', style: TextStyle(color: p.errorColor)),
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
              '${GameConstants.appName} v${GameConstants.appVersion}\nClean Architecture + Riverpod + Dynamic Theme Engine',
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall(p.isDark),
            ),
          ),
        ],
      ),
    );
  }
}
