import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Animated Floating Money Pop-up Particle Model
class FloatingMoneyParticle {
  final String id;
  final double amount;
  final Offset position;
  final String label;

  FloatingMoneyParticle({
    required this.id,
    required this.amount,
    required this.position,
    this.label = '',
  });
}

/// Floating Money Pop-up Overlay Widget
class FloatingMoneyOverlay extends StatefulWidget {
  final Widget child;

  const FloatingMoneyOverlay({super.key, required this.child});

  static FloatingMoneyOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingMoneyOverlayState>();
  }

  @override
  State<FloatingMoneyOverlay> createState() => FloatingMoneyOverlayState();
}

class FloatingMoneyOverlayState extends State<FloatingMoneyOverlay> with TickerProviderStateMixin {
  final List<_ParticleItem> _particles = [];

  void showMoneyPopUp(double amount, {Offset? position, String label = ''}) {
    final startPos = position ?? Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height * 0.4);
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final particleItem = _ParticleItem(
      id: id,
      amount: amount,
      label: label,
      position: startPos,
      controller: controller,
    );

    setState(() {
      _particles.add(particleItem);
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => p.id == id);
        });
      }
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: widget.child),
        ..._particles.map((p) => _buildAnimatedParticle(p)),
      ],
    );
  }

  Widget _buildAnimatedParticle(_ParticleItem item) {
    final staticContent = RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.laserGreen, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.laserGreen,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_rounded, color: AppColors.laserGreen, size: 16),
            const SizedBox(width: 4),
            Text(
              '+${CurrencyFormatter.formatShort(item.amount)} ${item.label}',
              style: const TextStyle(
                color: AppColors.laserGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: item.controller,
      child: staticContent,
      builder: (context, child) {
        final progress = item.controller.value;
        final offsetY = item.position.dy - (progress * 70.0);
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        final scale = 0.8 + (progress * 0.4);

        return Positioned(
          left: item.position.dx - 60,
          top: offsetY,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ParticleItem {
  final String id;
  final double amount;
  final String label;
  final Offset position;
  final AnimationController controller;

  _ParticleItem({
    required this.id,
    required this.amount,
    required this.label,
    required this.position,
    required this.controller,
  });
}
