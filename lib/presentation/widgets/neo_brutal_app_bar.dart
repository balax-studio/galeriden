import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../providers/dashboard_provider.dart';
import 'hazard_stripe_widget.dart';

/// Screen-specific neo-brutalist micro-animation presets
enum NeoBrutalHeaderAnimation {
  none,
  neonFlicker, // Night Market & Race (Neon pulse, flicker & voltage variation)
  laserScan, // Expertise (Single vertical cyan laser scan line sweep)
  waterBubbles, // Car Wash (Rising floating cyan & white geometric bubbles)
  pressSlam, // Scrapyard & Special Plate (Hydraulic stamp slam & micro settle)
  wrenchRotate, // Workshop (45-degree wrench rotation locking into place)
  revBarFlash, // Tuning & Dyno (3-stage red rev LED strobe)
  punchCardDrop, // Staff (Card punch drop & bounce)
  gavelBounce, // Consignment (Auction gavel bounce)
  radarPulse, // Rent a Car & District Map (Expanding sonar radar rings)
  stockCandle, // Stock Market (Live green/red oscillating candlestick bar)
  cashShimmer, // Side Business & Lifestyle (45-degree specular gold shimmer shine)
  colorShift, // Theme Store (Slow fluid chromatic gradient shift)
  radioGlitch, // Industry Gossip (Radio frequency scan glitch + pulsing red REC dot)
  receiptPrint, // Sales History (Dot-matrix receipt typewriter entrance)
  starSpin, // Customer Reviews (360-degree star spin + heartbeat badge)
}

/// Maximalist Neo-Brutal App Bar with tactile back button strictly aligned to the left,
/// boxed marquee title plate, contextual slug subtitles, hazard bottom stripe,
/// screen-specific micro-animations, and responsive action buttons.
class NeoBrutalAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? statusBadge;
  final Color? titleBadgeColor;
  final Color? titleTextColor;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  final bool showLeading;
  final bool showHazardUnderline;
  final bool isHazardAnimated;
  final NeoBrutalHeaderAnimation headerAnimation;
  final PreferredSizeWidget? bottom;
  final double elevation;

  const NeoBrutalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.titleWidget,
    this.statusBadge,
    this.titleBadgeColor,
    this.titleTextColor,
    this.actions,
    this.onLeadingPressed,
    this.showLeading = true,
    this.showHazardUnderline = true,
    this.isHazardAnimated = false,
    this.headerAnimation = NeoBrutalHeaderAnimation.none,
    this.bottom,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        (kToolbarHeight - 2.0) +
            (showHazardUnderline ? 4.0 : 0.0) +
            (bottom?.preferredSize.height ?? 0.0) +
            (showHazardUnderline ? 1.5 : 2.0),
      );

  @override
  ConsumerState<NeoBrutalAppBar> createState() => _NeoBrutalAppBarState();
}

