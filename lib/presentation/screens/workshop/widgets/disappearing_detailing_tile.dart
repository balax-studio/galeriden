import 'package:flutter/material.dart';
import '../../../../data/models/detailing_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/app_vector_icons.dart';

class DisappearingDetailingTile extends StatefulWidget {
  final DetailingOption opt;
  final ThemePaletteModel p;
  final bool canAfford;
  final VoidCallback onApply;

  const DisappearingDetailingTile({
    required super.key,
    required this.opt,
    required this.p,
    required this.canAfford,
    required this.onApply,
  });

  @override
  State<DisappearingDetailingTile> createState() => _DisappearingDetailingTileState();
}

class _DisappearingDetailingTileState extends State<DisappearingDetailingTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sizeAnimation;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_fadeAnimation);
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleApply() async {
    if (_isAnimatingOut) return;
    setState(() => _isAnimatingOut = true);
    await _controller.forward();
    if (mounted) {
      widget.onApply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final opt = widget.opt;
    final p = widget.p;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeAnimation),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: opt.isRisky ? p.secondaryColor : p.surfaceBorderColor,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: opt.isRisky
                      ? p.secondaryColor.withValues(alpha: 0.15)
                      : p.primaryColor.withValues(alpha: 0.15),
                  child: VectorIconWidget(
                    type: opt.vectorIcon,
                    color: opt.isRisky ? p.secondaryColor : p.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(opt.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: opt.isRisky ? p.secondaryColor : p.primaryColor,
                    foregroundColor: opt.isRisky ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: widget.canAfford && !_isAnimatingOut ? _handleApply : null,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.formatShort(opt.cost),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
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
