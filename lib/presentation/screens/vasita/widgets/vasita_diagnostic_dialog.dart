import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/listing_model.dart';
import '../../../widgets/neo_brutal_button.dart';


class DiagnosticStepConfig {
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color accentColor;

  const DiagnosticStepConfig({
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.accentColor,
  });
}

class VasitaDiagnosticDialog extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback onCompleted;

  const VasitaDiagnosticDialog({
    super.key,
    required this.listing,
    required this.onCompleted,
  });

  static Future<void> show({
    required BuildContext context,
    required ListingModel listing,
    required VoidCallback onCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VasitaDiagnosticDialog(
        listing: listing,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<VasitaDiagnosticDialog> createState() => _VasitaDiagnosticDialogState();
}

class _VasitaDiagnosticDialogState extends State<VasitaDiagnosticDialog>
    with SingleTickerProviderStateMixin {
  late final List<DiagnosticStepConfig> _steps;
  late final String _archetypeBadgeKey;
  late final Color _archetypeBadgeColor;

  late AnimationController _progressController;
  Timer? _stepTimer;
  Timer? _telemetryTimer;

  int _currentStepIndex = 0;
  bool _isCompleted = false;
  String _telemetryString = 'OBD-II 0x7E0 • CAN 500kbps • INITIALIZING';

  final List<String> _telemetrySamples = const [
    'CAN ID: 0x7E0 • ECU_STREAM: OK • BAUD: 500k',
    'READ DTC: MEMORY SCAN • PACKETS: 128/128',
    'PID 0x0C: RPM_VAR 0.4% • LAMBDA 1.002',
    'SENSOR AD: 4.88V • RAIL_PRESS: NOMINAL',
    'CHECKSUM VERIFIED • DIAG_STREAM ACTIVE',
  ];

  @override
  void initState() {
    super.initState();
    _resolveArchetypeAndSteps();

    // 3.6 seconds total for smooth progression over 4 steps (approx 900ms per step)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _progressController.addListener(() {
      if (!mounted) return;
      final val = _progressController.value;
      final newIndex = (val * 4).floor().clamp(0, 3);
      if (newIndex != _currentStepIndex && !_isCompleted) {
        setState(() {
          _currentStepIndex = newIndex;
        });
        HapticFeedback.selectionClick();
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_isCompleted) {
        _handleCompletion();
      }
    });

    // Start progress immediately
    _progressController.forward();

    // Periodic telemetry string flicker for real-time diagnostic terminal feel
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted || _isCompleted) {
        timer.cancel();
        return;
      }
      final idx = (timer.tick) % _telemetrySamples.length;
      setState(() {
        _telemetryString = _telemetrySamples[idx];
      });
    });
  }

  void _handleCompletion() {
    setState(() {
      _isCompleted = true;
      _currentStepIndex = 4;
      _telemetryString = 'CAN 0x7E0 • DIAGNOSTIC VERIFIED • 100%';
    });
    HapticFeedback.heavyImpact();
    // Invoke completion callback so market state updates
    widget.onCompleted();
  }

  void _resolveArchetypeAndSteps() {
    final car = widget.listing.car;
    final bType = car.bodyType.toLowerCase();
    final brand = car.brand.toLowerCase();
    final model = car.modelName.toLowerCase();
    final year = car.modelYear;

    if (year < 2005 ||
        bType.contains('klasik') ||
        brand.contains('tofaş') ||
        brand.contains('tofas') ||
        brand.contains('lada') ||
        brand.contains('anadol') ||
        model.contains('şahin') ||
        model.contains('sahin') ||
        model.contains('doğan') ||
        model.contains('dogan') ||
        model.contains('kartal') ||
        model.contains('toros') ||
        model.contains('murat') ||
        model.contains('broadway') ||
        model.contains('vosvos') ||
        model.contains('beetle')) {
      _archetypeBadgeKey = 'diag_arch_classic';
      _archetypeBadgeColor = const Color(0xFFB45309);
      _steps = const [
        DiagnosticStepConfig(
          titleKey: 'diag_classic_s1_t',
          descKey: 'diag_classic_s1_d',
          icon: Icons.settings_suggest_rounded,
          accentColor: Color(0xFFF97316),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_classic_s2_t',
          descKey: 'diag_classic_s2_d',
          icon: Icons.shield_outlined,
          accentColor: Color(0xFFEF4444),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_classic_s3_t',
          descKey: 'diag_classic_s3_d',
          icon: Icons.sync_alt_rounded,
          accentColor: Color(0xFFEAB308),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_classic_s4_t',
          descKey: 'diag_classic_s4_d',
          icon: Icons.water_drop_rounded,
          accentColor: Color(0xFF06B6D4),
        ),
      ];
      return;
    }

    if (bType.contains('ticari') ||
        bType.contains('van') ||
        bType.contains('kamyonet') ||
        model.contains('caddy') ||
        model.contains('doblo') ||
        model.contains('transporter') ||
        model.contains('transit') ||
        model.contains('fiorino') ||
        model.contains('kangoo') ||
        model.contains('sprinter') ||
        model.contains('crafter') ||
        model.contains('ducato') ||
        model.contains('hilux') ||
        model.contains('amarok') ||
        model.contains('navara') ||
        model.contains('ranger')) {
      _archetypeBadgeKey = 'diag_arch_comm';
      _archetypeBadgeColor = const Color(0xFF2563EB);
      _steps = const [
        DiagnosticStepConfig(
          titleKey: 'diag_comm_s1_t',
          descKey: 'diag_comm_s1_d',
          icon: Icons.filter_alt_rounded,
          accentColor: Color(0xFF0EA5E9),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_comm_s2_t',
          descKey: 'diag_comm_s2_d',
          icon: Icons.fact_check_rounded,
          accentColor: Color(0xFFEC4899),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_comm_s3_t',
          descKey: 'diag_comm_s3_d',
          icon: Icons.local_shipping_rounded,
          accentColor: Color(0xFFF59E0B),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_comm_s4_t',
          descKey: 'diag_comm_s4_d',
          icon: Icons.build_circle_rounded,
          accentColor: Color(0xFF10B981),
        ),
      ];
      return;
    }

    if (bType.contains('suv') ||
        bType.contains('arazi') ||
        bType.contains('pickup') ||
        brand.contains('jeep') ||
        brand.contains('land rover') ||
        brand.contains('range rover') ||
        model.contains('duster') ||
        model.contains('cherokee') ||
        model.contains('discovery') ||
        model.contains('defender') ||
        model.contains('qashqai') ||
        model.contains('tiguan') ||
        model.contains('tucson') ||
        model.contains('sportage') ||
        model.contains('rav4') ||
        model.contains('cr-v') ||
        model.contains('x5') ||
        model.contains('x3') ||
        model.contains('q7') ||
        model.contains('q5') ||
        model.contains('gle') ||
        model.contains('glc')) {
      _archetypeBadgeKey = 'diag_arch_suv';
      _archetypeBadgeColor = const Color(0xFFD97706);
      _steps = const [
        DiagnosticStepConfig(
          titleKey: 'diag_suv_s1_t',
          descKey: 'diag_suv_s1_d',
          icon: Icons.alt_route_rounded,
          accentColor: Color(0xFFF59E0B),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_suv_s2_t',
          descKey: 'diag_suv_s2_d',
          icon: Icons.air_rounded,
          accentColor: Color(0xFF06B6D4),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_suv_s3_t',
          descKey: 'diag_suv_s3_d',
          icon: Icons.terrain_rounded,
          accentColor: Color(0xFF10B981),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_suv_s4_t',
          descKey: 'diag_suv_s4_d',
          icon: Icons.explore_rounded,
          accentColor: Color(0xFF8B5CF6),
        ),
      ];
      return;
    }

    if (bType.contains('spor') ||
        bType.contains('cabrio') ||
        brand.contains('porsche') ||
        brand.contains('ferrari') ||
        brand.contains('lamborghini') ||
        brand.contains('maserati') ||
        brand.contains('aston martin') ||
        brand.contains('mclaren') ||
        ((brand.contains('bmw') ||
                brand.contains('mercedes') ||
                brand.contains('audi')) &&
            year >= 2012) ||
        model.contains('m3') ||
        model.contains('m4') ||
        model.contains('m5') ||
        model.contains('amg') ||
        model.contains('rs') ||
        model.contains('gti') ||
        model.contains('type r') ||
        model.contains('mustang') ||
        model.contains('camaro') ||
        model.contains('corvette') ||
        model.contains('supra')) {
      _archetypeBadgeKey = 'diag_arch_perf';
      _archetypeBadgeColor = const Color(0xFFE11D48);
      _steps = const [
        DiagnosticStepConfig(
          titleKey: 'diag_perf_s1_t',
          descKey: 'diag_perf_s1_d',
          icon: Icons.memory_rounded,
          accentColor: Color(0xFF38BDF8),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_perf_s2_t',
          descKey: 'diag_perf_s2_d',
          icon: Icons.speed_rounded,
          accentColor: Color(0xFFF43F5E),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_perf_s3_t',
          descKey: 'diag_perf_s3_d',
          icon: Icons.tune_rounded,
          accentColor: Color(0xFFEAB308),
        ),
        DiagnosticStepConfig(
          titleKey: 'diag_perf_s4_t',
          descKey: 'diag_perf_s4_d',
          icon: Icons.security_rounded,
          accentColor: Color(0xFFA855F7),
        ),
      ];
      return;
    }

    _archetypeBadgeKey = 'diag_arch_standard';
    _archetypeBadgeColor = const Color(0xFF059669);
    _steps = const [
      DiagnosticStepConfig(
        titleKey: 'diag_std_s1_t',
        descKey: 'diag_std_s1_d',
        icon: Icons.developer_board_rounded,
        accentColor: Color(0xFF38BDF8),
      ),
      DiagnosticStepConfig(
        titleKey: 'diag_std_s2_t',
        descKey: 'diag_std_s2_d',
        icon: Icons.bolt_rounded,
        accentColor: Color(0xFFEAB308),
      ),
      DiagnosticStepConfig(
        titleKey: 'diag_std_s3_t',
        descKey: 'diag_std_s3_d',
        icon: Icons.car_repair_rounded,
        accentColor: Color(0xFF10B981),
      ),
      DiagnosticStepConfig(
        titleKey: 'diag_std_s4_t',
        descKey: 'diag_std_s4_d',
        icon: Icons.straighten_rounded,
        accentColor: Color(0xFFA855F7),
      ),
    ];
  }

  @override
  void dispose() {
    _progressController.dispose();
    _stepTimer?.cancel();
    _telemetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final car = widget.listing.car;

    return PopScope(
      canPop: _isCompleted,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : Colors.black,
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              final progressVal = _progressController.value;
              final percentInt = (progressVal * 100).toInt().clamp(0, 100);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar
                    _buildHeader(context, isDark),
                    const SizedBox(height: 12),

                    // Vehicle & Archetype Banner
                    _buildVehicleBanner(context, isDark, car),
                    const SizedBox(height: 14),

                    // Real-Time Progress Bar & Terminal Telemetry
                    _buildProgressSection(context, isDark, progressVal, percentInt),
                    const SizedBox(height: 16),

                    // Diagnostic Step Items
                    ...List.generate(_steps.length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildStepItem(
                          context: context,
                          isDark: isDark,
                          index: idx,
                          config: _steps[idx],
                          currentIndex: _currentStepIndex,
                          isDoneAll: _isCompleted,
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // Bottom Action / Complete Button
                    _buildBottomAction(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB020).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB020), width: 1.5),
          ),
          child: const Icon(
            Icons.memory_rounded,
            color: Color(0xFFFFB020),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('diag_dialog_title'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('diag_dialog_subtitle'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (_isCompleted)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: isDark ? Colors.white70 : Colors.black,
            splashRadius: 18,
          ),
      ],
    );
  }

  Widget _buildVehicleBanner(BuildContext context, bool isDark, CarModel car) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B202E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.modelYear} • ${car.brand} ${car.modelName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  car.plateNumber.isNotEmpty ? car.plateNumber : car.bodyType,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _archetypeBadgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _archetypeBadgeColor, width: 1.2),
            ),
            child: Text(
              context.tr(_archetypeBadgeKey),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                color: _archetypeBadgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    bool isDark,
    double progress,
    int percent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('diag_progress_text', {'percent': '$percent'}),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFB020),
              ),
            ),
            Text(
              _isCompleted
                  ? context.tr('diag_status_done')
                  : context.tr('diag_status_scanning'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _isCompleted ? const Color(0xFF00E575) : const Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F121B) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : Colors.black,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isCompleted
                        ? const [Color(0xFF00E575), Color(0xFF10B981)]
                        : const [Color(0xFFFFB020), Color(0xFF38BDF8)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Live Telemetry Line
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0C13) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFB020),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _telemetryString,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00E575),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required bool isDark,
    required int index,
    required DiagnosticStepConfig config,
    required int currentIndex,
    required bool isDoneAll,
  }) {
    final isStepCompleted = isDoneAll || index < currentIndex;
    final isStepScanning = !isDoneAll && index == currentIndex;

    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    if (isStepCompleted) {
      statusColor = const Color(0xFF00E575);
      statusText = context.tr('diag_status_done');
      statusIcon = Icons.check_circle_rounded;
    } else if (isStepScanning) {
      statusColor = const Color(0xFFFFB020);
      statusText = context.tr('diag_status_scanning');
      statusIcon = Icons.sync_rounded;
    } else {
      statusColor = const Color(0xFF64748B);
      statusText = context.tr('diag_status_queued');
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isStepScanning
            ? (isDark
                ? const Color(0xFF1E2538)
                : const Color(0xFFFFFBEB))
            : (isDark ? const Color(0xFF171B26) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isStepScanning
              ? const Color(0xFFFFB020)
              : (isStepCompleted
                  ? const Color(0xFF00E575).withValues(alpha: 0.6)
                  : (isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0))),
          width: isStepScanning ? 1.8 : 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Category Icon Container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: config.accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: config.accentColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Icon(config.icon, color: config.accentColor, size: 18),
          ),
          const SizedBox(width: 10),
          // Titles and Explanations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr(config.titleKey),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr(config.descKey),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    if (_isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E575).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00E575), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF00E575), size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.tr('diag_complete_badge'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          NeoBrutalButton(
            icon: Icons.check_circle_rounded,
            label: context.tr('diag_view_report_btn'),
            backgroundColor: const Color(0xFF00E575),
            textColor: Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return NeoBrutalButton(
      icon: Icons.search_rounded,
      label: context.tr('diag_status_scanning'),
      backgroundColor: const Color(0xFF64748B),
      textColor: Colors.white,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(vertical: 12),
      onPressed: null,
    );
  }
}
