import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import 'widgets/showroom_car_card.dart';
import 'widgets/showroom_offers_tab.dart';

class ShowroomScreen extends ConsumerStatefulWidget {
  const ShowroomScreen({super.key});

  @override
  ConsumerState<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends ConsumerState<ShowroomScreen> {
  String _selectedFilter = 'Tümü';
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final hasSalesman = game.hiredStaff.any((s) => s.role == StaffRole.salesman);
    final unwashedCount = game.ownedCars.where((c) => !c.isWashed || !c.isPolished || !c.isDetailedCleaned).length;

    // Filter cars
    List<CarModel> filteredCars = game.ownedCars.where((c) {
      switch (_selectedFilter) {
        case 'Onarım Bekliyor':
          return c.expertise.engineCondition < 80 || c.expertise.transmissionCondition < 80 || !c.isWashed;
        case 'İlana Hazır':
          return !c.isListed && c.expertise.engineCondition >= 80 && c.expertise.transmissionCondition >= 80;
        case 'İlanda':
          return c.isListed;
        case 'Teklif Var':
          return game.incomingOffers.any((o) => o.carId == c.id && !o.isExpired);
        case 'Tümü':
        default:
          return true;
      }
    }).toList();

    // Sort cars: Onarım Bekliyor -> İlana Hazır -> İlanda -> Teklif Var
    filteredCars.sort((a, b) {
      int score(CarModel c) {
        final hasOffer = game.incomingOffers.any((o) => o.carId == c.id && !o.isExpired);
        if (hasOffer) return 4;
        if (c.isListed) return 3;
        if (c.expertise.engineCondition >= 80 && c.expertise.transmissionCondition >= 80) return 2;
        return 1;
      }
      return score(b).compareTo(score(a));
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(
          title: 'SHOWROOM VE İLANLARIM',
          bottom: NeoBrutalTabBar(
            tabs: [
              'Galerideki Araçlar (${game.ownedCars.length})',
              'Gelen Teklifler (${game.incomingOffers.length})',
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Owned Cars & Publish Listing
            game.ownedCars.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    children: [
                      const SizedBox(height: 40),
                      NeoBrutalEmptyState(
                        icon: Icons.directions_car_filled_rounded,
                        badgeText: 'VİTRİN BOŞ',
                        title: 'Galerinde Satılık Araç Yok',
                        description: 'Galerini doldurmak ve kâr elde etmek için ikinci el pazarından veya ihale salonundan fırsat araçları satın alabilirsin.',
                        actionLabel: 'Pazara Git',
                        actionIcon: Icons.storefront_rounded,
                        onActionPressed: () => context.push('/marketplace'),
                      ),
                    ],
                  )
                : RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: const Color(0xFFFFDE59),
                    strokeWidth: 2.5,
                    onRefresh: () async {
                      HapticFeedback.mediumImpact();
                      await Future.delayed(const Duration(milliseconds: 400));
                      ref.read(gameProvider.notifier).triggerOrganicOffers();
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      children: [
                        // Batch Operations Bar (§1.5 / Q10)
                        NeoBrutalCard(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
                          borderColor: const Color(0xFF3B82F6),
                          borderRadius: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOPLU VİTRİN İŞLEMLERİ',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  Text(
                                    '${game.ownedCars.length} Araç',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    NeoBrutalButton(
                                      label: unwashedCount > 0 ? 'Tümünü Yıka ($unwashedCount)' : 'Tümü Temiz',
                                      icon: Icons.local_car_wash_rounded,
                                      backgroundColor: unwashedCount > 0 ? const Color(0xFF3B82F6) : (isDark ? Colors.white12 : Colors.black12),
                                      textColor: Colors.white,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      onPressed: unwashedCount > 0
                                          ? () {
                                              final count = ref.read(gameProvider.notifier).washAllShowroomCars();
                                              if (count > 0) {
                                                NotificationService.showSuccess(context, '$count araç yıkandı ve parlatıldı!');
                                              } else if (count == -1) {
                                                NotificationService.showError(context, 'Yıkama için bakiye yetersiz.');
                                              }
                                            }
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    NeoBrutalButton(
                                      label: 'Tümünü İlana Koy',
                                      icon: Icons.publish_rounded,
                                      backgroundColor: const Color(0xFF00E575),
                                      textColor: Colors.black,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      onPressed: () {
                                        final count = ref.read(gameProvider.notifier).publishAllReadyCars();
                                        if (count > 0) {
                                          NotificationService.showSuccess(context, '$count yeni araç ilana çıkarıldı!');
                                        } else {
                                          NotificationService.showInfo(context, 'İlana konulacak hazır araç bulunamadı.');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    NeoBrutalButton(
                                      label: 'Flaş İndirim (%10)',
                                      icon: Icons.local_fire_department_rounded,
                                      backgroundColor: const Color(0xFFFFDE59),
                                      textColor: Colors.black,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      onPressed: () {
                                        final count = ref.read(gameProvider.notifier).startWeekendFlashSale();
                                        if (count > 0) {
                                          NotificationService.showSuccess(context, '$count ilanda %10 flaş indirim yapıldı! Müşteriler hızlandı.');
                                        } else {
                                          NotificationService.showInfo(context, 'İndirim uygulanacak aktif ilan bulunamadı.');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    NeoBrutalButton(
                                      label: 'Bayat İlanları İndir',
                                      icon: Icons.archive_rounded,
                                      backgroundColor: const Color(0xFFEF4444),
                                      textColor: Colors.white,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      onPressed: () {
                                        final count = ref.read(gameProvider.notifier).delistStaleListings();
                                        if (count > 0) {
                                          NotificationService.showSuccess(context, '$count adet 20+ günlük bayat ilan yayından kaldırıldı.');
                                        } else {
                                          NotificationService.showInfo(context, 'Yayında 20 günü aşmış bayat ilan yok.');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              'Tümü',
                              'Teklif Var',
                              'İlanda',
                              'İlana Hazır',
                              'Onarım Bekliyor',
                            ].map((filter) {
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.black
                                          : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFFFDE59),
                                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                                    width: 1.4,
                                  ),
                                  onSelected: (sel) {
                                    if (sel) setState(() => _selectedFilter = filter);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filtered cars list
                        if (filteredCars.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Bu filtreye uygun araç bulunamadı.',
                                style: AppTypography.bodyMedium(p.isDark),
                              ),
                            ),
                          )
                        else
                          ...filteredCars.map((car) => ShowroomCarCard(
                                car: car,
                                game: game,
                                palette: p,
                                hasSalesman: hasSalesman,
                              )),
                      ],
                    ),
                  ),

            // Tab 2: Incoming Negotiation Offers
            ShowroomOffersTab(game: game, palette: p),
          ],
        ),
      ),
    );
  }
}
