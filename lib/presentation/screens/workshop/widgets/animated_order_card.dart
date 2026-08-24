import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/part_order_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';

class AnimatedOrderCard extends StatefulWidget {
  final PartOrderModel order;
  final ThemePaletteModel p;
  final VoidCallback onInstall;
  final VoidCallback? onFastDeliverWithAd;

  const AnimatedOrderCard({
    super.key,
    required this.order,
    required this.p,
    required this.onInstall,
    this.onFastDeliverWithAd,
  });

  @override
  State<AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;
  bool _isInstalling = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Refresh UI every second for countdown/progress only while order is in transit
    if (!widget.order.isDelivered) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (widget.order.isDelivered) {
          timer.cancel();
          _refreshTimer = null;
        }
        setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.order.isDelivered && _refreshTimer == null) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (widget.order.isDelivered) {
          timer.cancel();
          _refreshTimer = null;
        }
        setState(() {});
      });
    } else if (widget.order.isDelivered && _refreshTimer != null) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _triggerInstallation() {
    if (_isInstalling) return;
    setState(() => _isInstalling = true);
    _controller.forward().then((_) {
      if (mounted) {
        widget.onInstall();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final p = widget.p;
    final isReady = order.isDelivered;
    final remainingSec = order.remainingSeconds;
    final orderTypeLabel = order.orderType == OrderType.quickPatch
        ? context.tr('order_card_temp')
        : order.orderType == OrderType.masterRepair
            ? context.tr('order_card_master')
            : context.tr('order_card_new');

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isInstalling
                  ? p.successColor.withValues(alpha: 0.25)
                  : p.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isInstalling ? p.successColor : p.surfaceBorderColor,
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                VectorIconWidget(
                  type: order.orderType == OrderType.masterRepair
                      ? 'craftsman'
                      : 'workshop',
                  size: 24,
                  color: isReady ? p.successColor : p.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.partName} • $orderTypeLabel',
                        style: AppTypography.titleLarge(p.isDark).copyWith(
                            fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: order.progressPercentage,
                          backgroundColor: p.surfaceBorderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              isReady ? p.successColor : p.primaryColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReady
                            ? (_isInstalling
                                ? context.tr('order_card_installing')
                                : context.tr('order_card_delivered'))
                            : context.tr(
                                'order_card_in_cargo', {'sec': remainingSec}),
                        style: AppTypography.labelSmall(p.isDark).copyWith(
                          color: isReady ? p.successColor : p.warningColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isReady && widget.onFastDeliverWithAd != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: widget.onFastDeliverWithAd,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDE59),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: p.isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 14, color: Colors.black),
                            const SizedBox(width: 2),
                            Text(
                              context.tr('order_card_speed_up'),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                NeoBrutalButton(
                  label: isReady
                      ? (_isInstalling
                          ? '...'
                          : context.tr('order_card_btn_install'))
                      : context.tr('order_card_btn_waiting'),
                  backgroundColor: isReady
                      ? p.successColor
                      : (p.isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFCBD5E1)),
                  textColor: isReady
                      ? Colors.black
                      : (p.isDark ? Colors.white60 : Colors.black54),
                  borderColor: p.isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  fontSize: 10.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onPressed:
                      (isReady && !_isInstalling) ? _triggerInstallation : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
