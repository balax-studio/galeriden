import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color color;
  final String route;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.color,
    required this.route,
  });
}

class DashboardServicesGrid extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardServicesGrid({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final marketListings = ref.watch(marketProvider);
    final pendingOrdersCount = game.pendingOrders.length;

    // Full Service Modules List ordered by progression level
    final allServices = [
      // Level 1: Core Dealership
      _ServiceItem(
        icon: Icons.directions_car_filled_rounded,
        title: 'Araç Satın Al',
        subtitle: 'İkinci El Pazar',
        badge: '${marketListings.length} İlan',
        color: const Color(0xFF3B82F6),
        route: '/marketplace',
      ),
      _ServiceItem(
        icon: Icons.storefront_rounded,
        title: 'Showroom & Galerim',
        subtitle: 'Stoktaki Araçlar',
        badge: '${game.ownedCars.length}/${game.maxGarageSlots} Araç',
        color: const Color(0xFFFFDE59),
        route: '/showroom',
      ),
      _ServiceItem(
        icon: Icons.local_car_wash_rounded,
        title: 'Oto Yıkama',
        subtitle: 'Detailing & Parlatma',
        color: const Color(0xFF00F0FF),
        route: '/car-wash',
      ),

      // Level 2: Workshop & Staff (Oto Galericiler Sitesi Dükkânı)
      _ServiceItem(
        icon: Icons.build_circle_rounded,
        title: 'Tamir & Atölye',
        subtitle: 'Onarım & Servis',
        badge: pendingOrdersCount > 0 ? '$pendingOrdersCount Sipariş' : null,
        color: const Color(0xFFFF7A00),
        route: '/workshop',
      ),
      _ServiceItem(
        icon: Icons.speed_rounded,
        title: 'Tuning Stüdyosu',
        subtitle: 'Performans & Modifiye',
        color: const Color(0xFFA855F7),
        route: '/tuning-studio',
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        title: 'Personel Kadrosu',
        subtitle: '${game.hiredStaff.length} Personel',
        color: const Color(0xFFEC4899),
        route: '/staff',
      ),
      _ServiceItem(
        icon: Icons.history_edu_rounded,
        title: 'Satış Raporları',
        subtitle: 'İşlem Geçmişi',
        color: const Color(0xFF14B8A6),
        route: '/history',
      ),

      // Level 3: Investment, Auction & Finance (Maslak Otomotiv Plazası)
      _ServiceItem(
        icon: Icons.gavel_rounded,
        title: 'Canlı İhale',
        subtitle: 'Kelepir Teklifler',
        badge: 'CANLI',
        color: const Color(0xFFEF4444),
        route: '/auction',
      ),
      _ServiceItem(
        icon: Icons.account_balance_rounded,
        title: 'Finans & Banka',
        subtitle: 'Krediler & Mevduat',
        color: const Color(0xFF00E575),
        route: '/finance',
      ),
      _ServiceItem(
        icon: Icons.trending_up_rounded,
        title: 'Borsa & Yatırım',
        subtitle: 'Hisseler & Fonlar',
        color: const Color(0xFF6366F1),
        route: '/stock-market',
      ),
      _ServiceItem(
        icon: Icons.reviews_rounded,
        title: 'Müşteri Yorumları',
        subtitle: '${game.reputationScore} İtibar',
        color: const Color(0xFFF59E0B),
        route: '/reviews',
      ),
      _ServiceItem(
        icon: Icons.palette_rounded,
        title: 'Showroom Mimari',
        subtitle: 'Lüks Dekorasyon',
        color: const Color(0xFF06B6D4),
        route: '/showroom-decor',
      ),

      // Level 4+: Empire Expansion (Etiler & Bodrum Lüks Motor World)
      _ServiceItem(
        icon: Icons.delete_outline_rounded,
        title: 'Hurdalık & Parça',
        subtitle: 'Çıkma Yedek Parça',
        color: const Color(0xFF64748B),
        route: '/scrapyard',
      ),
      _ServiceItem(
        icon: Icons.car_rental_rounded,
        title: 'Rent-a-Car',
        subtitle: 'Günlük Kiralama',
        color: const Color(0xFF38BDF8),
        route: '/rent-a-car',
      ),
      _ServiceItem(
        icon: Icons.masks_rounded,
        title: 'Karaborsa',
        subtitle: 'Gizli Kelepirler',
        color: const Color(0xFFDC2626),
        route: '/black-market',
      ),
      _ServiceItem(
        icon: Icons.apartment_rounded,
        title: 'Şube Yönetimi',
        subtitle: 'Plaza & Mülkler',
        color: const Color(0xFF8B5CF6),
        route: '/branches',
      ),
      _ServiceItem(
        icon: Icons.business_center_rounded,
        title: 'Yan İşletmeler',
        subtitle: 'Pasif Gelirler',
        color: const Color(0xFF10B981),
        route: '/side-businesses',
      ),
    ];

    // Progressive Disclosure: Unlocked items + NEXT single locked preview item
    final unlockedItems = allServices.where((s) => game.isFeatureUnlocked(s.route)).toList();
    final nextLockedItem = allServices.where((s) => !game.isFeatureUnlocked(s.route)).firstOrNull;

    final displayItems = List<_ServiceItem>.from(unlockedItems);
    if (nextLockedItem != null) {
      displayItems.add(nextLockedItem);
    }

    // Build Dynamic 2-Column Span-2 Rows
    final List<Widget> gridRows = [];
    for (int i = 0; i < displayItems.length; i += 2) {
      if (i + 1 < displayItems.length) {
        // Symmetric Pair Row (1fr - 1fr)
        gridRows.add(
          Row(
            children: [
              Expanded(child: _buildServiceCard(context, game, palette, isDark, displayItems[i])),
              const SizedBox(width: 10),
              Expanded(child: _buildServiceCard(context, game, palette, isDark, displayItems[i + 1])),
            ],
          ),
        );
      } else {
        // Odd trailing item -> Dynamic Span-2 Full-Width Banner
        gridRows.add(
          _buildSpan2ServiceCard(context, game, palette, isDark, displayItems[i]),
        );
      }
      if (i + 2 < displayItems.length) {
        gridRows.add(const SizedBox(height: 10));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: gridRows,
    );
  }

  /// Standard 1-Slot Service Card
  Widget _buildServiceCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
    _ServiceItem item,
  ) {
    final isUnlocked = game.isFeatureUnlocked(item.route);
    final reqLevel = DealershipModel.getRequiredLevel(item.route);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 96),
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: isUnlocked
            ? (isDark ? const Color(0xFF141721) : Colors.white)
            : (isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0)),
        borderColor: isUnlocked
            ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
            : (isDark ? const Color(0xFF202636) : const Color(0xFF94A3B8)),
        borderRadius: 12,
        onTap: () {
          if (isUnlocked) {
            context.push(item.route);
          } else {
            NotificationService.showInfo(
              context,
              'Kilitli Alan! Bu özellik ${DealershipModel.getRequiredBranchName(item.route)} satın alındığında açılır. Şubeler ekranından inceleyebilirsin.',
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isUnlocked ? item.color : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? item.icon : Icons.lock_outline_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                if (!isUnlocked)
                  NeoBrutalBadge(
                    text: 'Sev. $reqLevel',
                    icon: Icons.lock_outline_rounded,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                    borderColor: isDark ? const Color(0xFF475569) : const Color(0xFF64748B),
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  )
                else if (item.badge != null)
                  NeoBrutalBadge(
                    text: item.badge!,
                    backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.2),
                    textColor: isDark ? item.color : const Color(0xFF0F172A),
                    borderColor: item.color,
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  isUnlocked ? item.subtitle : 'Seviye $reqLevel Mülkü Gerekli',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamic Span-2 Full-Width Service Card
  Widget _buildSpan2ServiceCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
    _ServiceItem item,
  ) {
    final isUnlocked = game.isFeatureUnlocked(item.route);
    final reqLevel = DealershipModel.getRequiredLevel(item.route);

    return SizedBox(
      height: 72,
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: isUnlocked
            ? (isDark ? const Color(0xFF141721) : Colors.white)
            : (isDark ? const Color(0xFF121526) : const Color(0xFFEEF2F6)),
        borderColor: isUnlocked
            ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
            : (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5)),
        borderWidth: isUnlocked ? 2.0 : 2.2,
        borderRadius: 12,
        onTap: () {
          if (isUnlocked) {
            context.push(item.route);
          } else {
            NotificationService.showInfo(
              context,
              'Kilitli Önizleme: Bu özellik ${DealershipModel.getRequiredBranchName(item.route)} satın alındığında açılır.',
            );
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUnlocked ? item.color : const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                  width: 1.4,
                ),
              ),
              child: Icon(
                isUnlocked ? item.icon : Icons.lock_outline_rounded,
                size: 20,
                color: isUnlocked ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked
                                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(width: 8),
                        const NeoBrutalBadge(
                          text: 'SIRADAKİ HEDEF',
                          backgroundColor: Color(0xFF6366F1),
                          textColor: Colors.white,
                          fontSize: 9,
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnlocked
                        ? item.subtitle
                        : 'Seviye $reqLevel Şubesi (Ofis/Mülk) ile Otomatik Açılır',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                          : (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isUnlocked && item.badge != null)
              NeoBrutalBadge(
                text: item.badge!,
                backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.2),
                textColor: isDark ? item.color : const Color(0xFF0F172A),
                borderColor: item.color,
                fontSize: 10,
              )
            else if (!isUnlocked)
              NeoBrutalButton(
                label: 'ŞUBELER',
                fontSize: 10.5,
                backgroundColor: const Color(0xFF6366F1),
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () => context.push('/branches'),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }
}
