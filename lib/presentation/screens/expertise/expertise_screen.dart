import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/animated_rolling_counter.dart';
import '../../widgets/dot_grid_background.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../widgets/neo_brutal_stamp.dart';
import '../../widgets/slam_stamp_widget.dart';
import '../../widgets/hydraulic_lift_widget.dart';
import '../../widgets/engine_pulse_widget.dart';
import '../../widgets/paint_spark_widget.dart';
import '../../widgets/mini_games/micron_body_scan_canvas.dart';
import '../../widgets/mini_games/vehicle_inspection_canvas.dart';

class ExpertiseScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const ExpertiseScreen({super.key, required this.listing});

  @override
  ConsumerState<ExpertiseScreen> createState() => _ExpertiseScreenState();
}

class _ExpertiseScreenState extends ConsumerState<ExpertiseScreen> {
  bool _isInspected = false;
  String? _inspectionStampText;

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
    final stampInfo =
        ExpertiseEngine.getInspectionStamp(car: car, exp: exp, eval: eval);
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('exp_report_title'),
      ),
      body: DotGridBackground(
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Vehicle Title Header Card (Official Noter / Inspection Style)
            HydraulicLiftWidget(
              isLifting: _isInspected,
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 10,
                borderWidth: 2.5,
                shadowOffset: const Offset(4.0, 4.0),
                showDotGrid: true,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.2,
                        ),
                      ),
                      child: const Icon(Icons.directions_car_rounded,
                          color: Colors.black, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                '[RAPOR #EXP-${car.id.hashCode.abs().toString().padLeft(6, '0').substring(0, 5)}]',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              )),
                              if (_isInspected) ...[
                                NeoBrutalStamp(
                                  text: stampInfo.text,
                                  color: stampInfo.color,
                                  fontSize: 9.5,
                                  angle: -0.08,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${car.brand} ${car.modelName}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${car.modelYear} • ${car.bodyType} • ${widget.listing.sellerCity}',
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (!_isInspected) ...[
              // Locked State Card
              NeoBrutalCard(
                padding: const EdgeInsets.all(20),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: AppColors.brutalOrange,
                borderRadius: 14,
                child: Column(
                  children: [
                    const Icon(Icons.lock_clock_rounded,
                        size: 44, color: AppColors.brutalOrange),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('exp_locked_title'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final hasAppraiser = game.hiredStaff
                            .any((s) => s.role == StaffRole.appraiser);
                        final discount = game.skills.expertiseCostDiscount;
                        final haydarFactor =
                            game.hasHighNpcTrust('haydar_usta') ? 0.50 : 1.0;
                        final fee = hasAppraiser
                            ? 0.0
                            : (GameConstants.expertiseBaseCost *
                                    (1.0 - discount) *
                                    haydarFactor)
                                .roundToDouble();
                        final feeFormatted = CurrencyFormatter.format(fee);

                        return Column(
                          children: [
                            Text(
                              hasAppraiser
                                  ? context.tr('exp_locked_appraiser_desc')
                                  : context.tr('exp_locked_pay_desc',
                                      {'cost': feeFormatted}),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            NeoBrutalButton(
                              label: hasAppraiser
                                  ? context.tr('exp_btn_unlock_free')
                                  : context.tr('exp_btn_unlock_pay',
                                      {'cost': feeFormatted}),
                              icon: hasAppraiser
                                  ? Icons.verified_user_rounded
                                  : Icons.fact_check_rounded,
                              backgroundColor: hasAppraiser
                                  ? AppColors.brutalGreen
                                  : AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 12.5,
                              fullWidth: true,
                              onPressed: (game.balance < fee && !hasAppraiser)
                                  ? null
                                  : () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .performMarketExpertise(fee);
                                      if (success) {
                                        ref
                                            .read(marketProvider.notifier)
                                            .markExpertiseCompleted(
                                                widget.listing.id);
                                        setState(() {
                                          _isInspected = true;
                                        });
                                      }
                                    },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Full Inspection Report Unlocked with Slam Stamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('exp_overall_grade'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      NeoBrutalBadge(
                        text: eval['overallGrade'] as String,
                        backgroundColor: (eval['overallGrade'] as String)
                                .startsWith('D')
                            ? AppColors.errorRed
                            : ((eval['overallGrade'] as String).startsWith('A')
                                ? AppColors.brutalGreen
                                : AppColors.primaryAmber),
                        textColor:
                            (eval['overallGrade'] as String).startsWith('D')
                                ? Colors.white
                                : Colors.black,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  SlamStampWidget(
                    text: stampInfo.text,
                    color: stampInfo.color,
                    fontSize: 11,
                    angle: -0.08,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Color-Coded Engine & Transmission Bars
              _buildProgressStat(
                  context.tr('exp_engine_health'), exp.engineCondition, isDark),
              const SizedBox(height: 8),
              _buildProgressStat(context.tr('exp_transmission_health'),
                  exp.transmissionCondition, isDark),
              const SizedBox(height: 16),

              // Mileage & Tramer Info Cards
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor:
                          isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A),
                      borderRadius: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('exp_mileage_title'),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${NumberFormat('#,###', 'tr_TR').format(exp.mileage)} KM',
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          NeoBrutalBadge(
                            text: exp.isMileageTampered
                                ? context.tr('exp_mileage_suspicious')
                                : context.tr('exp_mileage_original'),
                            backgroundColor: exp.isMileageTampered
                                ? AppColors.errorRed
                                : AppColors.brutalGreen,
                            textColor: exp.isMileageTampered
                                ? Colors.white
                                : Colors.black,
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
                      backgroundColor:
                          isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A),
                      borderRadius: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('exp_tramer_title'),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(
                                exp.tramerAmount.toDouble()),
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          NeoBrutalBadge(
                            text: StatColors.getTramerLabel(exp.tramerAmount),
                            backgroundColor: exp.tramerAmount > 0
                                ? AppColors.brutalOrange
                                : AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 9.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (exp.isMileageTampered) ...[
                const SizedBox(height: 12),
                NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: AppColors.errorRed.withValues(alpha: 0.12),
                  borderColor: AppColors.errorRed,
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gavel_rounded,
                              color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('exp_fraud_title'),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.errorRed),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Builder(
                        builder: (context) {
                          final compFormatted = CurrencyFormatter.format(
                              GameConstants.notaryFraudCompensationAmount);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('exp_fraud_desc',
                                    {'amount': compFormatted}),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 10),
                              NeoBrutalButton(
                                label: context.tr(
                                    'exp_fraud_btn', {'amount': compFormatted}),
                                icon: Icons.assignment_turned_in_rounded,
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fullWidth: true,
                                onPressed: () {
                                  final success = ref
                                      .read(gameProvider.notifier)
                                      .claimNotaryFraudCompensation(car.id);
                                  if (success) {
                                    NotificationService.showSuccess(
                                        context,
                                        context.tr('exp_fraud_success',
                                            {'amount': compFormatted}));
                                    setState(() {});
                                  } else {
                                    NotificationService.showError(context,
                                        'Tazminat talebi gerçekleştirilemedi.');
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: _inspectionStampText != null
                    ? AppColors.brutalGreen
                    : const Color(0xFF38BDF8),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded,
                                color: Color(0xFF38BDF8), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('exp_tuvturk_title'),
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        if (_inspectionStampText != null)
                          NeoBrutalBadge(
                            text: _inspectionStampText!,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 9.5,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('exp_tuvturk_desc'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),
                    NeoBrutalButton(
                      label: _inspectionStampText != null
                          ? context.tr('exp_tuvturk_btn_done')
                          : context.tr('exp_tuvturk_btn_start'),
                      icon: _inspectionStampText != null
                          ? Icons.check_circle_rounded
                          : Icons.play_arrow_rounded,
                      backgroundColor: _inspectionStampText != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF38BDF8),
                      textColor: _inspectionStampText != null
                          ? Colors.white54
                          : Colors.black,
                      fontSize: 11.5,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _inspectionStampText != null
                          ? null
                          : () {
                              VehicleInspectionModal.show(
                                context,
                                car: car,
                                onInspectionFinished: (passed, brakeScore,
                                    headlightScore, reportBadge) {
                                  setState(() {
                                    _inspectionStampText = reportBadge;
                                  });
                                  NotificationService.showSuccess(
                                    context,
                                    '$reportBadge • OK',
                                  );
                                  if (passed) {
                                    final luckyOpp = ref
                                        .read(gameProvider.notifier)
                                        .checkAndRollLuckyOpportunity();
                                    if (luckyOpp != null && context.mounted) {
                                      Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                        if (context.mounted) {
                                          LuckyOpportunityDialog.show(
                                              context, luckyOpp);
                                        }
                                      });
                                    }
                                  }
                                },
                              );
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Body Part Inspection Grid
              Text(
                context.tr('exp_body_schema_title'),
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
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                          Expanded(
                              child: Text(
                            entry.key,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800),
                          )),
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
                context.tr('exp_micron_gauge_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              MicronBodyScanCanvasWidget(
                  bodyParts: exp.bodyParts, isDark: isDark),
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
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isOverpriced
                        ? AppColors.brutalOrange
                        : AppColors.brutalGreen,
                    borderRadius: 14,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('exp_fair_market_value'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF64748B)),
                                ),
                                AnimatedRollingCounter(
                                  value: fairValue,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  context.tr('exp_asking_price'),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF64748B)),
                                ),
                                AnimatedRollingCounter(
                                  value: askingPrice,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        NeoBrutalCard(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isOverpriced
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF0FDF4),
                          borderColor: isOverpriced
                              ? AppColors.brutalOrange
                              : AppColors.brutalGreen,
                          borderRadius: 10,
                          child: Row(
                            children: [
                              Icon(
                                isOverpriced
                                    ? Icons.trending_up_rounded
                                    : Icons.local_offer_rounded,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isOverpriced
                                      ? context.tr('exp_overpriced_msg', {
                                          'diff': CurrencyFormatter.formatShort(
                                              diff)
                                        })
                                      : context.tr('exp_underpriced_msg', {
                                          'diff': CurrencyFormatter.formatShort(
                                              -diff)
                                        }),
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
      ),
      bottomNavigationBar: _isInspected
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: game.ownedCars.any((c) => c.id == car.id)
                    ? NeoBrutalButton(
                        label: context.tr('exp_btn_owned_car'),
                        icon: Icons.check_circle_rounded,
                        backgroundColor:
                            isDark ? Colors.white12 : Colors.black12,
                        textColor: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                        fullWidth: true,
                        onPressed: null,
                      )
                    : NeoBrutalButton(
                        label: context.tr('btn_negotiate_buy'),
                        icon: Icons.handshake_rounded,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 13,
                        fullWidth: true,
                        onPressed: () {
                          context.push('/negotiation', extra: widget.listing);
                        },
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildProgressStat(String title, double value, bool isDark) {
    final color = value >= 75
        ? AppColors.brutalGreen
        : (value >= 50 ? AppColors.brutalYellow : AppColors.errorRed);
    final isEngine = title.toLowerCase().contains('motor') ||
        title.toLowerCase().contains('engine');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isEngine) ...[
                  EnginePulseWidget(engineHealthPercent: value, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(title,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w800)),
              ],
            ),
            Expanded(
                child: Text('%${value.round()}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 12))),
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
      borderColor:
          widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded,
                  color: AppColors.brutalYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                _selectedPart == null
                    ? context.tr('exp_micron_probe_prompt')
                    : context
                        .tr('exp_micron_measurement', {'part': _selectedPart}),
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w900),
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
                  Expanded(
                      child: Text(
                    context.tr('exp_measured_thickness'),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  )),
                  Row(
                    children: [
                      PaintSparkWidget(
                          micronValue: _measuredMicrons!.toDouble()),
                      const SizedBox(width: 6),
                      Text(
                        '$_measuredMicrons µm',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                    ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (widget.isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : (widget.isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A)),
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.black
                          : (widget.isDark ? Colors.white70 : Colors.black87),
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
