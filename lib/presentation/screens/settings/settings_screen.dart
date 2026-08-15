import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'AYARLAR & PROFİL',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Dealership Identity
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: InkWell(
              onTap: () => context.push('/dealership-identity'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.badge_rounded, color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GALERİ & PROFİL KİMLİĞİ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.dealershipName} (${game.playerName})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Theme Store
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: InkWell(
              onTap: () => context.push('/theme-store'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.palette_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TEMA & GÖRÜNÜM MAĞAZASI',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Aktif Tema: ${p.name}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Audio & Language Settings
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ses Efektleri',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Motor ve buton sesleri',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.isAudioEnabled,
                      activeTrackColor: AppColors.brutalYellow,
                      onChanged: (_) => ref.read(settingsProvider.notifier).toggleAudio(),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dil Seçeneği',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Arayüz dili',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: settings.languageCode == 'tr' ? 'Türkçe (TR)' : 'English (EN)',
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      fontSize: 11,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Rewarded Support Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SPONSOR DESTEK FONU (OPSİYONEL)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Oyunda zorunlu reklam yoktur. Destek olmak istediğinde video izleyerek kasana ₺25.000 hibe alabilirsin.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: 'VİDEO İZLE (+₺25.000 KAZAN)',
                  icon: Icons.play_circle_fill_rounded,
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 12,
                  fullWidth: true,
                  onPressed: () {
                    AdService.instance.showRewardedAd(
                      onRewardEarned: () {
                        ref.read(gameProvider.notifier).claimAdReward(25000.0);
                        NotificationService.showSuccess(context, 'Tebrikler! ₺25.000 sponsor ödülü kasanıza eklendi.');
                      },
                      onAdUnavailable: () {
                        NotificationService.showWarning(context, 'Reklam henüz hazır değil, lütfen birkaç saniye sonra tekrar deneyin.');
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Developer / Cheats Card (Only in debug mode)
          if (kDebugMode) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF1B182B) : const Color(0xFFF5F3FF),
              borderColor: const Color(0xFF8B5CF6),
              borderWidth: 2.2,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFF8B5CF6), size: 20),
                          SizedBox(width: 6),
                          Text(
                            'GELİŞTİRİCİ PANELİ (GOD MODE)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: 'DEV TEST',
                        backgroundColor: const Color(0xFF8B5CF6),
                        textColor: Colors.white,
                        fontSize: 9.5,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hızlı mekanik doğrulaması ve tüm mülk/modül testleri için tek tıkla sermaye ve seviye hilesi uygula.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: '+₺100.000.000',
                          icon: Icons.attach_money_rounded,
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref.read(gameProvider.notifier).addCheatFunds(100000000.0);
                            NotificationService.showSuccess(context, '₺100.000.000 Hile Sermayesi Eklendi!');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: 'SEVİYE 4 & FULL AÇ',
                          icon: Icons.workspace_premium_rounded,
                          backgroundColor: const Color(0xFF8B5CF6),
                          textColor: Colors.white,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref.read(gameProvider.notifier).unlockAllPropertiesAndMaxLevel();
                            NotificationService.showSuccess(context, 'Seviye 4 (Mega Otomotiv Kalesi) ve Tüm Özellikler Açıldı!');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: 'GARAJI TEMİZLE (BOŞALT)',
                    icon: Icons.cleaning_services_rounded,
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                    fontSize: 10.5,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () {
                      ref.read(gameProvider.notifier).clearGarage();
                      NotificationService.showInfo(context, 'Garaj temizlendi.');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 6. Dynasty & Season Reset (Prestige Miras Döngüsü §2.7)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF161F30) : const Color(0xFFFAF5FF),
            borderColor: const Color(0xFFA855F7),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SEZON DEVİR & KUŞAK MİRASI',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFA855F7)),
                    ),
                    NeoBrutalBadge(
                      text: '${game.dynastyGeneration}. KUŞAK',
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Galeri bayrağını sonraki nesle devreder. Koleksiyon vitrinine kilitlediğin yadigâr araçlar (${game.ownedCars.where((c) => c.isLockedInShowcase).length} adet) ve unvan mirası sonraki kuşağa aynen aktarılır.',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                if (game.dynastyHistoryLog.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1118) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SOY VE MİRAS GEÇMİŞİ:', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        ...game.dynastyHistoryLog.reversed.take(3).map((log) => Text('• $log', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: 'GALERİYİ YENİ NESLE DEVRET (DEVİR)',
                  icon: Icons.auto_awesome_rounded,
                  backgroundColor: (game.level >= 5 || game.balance >= 1000000) ? const Color(0xFFA855F7) : const Color(0xFF64748B),
                  textColor: Colors.white,
                  fontSize: 11.5,
                  fullWidth: true,
                  onPressed: (game.level >= 5 || game.balance >= 1000000)
                      ? () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: NeoBrutalCard(
                                padding: const EdgeInsets.all(20),
                                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                                borderColor: const Color(0xFFA855F7),
                                borderRadius: 16,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFA855F7), size: 44),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'KUŞAK DEVİR ONAYI',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Mevcut ${game.dynastyGeneration}. Kuşak galeriniz tamamlanacak. Vitrindeki yadigâr araçlarınız korunarak ${game.dynastyGeneration + 1}. Kuşak olarak yeni köken ve prestijle başlayacaksınız. Devam edilsin mi?',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: NeoBrutalButton(
                                            label: 'VAZGEÇ',
                                            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                            textColor: isDark ? Colors.white : Colors.black,
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: NeoBrutalButton(
                                            label: 'DEVRET',
                                            backgroundColor: const Color(0xFFA855F7),
                                            textColor: Colors.white,
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ref.read(gameProvider.notifier).performDynastySeasonReset();
                                              NotificationService.showSuccess(context, 'Tebrikler! ${game.dynastyGeneration + 1}. Kuşak Miras Galeri dönemi başladı.');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      : () {
                          NotificationService.showWarning(context, 'Kuşak Devri için Seviye 5 veya ₺1.000.000 sermaye gereklidir.');
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 7. Reset Game
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İLERLEMEYİ SIFIRLA',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.errorRed),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Oyunu başlangıç durumuna (₺50.000 başlangıç sermayesi) sıfırlar.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: 'TÜM OYUNU SIFIRLA',
                  icon: Icons.delete_forever_rounded,
                  backgroundColor: AppColors.errorRed,
                  textColor: Colors.white,
                  fontSize: 11.5,
                  fullWidth: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(20),
                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: AppColors.errorRed,
                          borderRadius: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed, size: 40),
                              const SizedBox(height: 12),
                              const Text(
                                'SIFIRLAMA ONAYI',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tüm garajınız ve birikiminiz sıfırlanacaktır. Emin misiniz?',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: 'VAZGEÇ',
                                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                      textColor: isDark ? Colors.white : Colors.black,
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: 'SIFIRLA',
                                      backgroundColor: AppColors.errorRed,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ref.read(gameProvider.notifier).resetGame();
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              '${GameConstants.appName} v${GameConstants.appVersion}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
