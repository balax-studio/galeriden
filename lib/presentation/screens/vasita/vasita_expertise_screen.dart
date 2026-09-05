import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/listing_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/vasita_market_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_stamp.dart';
import 'vasita_negotiation_screen.dart';

class VasitaExpertiseScreen extends ConsumerStatefulWidget {
  final String? listingId;
  final ListingModel? initialListing;

  const VasitaExpertiseScreen({
    super.key,
    this.listingId,
    this.initialListing,
  }) : assert(listingId != null || initialListing != null, 'Either listingId or initialListing must be provided');

  @override
  ConsumerState<VasitaExpertiseScreen> createState() => _VasitaExpertiseScreenState();
}

class _VasitaExpertiseScreenState extends ConsumerState<VasitaExpertiseScreen> {
  static const double diagnosticCost = 3500.0;
  bool _isProcessingDiagnostic = false;

  ListingModel? _findListing(List<ListingModel> allListings) {
    final targetId = widget.listingId ?? widget.initialListing?.id;
    if (targetId == null) return widget.initialListing;
    try {
      return allListings.firstWhere((l) => l.id == targetId);
    } catch (_) {
      return widget.initialListing;
    }
  }

  Future<void> _runDiagnostic(ListingModel listing) async {
    final game = ref.read(gameProvider);
    if (game.balance < diagnosticCost) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('noter_buy_error_funds'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isProcessingDiagnostic = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    final success = ref
        .read(vasitaMarketProvider.notifier)
        .performDetailedExpertise(listing.id, cost: diagnosticCost);

    if (mounted) {
      setState(() => _isProcessingDiagnostic = false);
      if (success) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('vasita_expertise_complete_desc'),
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
            ),
            backgroundColor: const Color(0xFF00E575),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allListings = ref.watch(vasitaMarketProvider);
    final listing = _findListing(allListings);
    final game = ref.watch(gameProvider);

    if (listing == null) {
      return Scaffold(
        appBar: NeoBrutalAppBar(title: context.tr('vasita_expertise_title')),
        body: Center(
          child: Text(
            context.tr('empty_cars_found'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final car = listing.car;
    final exp = car.expertise;
    final isCompleted = listing.isExpertiseCompleted;
    final canAfford = game.balance >= diagnosticCost;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('vasita_expertise_title'),
        statusBadge: NeoBrutalBadge(
          text: isCompleted
              ? context.tr('vasita_expertise_seal_text')
              : context.tr('vasita_expertise_zeigarnik_badge').replaceAll('{percent}', '65'),
          backgroundColor: isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFB020),
          textColor: Colors.black,
          fontSize: 10,
        ),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.workshop,
        child: ListView(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 100 + MediaQuery.paddingOf(context).bottom),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Vehicle Identification & TSE Seal Header
            _buildVehicleOverviewCard(context, listing, isDark, isCompleted),

            const SizedBox(height: 14),

            // 2. Psychological Zeigarnik Effect Card (Incomplete vs Complete)
            _buildZeigarnikProgressCard(context, listing, isDark, isCompleted, canAfford),

            const SizedBox(height: 14),

            // 3. Body Paint & Panel Inspection Matrix
            _buildBodyPartsInspectionMatrix(context, exp, isDark, isCompleted),

            const SizedBox(height: 14),

            // 4. Mechanical & Telemetry Diagnostic Card
            _buildMechanicalDiagnosticCard(context, car, exp, isDark, isCompleted),

            const SizedBox(height: 14),

            // 5. Tramer Damage History & Seller Disclosure
            _buildTramerAndSellerCard(context, listing, exp, isDark, isCompleted),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionSheet(context, listing, isDark, isCompleted),
    );
  }

  Widget _buildVehicleOverviewCard(
    BuildContext context,
    ListingModel listing,
    bool isDark,
    bool isCompleted,
  ) {
    final car = listing.car;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NeoBrutalBadge(
                    text: context.tr(car.vehicleCategory.localizationKey).toUpperCase(),
                    backgroundColor: car.vehicleCategory.badgeColor,
                    textColor: Colors.black,
                    fontSize: 9.5,
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalBadge(
                    text: '${car.modelYear}',
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${car.brand} ${car.modelName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${car.bodyType} • ${car.colorDisplayName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('deal_seller_asking_price'),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      Text(
                        CurrencyFormatter.format(listing.askingPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E575),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        context.tr('noter_field_mileage'),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${car.expertise.mileage} KM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (isCompleted)
            Positioned(
              top: 0,
              right: 0,
              child: NeoBrutalStamp(
                text: context.tr('vasita_expertise_seal_text'),
                color: const Color(0xFF00E575),
                fontSize: 10,
                angle: -0.08,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZeigarnikProgressCard(
    BuildContext context,
    ListingModel listing,
    bool isDark,
    bool isCompleted,
    bool canAfford,
  ) {
    if (isCompleted) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: const Color(0xFF00E575).withValues(alpha: isDark ? 0.15 : 0.12),
        borderColor: const Color(0xFF00E575),
        borderRadius: 12,
        borderWidth: 2.5,
        shadowOffset: const Offset(4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF00E575), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('vasita_expertise_complete_desc'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                value: 1.0,
                minHeight: 8,
                backgroundColor: Color(0xFF2A3142),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E575)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('vasita_sunk_cost_warning').replaceAll('{amount}', '3.500'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      );
    }

    // Incomplete Zeigarnik Psychological State
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: const Color(0xFFFFB020).withValues(alpha: isDark ? 0.15 : 0.12),
      borderColor: const Color(0xFFFFB020),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB020), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('vasita_expertise_zeigarnik_badge').replaceAll('{percent}', '65'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFB020),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 10,
              backgroundColor: Color(0xFF2A3142),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB020)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.tr('vasita_expertise_incomplete_desc'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFB020),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(diagnosticCost),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFB020),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('vasita_sunk_cost_warning').replaceAll('{amount}', '3.500'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeoBrutalButton(
              icon: Icons.search_rounded,
              label: _isProcessingDiagnostic
                  ? context.tr('vasita_think_step_1')
                  : context.tr('vasita_expertise_btn_full_check').replaceAll('{cost}', CurrencyFormatter.format(diagnosticCost)),
              backgroundColor: canAfford ? const Color(0xFFFFB020) : const Color(0xFF64748B),
              textColor: Colors.black,
              fontSize: 12,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: (_isProcessingDiagnostic || !canAfford)
                  ? null
                  : () => _runDiagnostic(listing),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartsInspectionMatrix(
    BuildContext context,
    ExpertiseReport exp,
    bool isDark,
    bool isCompleted,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('exp_body_schema_title'),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              Icon(
                isCompleted ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 18,
                color: isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFB020),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exp.bodyParts.entries.map((entry) {
              final partName = entry.key;
              final status = entry.value;

              if (!isCompleted) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        partName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFB020),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Inspected & Unlocked state
              Color statusColor;
              String statusLabel;

              switch (status) {
                case PartStatus.original:
                  statusColor = const Color(0xFF00E575);
                  statusLabel = context.tr('vasita_expertise_original');
                  break;
                case PartStatus.painted:
                  statusColor = const Color(0xFFFFB020);
                  statusLabel = context.tr('vasita_expertise_painted');
                  break;
                case PartStatus.changed:
                  statusColor = const Color(0xFFF97316);
                  statusLabel = context.tr('vasita_expertise_changed');
                  break;
                case PartStatus.damaged:
                  statusColor = const Color(0xFFEF4444);
                  statusLabel = context.tr('vasita_expertise_damaged');
                  break;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  border: Border.all(color: statusColor, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      partName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicalDiagnosticCard(
    BuildContext context,
    dynamic car,
    ExpertiseReport exp,
    bool isDark,
    bool isCompleted,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('dyno_dialog_title'),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              NeoBrutalBadge(
                text: isCompleted
                    ? '${(exp.engineCondition * 1.5).round()} HP'
                    : '? HP',
                backgroundColor: isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFB020),
                textColor: Colors.black,
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTelemetryRow(
            title: context.tr('exp_engine_health'),
            valuePct: isCompleted ? exp.engineCondition.toInt() : 65,
            isLocked: !isCompleted,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTelemetryRow(
            title: context.tr('exp_transmission_health'),
            valuePct: isCompleted ? exp.transmissionCondition.toInt() : 70,
            isLocked: !isCompleted,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTelemetryRow(
            title: context.tr('vasita_expertise_brake_efficiency'),
            valuePct: isCompleted ? 88 : 60,
            isLocked: !isCompleted,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTelemetryRow(
            title: context.tr('vasita_expertise_suspension'),
            valuePct: isCompleted ? 82 : 55,
            isLocked: !isCompleted,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow({
    required String title,
    required int valuePct,
    required bool isLocked,
    required bool isDark,
  }) {
    final color = valuePct >= 80
        ? const Color(0xFF00E575)
        : (valuePct >= 60 ? const Color(0xFFFFB020) : const Color(0xFFEF4444));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            Text(
              isLocked ? '%?' : '%$valuePct',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isLocked ? const Color(0xFFFFB020) : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isLocked ? 0.30 : (valuePct / 100.0),
            minHeight: 6,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(isLocked ? const Color(0xFFFFB020) : color),
          ),
        ),
      ],
    );
  }

  Widget _buildTramerAndSellerCard(
    BuildContext context,
    ListingModel listing,
    ExpertiseReport exp,
    bool isDark,
    bool isCompleted,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('exp_tramer_title'),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              Text(
                isCompleted
                    ? CurrencyFormatter.format(exp.tramerAmount.toDouble())
                    : context.tr('vasita_expertise_tramer_masked'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                '${listing.getLocalizedSellerName(context)} • ${listing.sellerCity}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            listing.description,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSheet(
    BuildContext context,
    ListingModel listing,
    bool isDark,
    bool isCompleted,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        children: [
          NeoBrutalButton(
            label: context.tr('btn_close'),
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white : Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NeoBrutalButton(
              icon: Icons.handshake_rounded,
              label: context.tr('vasita_expertise_btn_negotiate'),
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 12,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VasitaNegotiationScreen(listing: listing),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
