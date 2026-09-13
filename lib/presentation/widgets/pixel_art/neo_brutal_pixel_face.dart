import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../procedural_shader_textures.dart';

/// Contextual facial expressions for dialog popups and cards.
enum PixelFaceExpression {
  /// Cunning car dealer: raised eyebrow, cocky smirk, gold tooth glint.
  cunningDealer,

  /// Panicked banker/dealer: wide eyes, shouting mouth, splashing sweat drops.
  panickedBanker,

  /// Sweating mechanic: bandana, oil smudge, focused squint, grit.
  sweatingMechanic,

  /// Smug notary: thick square glasses, straight strict mouth, official tie.
  smugNotary,

  /// Hyped gambler: star eyes, huge grin, glowing gold/green energy.
  hypedGambler,
}

extension PixelFaceExpressionExtension on PixelFaceExpression {
  Color get defaultAccentColor {
    switch (this) {
      case PixelFaceExpression.cunningDealer:
        return AppColors.brutalYellow;
      case PixelFaceExpression.panickedBanker:
        return AppColors.brutalRed;
      case PixelFaceExpression.sweatingMechanic:
        return AppColors.brutalOrange;
      case PixelFaceExpression.smugNotary:
        return AppColors.brutalCyan;
      case PixelFaceExpression.hypedGambler:
        return AppColors.brutalGreen;
    }
  }

  String get badgeKey {
    switch (this) {
      case PixelFaceExpression.cunningDealer:
        return 'pixel_face_dealer';
      case PixelFaceExpression.panickedBanker:
        return 'pixel_face_banker';
      case PixelFaceExpression.sweatingMechanic:
        return 'pixel_face_mechanic';
      case PixelFaceExpression.smugNotary:
        return 'pixel_face_notary';
      case PixelFaceExpression.hypedGambler:
        return 'pixel_face_gambler';
    }
  }
}

/// Procedural 16-Bit Neo-Brutalist Pixel Face Badge
/// Renders authentic retro-arcade avatars with 16x16 coordinate matrices,
/// tactile solid borders, zero-blur hard offset shadows, and subtle CRT scanline textures.
class NeoBrutalPixelFaceWidget extends StatefulWidget {
  final PixelFaceExpression expression;
  final double size;
  final bool showBadge;
  final double customAngle;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final VoidCallback? onTap;

  const NeoBrutalPixelFaceWidget({
    super.key,
    required this.expression,
    this.size = 52.0,
    this.showBadge = false,
    this.customAngle = -0.06,
    this.backgroundColor,
    this.borderColor = const Color(0xFF0F172A),
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(3.0, 3.0),
    this.onTap,
  });

  @override
  State<NeoBrutalPixelFaceWidget> createState() =>
      _NeoBrutalPixelFaceWidgetState();
}

class _NeoBrutalPixelFaceWidgetState extends State<NeoBrutalPixelFaceWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? widget.expression.defaultAccentColor;

    Widget faceBox = GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        transform: Matrix4.translationValues(
          _isPressed ? 1.5 : 0.0,
          _isPressed ? 1.5 : 0.0,
          0.0,
        ),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.borderColor,
                    offset: widget.shadowOffset,
                    blurRadius: 0,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            math.max(0, 10 - widget.borderWidth),
          ),
          child: CrtScanlinesOverlay(
            opacity: 0.05,
            lineSpacing: 2.5,
            scanlineColor: Colors.black,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _NeoBrutalPixelFacePainter(
                expression: widget.expression,
              ),
            ),
          ),
        ),
      ),
    );

    Widget content = faceBox;

    if (widget.showBadge) {
      final badgeLabel = context.tr(widget.expression.badgeKey);
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          faceBox,
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeLabel.toUpperCase(),
              style: TextStyle(
                color: bg,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      );
    }

    if (widget.customAngle != 0.0) {
      return Transform.rotate(
        angle: widget.customAngle,
        child: content,
      );
    }

    return content;
  }
}

/// High-efficiency CustomPainter for 16x16 pixel face representations.
class _NeoBrutalPixelFacePainter extends CustomPainter {
  final PixelFaceExpression expression;

  _NeoBrutalPixelFacePainter({required this.expression});

  // 16-Bit Neo-Brutalist Palette (Cached Paint objects)
  static final Paint _paintBlack = Paint()..color = const Color(0xFF0F172A);
  static final Paint _paintSkin = Paint()..color = const Color(0xFFF3C294);
  static final Paint _paintSkinDark = Paint()..color = const Color(0xFFBC7643);
  static final Paint _paintWhite = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _paintPupil = Paint()..color = const Color(0xFF090D16);
  static final Paint _paintRed = Paint()..color = const Color(0xFFEF4444);
  static final Paint _paintCyan = Paint()..color = const Color(0xFF00F0FF);
  static final Paint _paintYellow = Paint()..color = const Color(0xFFFFDE59);
  static final Paint _paintOil = Paint()..color = const Color(0xFF334155);
  static final Paint _paintGrey = Paint()..color = const Color(0xFF94A3B8);

