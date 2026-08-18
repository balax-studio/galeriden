import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      _ServiceItem(
        icon: Icons.map_rounded,
        title: 'Semt Hakimiyeti',
        subtitle: 'Pazar Payı & Avantaj',
        color: const Color(0xFF38BDF8),
        route: '/districts',
      ),
      _ServiceItem(
        icon: Icons.record_voice_over_rounded,
        title: 'Dedikodu Hattı',
        subtitle: 'Asimetrik İstihbarat',
        badge: game.activeGossips.isNotEmpty ? '${game.activeGossips.length} Kulis' : null,
        color: const Color(0xFFFFDE59),
        route: '/gossip',
      ),
      _ServiceItem(
        icon: Icons.handshake_rounded,
        title: 'Konsinye & Emanet',
        subtitle: 'Sıfır Sermaye Satış',
        badge: game.consignmentOffers.isNotEmpty ? '${game.consignmentOffers.length} Teklif' : null,
        color: const Color(0xFF00E575),
        route: '/consignment',
      ),
      _ServiceItem(
        icon: Icons.sports_score_rounded,
        title: 'Gece Sanayisi',
        subtitle: 'Modifiye & Drag',
        color: const Color(0xFFF43F5E),
        route: '/night-market',
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

  String _getMotivationalBenefit(String route, int reqLevel) {
    switch (route) {
      case '/car-wash':
        return 'Araçları yıka & detaylandır, kâr marjını %10-15 artır!';
      case '/workshop':
        return 'Hasarlı araçları kelepire topla, onarıp yüksek kârla sat!';
      case '/tuning-studio':
        return 'Stage yazılım & egzoz tak, gece yarışlarına hükmet!';
      case '/staff':
        return 'Usta & satış danışmanı kirala, galerini otomatik işlet!';
      case '/history':
        return 'Tüm kâr-zarar geçmişini & satış trendlerini analiz et!';
      case '/auction':
        return 'İcra ve gümrük ihalelerinden kelepir araçlar topla!';
      case '/finance':
        return 'Ticari kredi & mevduatla dev araç filoları finanse et!';
      case '/stock-market':
        return 'Otomotiv hisselerine yatırım yap, pasif servet kazan!';
      case '/reviews':
        return 'Müşteri memnuniyetini yükselt, elit VIP alıcıları çek!';
      case '/showroom-decor':
        return 'Lüks ofis mobilyaları ve dekorasyonla itibarını katla!';
      case '/scrapyard':
        return 'Hurda araçları parçala, çıkma orijinal yedek parça sat!';
      case '/rent-a-car':
        return 'Filo kur, araçları kiraya verip günlük nakit akışı sağla!';
      case '/black-market':
        return 'Ruhsatsız ve gizli efsane spor arabalara eriş!';
      case '/side-businesses':
        return 'Otopark & benzinlik aç, dükkan kapalıyken bile kazan!';
      case '/districts':
        return 'İstanbul ilçelerinde pazar payı kap, semt hakimi ol!';
      case '/gossip':
        return 'Piyasa kulislerini dinle, fırsatları krizden önce yakala!';
      case '/consignment':
        return 'Sıfır sermaye ile emanet lüks araçları komisyonla sat!';
      default:
        return 'Seviye $reqLevel Şubesi (Ofis/Mülk) ile Otomatik Açılır';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lockedItems.isEmpty) return const SizedBox.shrink();

    final currentItem = widget.lockedItems[_currentIndex % widget.lockedItems.length];
    final reqLevel = DealershipModel.getRequiredLevel(currentItem.route);
    final benefit = _getMotivationalBenefit(currentItem.route, reqLevel);
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
                              text: 'SIRADAKİ HEDEF',
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
                  label: 'ŞUBELER',
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

