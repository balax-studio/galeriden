import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';

class CustomerReviewsScreen extends ConsumerWidget {
  const CustomerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    final reviews = game.customerReviews;
    final avgRating = reviews.isEmpty
        ? 5.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MÜŞTERİ YORUMLARI & YILDIZ PUANI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Header Card
            AppGlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTypography.moneyLarge(p.isDark).copyWith(fontSize: 36, color: p.primaryColor),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < avgRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HARİTA VE HARİCİ GALERİ PUANI', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 4),
                        Text(
                          '${reviews.length} Gerçek Müşteri Değerlendirmesi',
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Galeri İtibar Puanı: ${game.reputationScore} / 100',
                          style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('GELEN MÜŞTERİ YORUMLARI', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            reviews.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Henüz müşteri yorumu yok. İlk araç satışını yaptığında alıcılar buraya değerlendirme bırakacak!',
                      style: AppTypography.bodyMedium(p.isDark),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.surfaceBorderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.reviewerName,
                                  style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15),
                                ),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < r.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Satılan Araç: ${r.carTitle}', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor)),
                            const SizedBox(height: 8),
                            Text(r.comment, style: AppTypography.bodyMedium(p.isDark)),
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
