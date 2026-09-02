import 'dart:async';
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
  Timer? _tickerTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarqueeScroll();
    });
  }

  void _startMarqueeScroll() {
    if (!mounted || _isDisposed) return;
    const interval = Duration(milliseconds: 32);
    final delta = widget.velocity * 0.032;

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(interval, (_) {
      if (!_scrollController.hasClients || _isDisposed) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      if (maxExtent <= 0) return;

      if (current >= maxExtent) {
        _scrollController.jumpTo(0.0);
      } else {
        _scrollController.jumpTo(current + delta);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tickerTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final separator = '  •  ';
    final fullText = widget.newsItems.join(separator) + separator;
    // Repeat for seamless looping
    final repeatedText = fullText * 4;

    return Container(
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
