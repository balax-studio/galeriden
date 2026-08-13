import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';

class SideBusinessScreen extends ConsumerWidget {
  const SideBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'YAN İŞLETMELER',
          style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: game.sideBusinesses.length,
        itemBuilder: (context, index) {
          final business = game.sideBusinesses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.storefront_rounded, color: p.primaryColor),
                          const SizedBox(width: 8),
                          Text(business.name, style: AppTypography.titleLarge(p.isDark)),
                        ],
                      ),
                      if (business.isOwned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.successColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.successColor),
                          ),
                          child: Text('Lvl ${business.level}', style: TextStyle(color: p.successColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(business.description, style: AppTypography.bodyMedium(p.isDark)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Günlük Gelir', style: AppTypography.labelSmall(p.isDark)),
                          Text(
                            '₺${CurrencyFormatter.formatShort(business.dailyIncome)}',
                            style: AppTypography.titleLarge(p.isDark).copyWith(color: p.successColor),
                          ),
                        ],
                      ),
                      if (!business.isOwned)
                        ElevatedButton.icon(
                          onPressed: () {
                            final success = ref.read(gameProvider.notifier).buySideBusiness(business.id);
                            if (success) {
                              NotificationService.showSuccess(context, '${business.name} satın alındı!');
                            } else {
                              NotificationService.showError(context, 'Yetersiz bakiye!');
                            }
                          },
                          icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                          label: Text('Satın Al: ₺${CurrencyFormatter.formatShort(business.cost)}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            final success = ref.read(gameProvider.notifier).upgradeSideBusiness(business.id);
                            if (success) {
                              NotificationService.showSuccess(context, '${business.name} yükseltildi!');
                            } else {
                              NotificationService.showError(context, 'Yetersiz bakiye!');
                            }
                          },
                          icon: const Icon(Icons.upgrade_rounded, size: 16),
                          label: Text('Yükselt: ₺${CurrencyFormatter.formatShort(business.cost * 0.5 * business.level)}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.secondaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
