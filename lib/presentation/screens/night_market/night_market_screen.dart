import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../domain/usecases/night_market_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/pulsing_dot.dart';
import '../../widgets/mini_games/drag_race_canvas.dart';

class NightMarketScreen extends ConsumerStatefulWidget {
  const NightMarketScreen({super.key});

  @override
  ConsumerState<NightMarketScreen> createState() => _NightMarketScreenState();
}

class _NightMarketScreenState extends ConsumerState<NightMarketScreen> {
  String? _selectedCarId;
  NightRivalModel? _currentRival;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final ownedCars = game.ownedCars;

    if (_selectedCarId == null && ownedCars.isNotEmpty) {
      _selectedCarId = ownedCars.first.id;
    }

    final selectedCar = ownedCars.cast<CarModel?>().firstWhere(
          (c) => c?.id == _selectedCarId,
          orElse: () => ownedCars.isNotEmpty ? ownedCars.first : null,
        );

    if (selectedCar != null && _currentRival == null) {
      _currentRival = NightMarketEngine.getMatchedRival(selectedCar);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: const NeoBrutalAppBar(
        title: 'GECE SANAYİSİ & YARIŞ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Neon Cyber Header
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: const Color(0xFF1E142B),
            borderColor: AppColors.brutalPink,
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brutalPink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.sports_score_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PulsingDot(color: AppColors.brutalPink, size: 7.0),
                          SizedBox(width: 6),
                          Text(
                            'GECE MEZATI & DRAG YARIŞI',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sanayinin arka sokaklarında gece yarısı modifiye drag yarışları düzenleniyor. En hızlı aracını seç, rakipleri tokatla!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFC084FC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (ownedCars.isEmpty)
            const NeoBrutalEmptyState(
              icon: Icons.directions_car_filled_outlined,
              title: 'YARIŞACAK ARAÇ YOK',
              description: 'Gece yarışına katılmak için garajınızda en az 1 araç bulunmalıdır.',
            )
          else ...[
            // 2. Select Car Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'YARIŞ ARACINI SEÇ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  '${ownedCars.length} Araç Mevcut',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ownedCars.length,
                itemBuilder: (context, index) {
                  final car = ownedCars[index];
                  final isSelected = car.id == selectedCar?.id;
                  final carPower = NightMarketEngine.calculatePlayerPower(car);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCarId = car.id;
                        _currentRival = NightMarketEngine.getMatchedRival(car);
                      });
                    },
                    child: Container(
                      width: 165,
                      margin: const EdgeInsets.only(right: 10),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: isSelected ? const Color(0xFF2E1065) : const Color(0xFF161922),
                        borderColor: isSelected ? AppColors.brutalPink : const Color(0xFF333B4F),
                        borderRadius: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              car.modelName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Motor: %${car.expertise.engineCondition.round()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brutalGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.brutalYellow.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.brutalYellow, width: 1),
                                  ),
                                  child: Text(
                                    '$carPower HP',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.brutalYellow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. Selected Car Battle Card
            if (selectedCar != null) _buildRaceDuelCard(context, selectedCar),
          ],
        ],
      ),
    );
  }

  Widget _buildRaceDuelCard(BuildContext context, CarModel car) {
    final dailyRacesRemaining = ref.watch(gameProvider.select((g) => g.dailyRacesRemaining));
    final rival = _currentRival ?? NightMarketEngine.getMatchedRival(car);
    final playerPower = NightMarketEngine.calculatePlayerPower(car);
    final winChance = NightMarketEngine.estimateWinChance(car, rival);

    final winChanceColor = winChance >= 65
        ? AppColors.brutalGreen
        : (winChance >= 45 ? AppColors.brutalYellow : AppColors.errorRed);

    final winStatusText = winChance >= 70
        ? 'Avantajlısın'
        : (winChance >= 55
            ? 'Hafif Üstünsün'
            : (winChance >= 45 ? 'Denk Mücadele' : 'Zorlu Rakip'));

    String prizeRangeText = '₺20.000 - ₺35.000 • +4 İtibar';
    if (rival.tier == 2) {
      prizeRangeText = '₺40.000 - ₺65.000 • +6 İtibar';
    } else if (rival.tier == 3) {
      prizeRangeText = '₺75.000 - ₺120.000 • +10 İtibar';
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF161922),
      borderColor: AppColors.brutalPink,
      borderRadius: 10,
      borderWidth: 2.5,
      shadowOffset: const Offset(4.0, 4.0),
      showDotGrid: true,
      showHazardHeader: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: AppColors.brutalYellow, size: 20),
              const SizedBox(width: 6),
              const Text(
                'YARIŞ EŞLEŞMESİ & ORANLAR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              NeoBrutalBadge(
                text: '$dailyRacesRemaining/3 Hak',
                backgroundColor: dailyRacesRemaining > 0 ? AppColors.brutalYellow : AppColors.errorRed,
                textColor: Colors.black,
                fontSize: 10,
              ),
              const SizedBox(width: 4),
              NeoBrutalBadge(
                text: rival.badge,
                backgroundColor: AppColors.brutalPink,
                textColor: Colors.white,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Player vs Rival info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1117),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF262C3D), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SENİN ARACIN',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.modelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        'Güç: $playerPower HP • Kond: %${car.expertise.engineCondition.round()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        rival.title.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rival.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${rival.carName} • ~${rival.basePower} HP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brutalYellow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Odds & Matchmaking Analytics
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: winChanceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: winChanceColor.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.query_stats_rounded, size: 16, color: winChanceColor),
                      const SizedBox(width: 6),
                      Text(
                        'Kazanma Tahmini: %$winChance • $winStatusText',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: winChanceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _currentRival = NightMarketEngine.getRandomRivalForTier(rival.tier, excludeId: rival.id);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262C3D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF475569), width: 1.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Rakip Değiş',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prize & Stakes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KAZANILACAK ÖDÜL • GİRİŞ ${CurrencyFormatter.format(GameConstants.nightRaceEntryFee)}',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                  ),
                  Text(
                    prizeRangeText,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                  ),
                ],
              ),
              NeoBrutalButton(
                label: dailyRacesRemaining > 0 ? 'GAZLA & YARIŞ • ${CurrencyFormatter.format(GameConstants.nightRaceEntryFee)}' : 'GÜNLÜK HAK BİTTİ',
                backgroundColor: dailyRacesRemaining > 0 ? AppColors.brutalPink : const Color(0xFF475569),
                textColor: Colors.white,
                onPressed: dailyRacesRemaining > 0
                    ? () {
                        final result = ref.read(gameProvider.notifier).enterNightRace(car, rival: rival);
                        DragRaceMiniGameModal.show(
                          context,
                          car: car,
                          rival: rival,
                          raceResult: result,
                          onFinished: () {
                            setState(() {
                              _currentRival = NightMarketEngine.getMatchedRival(car);
                            });
                          },
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
