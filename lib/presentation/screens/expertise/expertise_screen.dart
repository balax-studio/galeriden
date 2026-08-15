import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../marketplace/interactive_negotiation_sheet.dart';

class ExpertiseScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const ExpertiseScreen({super.key, required this.listing});

  @override
  ConsumerState<ExpertiseScreen> createState() => _ExpertiseScreenState();
}

class _ExpertiseScreenState extends ConsumerState<ExpertiseScreen> {
  bool _isInspected = false;

  @override
  void initState() {
    super.initState();
    _isInspected = widget.listing.isExpertiseCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final car = widget.listing.car;
    final exp = car.expertise;
    final eval = ExpertiseEngine.evaluateVehicle(car);
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'DETAYLI EKSPERTİZ RAPORU',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Vehicle Title Header Card
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
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: Colors.black, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brand} ${car.modelName}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${car.modelYear} • ${car.bodyType} • ${widget.listing.sellerCity}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (!_isInspected) ...[
            // Locked State Card
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalOrange,
              borderRadius: 14,
              child: Column(
                children: [
                  const Icon(Icons.lock_clock_rounded, size: 44, color: AppColors.brutalOrange),
                  const SizedBox(height: 10),
                  const Text(
                    'EKSPERTİZ RAPORU KİLİTLİ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bu aracın kaporta, motor, tramer ve kilometre orijinalliğini görmek için ₺1.500 ödeyerek detaylı test yaptırmalısın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final discount = game.skills.expertiseCostDiscount;
                      final haydarFactor = game.hasHighNpcTrust('haydar_usta') ? 0.50 : 1.0;
                      final fee = (1500.0 * (1.0 - discount) * haydarFactor).roundToDouble();
                      final feeFormatted = CurrencyFormatter.format(fee);
                      final perkLabel = game.hasHighNpcTrust('haydar_usta') ? ' (Haydar Usta %50 Dost İndirimi)' : '';
                      return NeoBrutalButton(
                        label: 'EKSPERTİZ YAPTIR ($feeFormatted)$perkLabel',
                        icon: Icons.fact_check_rounded,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 12.5,
                        fullWidth: true,
                        onPressed: game.balance < fee
                            ? null
                            : () {
                                final success = ref.read(gameProvider.notifier).performMarketExpertise(fee);
                                if (success) {
                                  ref.read(marketProvider.notifier).markExpertiseCompleted(widget.listing.id);
                                  setState(() {
                                    _isInspected = true;
                                  });
                                }
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // Full Inspection Report Unlocked
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GENEL DERECELENDİRME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                NeoBrutalBadge(
                  text: eval['overallGrade'] as String,
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 12,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Color-Coded Engine & Transmission Bars
            _buildProgressStat('Motor Sağlığı', exp.engineCondition, isDark),
            const SizedBox(height: 8),
            _buildProgressStat('Şanzıman Sağlığı', exp.transmissionCondition, isDark),
            const SizedBox(height: 16),

            // Mileage & Tramer Info Cards
            Row(
              children: [
                Expanded(
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                    borderRadius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KİLOMETRE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${CurrencyFormatter.formatShort(exp.mileage.toDouble())} KM',
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        NeoBrutalBadge(
                          text: exp.isMileageTampered ? 'Şüpheli KM' : 'Orijinal KM',
                          backgroundColor: exp.isMileageTampered ? AppColors.errorRed : AppColors.brutalGreen,
                          textColor: exp.isMileageTampered ? Colors.white : Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                    borderRadius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TRAMER KAYDI',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(exp.tramerAmount.toDouble()),
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        NeoBrutalBadge(
                          text: StatColors.getTramerLabel(exp.tramerAmount),
                          backgroundColor: exp.tramerAmount > 0 ? AppColors.brutalOrange : AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Body Part Inspection Grid
            Text(
              'KAPORTA VE BOYA ŞEMASI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: Column(
                children: exp.bodyParts.entries.map((entry) {
                  final color = StatColors.getPartColor(entry.value.name);
                  final label = StatColors.getPartLabel(entry.value.name);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                        NeoBrutalBadge(
                          text: label,
                          backgroundColor: color,
                          textColor: Colors.black,
                          fontSize: 10.5,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Micron Gauge Mini-Game
            Text(
              'BOYA MİKRON ÖLÇER (İNTERAKTİF CİHAZ)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            _MicronGaugeMiniGame(bodyParts: exp.bodyParts, isDark: isDark),
            const SizedBox(height: 16),

            // Fair Market Value vs Asking Price Summary Card
            Builder(
              builder: (context) {
                final fairValue = eval['fairMarketValue'] as double;
                final askingPrice = widget.listing.askingPrice;
                final diff = askingPrice - fairValue;
                final isOverpriced = diff > 0;

                return NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isOverpriced ? AppColors.brutalOrange : AppColors.brutalGreen,
                  borderRadius: 14,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EKSPERTİZ DEĞERİ',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                              ),
                              Text(
                                CurrencyFormatter.format(fairValue),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'İLAN FİYATI',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                              ),
                              Text(
                                CurrencyFormatter.format(askingPrice),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      NeoBrutalCard(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: isOverpriced ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                        borderColor: isOverpriced ? AppColors.brutalOrange : AppColors.brutalGreen,
                        borderRadius: 10,
                        child: Row(
                          children: [
                            Icon(
                              isOverpriced ? Icons.trending_up_rounded : Icons.local_offer_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOverpriced
                                    ? 'Satıcı ${CurrencyFormatter.formatShort(diff)} yüksek istiyor (Pazarlık Kozu!)'
                                    : 'Piyasanın ${CurrencyFormatter.formatShort(-diff)} altında kelepir fırsat!',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      bottomNavigationBar: _isInspected
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: NeoBrutalButton(
                  label: 'PAZARLIK ET & SATIN AL',
                  icon: Icons.handshake_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 13,
                  fullWidth: true,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => InteractiveNegotiationSheet(listing: widget.listing),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProgressStat(String title, double value, bool isDark) {
    final color = value >= 75 ? AppColors.brutalGreen : (value >= 50 ? AppColors.brutalYellow : AppColors.errorRed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            Text('%${value.round()}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.5,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100.0).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MicronGaugeMiniGame extends StatefulWidget {
  final Map<String, PartStatus> bodyParts;
  final bool isDark;

  const _MicronGaugeMiniGame({
    required this.bodyParts,
    required this.isDark,
  });

  @override
  State<_MicronGaugeMiniGame> createState() => _MicronGaugeMiniGameState();
}

class _MicronGaugeMiniGameState extends State<_MicronGaugeMiniGame> {
  String? _selectedPart;
  int? _measuredMicrons;

  int _calculateMicrons(PartStatus status) {
    switch (status) {
      case PartStatus.original:
        return 90 + (widget.bodyParts.hashCode % 25);
      case PartStatus.painted:
        return 160 + (widget.bodyParts.hashCode % 60);
      case PartStatus.changed:
        return 280 + (widget.bodyParts.hashCode % 100);
      case PartStatus.damaged:
        return 380 + (widget.bodyParts.hashCode % 150);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: AppColors.brutalYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                _selectedPart == null
                    ? 'Probunu dokundurmak istediğin parçayı seç'
                    : '$_selectedPart Ölçümü',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_measuredMicrons != null) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(10),
              backgroundColor: AppColors.brutalYellow,
              borderColor: Colors.black,
              borderRadius: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ÖLÇÜLEN BOYA KALINLIĞI:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  Text(
                    '$_measuredMicrons µm (Mikron)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.bodyParts.entries.map((e) {
              final isSelected = _selectedPart == e.key;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPart = e.key;
                    _measuredMicrons = _calculateMicrons(e.value);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (widget.isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0F172A) : (widget.isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black : (widget.isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
