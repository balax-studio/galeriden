import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../domain/usecases/construction_timeline_engine.dart';
import '../../../domain/usecases/zoning_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class RealEstateConstructionScreen extends ConsumerStatefulWidget {
  final String landId;

  const RealEstateConstructionScreen({
    super.key,
    required this.landId,
  });

  @override
  ConsumerState<RealEstateConstructionScreen> createState() =>
      _RealEstateConstructionScreenState();
}

class _RealEstateConstructionScreenState
    extends ConsumerState<RealEstateConstructionScreen> {
  int _selectedTabIndex = 0; // 0: Şantiye & Etaplar, 1: KAKS & Tipoloji, 2: Belediye Dosyası, 3: Ön Satış
  ZoningUnitMix? _workingMix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);

    final landIndex =
        game.ownedRealEstates.indexWhere((p) => p.id == widget.landId);

    if (landIndex == -1) {
      return Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('real_estate_construction_title'),
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.tr('real_estate_empty_portfolio_title'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final land = game.ownedRealEstates[landIndex];
    final defaultZoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: land.squareMeters.toDouble(),
      baseMarketValue: land.baseMarketValue,
    );

    // Initialize or bind working unit mix
    if (_workingMix == null) {
      if (land.customUnitMix != null) {
        _workingMix = ZoningUnitMix.fromMap(land.customUnitMix!);
      } else {
        _workingMix =
            ZoningEngine.optimizeUnitMix(defaultZoning.netResidentialArea);
      }
    }

    final activeZoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: land.squareMeters.toDouble(),
      baseMarketValue: land.baseMarketValue,
      customUnitMix: _workingMix,
    );

    final isFinished = land.isConstructionComplete;
    final isActive = land.isConstructionActive;

    String statusBadgeText;
    Color statusBadgeBg;
    if (isFinished) {
      statusBadgeText = context.tr('real_estate_construction_badge_ready');
      statusBadgeBg = const Color(0xFFD1FAE5);
    } else if (isActive) {
      statusBadgeText =
          '${context.tr('real_estate_construction_badge_active')} • %${land.constructionPercent}';
      statusBadgeBg = const Color(0xFFFEF3C7);
    } else {
      statusBadgeText = context.tr('real_estate_construction_badge_idle');
      statusBadgeBg = const Color(0xFFE0E7FF);
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: context.tr('real_estate_construction_title'),
        onLeadingPressed: () => context.pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NeoBrutalBadge(
              text: statusBadgeText,
              backgroundColor: statusBadgeBg,
              textColor: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LAND OVERVIEW CARD
            _buildLandOverviewCard(context, theme, land, activeZoning, isDark),
            const SizedBox(height: 14),

            // 2. NEO-BRUTALIST SUB-PAGE / TAB SELECTOR
            _buildTabSelector(context, isDark),
            const SizedBox(height: 14),

            // 3. TAB CONTENT
            if (_selectedTabIndex == 0) ...[
              // TAB 0: ŞANTİYE & ETAP MATRİSİ
              _buildStagesTabContent(
                  context, theme, land, activeZoning, game.balance, isDark, isFinished, isActive),
            ] else if (_selectedTabIndex == 1) ...[
              // TAB 1: KAKS & MİMARİ TİPOLOJİ MASASI
              _buildKaksTypologyStudio(
                  context, theme, land, activeZoning, isDark),
            ] else if (_selectedTabIndex == 2) ...[
              // TAB 2: BELEDİYE & RESMİ RUHSAT DOSYASI
              _buildMunicipalDossierTab(
                  context, theme, land, isDark, isFinished),
            ] else if (_selectedTabIndex == 3) ...[
              // TAB 3: TOPRAKTAN ÖN SATIŞ & FİNANSMAN
              _buildPreSaleTab(context, theme, land, isDark, isFinished),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- TOP TAB SELECTOR ---
  Widget _buildTabSelector(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabPill(
            index: 0,
            icon: Icons.construction_rounded,
            label: context.tr('real_estate_construction_tab_stages'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 1,
            icon: Icons.architecture_rounded,
            label: context.tr('real_estate_construction_tab_kaks'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 2,
            icon: Icons.account_balance_rounded,
            label: context.tr('real_estate_construction_tab_municipal'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 3,
            icon: Icons.monetization_on_rounded,
            label: context.tr('real_estate_construction_tab_presale'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. LAND OVERVIEW CARD ---
  Widget _buildLandOverviewCard(BuildContext context, ThemeData theme,
      RealEstateModel land, ZoningProfile zoning, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: const Icon(Icons.landscape_rounded,
                    color: Color(0xFF10B981), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${land.city} • ${land.district} • ${land.squareMeters} m²',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('real_estate_label_market_value'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(land.baseMarketValue),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  NeoBrutalBadge(
                    text:
                        'TAKS ${zoning.taks.toStringAsFixed(2)} • KAKS ${zoning.kaks.toStringAsFixed(2)}',
                    backgroundColor: const Color(0xFFDBEAFE),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                  NeoBrutalBadge(
                    text: context.tr(land.deedType.localizationKey),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final costIndex = ref.watch(gameProvider.select((s) => s.constructionCostIndex));
                      final isHigh = costIndex > 1.05;
                      final isLow = costIndex < 0.95;
                      return NeoBrutalBadge(
                        text: 'Endeks ${costIndex.toStringAsFixed(2)}x',
                        backgroundColor: isHigh
                            ? const Color(0xFFFEE2E2)
                            : (isLow ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9)),
                        textColor: isHigh
                            ? const Color(0xFFDC2626)
                            : (isLow ? const Color(0xFF16A34A) : const Color(0xFF475569)),
                      );
                    },
                  ),
                  if (land.isConstructionActive || land.constructionStage > 1)
                    NeoBrutalBadge(
                      text: 'Kalite ${land.qualityScore.round()}/100',
                      backgroundColor: land.qualityScore >= 80
                          ? const Color(0xFFDCFCE7)
                          : (land.qualityScore < 60
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFFEF3C7)),
                      textColor: land.qualityScore >= 80
                          ? const Color(0xFF16A34A)
                          : (land.qualityScore < 60
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFD97706)),
                    ),
                  if (land.isMortgaged)
                    NeoBrutalBadge(
                      text: context.tr('real_estate_mortgaged_badge'),
                      backgroundColor: const Color(0xFFFEE2E2),
                      textColor: const Color(0xFFDC2626),
                    ),
                ],
              ),
            ),
          ],
          ),
        ],
      ),
    );
  }

  // --- TAB 0: ŞANTİYE & ETAPLAR CONTENT ---
  Widget _buildStagesTabContent(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    ZoningProfile zoning,
    double balance,
    bool isDark,
    bool isFinished,
    bool isActive,
  ) {
    if (land.constructionStage == 0 && !isActive) {
      return _buildContractSelectionSection(
          context, theme, land, zoning, balance, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 8-STAGE TIMELINE CARD
        _buildEightStageTimelineCard(
            context, theme, land, isDark, isFinished),
        const SizedBox(height: 14),

        // SITE RADIO DISPATCH CARD
        if (land.constructionMode == 'selfBuild') ...[
          _buildSiteRadioDispatchCard(context, theme, land, isDark),
          const SizedBox(height: 14),
        ],

        // BENTO PROJECT STATS
        _buildProjectStatsBento(context, theme, land, isDark),
        const SizedBox(height: 14),

        // FINALIZE OR NEXT STAGE ACTION
        if (isFinished) ...[
          _buildFinalizeCard(context, theme, land, isDark),
        ] else if (land.constructionMode == 'selfBuild') ...[
          _buildSelfBuildAdvanceCard(
              context, theme, land, balance, isDark),
          const SizedBox(height: 14),
          _buildConstructionLoanCard(context, theme, land, balance, isDark),
        ] else ...[
          _buildContractorWaitCard(context, theme, land, isDark),
        ],
        if (isActive && !isFinished) ...[
          const SizedBox(height: 14),
          _buildCancelProjectButton(context, land, isDark),
        ],
      ],
    );
  }

  Widget _buildCancelProjectButton(
      BuildContext context, RealEstateModel land, bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showCancelProjectDialog(context, land),
        icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFEF4444)),
        label: Text(
          context.tr('real_estate_btn_cancel_project'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }

  void _showCancelProjectDialog(BuildContext context, RealEstateModel land) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          context.tr('real_estate_dialog_cancel_title'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          context.tr('real_estate_dialog_cancel_desc'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final ok = ref.read(gameProvider.notifier).cancelConstruction(land.id);
              if (ok) {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_cancel_success_toast'),
                );
              }
            },
            child: Text(
              context.tr('real_estate_btn_confirm_cancel'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: KAKS & MİMARİ TİPOLOJİ MASASI ---
  Widget _buildKaksTypologyStudio(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    ZoningProfile zoning,
    bool isDark,
  ) {
    final netArea = zoning.netResidentialArea;
    final usedArea = zoning.consumedEmsalArea;
    final remainingArea = zoning.remainingEmsalArea;
    final usageRatio = zoning.emsalUtilizationRatio;
    final isExceeded = zoning.isEmsalExceeded;

    Color gaugeColor;
    if (isExceeded) {
      gaugeColor = const Color(0xFFEF4444); // Red
    } else if (usageRatio >= 0.95) {
      gaugeColor = const Color(0xFF10B981); // Emerald
    } else {
      gaugeColor = const Color(0xFF2563EB); // Blue
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Capacity Header Card
        NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderColor: isExceeded ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.architecture_rounded,
                          color: Color(0xFF2563EB), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('real_estate_kaks_capacity_header'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: isExceeded
                        ? 'EMSAL AŞILDI'
                        : '%${(usageRatio * 100).toStringAsFixed(0)} DOLU',
                    backgroundColor: isExceeded
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFDBEAFE),
                    textColor: isExceeded
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF1D4ED8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Thick Progress Meter
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: usageRatio.clamp(0.0, 1.0),
                    child: Container(color: gaugeColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildZoningStatBox(
                      context.tr('real_estate_kaks_allowable_label'),
                      '${netArea.toStringAsFixed(0)} m²',
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildZoningStatBox(
                      context.tr('real_estate_kaks_consumed_label'),
                      '${usedArea.toStringAsFixed(0)} m²',
                      isDark,
                      textColor: isExceeded ? const Color(0xFFDC2626) : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildZoningStatBox(
                      context.tr('real_estate_kaks_remaining_label'),
                      '${remainingArea.toStringAsFixed(0)} m²',
                      isDark,
                    ),
                  ),
                ],
              ),

              if (isExceeded) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('real_estate_kaks_warning_exceeded'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Typology Selector Cards
        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_1plus0_title'),
          desc: context.tr('real_estate_typology_1plus0_desc'),
          grossM2: ZoningUnitMix.grossArea1Plus0,
          count: _workingMix?.units1Plus0 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units1Plus0: m.units1Plus0 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units1Plus0: (m.units1Plus0 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_1plus1_title'),
          desc: context.tr('real_estate_typology_1plus1_desc'),
          grossM2: ZoningUnitMix.grossArea1Plus1,
          count: _workingMix?.units1Plus1 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units1Plus1: m.units1Plus1 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units1Plus1: (m.units1Plus1 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_2plus0_title'),
          desc: context.tr('real_estate_typology_2plus0_desc'),
          grossM2: ZoningUnitMix.grossArea2Plus0,
          count: _workingMix?.units2Plus0 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units2Plus0: m.units2Plus0 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units2Plus0: (m.units2Plus0 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_2plus1_title'),
          desc: context.tr('real_estate_typology_2plus1_desc'),
          grossM2: ZoningUnitMix.grossArea2Plus1,
          count: _workingMix?.units2Plus1 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units2Plus1: m.units2Plus1 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units2Plus1: (m.units2Plus1 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_3plus1_title'),
          desc: context.tr('real_estate_typology_3plus1_desc'),
          grossM2: ZoningUnitMix.grossArea3Plus1,
          count: _workingMix?.units3Plus1 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units3Plus1: m.units3Plus1 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units3Plus1: (m.units3Plus1 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildTypologySelectorCard(
          context: context,
          title: context.tr('real_estate_typology_4plus1_title'),
          desc: context.tr('real_estate_typology_4plus1_desc'),
          grossM2: ZoningUnitMix.grossArea4Plus1,
          count: _workingMix?.units4Plus1 ?? 0,
          onIncrement: () => _updateMix((m) => m.copyWith(units4Plus1: m.units4Plus1 + 1)),
          onDecrement: () => _updateMix((m) => m.copyWith(units4Plus1: (m.units4Plus1 - 1).clamp(0, 99))),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: NeoBrutalButton(
                label: context.tr('real_estate_kaks_btn_auto_optimize'),
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _workingMix =
                        ZoningEngine.optimizeUnitMix(zoning.netResidentialArea);
                  });
                },
                backgroundColor: const Color(0xFFFEF3C7),
                textColor: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 8),
            NeoBrutalButton(
              label: context.tr('real_estate_kaks_reset_btn'),
              icon: Icons.refresh_rounded,
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _workingMix = const ZoningUnitMix(
                    units1Plus1: 1,
                    units2Plus1: 1,
                    units3Plus1: 1,
                  );
                });
              },
              backgroundColor: const Color(0xFFF1F5F9),
              textColor: Colors.black,
            ),
          ],
        ),
        const SizedBox(height: 10),

        NeoBrutalButton(
          label: isExceeded
              ? context.tr('real_estate_kaks_warning_exceeded')
              : context.tr('real_estate_kaks_btn_confirm_mix'),
          icon: Icons.check_circle_rounded,
          onPressed: isExceeded
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  if (_workingMix != null) {
                    ref.read(gameProvider.notifier).saveUnitMix(land.id, _workingMix!.toMap());
                  }
                  NotificationService.showSuccess(
                    context,
                    context.tr('real_estate_kaks_confirmed_toast'),
                  );
                  setState(() {
                    _selectedTabIndex = 0; // Return to stages tab
                  });
                },
          backgroundColor: isExceeded
              ? const Color(0xFF94A3B8)
              : const Color(0xFF10B981),
          textColor: Colors.white,
        ),
      ],
    );
  }

  void _updateMix(ZoningUnitMix Function(ZoningUnitMix) update) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _workingMix ??
          const ZoningUnitMix(units1Plus1: 1, units2Plus1: 1, units3Plus1: 1);
      _workingMix = update(current);
    });
  }

  Widget _buildTypologySelectorCard({
    required BuildContext context,
    required String title,
    required String desc,
    required double grossM2,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Stepper Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
              ),
              Container(
                width: 38,
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 2: BELEDİYE DOSYASI CONTENT ---
  Widget _buildMunicipalDossierTab(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    bool isDark,
    bool isFinished,
  ) {
    final docs = ConstructionTimelineEngine.getMunicipalDocuments(
      land.constructionStage,
      isFinished: isFinished,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dossier Header
        NeoBrutalCard(
          backgroundColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          borderColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_rounded,
                      color: Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('municipal_dossier_header'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('municipal_dossier_guide'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...docs.map((doc) {
          final Color statusBg;
          final Color statusText;
          final String statusLabel;

          switch (doc.status) {
            case MunicipalDocStatus.approved:
              statusBg = const Color(0xFFD1FAE5);
              statusText = const Color(0xFF065F46);
              statusLabel = context.tr('municipal_status_approved');
              break;
            case MunicipalDocStatus.inReview:
              statusBg = const Color(0xFFDBEAFE);
              statusText = const Color(0xFF1D4ED8);
              statusLabel = context.tr('municipal_status_in_review');
              break;
            case MunicipalDocStatus.pendingFee:
              statusBg = const Color(0xFFFEF3C7);
              statusText = const Color(0xFF92400E);
              statusLabel = context.tr('municipal_status_pending_fee');
              break;
            case MunicipalDocStatus.locked:
              statusBg = const Color(0xFFE2E8F0);
              statusText = const Color(0xFF64748B);
              statusLabel = context.tr('municipal_status_locked');
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoBrutalCard(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.tr(doc.titleKey),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: statusLabel,
                        backgroundColor: statusBg,
                        textColor: statusText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(doc.authorityKey),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(doc.descriptionKey),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aşama ${doc.requiredStage} Zorunlu Evrakı',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                      Text(
                        context.tr('municipal_fee_label',
                            {'fee': CurrencyFormatter.format(doc.officialFee)}),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- TAB 3: TOPRAKTAN ÖN SATIŞ CONTENT ---
  Widget _buildPreSaleTab(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    bool isDark,
    bool isFinished,
  ) {
    if (land.constructionMode != 'selfBuild' ||
        land.constructionStage < 1 ||
        isFinished) {
      return NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_rounded,
                size: 36, color: Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            Text(
              context.tr('real_estate_construction_badge_idle'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('real_estate_presale_locked_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return _buildPreSaleCard(context, theme, land, isDark);
  }

  // --- 8-STAGE TIMELINE CARD (ZEIGARNIK PROGRESSION) ---
  Widget _buildEightStageTimelineCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    bool isDark,
    bool isFinished,
  ) {
    final stages = ConstructionTimelineEngine.stages;
    final currentStage = land.constructionStage;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('real_estate_construction_progress_header'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              NeoBrutalBadge(
                text: '%${land.constructionPercent}',
                backgroundColor: isFinished
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                textColor: isFinished ? Colors.white : Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Thick Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: land.constructionProgress,
                child: Container(
                  color: isFinished
                      ? const Color(0xFF10B981)
                      : (currentStage >= 4
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF59E0B)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Zeigarnik Suspense Hook Lore
          Text(
            context.tr('real_estate_construction_zeigarnik_lore'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const Divider(height: 24),

          // 8 Stages List
          Text(
            context.tr('real_estate_construction_timeline_title'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),

          ...stages.map((stage) {
            final isStagePassed = currentStage > stage.stageNumber;
            final isCurrentStage = currentStage == stage.stageNumber;
            final isWorking = isCurrentStage &&
                land.isConstructionWorking &&
                land.constructionDaysRemaining > 0;
            final isReady = isCurrentStage &&
                land.isConstructionWorking &&
                land.constructionDaysRemaining == 0;

            final IconData statusIcon;
            final Color statusColor;
            final String statusBadge;

            if (isStagePassed) {
              statusIcon = Icons.check_circle_rounded;
              statusColor = const Color(0xFF10B981);
              statusBadge = context.tr('subcontractor_badge_completed');
            } else if (isWorking) {
              statusIcon = Icons.play_circle_fill_rounded;
              statusColor = const Color(0xFFF59E0B);
              statusBadge =
                  '${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}';
            } else if (isReady) {
              statusIcon = Icons.task_alt_rounded;
              statusColor = const Color(0xFF10B981);
              statusBadge = context.tr('real_estate_stage_btn_handover');
            } else if (isCurrentStage) {
              statusIcon = Icons.pending_actions_rounded;
              statusColor = const Color(0xFF2563EB);
              statusBadge = context.tr('subcontractor_badge_unstarted');
            } else {
              statusIcon = Icons.radio_button_unchecked_rounded;
              statusColor = Colors.grey;
              statusBadge = context.tr('subcontractor_badge_locked');
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(statusIcon, size: 18, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${stage.stageNumber}. ${context.tr(stage.titleKey)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isStagePassed || isCurrentStage
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isStagePassed
                            ? (isDark ? Colors.white : Colors.black)
                            : (isCurrentStage
                                ? (isDark
                                    ? const Color(0xFF93C5FD)
                                    : const Color(0xFF1D4ED8))
                                : Colors.grey),
                      ),
                    ),
                  ),
                  Text(
                    statusBadge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- SELECTION OF MODES (START OF PROJECT) ---
  Widget _buildContractSelectionSection(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    ZoningProfile zoning,
    double balance,
    bool isDark,
  ) {
    final totalUnits = zoning.unitMix.totalUnits;
    final contractorUnits = (totalUnits * 0.5).round();
    final costIndex = ref.watch(gameProvider.select((s) => s.constructionCostIndex));
    final hasArchitectStaff = ref.watch(gameProvider.select((s) => s.hiredStaff.any((st) => st.role == StaffRole.appraiser || st.role == StaffRole.legalAdvisor)));
    final selfBuildInitialCost = ConstructionPricing.architecturalPlanCost(
      land,
      costIndex: costIndex,
      hasArchitectStaff: hasArchitectStaff,
    );
    final canAffordSelfBuild = balance >= selfBuildInitialCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner
        NeoBrutalCard(
          backgroundColor:
              isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.architecture_rounded,
                  color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('real_estate_construction_potential_desc',
                      {'units': totalUnits.toString()}),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // OPTION 1: KAT KARŞILIĞI MÜTEAHHİT ANLAŞMASI
        NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('real_estate_contractor_title'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  NeoBrutalBadge(
                    text: context.tr('real_estate_badge_zero_capital'),
                    backgroundColor: const Color(0xFFD1FAE5),
                    textColor: const Color(0xFF065F46),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('real_estate_contractor_desc'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(
                        Icons.handshake_rounded,
                        context.tr('real_estate_contractor_share', {
                          'share': '${100 - (land.isConstructionActive ? land.playerSharePercent : 50)}',
                        }),
                        const Color(0xFF10B981)),
                    _buildFeatureItem(
                        Icons.apartment_rounded,
                        context.tr('real_estate_contractor_units',
                            {'units': contractorUnits.toString()}),
                        const Color(0xFF3B82F6)),
                    _buildFeatureItem(
                        Icons.verified_rounded,
                        context.tr('real_estate_contractor_guarantee'),
                        const Color(0xFF8B5CF6)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('real_estate_contractor_btn'),
                      onPressed: zoning.isEmsalExceeded
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .startContractorConstruction(
                                    land.id,
                                    customUnitMix: _workingMix,
                                  );
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('real_estate_contractor_started_toast'),
                                );
                              }
                            },
                      backgroundColor: const Color(0xFF3B82F6),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalButton(
                    label: context.tr('real_estate_btn_negotiate_contractor'),
                    icon: Icons.chat_rounded,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/emlak-insaat/${land.id}/muteahhit');
                    },
                    backgroundColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // OPTION 2: KENDİ İNŞAATINI YAP (ÖZ-İNŞAAT)
        NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('real_estate_self_build_title'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  NeoBrutalBadge(
                    text: context.tr('real_estate_badge_all_units_share'),
                    backgroundColor: const Color(0xFFFEF3C7),
                    textColor: const Color(0xFF92400E),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('real_estate_self_build_desc'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(
                        Icons.star_rounded,
                        context.tr('real_estate_self_build_all_units',
                            {'units': totalUnits.toString()}),
                        const Color(0xFFF59E0B)),
                    _buildFeatureItem(
                        Icons.price_check_rounded,
                        context.tr('real_estate_self_build_presale_right'),
                        const Color(0xFF10B981)),
                    _buildFeatureItem(
                        Icons.trending_up_rounded,
                        context.tr('real_estate_self_build_max_profit'),
                        const Color(0xFFEC4899)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: (canAffordSelfBuild && !zoning.isEmsalExceeded)
                          ? '${context.tr('real_estate_self_build_plan_btn')} • ${CurrencyFormatter.format(selfBuildInitialCost)}'
                          : (zoning.isEmsalExceeded
                              ? context.tr('real_estate_kaks_warning_exceeded')
                              : context.tr('real_estate_expand_slots_error_funds')),
                      onPressed: (canAffordSelfBuild && !zoning.isEmsalExceeded)
                          ? () {
                              HapticFeedback.mediumImpact();
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .startSelfBuildArchitecturalPlan(
                                    land.id,
                                    customUnitMix: _workingMix,
                                  );
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr(
                                      'real_estate_self_build_plan_started_toast'),
                                );
                              }
                            }
                          : null,
                      backgroundColor: (canAffordSelfBuild && !zoning.isEmsalExceeded)
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF94A3B8),
                      textColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color iconColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- BENTO PROJECT STATS ---
  Widget _buildProjectStatsBento(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    final modeTitle = land.constructionMode == 'contractor'
        ? context.tr('real_estate_construction_mode_contractor')
        : context.tr('real_estate_construction_mode_self_build');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NeoBrutalCard(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('real_estate_stat_mode'),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modeTitle,
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalCard(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('real_estate_stat_player_units'),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${land.playerShareUnits} / ${land.totalProjectUnits} ${context.tr('real_estate_stat_units_suffix')}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalCard(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('real_estate_stat_days_remaining'),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      land.constructionDaysRemaining > 0
                          ? '${land.constructionDaysRemaining} ${context.tr('day')}'
                          : context.tr('real_estate_stat_stage_ready'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: land.constructionDaysRemaining > 0
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final costIndex = ref.watch(gameProvider.select((s) => s.constructionCostIndex));
                  return NeoBrutalCard(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('real_estate_construction_cost_index_title'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${costIndex.toStringAsFixed(2)}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: costIndex > 1.05
                                ? const Color(0xFFDC2626)
                                : (costIndex < 0.95 ? const Color(0xFF16A34A) : const Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalCard(
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('real_estate_quality_score_label'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${land.qualityScore.round()} / 100',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: land.qualityScore >= 80
                            ? const Color(0xFF16A34A)
                            : (land.qualityScore < 60 ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- CONSTRUCTION LOAN CARD ---
  Widget _buildConstructionLoanCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel land,
    double balance,
    bool isDark,
  ) {
    final maxLoan = (land.baseMarketValue * 0.50).roundToDouble();

    if (!land.isMortgaged) {
      return NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        padding: const EdgeInsets.all(16),
        borderColor: const Color(0xFF10B981),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('real_estate_construction_loan_dialog_title'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: 'Azami ${CurrencyFormatter.format(maxLoan)}',
                  backgroundColor: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF065F46),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('real_estate_construction_loan_dialog_desc'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            NeoBrutalButton(
              label: '${context.tr('real_estate_construction_loan_btn')} • ${CurrencyFormatter.format(maxLoan)}',
              backgroundColor: const Color(0xFF10B981),
              textColor: Colors.white,
              onPressed: () {
                _showTakeLoanDialog(context, land, maxLoan);
              },
            ),
          ],
        ),
      );
    } else {
      final loanId = 'loan_construction_${land.id}';
      final loans = ref.read(gameProvider).activeLoans;
      final loan = loans.cast<LoanModel?>().firstWhere((l) => l?.id == loanId, orElse: () => null);
      final remaining = loan?.remainingAmount ?? (maxLoan * 1.25);

      return NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        padding: const EdgeInsets.all(16),
        borderColor: const Color(0xFFEF4444),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('real_estate_mortgaged_badge'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: context.tr('real_estate_loan_debt_badge', {'amount': CurrencyFormatter.format(remaining)}),
                  backgroundColor: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('real_estate_construction_loan_repay_dialog_desc'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            NeoBrutalButton(
              label: '${context.tr('real_estate_construction_loan_repay_btn')} • ${CurrencyFormatter.format(remaining)}',
              backgroundColor: balance >= remaining ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
              textColor: Colors.white,
              onPressed: balance >= remaining
                  ? () {
                      _showRepayLoanDialog(context, land, remaining);
                    }
                  : null,
            ),
          ],
        ),
      );
    }
  }

  void _showTakeLoanDialog(BuildContext context, RealEstateModel land, double maxLoan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr('real_estate_construction_loan_dialog_title'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          context.tr('real_estate_construction_loan_dialog_desc'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.of(ctx).pop();
              final ok = ref.read(gameProvider.notifier).takeConstructionLoan(land.id, maxLoan);
              if (ok) {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_loan_taken_toast'),
                );
              }
            },
            child: Text(
              context.tr('real_estate_construction_loan_btn'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _showRepayLoanDialog(BuildContext context, RealEstateModel land, double remaining) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr('real_estate_construction_loan_repay_btn'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          context.tr('real_estate_construction_loan_repay_dialog_desc'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.of(ctx).pop();
              final ok = ref.read(gameProvider.notifier).repayConstructionLoan(land.id);
              if (ok) {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_loan_repaid_toast'),
                );
              }
            },
            child: Text(
              context.tr('real_estate_construction_loan_repay_btn'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // --- TOPRAKTAN ÖN SATIŞ CARD ---
  Widget _buildPreSaleCard(BuildContext context, ThemeData theme,
      RealEstateModel land, bool isDark) {
    final isLastUnitBlocked = land.playerShareUnits <= 1;

    return NeoBrutalCard(
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('real_estate_presale_title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E40AF),
                ),
              ),
              NeoBrutalBadge(
                text: isLastUnitBlocked
                    ? context.tr('real_estate_presale_last_unit_blocked')
                    : context.tr('real_estate_badge_hot_cash'),
                backgroundColor: isLastUnitBlocked
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDBEAFE),
                textColor: isLastUnitBlocked
                    ? const Color(0xFFB45309)
                    : const Color(0xFF1D4ED8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('real_estate_presale_desc'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (isLastUnitBlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('real_estate_presale_last_unit_blocked'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          NeoBrutalButton(
            label: isLastUnitBlocked
                ? context.tr('real_estate_presale_last_unit_blocked')
                : '${context.tr('real_estate_presale_btn')} • +${CurrencyFormatter.format(land.preSaleUnitPrice)}',
            onPressed: isLastUnitBlocked
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    final earned =
                        ref.read(gameProvider.notifier).preSellUnit(land.id);
                    if (earned > 0) {
                      NotificationService.showSuccess(
                        context,
                        context.tr('real_estate_presale_toast',
                            {'amount': CurrencyFormatter.format(earned)}),
                      );
                    }
                  },
            backgroundColor: isLastUnitBlocked
                ? const Color(0xFF94A3B8)
                : const Color(0xFF2563EB),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // --- ADVANCE STAGE (SELF BUILD) ---
  Widget _buildSelfBuildAdvanceCard(BuildContext context, ThemeData theme,
      RealEstateModel land, double balance, bool isDark) {
    final currentStage = land.constructionStage.clamp(1, 8);
    final costIndex = ref.watch(gameProvider.select((s) => s.constructionCostIndex));
    final hasLegalAdvisor = ref.watch(gameProvider.select((s) => s.hiredStaff.any((st) => st.role == StaffRole.legalAdvisor)));
    final hasArchitectStaff = ref.watch(gameProvider.select((s) => s.hiredStaff.any((st) => st.role == StaffRole.appraiser || st.role == StaffRole.legalAdvisor)));

    final isWorking =
        land.isConstructionWorking && land.constructionDaysRemaining > 0;
    final isReadyForHandover =
        land.isConstructionWorking && land.constructionDaysRemaining == 0;

    // Özel Aşama 1: Mimari Planlama & Belediye Ruhsatı
    if (land.constructionStage == 1) {
      if (!land.isArchitecturalApproved) {
        final planCost = ConstructionPricing.architecturalPlanCost(land, costIndex: costIndex, hasArchitectStaff: hasArchitectStaff);
        final canAffordPlan = balance >= planCost;

        return NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('real_estate_precon_plan_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  if (isWorking)
                    NeoBrutalBadge(
                      text: '${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}',
                      backgroundColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFF92400E),
                    )
                  else
                    NeoBrutalBadge(
                      text: context.tr('real_estate_stage_badge_unstarted'),
                      backgroundColor: const Color(0xFFE0E7FF),
                      textColor: const Color(0xFF3730A3),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isWorking
                    ? context.tr('real_estate_precon_plan_working_desc')
                    : context.tr('real_estate_precon_plan_idle_desc'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              if (isWorking)
                NeoBrutalButton(
                  label: context.tr('real_estate_precon_plan_btn_working'),
                  icon: Icons.hourglass_top_rounded,
                  onPressed: null,
                  backgroundColor: const Color(0xFFE2E8F0),
                  textColor: const Color(0xFF64748B),
                )
              else
                NeoBrutalButton(
                  label: canAffordPlan
                      ? '${context.tr('real_estate_self_build_plan_btn')} • ${CurrencyFormatter.format(planCost)}'
                      : context.tr('real_estate_expand_slots_error_funds'),
                  icon: Icons.architecture_rounded,
                  onPressed: canAffordPlan
                      ? () {
                          HapticFeedback.mediumImpact();
                          final success = ref.read(gameProvider.notifier).startSelfBuildArchitecturalPlan(land.id);
                          if (success) {
                            NotificationService.showSuccess(
                              context,
                              context.tr('real_estate_self_build_plan_started_toast'),
                            );
                          }
                        }
                      : null,
                  backgroundColor: canAffordPlan ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                  textColor: Colors.black,
                ),
            ],
          ),
        );
      } else if (!land.hasBuildingPermit) {
        final permitCost = ConstructionPricing.municipalPermitCost(land, costIndex: costIndex, hasLegalAdvisor: hasLegalAdvisor);
        final canAffordPermit = balance >= permitCost;

        return NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('real_estate_precon_permit_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  if (isWorking)
                    NeoBrutalBadge(
                      text: '${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}',
                      backgroundColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFF92400E),
                    )
                  else
                    NeoBrutalBadge(
                      text: context.tr('municipal_status_approved'),
                      backgroundColor: const Color(0xFFD1FAE5),
                      textColor: const Color(0xFF065F46),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isWorking
                    ? context.tr('real_estate_precon_permit_working_desc')
                    : context.tr('real_estate_precon_permit_idle_desc'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              if (isWorking)
                NeoBrutalButton(
                  label: context.tr('real_estate_precon_permit_btn_working'),
                  icon: Icons.hourglass_top_rounded,
                  onPressed: null,
                  backgroundColor: const Color(0xFFE2E8F0),
                  textColor: const Color(0xFF64748B),
                )
              else
                NeoBrutalButton(
                  label: canAffordPermit
                      ? '${context.tr('real_estate_precon_permit_btn')} • ${CurrencyFormatter.format(permitCost)}'
                      : context.tr('real_estate_expand_slots_error_funds'),
                  icon: Icons.account_balance_rounded,
                  onPressed: canAffordPermit
                      ? () {
                          HapticFeedback.mediumImpact();
                          final success = ref.read(gameProvider.notifier).submitSelfBuildMunicipalPermit(land.id);
                          if (success) {
                            NotificationService.showSuccess(
                              context,
                              context.tr('real_estate_precon_permit_submitted_toast'),
                            );
                          }
                        }
                      : null,
                  backgroundColor: canAffordPermit ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                  textColor: Colors.white,
                ),
            ],
          ),
        );
      }
    }

    final nextCost = ConstructionPricing.stageCost(land, currentStage);
    final canAfford = balance >= nextCost;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('real_estate_advance_title'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              if (isWorking)
                NeoBrutalBadge(
                  text:
                      '${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}',
                  backgroundColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFF92400E),
                )
              else if (isReadyForHandover)
                NeoBrutalBadge(
                  text: context.tr('real_estate_construction_badge_ready'),
                  backgroundColor: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF065F46),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isReadyForHandover
                ? context.tr('real_estate_stage_desc_ready_handover')
                : (isWorking
                    ? context.tr('real_estate_stage_desc_in_progress', {
                        'days': land.constructionDaysRemaining.toString(),
                        'name': land.activeSubcontractorName ?? 'Taşeron Ekibi',
                      })
                    : context.tr('real_estate_advance_desc')),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          if (isReadyForHandover)
            NeoBrutalButton(
              label: context.tr('real_estate_stage_btn_handover'),
              icon: Icons.check_circle_rounded,
              onPressed: () {
                HapticFeedback.heavyImpact();
                final success = ref
                    .read(gameProvider.notifier)
                    .completeSelfBuildStage(land.id);
                if (success) {
                  GameSoundHapticService.playCashSuccess();
                  NotificationService.showSuccess(
                    context,
                    context.tr('real_estate_advance_success_toast'),
                  );
                }
              },
              backgroundColor: const Color(0xFF10B981),
              textColor: Colors.white,
            )
          else if (isWorking)
            NeoBrutalButton(
              label: context.tr('real_estate_stage_btn_working', {
                'days': land.constructionDaysRemaining.toString(),
              }),
              icon: Icons.hourglass_top_rounded,
              onPressed: null,
              backgroundColor: const Color(0xFFE2E8F0),
              textColor: const Color(0xFF64748B),
            )
          else
            NeoBrutalButton(
              label: canAfford
                  ? '${context.tr('real_estate_stage_btn_select_subcontractor')} • ${CurrencyFormatter.format(nextCost)}'
                  : context.tr('real_estate_expand_slots_error_funds'),
              icon: Icons.play_arrow_rounded,
              onPressed: canAfford
                  ? () {
                      HapticFeedback.mediumImpact();
                      context.push('/emlak-insaat/${land.id}/taseron');
                    }
                  : null,
              backgroundColor: canAfford
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
              textColor: Colors.white,
            ),
          if (isWorking) ...[
            const SizedBox(height: 8),
            NeoBrutalButton(
              label: context.tr('subcontractor_btn_active_with_days', {
                'name': land.activeSubcontractorName ?? 'Taşeron Ekibi',
                'days': land.constructionDaysRemaining.toString(),
              }),
              icon: Icons.engineering_rounded,
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/emlak-insaat/${land.id}/taseron');
              },
              backgroundColor: const Color(0xFFFEF3C7),
              textColor: const Color(0xFF92400E),
            ),
          ],
        ],
      ),
    );
  }

  // --- SITE RADIO DISPATCH CARD ---
  Widget _buildSiteRadioDispatchCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    String latestDispatch = '';
    for (final log in land.provenanceLog.reversed) {
      if (log.contains('Şantiye Telsizi:') ||
          log.contains('Şantiye Olayı:') ||
          log.contains('Aşama') ||
          log.contains('Taşeron:')) {
        final parts = log.split('•');
        if (parts.length >= 2) {
          latestDispatch = parts.sublist(1).join('•').trim();
        } else {
          latestDispatch = log;
        }
        break;
      }
    }

    if (latestDispatch.isEmpty) {
      latestDispatch = context.tr('real_estate_radio_default_quote');
    }

    return NeoBrutalCard(
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
      borderColor: const Color(0xFFF59E0B),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.radio_rounded,
                      color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('real_estate_radio_dispatch_title'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: land.isConstructionWorking
                    ? context.tr('real_estate_radio_badge_channel')
                    : context.tr('real_estate_radio_badge_standby'),
                backgroundColor: const Color(0xFFFEF3C7),
                textColor: const Color(0xFF92400E),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFFDE68A),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    latestDispatch,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white70 : const Color(0xFF78350F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTRACTOR WAIT CARD ---
  Widget _buildContractorWaitCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    return NeoBrutalCard(
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: Color(0xFF3B82F6), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('real_estate_contractor_working_title'),
                  style:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('real_estate_contractor_working_desc',
                      {'days': land.constructionDaysRemaining.toString()}),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FINALIZE & CLAIM APARTMENTS CARD ---
  Widget _buildFinalizeCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    return NeoBrutalCard(
      backgroundColor:
          isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: Color(0xFF10B981), size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('real_estate_completion_title'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('real_estate_completion_desc',
                {'units': land.playerShareUnits.toString()}),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(height: 14),
          NeoBrutalButton(
            label: context.tr('real_estate_finalize_btn'),
            onPressed: () {
              HapticFeedback.heavyImpact();
              final created =
                  ref.read(gameProvider.notifier).finalizeConstruction(land.id);
              if (created.isNotEmpty) {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_finalize_success_toast',
                      {'count': created.length.toString()}),
                );
                context.pop();
              } else {
                NotificationService.showError(
                  context,
                  context.tr('real_estate_finalize_failed'),
                );
              }
            },
            backgroundColor: const Color(0xFF10B981),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildZoningStatBox(String label, String value, bool isDark,
      {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
