import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Prosedürel 8-Bit Halil Usta Avatarı
/// Kasketli, esnaf bıyıklı, gözlüklü retro esnaf usta figürü.
/// CRT raster tarama çizgileri (scanlines) ve yumuşak göz kırpma döngüsü içerir.
class PixelMentorAvatar extends StatefulWidget {
  final double size;
  final bool animated;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Offset shadowOffset;

  const PixelMentorAvatar({
    super.key,
    this.size = 64,
    this.animated = true,
    this.backgroundColor = AppColors.brutalYellow,
    this.borderColor = const Color(0xFF0F172A),
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(3.5, 3.5),
  });

  @override
  State<PixelMentorAvatar> createState() => _PixelMentorAvatarState();
}

class _PixelMentorAvatarState extends State<PixelMentorAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.borderColor,
            offset: widget.shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 - widget.borderWidth),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Blink cycle: blinks briefly every 3.2 seconds
            final progress = _controller.value;
            final isBlinking = progress > 0.46 && progress < 0.52;
            final scanlinePhase = progress * math.pi * 2;
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _HalilUstaPixelPainter(
                isBlinking: isBlinking,
                scanlinePhase: scanlinePhase,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HalilUstaPixelPainter extends CustomPainter {
  final bool isBlinking;
  final double scanlinePhase;

  _HalilUstaPixelPainter({
    required this.isBlinking,
    required this.scanlinePhase,
  });

  // Renk Paleti (16x16 Matris)
  static const Color _capBase = Color(0xFF2B2D42);      // Kasket ana kumaşı
  static const Color _capHighlight = Color(0xFF4A4E69); // Kasket üst dikiş
  static const Color _capBrim = Color(0xFF191924);      // Kasket siperliği
  static const Color _hair = Color(0xFF7F8C8D);         // Kır saçlar
  static const Color _hairLight = Color(0xFFBDC3C7);    // Beyaz teller
  static const Color _skin = Color(0xFFE0A96D);         // Sıcak buğday ten
  static const Color _skinShadow = Color(0xFFC58B54);   // Ten gölgesi
  static const Color _glasses = Color(0xFF1B2631);      // Gözlük çerçevesi
  static const Color _glassGlare = Color(0xFFFFFFFF);   // Cam yansıması
  static const Color _eye = Color(0xFF0F172A);          // Göz bebeği
  static const Color _mustache = Color(0xFF2C3E50);     // Kalın esnaf bıyığı
  static const Color _mustacheDark = Color(0xFF17202A); // Bıyık alt gölge
  static const Color _shirt = Color(0xFFF8F9F9);        // Beyaz gömlek yaka
  static const Color _vest = Color(0xFF1F3A52);         // Esnaf yeleği
  static const Color _vestShadow = Color(0xFF152636);   // Yelek gölgesi
  static const Color _chain = Color(0xFFF39C12);        // Köstekli saat zinciri

  @override
  void paint(Canvas canvas, Size size) {
    const int cols = 16;
    const int rows = 16;
    final double pixelW = size.width / cols;
    final double pixelH = size.height / rows;

    // 16x16 Halil Usta Piksel Şablonu:
    // 0 = Boş (Şeffaf / Arkaplan rengi görünür)
    // 1 = Kasket Üst Dikiş
    // 2 = Kasket Kumaşı
    // 3 = Kasket Siperliği
    // 4 = Kır Saç
    // 5 = Beyaz Saç Teli
    // 6 = Ten
    // 7 = Ten Gölgesi
    // 8 = Gözlük Çerçevesi
    // 9 = Cam Yansıması
    // 10 = Göz Bebeği (Blink'te 8 veya 7 olur)
    // 11 = Bıyık
    // 12 = Bıyık Gölgesi
    // 13 = Gömlek
    // 14 = Yelek
    // 15 = Yelek Gölgesi
    // 16 = Saat Zinciri

    final List<List<int>> matrix = [
      // 0: Kasket Tepe
      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      // 1: Kasket Gövde
      [0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0],
      // 2: Kasket Genişliği
      [0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0],
      // 3: Kasket Siperliği (Öne eğik)
      [0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0],
      // 4: Alın & Şakak Kır Saçları
      [0, 4, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 4, 0, 0],
      // 5: Gözlük Üst Çerçevesi & Kaş
      [0, 4, 8, 8, 8, 8, 6, 6, 8, 8, 8, 8, 6, 4, 0, 0],
      // 6: Gözler & Gözlük Camları (Blink durumu)
      [0, 4, 8, 9, 10, 8, 6, 6, 8, 9, 10, 8, 6, 4, 0, 0],
      // 7: Gözlük Alt Çerçevesi & Burun
      [0, 6, 8, 8, 8, 8, 7, 7, 8, 8, 8, 8, 6, 6, 0, 0],
      // 8: Esnaf Bıyığı (Görkemli)
      [0, 0, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 0, 0, 0],
      // 9: Bıyık Alt Kıvrımı & Çene
      [0, 0, 0, 12, 12, 11, 11, 11, 11, 11, 12, 12, 0, 0, 0, 0],
      // 10: Çene & Yaka Başlangıcı
      [0, 0, 0, 0, 6, 6, 7, 7, 6, 6, 0, 0, 0, 0, 0, 0],
      // 11: Gömlek & Yelek Omuzları
      [0, 14, 14, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 0, 0, 0],
      // 12: Yelek Gövdesi & Kravat/Fular & Cep
      [14, 14, 14, 15, 13, 13, 15, 15, 13, 13, 15, 14, 14, 14, 0, 0],
      // 13: Yelek & Köstekli Saat Zinciri
      [14, 14, 15, 15, 15, 16, 16, 16, 15, 15, 15, 15, 14, 14, 0, 0],
      // 14: Yelek Eteği
      [14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 0, 0],
      // 15: Alt Sınır
      [0, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 0, 0],
    ];

    final paint = Paint()..isAntiAlias = false;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int code = matrix[r][c];
        if (code == 0) continue;

        // Göz kırpma durumunda göz bebeği kapalı çizgiye dönüşür
        if (isBlinking && (code == 10 || code == 9)) {
          code = 8;
        }

        paint.color = _getColorForCode(code);
        final rect = Rect.fromLTWH(
          c * pixelW,
          r * pixelH,
          pixelW + 0.05, // Boşluksuz piksel kenarı
          pixelH + 0.05,
        );
        canvas.drawRect(rect, paint);
      }
    }

    // CRT Raster Tarama Çizgileri Efekti
    final scanlinePaint = Paint()
      ..color = Colors.black.withAlpha(28)
      ..strokeWidth = 1.0
      ..isAntiAlias = false;

    for (double y = 0.5; y < size.height; y += 2.5) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        scanlinePaint,
      );
    }

    // İnce CRT tarama ışıltısı (Scanline Wave)
    final sweepY = (math.sin(scanlinePhase) * 0.5 + 0.5) * size.height;
    final sweepPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, sweepY),
      Offset(size.width, sweepY),
      sweepPaint,
    );
  }

  Color _getColorForCode(int code) {
    switch (code) {
      case 1:
        return _capHighlight;
      case 2:
        return _capBase;
      case 3:
        return _capBrim;
      case 4:
        return _hair;
      case 5:
        return _hairLight;
      case 6:
        return _skin;
      case 7:
        return _skinShadow;
      case 8:
        return _glasses;
      case 9:
        return _glassGlare;
      case 10:
        return _eye;
      case 11:
        return _mustache;
      case 12:
        return _mustacheDark;
      case 13:
        return _shirt;
      case 14:
        return _vest;
      case 15:
        return _vestShadow;
      case 16:
        return _chain;
      default:
        return Colors.transparent;
    }
  }

  @override
  bool shouldRepaint(covariant _HalilUstaPixelPainter oldDelegate) {
    return oldDelegate.isBlinking != isBlinking ||
        oldDelegate.scanlinePhase != scanlinePhase;
  }
}
