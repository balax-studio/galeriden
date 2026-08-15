import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_dramatic_dialog.dart';
import '../../widgets/neo_brutal_story_ad_dialog.dart';
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

    // Listen for story ad encounters triggered by game progression
    ref.listen<DealershipModel>(gameProvider, (previous, next) {
      if (next.pendingStoryCard != null && (previous?.pendingStoryCard?.id != next.pendingStoryCard?.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NeoBrutalStoryAdDialog.show(context, next.pendingStoryCard!);
          }
        });
      }

      if (next.pendingDramaticCard != null && (previous?.pendingDramaticCard?.id != next.pendingDramaticCard?.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NeoBrutalDramaticDialog.show(context, next.pendingDramaticCard!);
          }
        });
      }
    });

    final hasWasher = game.hiredStaff.any((s) => s.role == StaffRole.washer);
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
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Galerinizde şu an araç bulunmuyor. İkinci el pazarından araç alarak satışa çıkarabilirsiniz.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(p.isDark),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Top Action & Filter Row
                      if (unwashedCount > 0) ...[
                        NeoBrutalCard(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
                          borderColor: const Color(0xFF3B82F6),
                          borderRadius: 10,
                          child: Row(
                            children: [
                              const Icon(Icons.local_car_wash_rounded, color: Color(0xFF3B82F6), size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  hasWasher
                                      ? '$unwashedCount araç yıkama bekliyor (Yıkamacı personeli ücretsiz yıkar)'
                                      : '$unwashedCount araç kirli (Toplu yıkama: ₺${unwashedCount * 600})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              NeoBrutalButton(
                                label: 'Tümünü Yıka',
                                icon: Icons.local_car_wash_rounded,
                                backgroundColor: const Color(0xFF3B82F6),
                                textColor: Colors.white,
                                fontSize: 10,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                onPressed: () {
                                  final success = ref.read(gameProvider.notifier).washAllCars();
                                  if (success) {
                                    NotificationService.showSuccess(context, 'Tüm araçlar yıkandı ve parlatıldı!');
                                  } else {
                                    NotificationService.showError(context, 'Yıkama için bakiye yetersiz.');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

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

            // Tab 2: Incoming Negotiation Offers
            ShowroomOffersTab(game: game, palette: p),
          ],
        ),
      ),
    );
  }
}
