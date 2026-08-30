import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/neo_brutal_segmented_gauge.dart';
import '../../../widgets/neo_brutal_slider.dart';

class NegotiationOfferDialCard extends StatelessWidget {
  final double offeredPrice;
  final double askingPrice;
  final int chancePercent;
  final double decorBonus;
  final bool isDark;
  final bool isLocked;
  final ValueChanged<double> onPriceChanged;
  final void Function(double discountPercent) onSnapDiscount;

  const NegotiationOfferDialCard({
    super.key,
    required this.offeredPrice,
    required this.askingPrice,
    required this.chancePercent,
    required this.decorBonus,
    required this.isDark,
    required this.isLocked,
    required this.onPriceChanged,
    required this.onSnapDiscount,
  });

  Color get _chanceColor {
    if (chancePercent >= 70) return const Color(0xFF00E575);
    if (chancePercent >= 45) return const Color(0xFFFFDE59);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final discountAmount = askingPrice - offeredPrice;
    final discountRatio =
        askingPrice > 0 ? (discountAmount / askingPrice * 100).round() : 0;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderWidth: 2,
      borderRadius: 12,
      shadowOffset: const Offset(3, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.tr('negotiation_your_offer_title'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              Row(
                children: [
                  if (decorBonus > 0) ...[
                    const NeoBrutalBadge(
                      icon: Icons.chair_rounded,
                      text: '+%4 Makam',
                      backgroundColor: Color(0xFFD97706),
                      textColor: Colors.black,
                      borderWidth: 1.5,
                      fontSize: 10,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    ),
                    const SizedBox(width: 4),
                  ],
                  NeoBrutalBadge(
                    icon: Icons.psychology_rounded,
                    text: context.tr('deal_persuasion_chance', {
                      'chance': chancePercent,
                    }),
                    backgroundColor: _chanceColor,
                    textColor: Colors.black,
                    borderWidth: 1.5,
                    fontSize: 11,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Stencil Price Display & Discount Diff
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(offeredPrice),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark
                      ? const Color(0xFFFFDE59)
                      : const Color(0xFF0F172A),
                ),
              ),
              Text(
                discountAmount > 0
                    ? context
                        .tr('deal_discount_info', {'pct': '$discountRatio'})
                    : context.tr('deal_full_price_offer'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: discountAmount > 0
                      ? (isDark
                          ? const Color(0xFF00E575)
                          : const Color(0xFF15803D))
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Bargaining Snap Chips (-%5, -%10, -%15, -%20, -%25, Tam Fiyat)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickSnapChip('-%5', 0.05),
                const SizedBox(width: 6),
                _buildQuickSnapChip('-%10', 0.10),
                const SizedBox(width: 6),
                _buildQuickSnapChip('-%15', 0.15),
                const SizedBox(width: 6),
                _buildQuickSnapChip('-%20', 0.20),
                const SizedBox(width: 6),
                _buildQuickSnapChip('-%25', 0.25),
                const SizedBox(width: 6),
                _buildQuickSnapChip('Tam Fiyat', 0.0),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Arcade Segmented Persuasion & Conviction Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İKNA VE KABUL OLASILIĞI',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              Text(
                '%$chancePercent İkna Gücü',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: _chanceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SegmentedArcadeGauge(
            totalSegments: 6,
            activeSegments: ((chancePercent / 100) * 6).round().clamp(1, 6),
            activeColor: _chanceColor,
            height: 10,
            gap: 4,
          ),
          const SizedBox(height: 10),

          // Neo-Brutalist Potentiometer Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFFDE59),
              inactiveTrackColor:
                  isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFFFFDE59),
              overlayColor: const Color(0xFFFFDE59).withValues(alpha: 0.2),
              trackHeight: 10.0,
              trackShape: NeoBrutalSliderTrackShape(
                trackBorderColor:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                trackBorderWidth: 2.0,
              ),
              thumbShape: NeoBrutalRectangularThumbShape(
                thumbWidth: 20,
                thumbHeight: 26,
                fillColor: const Color(0xFFFFDE59),
                borderColor:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                borderWidth: 2.2,
                shadowOffsetDistance: 2.5,
              ),
            ),
            child: Slider(
              value: offeredPrice,
              min: (askingPrice * 0.75).roundToDouble(),
              max: askingPrice,
              divisions: 50,
              onChanged: isLocked
                  ? null
                  : (val) {
                      HapticFeedback.selectionClick();
                      onPriceChanged(val.roundToDouble());
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSnapChip(String label, double discountPercent) {
    final targetPrice =
        (askingPrice * (1.0 - discountPercent)).roundToDouble();
    final isSelected = (offeredPrice - targetPrice).abs() < 500;

    return InkWell(
      onTap: isLocked ? null : () => onSnapDiscount(discountPercent),
      borderRadius: BorderRadius.circular(6),
      child: Opacity(
        opacity: isLocked ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFDE59)
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.8,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: isDark ? Colors.black : const Color(0xFF0F172A),
                      offset: isSelected
                          ? const Offset(1, 1)
                          : const Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }
}
