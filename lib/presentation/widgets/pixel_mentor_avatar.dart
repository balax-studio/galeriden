import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/usecases/smart_mentor_engine.dart' show MentorMood;

export '../../domain/usecases/smart_mentor_engine.dart' show MentorMood;

/// Prosedürel 16-Bit Halil Usta Avatarı (32x32 SNES Retro Tarzı)
/// Kasketli, kır saçlı, esnaf bıyıklı, gözlüklü, yelekli ve köstekli saatli usta figürü.
/// 4 farklı duygu moduna (proud, worried, clever, teaSip) ve
/// kriz anlarında analog CRT glitch / chromatic aberration efektine sahiptir.
class PixelMentorAvatar extends StatefulWidget {
  final double size;
  final bool animated;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Offset shadowOffset;
  final MentorMood mood;
  final bool isGlitching;

  const PixelMentorAvatar({
    super.key,
    this.size = 64,
    this.animated = true,
    this.backgroundColor = AppColors.brutalYellow,
    this.borderColor = const Color(0xFF0F172A),
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(3.5, 3.5),
    this.mood = MentorMood.neutral,
    this.isGlitching = false,
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
                mood: widget.mood,
                isGlitching: widget.isGlitching,
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
  final MentorMood mood;
  final bool isGlitching;

  _HalilUstaPixelPainter({
    required this.isBlinking,
    required this.scanlinePhase,
    this.mood = MentorMood.neutral,
    this.isGlitching = false,
  });

  // --- 16-Bit Zengin SNES Renk Paleti (40 Renk) ---
  // Kasket (Cap / Tweed flat cap)
  static const Color _capHighlight    = Color(0xFF6B729E); // 1: Üst dikiş & aydınlık kıvrım
  static const Color _capMidLight     = Color(0xFF484E72); // 2: Kasket üst gövde
  static const Color _capBase         = Color(0xFF323652); // 3: Kasket ana kumaşı
  static const Color _capDarkFold     = Color(0xFF202336); // 4: Kasket derin gölge
  static const Color _capBrimEdge     = Color(0xFF3A3E5B); // 5: Siperlik üst kenarı
  static const Color _capBrimDark     = Color(0xFF141624); // 6: Siperlik alt koyu gölge

  // Kır Saçlar & Şakaklar (Hair & Sideburns)
  static const Color _hairWhite       = Color(0xFFF1F5F9); // 7: Ak saç teli parıltısı
  static const Color _hairSilver      = Color(0xFF94A3B8); // 8: Gümüş kır saç
  static const Color _hairSlate       = Color(0xFF64748B); // 9: Gri saç gölgesi
  static const Color _hairDeepDark    = Color(0xFF334155); // 10: Şakak derin kök gölgesi

  // Esnaf Ten Tonları (Skin & Facial Tones)
  static const Color _skinSpecular    = Color(0xFFFCE7D2); // 11: Burun ve yanak aydınlığı
  static const Color _skinWarmPeach   = Color(0xFFF3C294); // 12: Aydınlık ten
  static const Color _skinBaseTan     = Color(0xFFDE9964); // 13: Sıcak esnaf buğday teni
  static const Color _skinContour     = Color(0xFFBC7643); // 14: Ten konturu & yanak gölgesi
  static const Color _skinDeepTone    = Color(0xFF8E4F28); // 15: Siperlik altı & kırışıklık

  // Gözlük & Bakış (Glasses & Eyes)
  static const Color _glassesFrame    = Color(0xFF1E293B); // 16: Koyu boynuz çerçeve
  static const Color _glassesRim      = Color(0xFF475569); // 17: Çerçeve metalik parıltı
  static const Color _glassTint       = Color(0xFF93C5FD); // 18: Cam mavi/açık yansıması
  static const Color _glassGlare      = Color(0xFFFFFFFF); // 19: Kristal cam parıltısı
  static const Color _eyePupil        = Color(0xFF090D16); // 20: Göz bebeği
  static const Color _eyeIris         = Color(0xFF451A03); // 21: Sıcak ela iris

  // Gür Esnaf Bıyığı (Layered Master Mustache)
  static const Color _mustacheHair    = Color(0xFF8896AB); // 22: Kır bıyık telleri
  static const Color _mustacheMid     = Color(0xFF4B5565); // 23: Bıyık orta ton kıllar
  static const Color _mustacheDark    = Color(0xFF2B3441); // 24: Kalın bıyık gövdesi
  static const Color _mustacheBase    = Color(0xFF161B22); // 25: Bıyık alt derin gölge

  // Kıyafet & Yelek & Köstekli Saat Zinciri (Clothing & Vest)
  static const Color _shirtWhite      = Color(0xFFFFFFFF); // 26: Beyaz yaka gömlek
  static const Color _shirtShadow     = Color(0xFFCBD5E1); // 27: Gömlek yaka gölgesi
  static const Color _tieRuby         = Color(0xFFDC2626); // 28: Bordo fular/kravat
  static const Color _tieShadow       = Color(0xFF991B1B); // 29: Kravat gölgesi
  static const Color _vestNavy        = Color(0xFF1E293B); // 30: Yün esnaf yeleği
  static const Color _vestMidLight    = Color(0xFF334155); // 31: Yelek kumaş dikiş hattı
  static const Color _vestDeepDark    = Color(0xFF0F172A); // 32: Yelek cep & kıvrım gölgesi
  static const Color _goldChainBright = Color(0xFFFBBF24); // 33: Köstekli saat altın zincir
  static const Color _goldChainDark   = Color(0xFFB45309); // 34: Saat zincir gölgesi

  // İnce Belli Çay Bardağı & Buhar (Tea & Hospitality)
  static const Color _teaCrimson      = Color(0xFFB91C1C); // 35: Demli tavşan kanı çay
  static const Color _teaDarkAmber    = Color(0xFF7F1D1D); // 36: Çay dip tortusu
  static const Color _glassBorder     = Color(0xFFE2E8F0); // 37: İnce belli cam kenarı
  static const Color _glassShade      = Color(0xFF64748B); // 38: Bardak altı & tabak
  static const Color _steamWhite      = Color(0xFFF8FAFC); // 39: Yükselen çay buharı
  static const Color _goldGlint       = Color(0xFFFACC15); // 40: Kurnaz bakış altın parıltısı

  @override
  void paint(Canvas canvas, Size size) {
    const int cols = 32;
    const int rows = 32;
    final double pixelW = size.width / cols;
    final double pixelH = size.height / rows;

    // 32x32 Halil Usta 16-Bit Piksel Şablonu
    final List<List<int>> matrix = [
      // 0: Kasket tepe dikişi
      [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0],
      // 1: Kasket kubbe üstü
      [0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0],
      // 2: Kasket üst bombe
      [0,0,0,0,0,0,1,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,1,0,0,0,0,0,0],
      // 3: Kasket gövdesi genişleme
      [0,0,0,0,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1,0,0,0,0,0],
      // 4: Kasket tam genişlik ve kumaş kırışıklığı
      [0,0,0,1,2,3,3,3,3,3,3,4,4,3,3,3,3,3,3,4,4,3,3,3,3,3,2,1,0,0,0,0],
      // 5: Kasket alt kıvrımları
      [0,0,1,2,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,2,1,0,0,0],
      // 6: Kasket siperliği üst kenar
      [0,1,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,2,1,0,0,0],
      // 7: Siperlik gölgesi ve alt kenar
      [0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0],
      // 8: Siperlik altı derin gölge ve şakak saçları
      [0,0,0,9,8,7,15,15,14,14,14,14,14,14,14,14,14,14,14,14,15,15,7,8,9,0,0,0,0,0,0,0],
      // 9: Alın sıcak tonu ve kırışıklıklar
      [0,0,10,9,8,7,15,14,13,13,13,13,13,13,13,13,13,13,13,13,14,15,7,8,9,10,0,0,0,0,0,0],
      // 10: Alın ışığı ve şakak kır telleri
      [0,0,10,9,8,7,14,13,12,12,11,11,12,12,12,12,11,11,12,12,13,14,7,8,9,10,0,0,0,0,0,0],
      // 11: Kaşlar (Usta esnaf kaşları)
      [0,0,0,9,8,7,14,15,24,24,24,23,13,13,13,13,23,24,24,24,15,14,7,8,9,0,0,0,0,0,0,0],
      // 12: Gözlük üst çerçevesi
      [0,0,0,10,9,8,14,16,17,17,17,17,16,13,13,16,17,17,17,17,16,14,8,9,10,0,0,0,0,0,0,0],
      // 13: Gözlük camları üst kısmı
      [0,0,0,0,9,8,14,16,19,18,18,18,16,13,13,16,19,18,18,18,16,14,8,9,0,0,0,0,0,0,0,0],
      // 14: Gözler, bebekler ve yansıma (Blink etkiler)
      [0,0,0,0,8,7,13,16,18,20,20,18,16,14,14,16,18,20,20,18,16,13,7,8,0,0,0,0,0,0,0,0],
      // 15: Alt camlar ve göz kenarları
      [0,0,0,0,9,8,13,16,18,18,20,18,16,14,14,16,18,18,20,18,16,13,8,9,0,0,0,0,0,0,0,0],
      // 16: Alt çerçeve ve burun köprüsü
      [0,0,0,0,10,9,14,16,17,17,17,17,16,13,13,16,17,17,17,17,16,14,9,10,0,0,0,0,0,0,0,0],
      // 17: Burun ucu ve yanaklar
      [0,0,0,0,0,9,14,13,13,13,12,13,14,12,12,14,13,12,13,13,13,14,9,0,0,0,0,0,0,0,0,0],
      // 18: Burun delikleri ve bıyık kökleri
      [0,0,0,0,0,8,14,14,24,24,23,23,24,15,15,24,23,23,24,24,14,14,8,0,0,0,0,0,0,0,0,0],
      // 19: Görkemli bıyık üst hattı
      [0,0,0,0,23,24,24,24,23,22,22,23,24,24,24,24,23,22,22,23,24,24,24,23,0,0,0,0,0,0,0,0],
      // 20: Bıyık ana gövdesi
      [0,0,0,23,24,25,25,24,23,23,22,23,24,25,25,24,23,22,23,23,24,25,25,24,23,0,0,0,0,0,0,0],
      // 21: Bıyık kıvrımı ve yoğun kıllar
      [0,0,22,24,25,25,25,24,24,23,24,24,25,25,25,25,24,24,23,24,24,25,25,25,24,22,0,0,0,0,0,0],
      // 22: Bıyık uçları kıvrım
      [0,0,23,25,25,24,23,0,25,25,25,25,25,25,25,25,25,25,25,25,0,23,24,25,25,23,0,0,0,0,0,0],
      // 23: Çene ve bıyık altı gölgesi
      [0,0,0,24,23,0,0,0,15,15,14,14,14,14,14,14,14,14,15,15,0,0,0,23,24,0,0,0,0,0,0,0],
      // 24: Alt çene ve beyaz yaka tepesi
      [0,0,0,0,0,0,0,27,26,15,14,13,13,13,13,13,13,14,15,26,27,0,0,0,0,0,0,0,0,0,0,0],
      // 25: Gömlek yaka açıklığı ve boyun
      [0,0,0,0,0,0,30,31,26,26,15,14,14,14,14,14,14,15,26,26,31,30,0,0,0,0,0,0,0,0,0,0],
      // 26: Yelek omuzları ve yaka kanatları
      [0,0,0,0,30,31,30,30,31,26,26,27,28,28,28,28,27,26,26,31,30,30,31,30,0,0,0,0,0,0,0,0],
      // 27: Yelek klapaları ve bordo kravat
      [0,0,0,30,31,30,30,30,30,31,26,27,29,28,28,29,27,26,31,30,30,30,30,31,30,0,0,0,0,0,0,0],
      // 28: Yelek göğsü ve köstekli zincir başlangıcı
      [0,0,30,31,30,30,30,30,30,30,31,26,27,29,29,27,26,31,30,30,30,30,30,30,31,30,0,0,0,0,0,0],
      // 29: Yelek cepleri ve sarkan altın zincir
      [0,30,31,30,30,30,30,32,32,30,30,31,26,27,27,26,31,30,33,33,30,30,30,30,30,31,30,0,0,0,0,0],
      // 30: Altın köstekli saat zincir kıvrımı
      [30,31,30,30,30,30,32,30,30,30,30,30,31,33,33,31,30,33,34,34,33,30,30,30,30,30,31,30,0,0,0,0],
      // 31: Yelek etek hattı
      [30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,0,0,0,0],
    ];

    // Duygu Moduna Göre 16-Bit Matris Adaptasyonu
    if (mood == MentorMood.proud) {
      // Keyifli gururlu gülüş: Bıyık uçları daha da yukarı kıvrık
      matrix[20][2] = 22;
      matrix[20][3] = 23;
      matrix[19][2] = 23;
      matrix[20][28] = 23;
      matrix[20][29] = 22;
      matrix[19][29] = 23;
      // Gözlük camlarında çifte yıldız parıltısı
      matrix[13][9] = 19;
      matrix[13][21] = 19;
    } else if (mood == MentorMood.worried) {
      // Endişeli usta: Kaşlar merkeze doğru çatık
      matrix[11][12] = 24;
      matrix[11][19] = 24;
      // Şakakta soğuk ter damlası
      matrix[9][25] = 18;
      matrix[10][25] = 18;
      // Bıyık uçları aşağı sarkık
      matrix[23][2] = 24;
      matrix[23][29] = 24;
    } else if (mood == MentorMood.clever) {
      // Uyanık mod: Sağ göz kırpıyor (kapalı kapak)
      for (int c = 17; c <= 21; c++) {
        matrix[14][c] = 16;
        matrix[15][c] = 14;
      }
      // Sol gözde altın fırsat parıltısı
      matrix[14][10] = 40;
      matrix[14][11] = 40;
    } else if (mood == MentorMood.teaSip) {
      // Çay içme modu: Sağ alt köşede ince belli çay bardağı ve buhar
      matrix[16][26] = 39; // Buhar
      matrix[17][25] = 39;
      matrix[18][26] = 39;
      matrix[19][25] = 39;
      // Bardak ağzı cam
      for (int c = 24; c <= 27; c++) {
        matrix[20][c] = 37;
      }
      // İnce bel çay kırmızısı
      matrix[21][24] = 37;
      matrix[21][25] = 35;
      matrix[21][26] = 36;
      matrix[21][27] = 37;
      matrix[22][24] = 37;
      matrix[22][25] = 35;
      matrix[22][26] = 36;
      matrix[22][27] = 37;
      // Bardak alt gövdesi
      for (int r = 23; r <= 26; r++) {
        for (int c = 23; c <= 28; c++) {
          matrix[r][c] = 35;
        }
        matrix[r][23] = 37;
        matrix[r][28] = 37;
      }
      // Çay tabağı
      for (int c = 22; c <= 29; c++) {
        matrix[27][c] = 37;
        matrix[28][c] = 28;
      }
    }

    final paint = Paint()..isAntiAlias = false;

    for (int r = 0; r < rows; r++) {
      // Analog CRT Glitch satır kayması
      final double glitchOffset = isGlitching
          ? math.sin(scanlinePhase * 6.0 + r * 1.8) * (pixelW * 0.75)
          : 0.0;

      for (int c = 0; c < cols; c++) {
        int code = matrix[r][c];
        if (code == 0) continue;

        // Göz kırpma durumunda göz bebeği kapalı göz çizgisine dönüşür
        if (isBlinking && (code == 20 || code == 18 || code == 19 || code == 21)) {
          code = 14;
        }

        paint.color = _getColorForCode(code);
        final rect = Rect.fromLTWH(
          c * pixelW + glitchOffset,
          r * pixelH,
          pixelW + 0.05, // Boşluksuz piksel kenarı
          pixelH + 0.05,
        );
        canvas.drawRect(rect, paint);
      }
    }

    // CRT Trinitron Tarama Çizgileri Efekti (16-Bit Crisp)
    final scanlineAlpha = isGlitching ? 65 : 24;
    final scanlinePaint = Paint()
      ..color = Colors.black.withAlpha(scanlineAlpha)
      ..strokeWidth = 1.0
      ..isAntiAlias = false;

    for (double y = 0.5; y < size.height; y += 2.0) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        scanlinePaint,
      );
    }

    // İnce CRT tarama ışıltısı (Scanline Wave)
    final sweepY = (math.sin(scanlinePhase) * 0.5 + 0.5) * size.height;
    final sweepPaint = Paint()
      ..color = Colors.white.withAlpha(isGlitching ? 45 : 18)
      ..strokeWidth = isGlitching ? 2.5 : 1.8;
    canvas.drawLine(
      Offset(0, sweepY),
      Offset(size.width, sweepY),
      sweepPaint,
    );

    // Kriz durumlarında kromatik sapma çizgi sarsıntısı
    if (isGlitching) {
      final chromaticPaint = Paint()
        ..color = AppColors.brutalCyan.withAlpha(40)
        ..strokeWidth = 1.2;
      final shiftY = (math.cos(scanlinePhase * 4.0) * 0.5 + 0.5) * size.height;
      canvas.drawLine(Offset(0, shiftY), Offset(size.width, shiftY), chromaticPaint);
    }
  }

