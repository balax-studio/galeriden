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

class NightMarketScreen extends ConsumerStatefulWidget {
  const NightMarketScreen({super.key});

  @override
  ConsumerState<NightMarketScreen> createState() => _NightMarketScreenState();
}

class _NightMarketScreenState extends ConsumerState<NightMarketScreen> {
  String? _selectedCarId;

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
                      Text(
                        'GECE MEZATI & DRAG YARIŞI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
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
            const Text(
              'YARIŞ ARACINI SEÇ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ownedCars.length,
                itemBuilder: (context, index) {
                  final car = ownedCars[index];
                  final isSelected = car.id == selectedCar?.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCarId = car.id;
                      });
                    },
                    child: Container(
                      width: 160,
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
                            Text(
                              'Motor: %${car.expertise.engineCondition.round()}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brutalGreen,
                              ),
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
    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF161922),
      borderColor: AppColors.brutalPink,
      borderRadius: 16,
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
              const NeoBrutalBadge(
                text: 'GECE MEZATI',
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
                        'Kondisyon: %${car.expertise.engineCondition.round()}',
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
                    children: const [
                      Text(
                        'SANAYİ RAKİBİ',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'E30 Turbo Dragster',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        'Stage 2 Modifiyeli',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.brutalYellow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    'KAZANILACAK ÖDÜL (GİRİŞ: ${CurrencyFormatter.format(GameConstants.nightRaceEntryFee)})',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                  ),
                  const Text(
                    '₺25.000 - ₺60.000 (+5 İtibar)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                  ),
                ],
              ),
              NeoBrutalButton(
                label: dailyRacesRemaining > 0 ? 'GAZLA & YARIŞ (${CurrencyFormatter.format(GameConstants.nightRaceEntryFee)})' : 'GÜNLÜK HAK BİTTİ',
                backgroundColor: dailyRacesRemaining > 0 ? AppColors.brutalPink : const Color(0xFF475569),
                textColor: Colors.white,
                onPressed: dailyRacesRemaining > 0
                    ? () {
                        final result = ref.read(gameProvider.notifier).enterNightRace(car);
                        _showRaceResultDialog(context, result);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRaceResultDialog(BuildContext context, NightRaceResult result) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: const Color(0xFF141721),
          borderColor: result.isWon ? AppColors.brutalGreen : AppColors.errorRed,
          borderWidth: 2.5,
          borderRadius: 16,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: result.isWon ? AppColors.brutalGreen : AppColors.errorRed,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: Icon(
                      result.isWon ? Icons.emoji_events_rounded : Icons.sports_score_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.isWon ? 'YARIŞI KAZANDIN!' : 'YARIŞ KAYBEDİLDİ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0E14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF262C3D), width: 1.5),
                ),
                child: Text(
                  result.raceLog,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                    height: 1.4,
                  ),
                ),
              ),
              if (result.isWon) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brutalGreen, width: 2.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.brutalGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ödül: +${CurrencyFormatter.format(result.prizeMoney)} & +${result.reputationBonus} İtibar',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: 'TAMAM',
                fullWidth: true,
                backgroundColor: result.isWon ? AppColors.brutalGreen : AppColors.errorRed,
                textColor: Colors.black,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
