import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class BranchScreen extends ConsumerWidget {
  const BranchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);
    final branches = BranchModel.getAllBranches(
      currentSlotCount: game.maxGarageSlots,
      currentLevel: game.level,
      unlockedBuildings: game.unlockedBuildings,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'ŞUBE & PLAZA BÜYÜTME',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Current Branch Status Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MEVCUT GALERİ MERKEZİ',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  game.dealershipName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('Kapasite', '${game.maxGarageSlots} Araç Slotu', isDark),
                    _buildInfoColumn('Galeri Seviyesi', 'Seviye ${game.level}', isDark),
                    _buildInfoColumn('Sermaye', CurrencyFormatter.formatShort(game.balance), isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Showroom Decor Navigation Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.palette_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Showroom Mimari & Dekorasyon',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'LED tavan ızgarası, İtalyan mermer & VIP Salonu',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: game.isFeatureUnlocked('/showroom-decor') ? 'YENİLE' : 'KİLİTLİ',
                  backgroundColor: game.isFeatureUnlocked('/showroom-decor')
                      ? const Color(0xFF06B6D4)
                      : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                  textColor: game.isFeatureUnlocked('/showroom-decor') ? Colors.black : Colors.white70,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () {
                    if (game.isFeatureUnlocked('/showroom-decor')) {
                      context.push('/showroom-decor');
                    } else {
                      final reqLvl = DealershipModel.getRequiredLevel('/showroom-decor');
                      final reqBranch = DealershipModel.getRequiredBranchName('/showroom-decor');
                      NotificationService.showInfo(
                        context,
                        'Showroom dekorasyonu Seviye $reqLvl ($reqBranch) gerektirir.',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'GALERİ ŞUBE KADEMELERİ & KAPASİTE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Branches List
          ...branches.map((b) {
            final isCurrent = game.maxGarageSlots == b.maxGarageSlots;
            final isLevelUnlocked = game.level >= b.targetLevel;
            final canAfford = game.balance >= b.requiredBalance;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isCurrent ? AppColors.brutalYellow : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderWidth: isCurrent ? 2.5 : 2.0,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isCurrent || b.isUnlocked) ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Icon(_getBranchIcon(b.vectorIcon), color: Colors.black, size: 22),
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.name,
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      b.locationName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          const NeoBrutalBadge(
                            text: 'MEVCUT ŞUBE',
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else
                          NeoBrutalBadge(
                            text: 'SEVİYE ${b.targetLevel}',
                            backgroundColor: isLevelUnlocked ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                            textColor: Colors.white,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '• Kapasite: ${b.maxGarageSlots} Slot',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '• Sabit Gider: ${CurrencyFormatter.formatShort(b.dailyBurnRate)}/gün',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                          ),
                        ),
                        Text(
                          '• Kâr: ${b.profitMultiplier}x',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(isLevelUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded, size: 14, color: isLevelUnlocked ? AppColors.brutalGreen : const Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Açılanlar: ${b.unlockedSummary}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCurrent && !b.isUnlocked) ...[
                      const SizedBox(height: 12),
                      NeoBrutalButton(
                        label: !isLevelUnlocked
                            ? 'SEVİYE ${b.targetLevel} GEREKLİ (XP KAZAN)'
                            : (canAfford
                                ? 'MÜLKÜ SATIN AL (${CurrencyFormatter.formatShort(b.requiredBalance)})'
                                : 'YETERSİZ BAKİYE (${CurrencyFormatter.formatShort(b.requiredBalance)})'),
                        backgroundColor: !isLevelUnlocked
                            ? (isDark ? const Color(0xFF1A1F2C) : const Color(0xFFCBD5E1))
                            : (canAfford ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))),
                        textColor: isLevelUnlocked && canAfford ? Colors.black : const Color(0xFF64748B),
                        fontSize: 11.5,
                        fullWidth: true,
                        onPressed: (isLevelUnlocked && canAfford)
                            ? () {
                                 final success = ref.read(gameProvider.notifier).upgradeBranch(b);
                                 if (success) {
                                   showDialog(
                                     context: context,
                                     builder: (ctx) => Dialog(
                                       backgroundColor: Colors.transparent,
                                       insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                                       child: NeoBrutalCard(
                                         padding: const EdgeInsets.all(20),
                                         backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                                         borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                      borderRadius: 12,
                                      borderWidth: 2.5,
                                      shadowOffset: const Offset(4, 4),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.brutalYellow,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                                width: 2.0,
                                              ),
                                            ),
                                            child: const Icon(Icons.stars_rounded, size: 40, color: Colors.black),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text('TEBRİKLER! ŞUBE AÇILDI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Galeri Seviyeniz Seviye ${b.targetLevel} oldu! Yeni özellikler ve ${b.maxGarageSlots} araç slotu kullanıma açıldı.',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 16),
                                          NeoBrutalButton(
                                            label: 'HARİKA!',
                                            fullWidth: true,
                                            backgroundColor: AppColors.brutalYellow,
                                            textColor: Colors.black,
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                               }
                             }
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  IconData _getBranchIcon(String vectorIcon) {
    switch (vectorIcon) {
      case 'craftsman':
        return Icons.storefront_rounded;
      case 'car_wash':
        return Icons.local_car_wash_rounded;
      case 'workshop':
        return Icons.build_circle_rounded;
      case 'tuning':
        return Icons.tune_rounded;
      case 'auction':
        return Icons.gavel_rounded;
      case 'shield':
        return Icons.account_balance_rounded;
      case 'fleet':
        return Icons.car_rental_rounded;
      case 'rare':
        return Icons.domain_rounded;
      default:
        return Icons.apartment_rounded;
    }
  }
}