  // 16x16 Procedural Matrices for each expression
  // '.' = transparent
  // 'B' = black outline / feature
  // 'S' = base skin
  // 'D' = skin shadow
  // 'W' = eye white / teeth
  // 'P' = pupil
  // 'R' = red accent (bandana, blush, tie)
  // 'C' = cyan (sweat, glass glare)
  // 'Y' = yellow / gold / star
  // 'O' = dark oil smudge
  // 'G' = grey hair / shadow

  // 1. CUNNING DEALER: slick hair, raised eyebrow, sly wink/smirk, gold tooth
  static const List<String> _cunningDealerGrid = [
    "....BBBBBBBB....", // 0: Hair top
    "..BBGGGGGGGGGBB.", // 1: Slick hair
    ".BGGGGGGGGGGGGGB", // 2: Slick hair base
    ".BGGSSSSSSSSSSGB", // 3: Forehead with hair trim
    ".BSSBSSSSSSBSSSB", // 4: Eyebrows: left normal, right raised
    ".BSSSSSSSSSSBSSB", // 5: Eyebrow arch
    ".BSWPSSSSSWSBSSB", // 6: Eyes: left squint, right normal
    ".BSBBSSSSSBSBSSB", // 7: Eye line
    ".BSSSSSSSSSSBSSB", // 8: Cheeks
    ".BSSSSSBBSSSSSSB", // 9: Nose
    ".BSSSSSSSSSSSSSB", // 10: Upper lip
    ".BSSSWWYYWSSSSSB", // 11: Smirk with gold tooth (Y)
    ".BSSSBBSBSSSSSSB", // 12: Smile shadow
    "..BSSSSSSSSSSBB.", // 13: Chin
    "...BBBDDDDBBB...", // 14: Neck contour
    ".....BBBBBB.....", // 15: Base collar
  ];

  // 2. PANICKED BANKER: disheveled hair, giant popped eyes, open shouting mouth, splashing sweat
  static const List<String> _panickedBankerGrid = [
    "..C...BBBB...C..", // 0: Sweat droplets flying (C)
    ".C..BBGGGGGGBB.C", // 1: Hair + sweat
    "...BGGGGGGGGGGB.", // 2: Wild hair
    "..BSSSSSSSSSSSSB", // 3: Pale forehead
    ".BSSBBSSSSSSBBSS", // 4: High raised shock eyebrows
    ".BSSBBSSSSSSBBSS", // 5: High raised shock eyebrows
    ".BSWWPBSSSSWWPBS", // 6: Giant wide popped eyes
    ".BSWWPBSSSSWWPBS", // 7: Giant wide popped eyes
    "CBSSBSSSSSSSSBSC", // 8: Sweat on cheeks (C)
    ".BSSSSSSBBSSSSSB", // 9: Shaking nose
    ".BSSSSBBBBSSSSSB", // 10: Open mouth top
    ".BSSSBPWWPBSSSSB", // 11: Open mouth screaming
    ".BSSSBPWWPBSSSSB", // 12: Open mouth screaming
    "..BSSSBBBBSSSSB.", // 13: Open mouth bottom
    "...BSSSSSSSSBB..", // 14: Shaking chin
    "....BBBDDDBB....", // 15: Collar
  ];

  // 3. SWEATING MECHANIC: red bandana, oil smudge, focused squint, sweat drops
  static const List<String> _sweatingMechanicGrid = [
    "....RRRRRRRR....", // 0: Red bandana top
    "..RRRRRRRRRRRR..", // 1: Red bandana dome
    ".RRRRRRRRRRRRRR.", // 2: Red bandana body
    ".BBBBBBBBBBBBBB.", // 3: Bandana knot border
    ".BSSSSSSSSSSSSB.", // 4: Forehead under bandana
    ".BSBBBSSSSBBBSB.", // 5: Determined furrowed brows
    "CBBSBSSSSSSBSB.C", // 6: Sweat drop (C) + squint eyes
    ".BSWPSSSSSWSPSB.", // 7: Focused squint pupils
    ".BSBBSSSSSBSBSB.", // 8: Lower eye line
    ".BSSOOSSSSSSSSSB", // 9: Motor oil smudge on cheek (OO)
    ".BSSOOOSBBSSSSSB", // 10: Oil smudge + nose
    ".BSSSSSSSSSSSSSB", // 11: Upper lip
    ".BSSWBBBBBWWSSSB", // 12: Gritted teeth with toothpick (W)
    "..BSSSSSSSSSSBB.", // 13: Rugged jaw
    "...BBBDDDDBBB...", // 14: Neck
    "....OOOOOOOO....", // 15: Work overalls
  ];

