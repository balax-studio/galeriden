import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/real_estate_model.dart';
import '../../../../domain/usecases/zoning_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class ContractorNegotiationSheet extends ConsumerStatefulWidget {
  final RealEstateModel land;

  const ContractorNegotiationSheet({
    super.key,
    required this.land,
  });

  static Future<void> show({
    required BuildContext context,
    required RealEstateModel land,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContractorNegotiationSheet(land: land),
    );
  }

  @override
  ConsumerState<ContractorNegotiationSheet> createState() =>
      _ContractorNegotiationSheetState();
}

class _ContractorNegotiationSheetState
    extends ConsumerState<ContractorNegotiationSheet> {
  late ZoningProfile _zoning;
  late int _selectedContractorIndex;
  late int _playerSharePercent;
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    _zoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: widget.land.squareMeters.toDouble(),
      baseMarketValue: widget.land.baseMarketValue,
    );
    _selectedContractorIndex = 0;
    _playerSharePercent = ZoningEngine.standardContractors[0].defaultPlayerSharePercent;
  }

  void _onContractorSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedContractorIndex = index;
      _playerSharePercent =
          ZoningEngine.standardContractors[index].defaultPlayerSharePercent;
    });
  }

  void _signAgreement() {
    if (_isSigning) return;
    setState(() => _isSigning = true);

    HapticFeedback.heavyImpact();
    GameSoundHapticService.playCashSuccess();

    final success = ref.read(gameProvider.notifier).startContractorConstruction(
          widget.land.id,
          sharePercent: _playerSharePercent,
          customTotalUnits: _zoning.totalUnits,
        );

    if (success) {
      NotificationService.showSuccess(
        context,
        context.tr('contractor_agreement_success_toast', {'district': widget.land.district}),
      );
      Navigator.of(context).pop();
    } else {
      setState(() => _isSigning = false);
      NotificationService.showError(
        context,
        context.tr('contractor_agreement_error_toast'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerUnits = (_zoning.totalUnits * _playerSharePercent / 100).round();
    final contractorUnits = _zoning.totalUnits - playerUnits;
    final projectedPlayerRevenue = playerUnits * _zoning.turnkeyEstimatedUnitValue;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('contractor_sheet_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.land.city} • ${widget.land.district} • ${widget.land.squareMeters} m²',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Zoning Parameters Card
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('contractor_zoning_report_title'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      NeoBrutalBadge(
                        text: 'TAKS: ${_zoning.taks.toStringAsFixed(2)}',
                        backgroundColor: const Color(0xFFE0E7FF),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('contractor_kaks_badge', {'kaks': _zoning.kaks.toStringAsFixed(2)}),
                        backgroundColor: const Color(0xFFD1FAE5),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('contractor_total_area_badge', {'area': _zoning.totalConstructionArea.round()}),
                        backgroundColor: const Color(0xFFFEF3C7),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('contractor_max_floors_badge', {'floors': _zoning.calculatedFloors}),
                        backgroundColor: const Color(0xFFF1F5F9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_rounded, size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('contractor_mix_summary', {
                              'summary': _zoning.unitMix.summaryText,
                              'total': _zoning.totalUnits,
                            }),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Contractor Profile Selection
            Text(
              context.tr('contractor_select_title'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                ZoningEngine.standardContractors.length,
                (index) {
                  final cp = ZoningEngine.standardContractors[index];
                  final isSelected = _selectedContractorIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _onContractorSelected(index),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.black,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 8),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        cp.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      NeoBrutalBadge(
                                        text: context.tr('contractor_trust_badge', {'score': (cp.reliabilityScore * 100).round()}),
                                        backgroundColor: cp.reliabilityScore >= 0.90
                                            ? const Color(0xFFD1FAE5)
                                            : const Color(0xFFFEF3C7),
                                        textColor: cp.reliabilityScore >= 0.90
                                            ? const Color(0xFF065F46)
                                            : const Color(0xFF92400E),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cp.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cp.description,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 12),

            // Share Percentage Negotiation Slider
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('contractor_share_slider_title'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        context.tr('contractor_landowner_share', {'percent': _playerSharePercent}),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _playerSharePercent.toDouble(),
                    min: 40,
                    max: 60,
                    divisions: 4,
                    label: '%$_playerSharePercent',
                    activeColor: const Color(0xFF2563EB),
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _playerSharePercent = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUnitSummaryBox(
                        title: context.tr('contractor_your_share_box'),
                        value: context.tr('contractor_units_count', {'units': playerUnits}),
                        subtext: context.tr('contractor_contractor_units_subtext', {'units': contractorUnits}),
                        color: const Color(0xFF10B981),
                      ),
                      _buildUnitSummaryBox(
                        title: context.tr('contractor_estimated_revenue_box'),
                        value: CurrencyFormatter.format(projectedPlayerRevenue),
                        subtext: context.tr('contractor_turnkey_subtext'),
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confirmation Button
            NeoBrutalButton(
              label: context.tr('contractor_btn_sign_agreement'),
              icon: Icons.assignment_turned_in_rounded,
              backgroundColor: const Color(0xFF10B981),
              isLoading: _isSigning,
              onPressed: _isSigning ? null : _signAgreement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSummaryBox({
    required String title,
    required String value,
    required String subtext,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
