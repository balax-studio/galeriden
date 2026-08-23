import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
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

class DashboardServicesGrid extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardServicesGrid({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardServicesGridContent(
      game: game,
      palette: palette,
    );
  }
}

class _DashboardServicesGridContent extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const _DashboardServicesGridContent({
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final pendingOrdersCount = game.pendingOrders.length;

    // Full Service Modules List ordered by progression level
    final allServices = [
      // Level 1: Core Dealership & Marketplace
      _ServiceItem(
        icon: Icons.directions_car_rounded,
        title: context.tr('service_showroom'),
        subtitle: context.tr('service_showroom_sub'),
        badge: game.incomingOffers.isNotEmpty ? '${game.incomingOffers.length}' : null,
        color: const Color(0xFFFFDE59),
        route: '/showroom',
      ),
      _ServiceItem(
        icon: Icons.storefront_rounded,
        title: context.tr('service_buy_car'),
        subtitle: context.tr('service_buy_car_sub'),
        color: const Color(0xFF38BDF8),
        route: '/marketplace',
      ),
      _ServiceItem(
        icon: Icons.local_car_wash_rounded,
        title: context.tr('service_car_wash'),
        subtitle: context.tr('service_car_wash_sub'),
        color: const Color(0xFF00F0FF),
        route: '/car-wash',
      ),

      // Level 2: Workshop & Staff (Oto Galericiler Sitesi Dükkânı)
      _ServiceItem(
        icon: Icons.build_circle_rounded,
        title: context.tr('service_workshop'),
        subtitle: context.tr('service_workshop_sub'),
        badge: pendingOrdersCount > 0 ? '$pendingOrdersCount' : null,
        color: const Color(0xFFFF7A00),
        route: '/workshop',
      ),
      _ServiceItem(
        icon: Icons.speed_rounded,
        title: context.tr('service_tuning'),
        subtitle: context.tr('service_tuning_sub'),
        color: const Color(0xFFA855F7),
        route: '/tuning-studio',
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        title: context.tr('service_staff'),
        subtitle: context.tr('service_staff_sub', {'count': game.hiredStaff.length}),
        color: const Color(0xFFEC4899),
        route: '/staff',
      ),
      _ServiceItem(
        icon: Icons.history_edu_rounded,
        title: context.tr('service_history'),
        subtitle: context.tr('service_history_sub'),
        color: const Color(0xFF14B8A6),
        route: '/history',
      ),

      // Level 3: Investment, Auction & Finance (Maslak Otomotiv Plazası)
      _ServiceItem(
        icon: Icons.gavel_rounded,
        title: context.tr('service_auction'),
        subtitle: context.tr('service_auction_sub'),
        badge: context.tr('weather_live_impact'),
        color: const Color(0xFFEF4444),
        route: '/auction',
      ),
      _ServiceItem(
        icon: Icons.account_balance_rounded,
        title: context.tr('service_finance'),
        subtitle: context.tr('service_finance_sub'),
        color: const Color(0xFF00E575),
        route: '/finance',
      ),
      _ServiceItem(
        icon: Icons.trending_up_rounded,
        title: context.tr('service_stocks'),
        subtitle: context.tr('service_stocks_sub'),
        color: const Color(0xFF6366F1),
        route: '/stock-market',
      ),
      _ServiceItem(
        icon: Icons.reviews_rounded,
        title: context.tr('service_reviews'),
        subtitle: context.tr('service_reviews_sub', {'rep': game.reputationScore}),
        color: const Color(0xFFF59E0B),
        route: '/reviews',
      ),
      _ServiceItem(
        icon: Icons.palette_rounded,
        title: context.tr('service_decor'),
        subtitle: context.tr('service_decor_sub'),
        color: const Color(0xFF06B6D4),
        route: '/showroom-decor',
      ),

      // Level 4+: Empire Expansion (Etiler & Bodrum Lüks Motor World)
      _ServiceItem(
        icon: Icons.delete_outline_rounded,
        title: context.tr('service_scrapyard'),
        subtitle: context.tr('service_scrapyard_sub'),
        color: const Color(0xFF64748B),
        route: '/scrapyard',
      ),
      _ServiceItem(
        icon: Icons.car_rental_rounded,
        title: context.tr('service_rent_car'),
        subtitle: context.tr('service_rent_car_sub'),
        color: const Color(0xFF38BDF8),
        route: '/rent-a-car',
      ),
      _ServiceItem(
        icon: Icons.masks_rounded,
        title: context.tr('service_black_market'),
        subtitle: context.tr('service_black_market_sub'),
        color: const Color(0xFFDC2626),
        route: '/black-market',
      ),
      _ServiceItem(
        icon: Icons.apartment_rounded,
        title: context.tr('service_branches'),
        subtitle: context.tr('service_branches_sub'),
        color: const Color(0xFF8B5CF6),
        route: '/branches',
      ),
      _ServiceItem(
        icon: Icons.business_center_rounded,
        title: context.tr('service_side_biz'),
        subtitle: context.tr('service_side_biz_sub'),
        color: const Color(0xFF10B981),
        route: '/side-businesses',
      ),
      _ServiceItem(
        icon: Icons.map_rounded,
        title: context.tr('service_district'),
        subtitle: context.tr('service_district_sub'),
        color: const Color(0xFF38BDF8),
        route: '/districts',
      ),
      _ServiceItem(
        icon: Icons.record_voice_over_rounded,
        title: context.tr('service_gossip'),
        subtitle: context.tr('service_gossip_sub'),
        badge: game.activeGossips.isNotEmpty ? '${game.activeGossips.length}' : null,
        color: const Color(0xFFFFDE59),
        route: '/gossip',
      ),
      _ServiceItem(
        icon: Icons.handshake_rounded,
        title: context.tr('service_consignment'),
        subtitle: context.tr('service_consignment_sub'),
        badge: game.consignmentOffers.isNotEmpty ? '${game.consignmentOffers.length}' : null,
        color: const Color(0xFF00E575),
        route: '/consignment',
      ),
      _ServiceItem(
        icon: Icons.sports_score_rounded,
        title: context.tr('service_night_market'),
        subtitle: context.tr('service_night_market_sub'),
        color: const Color(0xFFF43F5E),
        route: '/night-market',
      ),
      _ServiceItem(
        icon: Icons.casino_rounded,
        title: context.tr('service_casino'),
        subtitle: context.tr('service_casino_sub'),
        badge: 'VIP',
        color: const Color(0xFFFFDE59),
        route: '/casino',
      ),
    ];

    // Progressive Disclosure: Unlocked items in grid + Dynamic Motivating Target Banner below
    final unlockedItems = allServices.where((s) => game.isFeatureUnlocked(s.route)).toList();
    final lockedItems = allServices.where((s) => !game.isFeatureUnlocked(s.route)).toList();

    // Build Dynamic 2-Column Grid for Unlocked Services
    final List<Widget> gridRows = [];
    for (int i = 0; i < unlockedItems.length; i += 2) {
      if (i + 1 < unlockedItems.length) {
        // Symmetric Pair Row (1fr - 1fr)
        gridRows.add(
          Row(
            children: [
              Expanded(child: _buildServiceCard(context, game, palette, isDark, unlockedItems[i])),
              const SizedBox(width: 10),
              Expanded(child: _buildServiceCard(context, game, palette, isDark, unlockedItems[i + 1])),
            ],
          ),
        );
      } else {
        // Odd trailing unlocked item -> Dynamic Span-2 Full-Width Card
        gridRows.add(
          _buildSpan2ServiceCard(context, game, palette, isDark, unlockedItems[i]),
        );
      }
      if (i + 2 < unlockedItems.length) {
        gridRows.add(const SizedBox(height: 10));
      }
    }

    // If there are locked items, append the Heartbeat & Dynamic Rotating Target Banner
    if (lockedItems.isNotEmpty) {
      if (gridRows.isNotEmpty) {
        gridRows.add(const SizedBox(height: 10));
      }
      gridRows.add(
        _DynamicNextTargetBanner(
          lockedItems: lockedItems,
          game: game,
          palette: palette,
          isDark: isDark,
        ),
      );
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
                if (item.badge != null)
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  item.subtitle,
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

  /// Dynamic Span-2 Full-Width Unlocked Service Card
  Widget _buildSpan2ServiceCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
    _ServiceItem item,
  ) {
    return SizedBox(
      height: 72,
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
        borderWidth: 2.0,
        borderRadius: 12,
        onTap: () {
          context.push(item.route);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                  width: 1.4,
                ),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.badge != null)
              NeoBrutalBadge(
                text: item.badge!,
                backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.2),
                textColor: isDark ? item.color : const Color(0xFF0F172A),
                borderColor: item.color,
                fontSize: 10,
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

/// Dynamic Heartbeat & Rotating Next Target Banner
class _DynamicNextTargetBanner extends StatefulWidget {
  final List<_ServiceItem> lockedItems;
  final DealershipModel game;
  final ThemePaletteModel palette;
  final bool isDark;

  const _DynamicNextTargetBanner({
    required this.lockedItems,
    required this.game,
    required this.palette,
    required this.isDark,
  });

  @override
  State<_DynamicNextTargetBanner> createState() => _DynamicNextTargetBannerState();
}

class _DynamicNextTargetBannerState extends State<_DynamicNextTargetBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Gentle Heartbeat Pulse & Glow Animation Loop (2.2s Cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Double-beat Cardiac Pulse Tween Sequence (lub-dub rhythm)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 0.98).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.08).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50,
      ),
    ]).animate(_pulseController);

    // Glowing Neon Border & Badge Shimmer
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.35, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.35).chain(CurveTween(curve: Curves.easeIn)),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.35),
        weight: 50,
      ),
    ]).animate(_pulseController);

    // Auto-advance rotating targets every 4.5 seconds
    _startAutoRotation();
  }

  void _startAutoRotation() {
    _timer?.cancel();
    if (widget.lockedItems.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.lockedItems.length;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _DynamicNextTargetBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lockedItems.length != oldWidget.lockedItems.length) {
      if (_currentIndex >= widget.lockedItems.length) {
        _currentIndex = 0;
      }
      _startAutoRotation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextTargetManually() {
    HapticFeedback.selectionClick();
    if (widget.lockedItems.length > 1) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.lockedItems.length;
      });
      _startAutoRotation(); // Reset timer so it doesn't flip immediately
    }
  }

  String _getMotivationalBenefit(BuildContext context, String route, int reqLevel) {
    switch (route) {
      case '/car-wash':
        return context.tr('benefit_car_wash');
      case '/workshop':
        return context.tr('benefit_workshop');
      case '/tuning-studio':
        return context.tr('benefit_tuning');
      case '/staff':
        return context.tr('benefit_staff');
      case '/history':
        return context.tr('benefit_history');
      case '/auction':
        return context.tr('benefit_auction');
      case '/finance':
        return context.tr('benefit_finance');
      case '/stock-market':
        return context.tr('benefit_stocks');
      case '/reviews':
        return context.tr('benefit_reviews');
      case '/showroom-decor':
        return context.tr('benefit_decor');
      case '/scrapyard':
        return context.tr('benefit_scrapyard');
      case '/rent-a-car':
        return context.tr('benefit_rent_car');
      case '/black-market':
        return context.tr('benefit_black_market');
      case '/side-businesses':
        return context.tr('benefit_side_biz');
      case '/districts':
        return context.tr('benefit_districts');
      case '/gossip':
        return context.tr('benefit_gossip');
      case '/consignment':
        return context.tr('benefit_consignment');
      case '/casino':
        return context.tr('benefit_casino');
      default:
        return context.tr('benefit_auto_branch', {'level': reqLevel});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lockedItems.isEmpty) return const SizedBox.shrink();

    final currentItem = widget.lockedItems[_currentIndex % widget.lockedItems.length];
    final reqLevel = DealershipModel.getRequiredLevel(currentItem.route);
    final benefit = _getMotivationalBenefit(context, currentItem.route, reqLevel);
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final glowColor = Color.lerp(
          const Color(0xFF6366F1),
          const Color(0xFFA5B4FC),
          _glowAnimation.value,
        )!;

        return SizedBox(
          height: 74,
          child: NeoBrutalCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            backgroundColor: isDark ? const Color(0xFF111424) : const Color(0xFFEEF2FF),
            borderColor: isDark ? glowColor : const Color(0xFF4F46E5),
            borderWidth: 2.3,
            borderRadius: 12,
            shadowColor: isDark
                ? const Color(0xFF6366F1).withValues(alpha: 0.25 * _glowAnimation.value)
                : const Color(0xFF0F172A),
            onTap: _nextTargetManually,
            child: Row(
              children: [
                // Heartbeat Animated Lock Icon Box
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white24 : const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4 * _glowAnimation.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 11),

                // Rotating Content Switcher with Slide & Fade Animation
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 0.4),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey<String>('${currentItem.route}_$_currentIndex'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentItem.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            NeoBrutalBadge(
                              text: context.tr('next_target'),
                              backgroundColor: const Color(0xFF6366F1),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                            if (widget.lockedItems.length > 1) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${_currentIndex + 1}/${widget.lockedItems.length}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ŞUBELER Action Button
                NeoBrutalButton(
                  label: context.tr('branches_btn'),
                  fontSize: 10.5,
                  backgroundColor: const Color(0xFF6366F1),
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/branches');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
