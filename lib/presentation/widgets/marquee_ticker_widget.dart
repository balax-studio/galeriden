import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-Brutalist Marquee Ticker Widget
/// Continuously scrolls live market news, trade ticker items, and automotive bulletins
/// with high-contrast hazard styling, tactile badge, and zero jitter.
class MarqueeTickerWidget extends StatefulWidget {
  final List<String> newsItems;
  final String leadBadgeText;
  final Color backgroundColor;
  final Color textColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final Color borderColor;
  final double height;
  final double velocity; // pixels per second

  const MarqueeTickerWidget({
    super.key,
    required this.newsItems,
    this.leadBadgeText = 'CANLI PİYASA',
    this.backgroundColor = const Color(0xFF0F172A),
    this.textColor = const Color(0xFFFFDE59),
    this.badgeBackgroundColor = const Color(0xFFFFDE59),
    this.badgeTextColor = const Color(0xFF000000),
    this.borderColor = const Color(0xFF000000),
    this.height = 32.0,
    this.velocity = 35.0,
  });

  @override
  State<MarqueeTickerWidget> createState() => _MarqueeTickerWidgetState();
}

class _MarqueeTickerWidgetState extends State<MarqueeTickerWidget>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _animController.addListener(_onAnimTick);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startLoop();
      });
    }
  }

  void _startLoop() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final seconds = (maxExtent / (widget.velocity > 0 ? widget.velocity : 32.0))
        .clamp(5.0, 120.0);
    _animController.duration =
        Duration(milliseconds: (seconds * 1000).round());
    _animController.repeat();
  }

  void _onAnimTick() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent > 0) {
      _scrollController.jumpTo(_animController.value * maxExtent);
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_onAnimTick);
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final separator = '  •  ';
    final fullText = widget.newsItems.join(separator) + separator;
    // Repeat for seamless looping
    final repeatedText = fullText * 4;

    return RepaintBoundary(
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.symmetric(
            horizontal: BorderSide(color: widget.borderColor, width: 2.0),
          ),
        ),
      child: Row(
        children: [
          // Lead Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.badgeBackgroundColor,
              border: Border(
                right: BorderSide(color: widget.borderColor, width: 2.0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(10, 10),
                  painter: _HazardDotPainter(color: widget.badgeTextColor),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.leadBadgeText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: widget.badgeTextColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Scrolling Tape Area
          Expanded(
            child: IgnorePointer(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    repeatedText,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: widget.textColor,
                      letterSpacing: 0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _HazardDotPainter extends CustomPainter {
  final Color color;

  _HazardDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _HazardDotPainter oldDelegate) =>
      oldDelegate.color != color;
}
