import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/construction_stages_model.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../domain/usecases/zoning_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class RealEstateConstructionScreen extends ConsumerWidget {
  final String landId;

  const RealEstateConstructionScreen({
    super.key,
    required this.landId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);

    final landIndex = game.ownedRealEstates.indexWhere((p) => p.id == landId);

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
    final isFinished = land.constructionStage >= 4;
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
            _buildLandOverviewCard(context, theme, land, isDark),
            const SizedBox(height: 14),

            // 2. ACTIVE CONSTRUCTION OR SELECTION MODES
            if (land.constructionStage == 0 && !isActive) ...[
              _buildContractSelectionSection(context, theme, land, game.balance, ref, isDark),
            ] else ...[
              // ZEIGARNIK 4-STEPPER CONSTRUCTION CARD
              _buildZeigarnikConstructionCard(context, theme, land, isDark),
              const SizedBox(height: 14),

              // BENTO PROJECT STATS
              _buildProjectStatsBento(context, theme, land, isDark),
              const SizedBox(height: 14),

              // TOPRAKTAN ÖN SATIŞ CARD (If selfBuild and under construction)
              if (land.constructionMode == 'selfBuild' &&
                  land.constructionStage >= 1 &&
                  land.constructionStage < 4) ...[
                _buildPreSaleCard(context, theme, land, ref, isDark),
                const SizedBox(height: 14),
              ],

              // SELF BUILD NEXT STAGE FUNDING OR COMPLETION
              if (isFinished) ...[
                _buildFinalizeCard(context, theme, land, ref, isDark),
              ] else if (land.constructionMode == 'selfBuild') ...[
                _buildSelfBuildAdvanceCard(context, theme, land, game.balance, ref, isDark),
              ] else ...[
                _buildContractorWaitCard(context, theme, land, isDark),
              ],
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 1. LAND OVERVIEW CARD ---
  Widget _buildLandOverviewCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Builder(builder: (_) {
                    final z = ZoningEngine.calculateZoning(
                      parcelSquareMeters: land.squareMeters.toDouble(),
                    );
                    return NeoBrutalBadge(
                      text: 'TAKS ${z.taks.toStringAsFixed(2)} • KAKS ${z.kaks.toStringAsFixed(2)}',
                      backgroundColor: const Color(0xFFDBEAFE),
                      textColor: const Color(0xFF1D4ED8),
                    );
                  }),
                  NeoBrutalBadge(
                    text: context.tr(land.deedType.localizationKey),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. SELECTION OF CONSTRUCTION MODES ---
  Widget _buildContractSelectionSection(BuildContext context, ThemeData theme,
      RealEstateModel land, double balance, WidgetRef ref, bool isDark) {
    final zoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: land.squareMeters.toDouble(),
      baseMarketValue: land.baseMarketValue,
    );
    final totalUnits = zoning.unitMix.totalUnits;
    final contractorUnits = (totalUnits * 0.5).round();
    final selfBuildInitialCost = (land.baseMarketValue * 0.15).roundToDouble();
    final canAffordSelfBuild = balance >= selfBuildInitialCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner
        NeoBrutalCard(
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
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
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(
                        Icons.handshake_rounded,
                        context.tr('real_estate_contractor_share',
                            {'share': '50'}),
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
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final success = ref
                            .read(gameProvider.notifier)
                            .startContractorConstruction(land.id);
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

        // ZONING POTENTIAL BLUEPRINT CARD
        _buildZoningPotentialCard(context, theme, land, zoning, isDark),
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
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
                      label: canAffordSelfBuild
                          ? '${context.tr('real_estate_self_build_btn')} • ${CurrencyFormatter.format(selfBuildInitialCost)}'
                          : context.tr('real_estate_expand_slots_error_funds'),
                      onPressed: canAffordSelfBuild
                          ? () {
                              HapticFeedback.mediumImpact();
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .startSelfBuildConstruction(land.id);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('real_estate_self_build_success_toast'),
                                );
                              }
                            }
                          : null,
                      backgroundColor: canAffordSelfBuild
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF94A3B8),
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalButton(
                    label: '120 Günlük Şantiye Ağı',
                    icon: Icons.engineering_rounded,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/emlak-insaat/${land.id}/taseron');
                    },
                    backgroundColor: const Color(0xFFFEF3C7),
                    textColor: const Color(0xFF92400E),
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

  // --- 3. ZEIGARNIK 4-STEPPER CONSTRUCTION CARD ---
  Widget _buildZeigarnikConstructionCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    String currentStageText;
    switch (land.constructionStage) {
      case 1:
        currentStageText = context.tr('real_estate_construction_stage1_status');
        break;
      case 2:
        currentStageText = context.tr('real_estate_construction_stage2_status');
        break;
      case 3:
        currentStageText = context.tr('real_estate_construction_stage3_status');
        break;
      case 4:
        currentStageText = context.tr('real_estate_construction_stage4_status');
        break;
      default:
        currentStageText = context.tr('real_estate_construction_stage0_status');
    }

    final isFinished = land.constructionStage >= 4;

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
                  fontSize: 13,
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
                      : (land.constructionStage >= 2
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF59E0B)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Zeigarnik Suspense Hook Text
          Text(
            currentStageText,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isFinished
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('real_estate_construction_zeigarnik_lore'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const Divider(height: 24),

          // 4 Milestone Indicators
          _buildMilestoneRow(
              context, 1, context.tr('real_estate_stage_m1_title'), land.constructionStage >= 1),
          const SizedBox(height: 8),
          _buildMilestoneRow(
              context, 2, context.tr('real_estate_stage_m2_title'), land.constructionStage >= 2),
          const SizedBox(height: 8),
          _buildMilestoneRow(
              context, 3, context.tr('real_estate_stage_m3_title'), land.constructionStage >= 3),
          const SizedBox(height: 8),
          _buildMilestoneRow(
              context, 4, context.tr('real_estate_stage_m4_title'), land.constructionStage >= 4),
          if (land.constructionMode == 'selfBuild') ...[
            const Divider(height: 24),
            _buildNineStageMilestones(context, land, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildNineStageMilestones(
      BuildContext context, RealEstateModel land, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('real_estate_nine_stage_spec_title'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        ...ConstructionStagesCatalog.stages.map((stage) {
          final isStagePassed = (land.constructionStage == 1 && stage.stageNumber <= 2) ||
              (land.constructionStage == 2 && stage.stageNumber <= 4) ||
              (land.constructionStage == 3 && stage.stageNumber <= 7) ||
              (land.constructionStage >= 4);
          final isCurrentStage = !isStagePassed && (
              (land.constructionStage == 1 && stage.stageNumber == 1) ||
              (land.constructionStage == 2 && stage.stageNumber == 3) ||
              (land.constructionStage == 3 && stage.stageNumber == 5) ||
              (land.constructionStage == 4 && stage.stageNumber == 8)
          );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  isStagePassed
                      ? Icons.check_circle_rounded
                      : (isCurrentStage
                          ? Icons.play_circle_fill_rounded
                          : Icons.radio_button_unchecked_rounded),
                  size: 16,
                  color: isStagePassed
                      ? const Color(0xFF10B981)
                      : (isCurrentStage ? const Color(0xFFF59E0B) : Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isStagePassed || isCurrentStage
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isStagePassed
                          ? (isDark ? Colors.white : Colors.black)
                          : (isCurrentStage
                              ? const Color(0xFFD97706)
                              : Colors.grey),
                    ),
                  ),
                ),
                Text(
                  stage.milestoneName,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildZoningPotentialCard(BuildContext context, ThemeData theme,
      RealEstateModel land, ZoningProfile zoning, bool isDark) {
    return NeoBrutalCard(
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(14),
      borderColor: const Color(0xFF2563EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.architecture_rounded,
                      color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('real_estate_zoning_sheet_title'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: 'TAKS ${zoning.taks.toStringAsFixed(2)} • KAKS ${zoning.kaks.toStringAsFixed(2)}',
                backgroundColor: const Color(0xFFDBEAFE),
                textColor: const Color(0xFF1D4ED8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildZoningStatBox(
                  context.tr('real_estate_zoning_footprint'),
                  '${zoning.footprintArea.toStringAsFixed(0)} m²',
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildZoningStatBox(
                  context.tr('real_estate_zoning_total_area'),
                  '${zoning.totalConstructionArea.toStringAsFixed(0)} m²',
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildZoningStatBox(
                  context.tr('real_estate_zoning_floors'),
                  '${zoning.maxFloors} Kat',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUnitTag('1+1', '${zoning.unitMix.units1Plus1} Adet',
                    const Color(0xFF3B82F6)),
                _buildUnitTag('2+1', '${zoning.unitMix.units2Plus1} Adet',
                    const Color(0xFF10B981)),
                _buildUnitTag('3+1', '${zoning.unitMix.units3Plus1} Adet',
                    const Color(0xFF8B5CF6)),
                _buildUnitTag('Toplam', '${zoning.unitMix.totalUnits} Daire',
                    const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoningStatBox(String label, String value, bool isDark) {
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTag(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          count,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildMilestoneRow(
      BuildContext context, int step, String title, bool isDone) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
              color: isDone ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. PROJECT STATS BENTO ---
  Widget _buildProjectStatsBento(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    final modeTitle = land.constructionMode == 'contractor'
        ? context.tr('real_estate_construction_mode_contractor')
        : context.tr('real_estate_construction_mode_self_build');

    return Row(
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 2),
                Text(
                  modeTitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
    );
  }

  // --- 5. TOPRAKTAN ÖN SATIŞ CARD ---
  Widget _buildPreSaleCard(BuildContext context, ThemeData theme,
      RealEstateModel land, WidgetRef ref, bool isDark) {
    final isLastUnitBlocked = land.playerShareUnits <= 1;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
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

  // --- 6. ADVANCE STAGE (SELF BUILD) ---
  Widget _buildSelfBuildAdvanceCard(BuildContext context, ThemeData theme,
      RealEstateModel land, double balance, WidgetRef ref, bool isDark) {
    final double stageRate;
    switch (land.constructionStage) {
      case 1:
        stageRate = 0.25;
        break;
      case 2:
        stageRate = 0.20;
        break;
      case 3:
        stageRate = 0.15;
        break;
      default:
        stageRate = 0.15;
    }
    final nextCost = (land.baseMarketValue * stageRate).roundToDouble();
    final canAfford = balance >= nextCost;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('real_estate_advance_title'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('real_estate_advance_desc'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          NeoBrutalButton(
            label: canAfford
                ? '${context.tr('real_estate_advance_stage_btn')} • ${CurrencyFormatter.format(nextCost)}'
                : context.tr('real_estate_expand_slots_error_funds'),
            onPressed: canAfford
                ? () {
                    HapticFeedback.heavyImpact();
                    final success = ref
                        .read(gameProvider.notifier)
                        .advanceSelfBuildStage(land.id);
                    if (success) {
                      NotificationService.showSuccess(
                        context,
                        context.tr('real_estate_advance_success_toast'),
                      );
                    }
                  }
                : null,
            backgroundColor: canAfford
                ? const Color(0xFFF59E0B)
                : const Color(0xFF94A3B8),
            textColor: Colors.black,
          ),
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: '120 Günlük Şantiye & Taşeron Ağı',
            icon: Icons.engineering_rounded,
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/emlak-insaat/${land.id}/taseron');
            },
            backgroundColor: const Color(0xFFEFF6FF),
            textColor: const Color(0xFF1D4ED8),
          ),
        ],
      ),
    );
  }

  // --- 7. CONTRACTOR WAIT CARD ---
  Widget _buildContractorWaitCard(
      BuildContext context, ThemeData theme, RealEstateModel land, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('real_estate_contractor_working_desc',
                      {'days': land.constructionDaysRemaining.toString()}),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. FINALIZE & CLAIM APARTMENTS CARD ---
  Widget _buildFinalizeCard(BuildContext context, ThemeData theme,
      RealEstateModel land, WidgetRef ref, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
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
              } else {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_finalize_success_toast',
                      {'count': '0'}),
                );
              }
              context.pop();
            },
            backgroundColor: const Color(0xFF10B981),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
