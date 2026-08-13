import 'package:flutter/material.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../core/theme/app_typography.dart';

class DisappearingRepairTile extends StatefulWidget {
  final String partName;
  final PartStatus status;
  final ThemePaletteModel p;
  final void Function(VoidCallback onSuccess) onOpenOptions;

  const DisappearingRepairTile({
    required super.key,
    required this.partName,
    required this.status,
    required this.p,
    required this.onOpenOptions,
  });

  @override
  State<DisappearingRepairTile> createState() => _DisappearingRepairTileState();
}

class _DisappearingRepairTileState extends State<DisappearingRepairTile> with SingleTickerProviderStateMixin {
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

  void _handleSuccess() async {
    if (_isAnimatingOut) return;
    if (!mounted) return;
    setState(() => _isAnimatingOut = true);
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeAnimation),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('${widget.partName} Restorasyonu', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
              subtitle: Text(widget.status == PartStatus.damaged 
                  ? 'Durum: Hasarlı (Onarım Gerekli)' 
                  : widget.status == PartStatus.painted 
                      ? 'Durum: Boyalı (Orijinale Çevrilebilir)' 
                      : 'Durum: Değişen (Orijinale Çevrilebilir)'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.secondaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isAnimatingOut ? null : () => widget.onOpenOptions(_handleSuccess),
                child: const Text('Usta Seç & Onar'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
