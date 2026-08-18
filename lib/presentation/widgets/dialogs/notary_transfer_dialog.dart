import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/notary_event_model.dart';
import '../neo_brutal_button.dart';

class NotaryTransferDialog extends StatefulWidget {
  final CarModel car;
  final String buyerName;
  final String sellerName;
  final double salePrice;
  final bool isBuying; // true = player buying, false = player selling
  final NotaryEventResult eventResult;
  final VoidCallback? onComplete;

  const NotaryTransferDialog({
    super.key,
    required this.car,
    required this.buyerName,
    required this.sellerName,
    required this.salePrice,
    this.isBuying = false,
    required this.eventResult,
    this.onComplete,
  });

  static Future<void> show({
    required BuildContext context,
    required CarModel car,
    required String buyerName,
    required String sellerName,
    required double salePrice,
    bool isBuying = false,
    required NotaryEventResult eventResult,
    VoidCallback? onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotaryTransferDialog(
        car: car,
        buyerName: buyerName,
        sellerName: sellerName,
        salePrice: salePrice,
        isBuying: isBuying,
        eventResult: eventResult,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<NotaryTransferDialog> createState() => _NotaryTransferDialogState();
}

class _NotaryTransferDialogState extends State<NotaryTransferDialog>
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

    // Trigger stamp impact after document reveals
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCancelled = widget.eventResult.isCancelled;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141721) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 3.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : const Color(0xFF0F172A),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar with Notary Seal title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isCancelled
                    ? const Color(0xFFEF4444)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFFFFDE59),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'T.C. NOTERLİĞİ • ARAÇ DEVİR TESCİLİ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Vehicle Information Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.car.brand} ${widget.car.modelName}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDE59),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF0F172A), width: 1.2),
                        ),
                        child: Text(
                          widget.car.plateNumber.isNotEmpty ? widget.car.plateNumber : '34 GLR 001',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Model Yılı: ${widget.car.modelYear} • Şasi / Ruhsat: ONAYLI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Satıcı: ${widget.sellerName}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alıcı: ${widget.buyerName}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tescil Satış Bedeli:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            CurrencyFormatter.format(widget.salePrice),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00E575),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Event Story & Stamp Area
            Stack(
              alignment: Alignment.center,
              children: [
                // Event note banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? const Color(0xFFFEF2F2)
                        : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF0FDF4)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCancelled ? const Color(0xFFEF4444) : const Color(0xFF00E575),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.eventResult.title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.eventResult.description,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Animated Notary Stamp Seal
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Transform.rotate(
                      angle: isCancelled ? 0.12 : -0.10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCancelled
                                ? const Color(0xFFEF4444).withValues(alpha: 0.9)
                                : const Color(0xFF00E575).withValues(alpha: 0.9),
                            width: 2.8,
                          ),
                        ),
                        child: Text(
                          isCancelled ? 'İŞLEM İPTAL' : 'MÜHÜRLENDİ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: isCancelled
                                ? const Color(0xFFEF4444).withValues(alpha: 0.9)
                                : const Color(0xFF00E575).withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button
            NeoBrutalButton(
              label: isCancelled ? 'GARAJA DÖN' : 'DEVİR VE TESCİLİ TAMAMLA',
              backgroundColor: isCancelled ? const Color(0xFFEF4444) : const Color(0xFF00E575),
              textColor: const Color(0xFF0F172A),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onComplete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