class _NeoBrutalAppBarState extends ConsumerState<NeoBrutalAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceCurved;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entranceCurved = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        p?.surfaceColor ?? (isDark ? const Color(0xFF10131B) : Colors.white);
    final borderColor = p?.surfaceBorderColor ??
        (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A));
    final textColor = p?.textPrimaryColor ??
        (isDark ? Colors.white : const Color(0xFF0F172A));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: widget.showHazardUnderline ? 1.5 : 2.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight - 2.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Middle / Centered Marquee Title Box with Micro-Animations
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: widget.titleWidget ??
                            _buildAnimatedTitlePlate(
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                      ),
                    ),

                    // Far-left: Strict Leading Back Button with expanded hit area
                    if (widget.showLeading)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (widget.onLeadingPressed != null) {
                              widget.onLeadingPressed!();
                              return;
                            }

                            final currentTab = ref.read(dashboardTabProvider);
                            if (currentTab != 0) {
                              ref.read(dashboardTabProvider.notifier).state = 0;
                            }

                            bool popped = false;
                            try {
                              if (context.canPop()) {
                                context.pop();
                                popped = true;
                              }
                            } catch (_) {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                                popped = true;
                              }
                            }

                            if (!popped) {
                              try {
                                context.go('/dashboard');
                              } catch (_) {}
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor,
                                    offset: const Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Far-right: Status Badge & Action items with Pulse
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.statusBadge != null) ...[
                            _buildAnimatedStatusBadge(widget.statusBadge!),
                            const SizedBox(width: 4),
                          ],
                          if (widget.actions != null &&
                              widget.actions!.isNotEmpty)
                            ...widget.actions!,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.bottom != null) widget.bottom!,
            if (widget.showHazardUnderline)
              HazardStripeWidget(
                height: 4.0,
                stripeWidth: 6.0,
                isAnimated: widget.isHazardAnimated,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatusBadge(Widget badge) {
    if (widget.headerAnimation == NeoBrutalHeaderAnimation.none) {
      return badge;
    }

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final t = _entranceCurved.value;
        final pulseScale = 0.95 + 0.05 * math.sin(t * math.pi);

        return Transform.scale(
          scale: pulseScale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.headerAnimation == NeoBrutalHeaderAnimation.radioGlitch ||
                  widget.headerAnimation == NeoBrutalHeaderAnimation.neonFlicker) ...[
                Container(
                  width: 5.5,
                  height: 5.5,
                  margin: const EdgeInsets.only(right: 3.5),
                  decoration: BoxDecoration(
                    color: (t < 0.85)
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
              child!,
            ],
          ),
        );
      },
      child: badge,
    );
  }

  Widget _buildAnimatedTitlePlate({
    required bool isDark,
    required Color borderColor,
  }) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        Widget content = _buildPlateContent(isDark: isDark);

        // Apply specialized transformation based on animation mode
        switch (widget.headerAnimation) {
          case NeoBrutalHeaderAnimation.pressSlam:
            final slamProgress = _entranceCurved.value;
            final yOffset = (1.0 - slamProgress) * -14.0;
            final scale = 0.92 + 0.08 * slamProgress;
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform.scale(
                scale: scale,
                child: _wrapPlateBox(
                  content: content,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
              ),
            );

          case NeoBrutalHeaderAnimation.wrenchRotate:
            final rotateProgress = _entranceCurved.value;
            final angle = (1.0 - rotateProgress) * 0.08;
            return Transform.rotate(
              angle: angle,
              child: _wrapPlateBox(
                content: content,
                isDark: isDark,
                borderColor: borderColor,
              ),
            );

          case NeoBrutalHeaderAnimation.punchCardDrop:
          case NeoBrutalHeaderAnimation.gavelBounce:
            final bounceProgress = _entranceCurved.value;
            final yOffset = (1.0 - bounceProgress) * -10.0;
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: _wrapPlateBox(
                content: content,
                isDark: isDark,
                borderColor: borderColor,
              ),
            );

          case NeoBrutalHeaderAnimation.starSpin:
            final spinProgress = _entranceCurved.value;
            final scale = 0.95 + 0.05 * math.sin(spinProgress * math.pi);
            return Transform.scale(
              scale: scale,
              child: _wrapPlateBox(
                content: content,
                isDark: isDark,
                borderColor: borderColor,
              ),
            );

          case NeoBrutalHeaderAnimation.neonFlicker:
            final t = _entranceCurved.value;
            final flicker = 0.88 + 0.12 * math.sin(t * 8 * math.pi);
            return Opacity(
              opacity: flicker.clamp(0.8, 1.0),
              child: _wrapPlateBox(
                content: content,
                isDark: isDark,
                borderColor: borderColor,
                neonGlow: true,
              ),
            );

          default:
            return _wrapPlateBox(
              content: content,
              isDark: isDark,
              borderColor: borderColor,
            );
        }
      },
    );
  }

  Widget _wrapPlateBox({
    required Widget content,
    required bool isDark,
    required Color borderColor,
    bool neonGlow = false,
  }) {
    Color baseBgColor = widget.titleBadgeColor ??
        (isDark ? const Color(0xFF181D2A) : const Color(0xFFFEF08A));

    if (widget.headerAnimation == NeoBrutalHeaderAnimation.colorShift) {
      final t = _entranceCurved.value;
      baseBgColor = Color.lerp(
            const Color(0xFFFEF08A),
            const Color(0xFFA3E635),
            math.sin(t * math.pi),
          ) ??
          baseBgColor;
    }

    final screenWidth = MediaQuery.maybeOf(context)?.size.width ?? 360.0;
    final maxPlateWidth = (screenWidth - (widget.showLeading ? 116.0 : 64.0)).clamp(80.0, 500.0);

    return Container(
      constraints: BoxConstraints(maxWidth: maxPlateWidth),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: baseBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: neonGlow ? const Color(0xFFF43F5E) : borderColor,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: neonGlow
                ? const Color(0xFFF43F5E).withValues(alpha: 0.5)
                : borderColor,
            offset: const Offset(2.0, 2.0),
            blurRadius: neonGlow ? 4.0 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            content,
            // Shimmer / Laser / Bubble Overlays on Entrance
            if (widget.headerAnimation == NeoBrutalHeaderAnimation.laserScan)
              Positioned.fill(
                child: _LaserScanOverlay(progress: _entranceCurved.value),
              ),
            if (widget.headerAnimation == NeoBrutalHeaderAnimation.cashShimmer)
              Positioned.fill(
                child: _CashShimmerOverlay(progress: _entranceCurved.value),
              ),
            if (widget.headerAnimation == NeoBrutalHeaderAnimation.waterBubbles)
              Positioned.fill(
                child: _WaterBubblesOverlay(progress: _entranceCurved.value),
              ),
            if (widget.headerAnimation == NeoBrutalHeaderAnimation.radarPulse)
              Positioned.fill(
                child: _RadarPulseOverlay(progress: _entranceCurved.value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateContent({required bool isDark}) {
    final titleColor = widget.titleTextColor ??
        (isDark ? Colors.white : const Color(0xFF0F172A));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
          _buildSubtitleWithDecryption(
            isDark: isDark,
            text: widget.subtitle!.toUpperCase(),
          ),
          const SizedBox(height: 1),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.headerAnimation ==
                NeoBrutalHeaderAnimation.stockCandle) ...[
              _StockCandleIndicator(progress: _entranceCurved.value),
              const SizedBox(width: 5),
            ],
            if (widget.headerAnimation ==
                NeoBrutalHeaderAnimation.revBarFlash) ...[
              _RevBarStrobeIndicator(progress: _entranceCurved.value),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: widget.subtitle != null ? 11.5 : 13.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtitleWithDecryption({
    required bool isDark,
    required String text,
  }) {
    if (widget.headerAnimation == NeoBrutalHeaderAnimation.none) {
      return Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 7.8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    final progress = _entranceCurved.value;
    final visibleCount = (text.length * progress).round().clamp(0, text.length);
    final displayedText = text.substring(0, visibleCount);

    return Text(
      displayedText,
      style: GoogleFonts.inter(
        fontSize: 7.8,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

/// Cyber Laser Scan Line Sweep Overlay
class _LaserScanOverlay extends StatelessWidget {
  final double progress;
  const _LaserScanOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) return const SizedBox.shrink();
    return CustomPaint(
      painter: _LaserScanPainter(progress: progress),
    );
  }
}

class _LaserScanPainter extends CustomPainter {
  final double progress;
  _LaserScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0xFF38BDF8), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _LaserScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Gold Cash Specular Shimmer Sweep Overlay
class _CashShimmerOverlay extends StatelessWidget {
  final double progress;
  const _CashShimmerOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) return const SizedBox.shrink();
    return CustomPaint(
      painter: _CashShimmerPainter(progress: progress),
    );
  }
}

class _CashShimmerPainter extends CustomPainter {
  final double progress;
  _CashShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = (size.width * 2.0 * progress) - (size.width * 0.5);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x - 20, 0, 40, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CashShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Floating Water Bubbles Overlay for Car Wash
class _WaterBubblesOverlay extends StatelessWidget {
  final double progress;
  const _WaterBubblesOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) return const SizedBox.shrink();
    return CustomPaint(
      painter: _WaterBubblesPainter(progress: progress),
    );
  }
}

class _WaterBubblesPainter extends CustomPainter {
  final double progress;
  _WaterBubblesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final seed = i * 0.33;
      final localP = (progress + seed) % 1.0;
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * (1.0 - localP);
      final radius = 2.0 + (i * 0.8);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterBubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Radar Sonar Wave Pulse Overlay
class _RadarPulseOverlay extends StatelessWidget {
  final double progress;
  const _RadarPulseOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) return const SizedBox.shrink();
    return CustomPaint(
      painter: _RadarPulsePainter(progress: progress),
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;
  _RadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.5;
    final radius = maxRadius * progress;
    final alpha = (1.0 - progress).clamp(0.0, 1.0) * 0.3;

    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// BIST Live Candlestick Micro Indicator
class _StockCandleIndicator extends StatelessWidget {
  final double progress;
  const _StockCandleIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isBullish = math.sin(progress * 2 * math.pi) >= 0;
    final color = isBullish ? AppColors.brutalGreen : const Color(0xFFEF4444);

    return Container(
      width: 5,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
    );
  }
}

/// 3-Stage Red Rev Bar LED Strobe Indicator
class _RevBarStrobeIndicator extends StatelessWidget {
  final double progress;
  const _RevBarStrobeIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLed(const Color(0xFF10B981), progress > 0.25),
        const SizedBox(width: 1.5),
        _buildLed(const Color(0xFFFBBF24), progress > 0.55),
        const SizedBox(width: 1.5),
        _buildLed(const Color(0xFFEF4444), progress > 0.85),
      ],
    );
  }

  Widget _buildLed(Color color, bool active) {
    return Container(
      width: 4,
      height: 9,
      decoration: BoxDecoration(
        color: active ? color : const Color(0xFF334155),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Colors.black, width: 0.6),
      ),
    );
  }
}

/// Neo-Brutalist Segmented Tab Bar for AppBars
class NeoBrutalTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<String> tabs;

  const NeoBrutalTabBar({
    super.key,
    this.controller,
    required this.tabs,
  });

  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final accentColor = p?.primaryColor ?? AppColors.brutalYellow;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          width: 1.5,
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : const Color(0xFF0F172A),
              offset: const Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0F172A),
        unselectedLabelColor:
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        tabs: tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
      ),
    );
  }
}