  Color _getColorForCode(int code) {
    switch (code) {
      case 1:
        return _capHighlight;
      case 2:
        return _capMidLight;
      case 3:
        return _capBase;
      case 4:
        return _capDarkFold;
      case 5:
        return _capBrimEdge;
      case 6:
        return _capBrimDark;
      case 7:
        return _hairWhite;
      case 8:
        return _hairSilver;
      case 9:
        return _hairSlate;
      case 10:
        return _hairDeepDark;
      case 11:
        return _skinSpecular;
      case 12:
        return _skinWarmPeach;
      case 13:
        return _skinBaseTan;
      case 14:
        return _skinContour;
      case 15:
        return _skinDeepTone;
      case 16:
        return _glassesFrame;
      case 17:
        return _glassesRim;
      case 18:
        return _glassTint;
      case 19:
        return _glassGlare;
      case 20:
        return _eyePupil;
      case 21:
        return _eyeIris;
      case 22:
        return _mustacheHair;
      case 23:
        return _mustacheMid;
      case 24:
        return _mustacheDark;
      case 25:
        return _mustacheBase;
      case 26:
        return _shirtWhite;
      case 27:
        return _shirtShadow;
      case 28:
        return _tieRuby;
      case 29:
        return _tieShadow;
      case 30:
        return _vestNavy;
      case 31:
        return _vestMidLight;
      case 32:
        return _vestDeepDark;
      case 33:
        return _goldChainBright;
      case 34:
        return _goldChainDark;
      case 35:
        return _teaCrimson;
      case 36:
        return _teaDarkAmber;
      case 37:
        return _glassBorder;
      case 38:
        return _glassShade;
      case 39:
        return _steamWhite;
      case 40:
        return _goldGlint;
      default:
        return Colors.transparent;
    }
  }

  @override
  bool shouldRepaint(covariant _HalilUstaPixelPainter oldDelegate) {
    return oldDelegate.isBlinking != isBlinking ||
        oldDelegate.scanlinePhase != scanlinePhase ||
        oldDelegate.mood != mood ||
        oldDelegate.isGlitching != isGlitching;
  }
}
