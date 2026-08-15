import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';

class CustomerReviewsScreen extends ConsumerWidget {
  const CustomerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final reviews = game.customerReviews;
    final avgRating = reviews.isEmpty
        ? 5.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'MÜŞTERİ YORUMLARI & PUAN',
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
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
                      const Text(
                        'GALERİ HARİTA PUANI',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reviews.length} Gerçek Müşteri Değerlendirmesi',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'İtibar Puanı: ${game.reputationScore} / 100',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'MÜŞTERİ GERİ BİLDİRİMLERİ',
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
            const NeoBrutalEmptyState(
              icon: Icons.rate_review_outlined,
              accentColor: AppColors.brutalYellow,
              badgeText: 'İLK YORUM BEKLENİYOR',
              title: 'Henüz Müşteri Yorumu Yok',
              description: 'Galeri vitrininden araç satışı yaptıkça ve müşterilerini memnun ettikçe dükkan puanın ve gerçekçi geri bildirimler burada birikecek.',
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                      const SizedBox(height: 2),
                      NeoBrutalBadge(
                        text: 'Satılan: ${r.carTitle}',
                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                        textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontSize: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.comment,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
}
