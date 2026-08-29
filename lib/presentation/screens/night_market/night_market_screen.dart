import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
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
import '../../widgets/neon_sign_widget.dart';
import '../../widgets/hazard_stripe_widget.dart';
import '../../widgets/mini_games/drag_race_canvas.dart';
import '../../widgets/chassis_laser_scan_widget.dart';

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
      appBar: NeoBrutalAppBar(
        title: context.tr('night_market_title'),
        subtitle: context.tr('night_market_slug'),
        titleBadgeColor: AppColors.brutalPink,
        headerAnimation: NeoBrutalHeaderAnimation.neonFlicker,
        statusBadge: NeoBrutalBadge(
          text: context.tr('night_market_daily_races_left', {
            'count': '${ref.watch(gameProvider.select((g) => g.dailyRacesRemaining))}'
          }),
          backgroundColor: AppColors.brutalYellow,
          textColor: Colors.black,
          fontSize: 9.5,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Animated Caution Hazard Stripe
          const HazardStripeWidget(
            height: 8.0,
            color1: AppColors.brutalPink,
            color2: Color(0xFF0F172A),
            stripeWidth: 8.0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            isAnimated: true,
          ),
          const SizedBox(height: 2),

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
                  child: const Icon(Icons.sports_score_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeonSignWidget(
                        text: context.tr('night_market_banner_title'),
                        neonColor: AppColors.brutalPink,
                        fontSize: 12.0,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('night_market_banner_desc'),
                        style: const TextStyle(
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
            NeoBrutalEmptyState(
              icon: Icons.directions_car_filled_outlined,
              title: context.tr('night_market_no_cars_title'),
              description: context.tr('night_market_no_cars_desc'),
            )
          else ...[
            // 2. Select Car Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  context.tr('night_market_select_car'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF94A3B8),
                  ),
                )),
                Expanded(
                    child: Text(
                  context.tr('night_market_cars_available',
                      {'count': '${ownedCars.length}'}),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                )),
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
                        backgroundColor: isSelected
                            ? const Color(0xFF2E1065)
                            : const Color(0xFF161922),
                        borderColor: isSelected
                            ? AppColors.brutalPink
                            : const Color(0xFF333B4F),
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
                                    context.tr(
                                        'night_market_engine_condition', {
                                      'cond':
                                          '${car.expertise.engineCondition.round()}'
                                    }),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.brutalYellow
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: AppColors.brutalYellow,
                                        width: 1),
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
    final dailyRacesRemaining =
        ref.watch(gameProvider.select((g) => g.dailyRacesRemaining));
    final rival = _currentRival ?? NightMarketEngine.getMatchedRival(car);
    final playerPower = NightMarketEngine.calculatePlayerPower(car);
    final winChance = NightMarketEngine.estimateWinChance(car, rival);

    final winChanceColor = winChance >= 65
        ? AppColors.brutalGreen
        : (winChance >= 45 ? AppColors.brutalYellow : AppColors.errorRed);

    final winStatusText = winChance >= 70
        ? context.tr('night_market_status_advantage')
        : (winChance >= 55
            ? context.tr('night_market_status_slight_advantage')
            : (winChance >= 45
                ? context.tr('night_market_status_even')
                : context.tr('night_market_status_hard')));

    String prizeRangeText = context.tr('night_market_prize_t1');
    if (rival.tier == 2) {
      prizeRangeText = context.tr('night_market_prize_t2');
    } else if (rival.tier == 3) {
      prizeRangeText = context.tr('night_market_prize_t3');
    }

    return ChassisLaserScanWidget(
      isScanning: true,
      laserColor: AppColors.brutalPink,
      child: NeoBrutalCard(
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
                const Icon(Icons.flash_on_rounded,
                    color: AppColors.brutalYellow, size: 20),
                const SizedBox(width: 6),
                Text(
                  context.tr('night_market_matchup_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                NeoBrutalBadge(
                  text: context.tr('night_market_daily_races_left',
                      {'count': '$dailyRacesRemaining'}),
                  backgroundColor: dailyRacesRemaining > 0
                      ? AppColors.brutalYellow
                      : AppColors.errorRed,
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
                        Text(
                          context.tr('night_market_your_car'),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          car.modelName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        Text(
                          context.tr('night_market_power_cond', {
                            'hp': '$playerPower',
                            'cond': '${car.expertise.engineCondition.round()}'
                          }),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rival.title.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rival.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        Text(
                          '${rival.carName} • ~${rival.basePower} HP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brutalYellow),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: winChanceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: winChanceColor.withValues(alpha: 0.6),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.query_stats_rounded,
                            size: 16, color: winChanceColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('night_market_win_chance', {
                              'rate': '$winChance',
                              'status': winStatusText
                            }),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: winChanceColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      _currentRival = NightMarketEngine.getRandomRivalForTier(
                          rival.tier,
                          excludeId: rival.id);
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262C3D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF475569), width: 1.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Rakip Değiş',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('night_market_prize_entry', {
                          'fee': CurrencyFormatter.formatShort(
                              GameConstants.nightRaceEntryFee)
                        }),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          prizeRangeText,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: dailyRacesRemaining > 0
                      ? context.tr('night_market_btn_race')
                      : context.tr('night_market_btn_no_fuel'),
                  backgroundColor: dailyRacesRemaining > 0
                      ? AppColors.brutalPink
                      : const Color(0xFF475569),
                  textColor: Colors.white,
                  onPressed: dailyRacesRemaining > 0
                      ? () {
                          final entryFee =
                              NightMarketEngine.getEntryFeeForRival(rival);
                          final balance = ref.read(gameProvider).balance;
                          if (balance < entryFee) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr('toast_race_entry_fee_needed', {'fee': '₺${entryFee.toInt()}'}),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                            return;
                          }

                          if (car.expertise.engineCondition < 30) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Motor sağlığı %30 altında olan araçlar piste çıkarılamaz!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                            return;
                          }

                          final startResult = ref
                              .read(gameProvider.notifier)
                              .startNightRace(car, rival: rival);

                          DragRaceMiniGameModal.show(
                            context,
                            car: car,
                            rival: rival,
                            raceResult: startResult,
                            onFinished: (resolvedResult) {
                              ref
                                  .read(gameProvider.notifier)
                                  .resolveNightRaceOutcome(
                                    car: car,
                                    rival: rival,
                                    finalResult: resolvedResult,
                                  );
                              setState(() {
                                _currentRival =
                                    NightMarketEngine.getMatchedRival(car);
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
      ),
    );
  }
}
