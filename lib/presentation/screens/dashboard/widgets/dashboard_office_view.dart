import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/ad_reward_calculator.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
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
          // Card A: Dynamic Daily Grant / Zarf Fonu
          Builder(
            builder: (context) {
              final dailyGrant = SmartOfficeHookEngine.getDailyGrantVariant(game);
              final isGrantUsed = game.isOfficeGrantClaimedToday;
              final garageTotal = game.ownedCars.fold<double>(0.0, (sum, c) => sum + c.baseMarketValue);
              final outcome = AdRewardCalculator.calculateDynamicReward(
                playerLevel: game.level,
                totalGarageValue: garageTotal,
              );

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF191D2B) : const Color(0xFFFEFCE8),
                borderColor: isGrantUsed ? const Color(0xFF475569) : const Color(0xFFEAB308),
                borderWidth: 2.4,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalBadge(
                          text: dailyGrant.badgeText,
                          backgroundColor: isGrantUsed ? const Color(0xFF475569) : const Color(0xFFEAB308),
                          textColor: isGrantUsed ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        if (isGrantUsed)
                          const NeoBrutalBadge(
                            text: 'KULLANILDI',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: Color(0xFF334155),
                            textColor: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          )
                        else
                          NeoBrutalBadge(
                            text: '+${CurrencyFormatter.formatShort(outcome.moneyAmount)} HİBE',
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
                              color: isGrantUsed
                                  ? const Color(0xFF475569)
                                  : (isDark ? const Color(0xFFEAB308) : const Color(0xFF0F172A)),
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: 'deal',
                            color: isGrantUsed ? const Color(0xFF64748B) : const Color(0xFFEAB308),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dailyGrant.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isGrantUsed
                                      ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dailyGrant.callerRole,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isGrantUsed ? const Color(0xFF64748B) : const Color(0xFFEAB308),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isGrantUsed
                                    ? '"Bugünkü hibe desteğini teslim aldın esnafım. Yarın sabah taze zarfla tekrar uğra!"'
                                    : dailyGrant.dialogue,
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
                      child: isGrantUsed
                          ? const NeoBrutalButton(
                              label: 'KULLANILDI • YARIN YENİLENİR',
                              icon: Icons.check_rounded,
                              backgroundColor: Color(0xFF222838),
                              textColor: Color(0xFF64748B),
                              fontSize: 11.5,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              onPressed: null,
                            )
                          : NeoBrutalButton(
                              label: 'ZARFI AÇ • +${CurrencyFormatter.formatShort(outcome.moneyAmount)} NAKİT AL',
                              icon: Icons.play_circle_filled_rounded,
                              backgroundColor: const Color(0xFFEAB308),
                              textColor: Colors.black,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                AdService.instance.showRewardedAdWithFallback(
                                  context: context,
                                  customRewardTitle: outcome.title,
                                  outcome: outcome,
                                  onRewardEarned: () {
                                    ref.read(gameProvider.notifier).claimOfficeAdGrant(outcome.moneyAmount);
                                    NotificationService.showSuccess(
                                      context,
                                      '${dailyGrant.callerName} Desteği Alındı! Kasaya +${CurrencyFormatter.format(outcome.moneyAmount)} Eklendi!',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Card B: Dynamic Smart Hook tailored to player deficiency
          Builder(
            builder: (context) {
              final isHookUsed = game.isSmartHookClaimedToday;

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF161A26) : const Color(0xFFF0FDF4),
                borderColor: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
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
                          backgroundColor: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
                          textColor: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        if (isHookUsed)
                          const NeoBrutalBadge(
                            text: 'KULLANILDI',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: Color(0xFF334155),
                            textColor: Color(0xFF94A3B8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          )
                        else
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
                              color: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: smartHook.characterAvatar,
                            color: isHookUsed ? const Color(0xFF64748B) : smartHook.accentColor,
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
                                      color: isHookUsed
                                          ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${smartHook.callerName} • ${smartHook.callerRole}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isHookUsed ? const Color(0xFF64748B) : smartHook.accentColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isHookUsed
                                    ? '"Bugünkü fırsatı değerlendirdin. Sanayide yeni bir haber çıktığında sana ilk ben haber vereceğim!"'
                                    : smartHook.storyDialogue,
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
                      child: isHookUsed
                          ? const NeoBrutalButton(
                              label: 'KULLANILDI • YENİ FIRSAT BEKLENİYOR',
                              icon: Icons.check_rounded,
                              backgroundColor: Color(0xFF222838),
                              textColor: Color(0xFF64748B),
                              fontSize: 11.5,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              onPressed: null,
                            )
                          : NeoBrutalButton(
                              label: smartHook.actionButtonLabel,
                              icon: Icons.play_circle_filled_rounded,
                              backgroundColor: smartHook.accentColor,
                              textColor: Colors.white,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                AdService.instance.showRewardedAdWithFallback(
                                  context: context,
                                  customRewardTitle: smartHook.rewardBadgeText,
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
              );
            },
          ),
          const SizedBox(height: 14),

          // Card C: Esnaf Dedikoduları & Piyasa Fısıltıları
          Builder(
            builder: (context) {
              final gossipList = SmartOfficeHookEngine.getOfficeGossipAndTips(game);

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141824) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
                borderWidth: 2.2,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const NeoBrutalBadge(
                          text: 'SANAYİ FISILTILARI',
                          backgroundColor: Color(0xFF38BDF8),
                          textColor: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        Text(
                          'Gün ${game.currentDay}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...gossipList.map((gossip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A3347) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  gossip.icon,
                                  color: const Color(0xFF38BDF8),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          gossip.sourceName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          gossip.title,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF38BDF8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      gossip.content,
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
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
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

          // Special License Plates (Emniyet & Noter Tescil)
          _buildOfficeItem(
            context: context,
            icon: Icons.confirmation_number_rounded,
            color: const Color(0xFFFFDE59),
            title: 'Özel Plaka Tescil Masası',
            subtitle: 'Efsanevi, Takım ve Özel Plaka Satın Al • Araca Ata',
            actionLabel: 'Tescil',
            route: '/special-plates',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Media & Influencer PR Agency Desk
          _buildOfficeItem(
            context: context,
            icon: Icons.campaign_rounded,
            color: const Color(0xFF38BDF8),
            title: 'Medya & PR Ajansı Masası',
            subtitle: game.activePrCampaign != null && game.activePrCampaign!.isActive(game.currentDay)
                ? 'Aktif Lansman Sürüyor • ${game.activePrCampaign!.remainingDays(game.currentDay)} Gün Kaldı'
                : 'Oto YouTuber & TV Reklam Kampanyası Başlat',
            actionLabel: 'Lansman',
            route: '/media-agency',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Lifestyle & Wardrobe Desk
          _buildOfficeItem(
            context: context,
            icon: Icons.dry_cleaning_rounded,
            color: const Color(0xFFEAB308),
            title: 'Kişisel Tarz & Prestij Masası',
            subtitle: 'İtalyan Takım Elbise, Altın Saat, Kehribar Tesbih & Makam',
            actionLabel: 'Gardırop',
            route: '/lifestyle',
            isUnlocked: true,
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
