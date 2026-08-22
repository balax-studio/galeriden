import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class CustomerReviewsScreen extends ConsumerWidget {
  const CustomerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/reviews')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('reviews_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/reviews',
          featureTitle: context.tr('reviews_screen_title'),
          icon: Icons.reviews_rounded,
        ),
      );
    }

    final reviews = game.customerReviews;
    final avgRating = reviews.isEmpty
        ? 5.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('reviews_screen_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Rating Header Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < avgRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                color: Colors.black,
                                size: 14,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('reviews_map_rating'),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('reviews_count_label', {'count': '${reviews.length}'}),
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('reviews_reputation_label', {'rep': '${game.reputationScore}'}),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bot / PR Review Purchase Action with Algorithmic Cost Scaling
                NeoBrutalButton(
                  label: context.tr('reviews_pr_bot_btn', {'cost': CurrencyFormatter.format(game.botReviewCost.toDouble())}),
                  icon: Icons.campaign_rounded,
                  backgroundColor: AppColors.brutalCyan,
                  textColor: Colors.black,
                  fullWidth: true,
                  onPressed: () {
                    final currentCost = game.botReviewCost.toDouble();
                    final success = ref.read(gameProvider.notifier).buyBotReview();
                    if (success) {
                      final botCount = game.botReviewCount;
                      final repGain = botCount < 3 ? 5 : (botCount < 6 ? 3 : 1);
                      NotificationService.showSuccess(context, 'Sosyal medya ajansı 5 yıldızlı pozitif yorum yayınladı! • +$repGain İtibar');
                    } else {
                      NotificationService.showError(context, 'Bakiye yetersiz! • Gereken: ${CurrencyFormatter.format(currentCost)}');
                    }
                  },
                ),
                if (game.botReviewCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('reviews_bot_count_info', {'count': '${game.botReviewCount}'}),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            context.tr('reviews_feedback_header'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Reviews List
          if (reviews.isEmpty)
            NeoBrutalEmptyState(
              icon: Icons.rate_review_outlined,
              accentColor: AppColors.brutalYellow,
              badgeText: context.tr('reviews_empty_badge'),
              title: context.tr('reviews_empty_title'),
              description: context.tr('reviews_empty_desc'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            )
          else
            ...reviews.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r.reviewerName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          Row(
                            children: [
                              if (r.isCompensated) ...[
                                NeoBrutalBadge(
                                  text: context.tr('reviews_compensated_badge'),
                                  backgroundColor: AppColors.brutalGreen,
                                  textColor: Colors.black,
                                  fontSize: 9,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < r.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: AppColors.brutalYellow,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      NeoBrutalBadge(
                        text: context.tr('reviews_sold_car_badge', {'car': r.carTitle}),
                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                        textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontSize: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.comment,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (r.reply != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brutalYellow.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.reply_rounded, size: 16, color: AppColors.brutalYellow),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('reviews_reply_prefix', {'reply': r.reply ?? ''}),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (r.reply == null)
                            Expanded(
                              child: NeoBrutalButton(
                                label: context.tr('reviews_reply_btn'),
                                icon: Icons.reply_rounded,
                                backgroundColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                                textColor: isDark ? Colors.white : Colors.black,
                                onPressed: () => _showReplyDialog(context, ref, r.id),
                              ),
                            ),
                          if (r.reply == null && r.rating <= 2 && !r.isCompensated) const SizedBox(width: 8),
                          if (r.rating <= 2 && !r.isCompensated)
                            Expanded(
                              child: NeoBrutalButton(
                                label: context.tr('reviews_compensate_btn', {'cost': CurrencyFormatter.format(GameConstants.customerCompensationCost)}),
                                icon: Icons.card_giftcard_rounded,
                                backgroundColor: AppColors.brutalOrange,
                                textColor: Colors.white,
                                onPressed: () {
                                  final success = ref.read(gameProvider.notifier).compensateCustomerReview(r.id);
                                  if (success) {
                                    NotificationService.showSuccess(context, 'Müşteriye ikram gönderildi, puan 4 yıldıza güncellendi! • +3 İtibar');
                                  } else {
                                    NotificationService.showError(context, 'Bakiye yetersiz! • Gereken: ${CurrencyFormatter.format(GameConstants.customerCompensationCost)}');
                                  }
                                },
                              ),
                            ),
                        ],
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

  void _showReplyDialog(BuildContext context, WidgetRef ref, String reviewId) {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderWidth: 2.5,
          borderRadius: 14,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.reply_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MÜŞTERİ YORUMUNA CEVAP VER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                maxLines: 3,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Nazik ve kurumsal bir yanıt yazın...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.brutalYellow : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: 'İPTAL',
                      backgroundColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeoBrutalButton(
                      label: 'YAYINLA',
                      icon: Icons.send_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          ref.read(gameProvider.notifier).replyToCustomerReview(reviewId, textController.text.trim());
                          Navigator.pop(ctx);
                          NotificationService.showSuccess(context, 'Cevabınız yayınlandı! • +1 İtibar');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((_) => textController.dispose());
  }
}
