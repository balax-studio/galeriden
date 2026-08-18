import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/smart_office_hook_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_app_bar.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

import 'dashboard_quick_finance_card.dart';

class DashboardOfficeView extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardOfficeView({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final smartHook = SmartOfficeHookEngine.evaluate(game);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'OFİS VE YÖNETİM',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Reputation Block
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayi İtibarı & Puanı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Müşteri memnuniyet skoru: %${game.reputationScore}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Financial Summary Card
          DashboardQuickFinanceCard(game: game, palette: palette),
          const SizedBox(height: 14),

          // ==========================================
          // 3. STORY-DRIVEN REWARDED AD BONUS CARDS
          // ==========================================
          // Card A: Gurbetçi Hikmet Dayı Zarf Fonu (+₺25.000)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF191D2B) : const Color(0xFFFEFCE8),
            borderColor: const Color(0xFFEAB308),
            borderWidth: 2.4,
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    NeoBrutalBadge(
                      text: 'GURBETÇİ DAYI FONU',
                      backgroundColor: Color(0xFFEAB308),
                      textColor: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                    NeoBrutalBadge(
                      text: '+₺25.000 HİBE',
                      icon: Icons.play_circle_filled_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF242A3D) : const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFFEAB308) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const AvatarIconWidget(
                        avatar: 'deal',
                        color: Color(0xFFEAB308),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hikmet Dayı\'dan Zarf İçinde Avans',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '"Yeğenim sanayide adını duyduk, piyasayı kasıp kavuruyorsun! Şu sarı zarfı al, dükkanın çorbası kaynasın, vitrine can suyu olsun!"',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: NeoBrutalButton(
                    label: 'ZARFI AÇ • +₺25.000 NAKİT AL',
                    icon: Icons.play_circle_filled_rounded,
                    backgroundColor: const Color(0xFFEAB308),
                    textColor: Colors.black,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      AdService.instance.showRewardedAd(
                        onRewardEarned: () {
                          ref.read(gameProvider.notifier).claimOfficeAdGrant();
                          NotificationService.showSuccess(
                            context,
                            'Hikmet Dayı\'nın Zarfı Açıldı! Kasaya +₺25.000 Nakit Eklendi!',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Card B: Dynamic Smart Hook tailored to player deficiency
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF161A26) : const Color(0xFFF0FDF4),
            borderColor: smartHook.accentColor,
            borderWidth: 2.4,
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NeoBrutalBadge(
                      text: 'DİNAMİK FIRSAT',
                      backgroundColor: smartHook.accentColor,
                      textColor: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                    NeoBrutalBadge(
                      text: smartHook.rewardBadgeText,
                      backgroundColor: isDark ? const Color(0xFF232B3E) : Colors.white,
                      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      borderColor: smartHook.accentColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22293A) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: smartHook.accentColor,
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AvatarIconWidget(
                        avatar: smartHook.characterAvatar,
                        color: smartHook.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                smartHook.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${smartHook.callerName} • ${smartHook.callerRole}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: smartHook.accentColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            smartHook.storyDialogue,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ödül: ${smartHook.rewardDescription}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: NeoBrutalButton(
                    label: smartHook.actionButtonLabel,
                    icon: Icons.play_circle_filled_rounded,
                    backgroundColor: smartHook.accentColor,
                    textColor: Colors.white,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      AdService.instance.showRewardedAd(
                        onRewardEarned: () {
                          ref.read(gameProvider.notifier).executeSmartOfficeHook(smartHook.type);
                          NotificationService.showSuccess(
                            context,
                            '${smartHook.title}: ${smartHook.rewardBadgeText} Başarıyla Uygulandı!',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Management Sections Header
          const Text(
            'YÖNETİM VE OPERASYONLAR',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          // Staff Management
          _buildOfficeItem(
            context: context,
            icon: Icons.people_alt_rounded,
            color: const Color(0xFFA855F7),
            title: 'Personel Kadrosu',
            subtitle: game.isFeatureUnlocked('/staff')
                ? '${game.hiredStaff.length} Aktif Usta / Danışman'
                : '${DealershipModel.getRequiredBranchName('/staff')} ile Açılır',
            actionLabel: game.isFeatureUnlocked('/staff') ? 'Yönet' : 'KİLİTLİ',
            route: '/staff',
            isUnlocked: game.isFeatureUnlocked('/staff'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Customer Reviews
          _buildOfficeItem(
            context: context,
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFFFFDE59),
            title: 'Müşteri Yorumları',
            subtitle: game.isFeatureUnlocked('/reviews')
                ? '${game.customerReviews.length} Toplam Değerlendirme'
                : '${DealershipModel.getRequiredBranchName('/reviews')} ile Açılır',
            actionLabel: game.isFeatureUnlocked('/reviews') ? 'İncele' : 'KİLİTLİ',
            route: '/reviews',
            isUnlocked: game.isFeatureUnlocked('/reviews'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Sales History
          _buildOfficeItem(
            context: context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF3B82F6),
            title: 'Satış & İşlem Geçmişi',
            subtitle: game.isFeatureUnlocked('/history')
                ? '${game.salesHistory.length} Tamamlanan Satış Defteri'
                : '${DealershipModel.getRequiredBranchName('/history')} ile Açılır',
            actionLabel: game.isFeatureUnlocked('/history') ? 'Görüntüle' : 'KİLİTLİ',
            route: '/history',
            isUnlocked: game.isFeatureUnlocked('/history'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Character Growth
          _buildOfficeItem(
            context: context,
            icon: Icons.bolt_rounded,
            color: const Color(0xFF00E575),
            title: 'Yetenek Ağacı & Başarımlar',
            subtitle: 'Seviye ${game.level} • Yetenek Puanlarını Yönet',
            actionLabel: 'Geliştir',
            route: '/character-growth',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Theme Store
          _buildOfficeItem(
            context: context,
            icon: Icons.palette_rounded,
            color: const Color(0xFFFF54B0),
            title: 'Tema Mağazası',
            subtitle: 'Görsel paletleri ve stilleri özelleştir',
            actionLabel: 'Mağaza',
            route: '/theme-store',
            isUnlocked: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required String route,
    required bool isUnlocked,
    required bool isDark,
  }) {
    final activeColor = isUnlocked ? color : const Color(0xFF64748B);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isUnlocked
          ? (isDark ? const Color(0xFF141721) : Colors.white)
          : (isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0)),
      borderColor: isUnlocked
          ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
          : (isDark ? const Color(0xFF202636) : const Color(0xFF94A3B8)),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? icon : Icons.lock_outline_rounded,
                    size: 20,
                    color: isUnlocked ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? Colors.white60 : const Color(0xFF475569)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                              : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: actionLabel,
            backgroundColor: activeColor,
            textColor: isUnlocked ? Colors.black : Colors.white,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: () {
              if (isUnlocked) {
                context.push(route);
              } else {
                NotificationService.showInfo(
                  context,
                  'Kilitli Alan! Bu özellik ${DealershipModel.getRequiredBranchName(route)} satın alındığında açılır. Şubeler ekranından inceleyebilirsin.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
