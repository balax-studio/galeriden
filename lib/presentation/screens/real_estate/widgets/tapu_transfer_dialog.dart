import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/real_estate_category.dart';
import '../../../../data/models/real_estate_model.dart';
import '../../../widgets/neo_brutal_button.dart';

class TapuTransferDialog extends StatefulWidget {
  final RealEstateModel realEstate;
  final String buyerName;
  final String sellerName;
  final double agreedPrice;
  final double deedFee;
  final double revolvingFundFee;
  final double commission;
  final VoidCallback? onComplete;

  const TapuTransferDialog({
    super.key,
    required this.realEstate,
    required this.buyerName,
    required this.sellerName,
    required this.agreedPrice,
    required this.deedFee,
    this.revolvingFundFee = RealEstateListingModel.revolvingFundFee,
    required this.commission,
    this.onComplete,
  });

  static Future<void> show({
    required BuildContext context,
    required RealEstateModel realEstate,
    required String buyerName,
    required String sellerName,
    required double agreedPrice,
    required double deedFee,
    double revolvingFundFee = RealEstateListingModel.revolvingFundFee,
    required double commission,
    VoidCallback? onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TapuTransferDialog(
        realEstate: realEstate,
        buyerName: buyerName,
        sellerName: sellerName,
        agreedPrice: agreedPrice,
        deedFee: deedFee,
        revolvingFundFee: revolvingFundFee,
        commission: commission,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<TapuTransferDialog> createState() => _TapuTransferDialogState();
}

class _TapuTransferDialogState extends State<TapuTransferDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _stampController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _stampController,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _stampController.forward();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCost = widget.agreedPrice +
        widget.deedFee +
        widget.revolvingFundFee +
        widget.commission;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('tapu_dialog_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('tapu_dialog_subtitle'),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Official Deed Certificate Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD97706),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header of Deed
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    context.tr('tapu_certificate_header'),
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 2,
                                    width: 120,
                                    color: const Color(0xFFD97706),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDeedRow(
                              context.tr('tapu_field_province_district'),
                              '${widget.realEstate.city} • ${widget.realEstate.district}',
                            ),
                            _buildDeedRow(
                              context.tr('tapu_field_property_type'),
                              context.tr(widget.realEstate.category.localizationKey),
                            ),
                            _buildDeedRow(
                              context.tr('tapu_field_deed_status'),
                              context.tr(widget.realEstate.deedType.localizationKey),
                            ),
                            _buildDeedRow(
                              context.tr('tapu_field_area_rooms'),
                              '${widget.realEstate.squareMeters} m² • ${widget.realEstate.roomCount}',
                            ),
                            _buildDeedRow(
                              context.tr('tapu_field_seller'),
                              widget.sellerName,
                            ),
                            _buildDeedRow(
                              context.tr('tapu_field_buyer'),
                              widget.buyerName,
                            ),
                            const Divider(color: Color(0xFFD97706), height: 20),
                            _buildDeedRow(
                              context.tr('tapu_field_agreed_price'),
                              CurrencyFormatter.format(widget.agreedPrice),
                              isBold: true,
                              textColor: const Color(0xFFB45309),
                            ),
                          ],
                        ),
                      ),

                      // Elastic Stamp Overlay
                      Positioned(
                        right: 20,
                        bottom: 25,
                        child: AnimatedBuilder(
                          animation: _stampController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Transform.rotate(
                                  angle: -0.22,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFDC2626),
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      context.tr('tapu_stamp_text'),
                                      style: const TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Cost Breakdown Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('tapu_costs_breakdown_title'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFeeLine(
                          context.tr('tapu_fee_deed_rate'),
                          CurrencyFormatter.format(widget.deedFee),
                        ),
                        _buildFeeLine(
                          context.tr('tapu_fee_revolving_fund'),
                          CurrencyFormatter.format(widget.revolvingFundFee),
                        ),
                        if (widget.commission > 0)
                          _buildFeeLine(
                            context.tr('tapu_fee_commission_rate'),
                            CurrencyFormatter.format(widget.commission),
                          ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('tapu_fee_total_cost'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(totalCost),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Confirmation Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: NeoBrutalButton(
                    label: context.tr('tapu_btn_complete_transfer'),
                    icon: Icons.assignment_turned_in_rounded,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop();
                      widget.onComplete?.call();
                    },
                    backgroundColor: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeedRow(String label, String value,
      {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF78350F),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: textColor ?? const Color(0xFF451A03),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeLine(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
