import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../widgets/neo_brutal_button.dart';

class NoterTransferDialog extends StatefulWidget {
  final CarModel car;
  final String buyerName;
  final String sellerName;
  final double agreedPrice;
  final double noterFee;
  final double registrationFee;
  final double playerBalance;
  final bool isGarageFull;
  final VoidCallback? onComplete;

  const NoterTransferDialog({
    super.key,
    required this.car,
    required this.buyerName,
    required this.sellerName,
    required this.agreedPrice,
    required this.noterFee,
    this.registrationFee = 850.0,
    this.playerBalance = 0.0,
    this.isGarageFull = false,
    this.onComplete,
  });

  static Future<void> show({
    required BuildContext context,
    required CarModel car,
    required String buyerName,
    required String sellerName,
    required double agreedPrice,
    required double noterFee,
    double registrationFee = 850.0,
    double playerBalance = 0.0,
    bool isGarageFull = false,
    VoidCallback? onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => NoterTransferDialog(
        car: car,
        buyerName: buyerName,
        sellerName: sellerName,
        agreedPrice: agreedPrice,
        noterFee: noterFee,
        registrationFee: registrationFee,
        playerBalance: playerBalance,
        isGarageFull: isGarageFull,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<NoterTransferDialog> createState() => _NoterTransferDialogState();
}

class _NoterTransferDialogState extends State<NoterTransferDialog>
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

    Future.delayed(const Duration(milliseconds: 300), () {
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
    final totalCost = widget.agreedPrice + widget.noterFee + widget.registrationFee;
    final hasEnoughFunds = widget.playerBalance >= totalCost;
    final canComplete = hasEnoughFunds && !widget.isGarageFull;

    final maskedVin = widget.car.id.length >= 8
        ? 'VF3${widget.car.id.substring(0, 4).toUpperCase()}...${widget.car.id.substring(widget.car.id.length - 4).toUpperCase()}'
        : 'TR-${widget.car.id.toUpperCase()}';

    final effectivePlate = widget.car.plateNumber.isNotEmpty
        ? widget.car.plateNumber
        : '34 GLR 101';

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
                // Header with Cancel/Close Button
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
                              context.tr('noter_dialog_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('noter_dialog_subtitle'),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        tooltip: context.tr('real_estate_dialog_btn_cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Official Vehicle Deed Certificate Card
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
                            // Certificate Header
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    context.tr('noter_certificate_header'),
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 2,
                                    width: 130,
                                    color: const Color(0xFFD97706),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildCertificateRow(
                              context.tr('noter_field_plate'),
                              effectivePlate,
                              isBold: true,
                            ),
                            _buildCertificateRow(
                              context.tr('noter_field_vin'),
                              maskedVin,
                            ),
                            _buildCertificateRow(
                              context.tr('noter_field_vehicle'),
                              '${widget.car.modelYear} ${widget.car.brand} ${widget.car.modelName}',
                            ),
                            _buildCertificateRow(
                              context.tr('noter_field_mileage'),
                              '${widget.car.expertise.mileage} KM',
                            ),
                            _buildCertificateRow(
                              context.tr('noter_field_seller'),
                              widget.sellerName,
                            ),
                            _buildCertificateRow(
                              context.tr('noter_field_buyer'),
                              widget.buyerName,
                            ),
                            const Divider(color: Color(0xFFD97706), height: 18),
                            _buildCertificateRow(
                              context.tr('noter_field_agreed_price'),
                              CurrencyFormatter.format(widget.agreedPrice),
                              isBold: true,
                              textColor: const Color(0xFFB45309),
                            ),
                          ],
                        ),
                      ),

                      // Elastic Stamp Overlay
                      Positioned(
                        right: 16,
                        bottom: 22,
                        child: AnimatedBuilder(
                          animation: _stampController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Transform.rotate(
                                  angle: -0.20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFDC2626),
                                        width: 2.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      context.tr('noter_stamp_text'),
                                      style: const TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.8,
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
                          context.tr('noter_costs_breakdown_title'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFeeLine(
                          context.tr('noter_fee_devir_rate'),
                          CurrencyFormatter.format(widget.noterFee),
                        ),
                        _buildFeeLine(
                          context.tr('noter_fee_registration'),
                          CurrencyFormatter.format(widget.registrationFee),
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('noter_fee_total_cost'),
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
                        const SizedBox(height: 6),
                        _buildFeeLine(
                          context.tr('noter_label_player_balance'),
                          CurrencyFormatter.format(widget.playerBalance),
                          textColor: hasEnoughFunds
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        if (!hasEnoughFunds) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFEF4444),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    context.tr('noter_insufficient_balance_warning'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.isGarageFull) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warehouse_rounded,
                                  color: Color(0xFFD97706),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    context.tr('vasita_btn_garage_full'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF92400E),
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
                ),

                const SizedBox(height: 16),

                // Confirmation Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: NeoBrutalButton(
                    label: widget.isGarageFull
                        ? context.tr('vasita_btn_garage_full')
                        : (hasEnoughFunds
                            ? context.tr('noter_btn_complete_transfer')
                            : context.tr('noter_insufficient_balance_warning')),
                    icon: canComplete
                        ? Icons.verified_rounded
                        : Icons.block_rounded,
                    fullWidth: true,
                    onPressed: canComplete
                        ? () {
                            HapticFeedback.heavyImpact();
                            Navigator.of(context).pop();
                            widget.onComplete?.call();
                          }
                        : null,
                    backgroundColor: canComplete
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
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

  Widget _buildFeeLine(String label, String amount, {Color? textColor}) {
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