  // 4. SMUG NOTARY: square black glasses, glare tint, strict straight mouth, formal tie
  static const List<String> _smugNotaryGrid = [
    "....BBBBBBBB....", // 0: Formal hair
    "..BBGGGGGGGGBB..", // 1: Hair top
    ".BGGGGGGGGGGGGB.", // 2: Comb-over hair
    ".BGGSSSSSSSSGGB.", // 3: Forehead
    ".BSBBBBSSBBBBSSB", // 4: Strict brow line
    ".BBCCCCBBCCCCBBB", // 5: Square glasses frame + cyan tint (CCCC)
    ".BBCPCCBBCPCCBBB", // 6: Glasses pupil behind glass
    ".BBCCCCBBCCCCBBB", // 7: Square glasses bottom
    ".BSSSSSSSSSSSSSB", // 8: Cheeks
    ".BSSSSSSBBSSSSSB", // 9: Bureaucrat nose
    ".BSSSSSSSSSSSSSB", // 10: Upper lip
    ".BSSSSBBBBBBSSSB", // 11: Deadpan straight strict mouth
    "..BSSSSSSSSSSBB.", // 12: Firm chin
    "...BWWWRRRWWWB..", // 13: Crisp white collar + red tie (RRR)
    "...BWWWRRRWWWB..", // 14: Red tie body
    "....BBBRRRBBB...", // 15: Notary formal suit
  ];

  // 5. HYPED GAMBLER: star eyes, gigantic toothy grin, gold sparkle pikselleri
  static const List<String> _hypedGamblerGrid = [
    "...Y...BBBB...Y.", // 0: Gold spark particles (Y)
    "..BBBBGGGGGGBBBB", // 1: Hype dynamic hair
    ".BGGGGGGGGGGGGB.", // 2: Spiky hair
    ".BGGSSSSSSSSGGB.", // 3: Forehead
    ".BSBSSSSSSSSBSB.", // 4: Happy arched brows
    ".BSBYBSSSSBYBSB.", // 5: Star eye top spark
    ".BBYWYBSSBYWYBBB", // 6: Star eyes sparkle (YWY)
    ".BSBYBSSSSBYBSB.", // 7: Star eye bottom spark
    ".BSSSSSSSSSSSSSB", // 8: Cheeks
    ".BSSSSSSBBSSSSSB", // 9: Nose
    ".BSWWWWWWWWWWWSB", // 10: Huge beaming smile upper teeth
    ".BSWWWWWWWWWWWSB", // 11: Huge beaming smile
    ".BSBBPBBBBBPBBSB", // 12: Smile contour & laugh lines
    "..BSSSSSSSSSSBB.", // 13: Joyful chin
    "...BBBDDDDBBB...", // 14: Neck
    "....YYYYYYYY....", // 15: Gold chain collar
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const int cols = 16;
    const int rows = 16;
    final double pixelW = size.width / cols;
    final double pixelH = size.height / rows;

    final grid = _getGridForExpression(expression);

    for (int r = 0; r < rows; r++) {
      final String rowStr = grid[r];
      for (int c = 0; c < cols; c++) {
        final char = rowStr[c];
        final paint = _getPaintForChar(char);
        if (paint != null) {
          canvas.drawRect(
            Rect.fromLTWH(c * pixelW, r * pixelH, pixelW, pixelH),
            paint,
          );
        }
      }
    }
  }

  List<String> _getGridForExpression(PixelFaceExpression exp) {
    switch (exp) {
      case PixelFaceExpression.cunningDealer:
        return _cunningDealerGrid;
      case PixelFaceExpression.panickedBanker:
        return _panickedBankerGrid;
      case PixelFaceExpression.sweatingMechanic:
        return _sweatingMechanicGrid;
      case PixelFaceExpression.smugNotary:
        return _smugNotaryGrid;
      case PixelFaceExpression.hypedGambler:
        return _hypedGamblerGrid;
    }
  }

  Paint? _getPaintForChar(String char) {
    switch (char) {
      case 'B':
        return _paintBlack;
      case 'S':
        return _paintSkin;
      case 'D':
        return _paintSkinDark;
      case 'W':
        return _paintWhite;
      case 'P':
        return _paintPupil;
      case 'R':
        return _paintRed;
      case 'C':
        return _paintCyan;
      case 'Y':
        return _paintYellow;
      case 'O':
        return _paintOil;
      case 'G':
        return _paintGrey;
      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(covariant _NeoBrutalPixelFacePainter oldDelegate) {
    return oldDelegate.expression != expression;
  }
}
