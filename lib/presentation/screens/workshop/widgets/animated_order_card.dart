import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/models/part_order_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/app_vector_icons.dart';

class AnimatedOrderCard extends StatefulWidget {
  final PartOrderModel order;
  final ThemePaletteModel p;
  final VoidCallback onInstall;

  const AnimatedOrderCard({
    super.key,
    required this.order,
    required this.p,
    required this.onInstall,
  });

  @override
  State<AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<AnimatedOrderCard> with SingleTickerProviderStateMixin {
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

    // Refresh UI every second for countdown/progress
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
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
              color: _isInstalling ? p.successColor.withValues(alpha: 0.25) : p.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isInstalling ? p.successColor : p.surfaceBorderColor,
                width: _isInstalling ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                VectorIconWidget(
                  type: order.orderType == OrderType.masterRepair ? 'craftsman' : 'workshop',
                  size: 24,
                  color: isReady ? p.successColor : p.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.partName} (${order.orderType == OrderType.quickPatch ? 'Geçici' : order.orderType == OrderType.masterRepair ? 'Usta Tamiri' : 'Yeni Parça'})',
                        style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: order.progressPercentage,
                          backgroundColor: p.surfaceBorderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(isReady ? p.successColor : p.primaryColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReady ? (_isInstalling ? 'Monte Ediliyor...' : 'Teslimat Tamamlandı!') : 'Kargoda ($remainingSec sn kaldı)',
                        style: AppTypography.labelSmall(p.isDark).copyWith(
                          color: isReady ? p.successColor : p.warningColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? p.successColor : p.surfaceBorderColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onPressed: (isReady && !_isInstalling) ? _triggerInstallation : null,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(isReady ? (_isInstalling ? '...' : 'Montaj Et') : 'Bekleniyor'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
