import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../providers/game_provider.dart';
import 'parallax_skyline_painter.dart';

/// 2.5D Isometric Coordinate Helper
class IsometricMath {
  static Offset isoToScreen(double row, double col, double tileWidth, double tileHeight, Offset origin) {
    final x = (col - row) * (tileWidth / 2) + origin.dx;
    final y = (col + row) * (tileHeight / 2) + origin.dy;
    return Offset(x, y);
  }

  static MathIsoPoint screenToIso(Offset pt, double tileWidth, double tileHeight, Offset origin) {
    final relX = pt.dx - origin.dx;
    final relY = pt.dy - origin.dy;
    final col = (relX / (tileWidth / 2) + relY / (tileHeight / 2)) / 2;
    final row = (relY / (tileHeight / 2) - relX / (tileWidth / 2)) / 2;
    return MathIsoPoint(row: row.roundToDouble(), col: col.roundToDouble());
  }
}

class MathIsoPoint {
  final double row;
  final double col;
  const MathIsoPoint({required this.row, required this.col});
}

/// Simulated Tycoon Customer Persona
enum _CustomerRole { businessman, enthusiast, collector, casual }

class _TycoonCustomer {
  final int id;
  final _CustomerRole role;
  final Color outfitColor;
  final Color accessoryColor;
  final double speed;
  final double startOffset;
  final String dialogue;
  final String emoji;

  _TycoonCustomer({
    required this.id,
    required this.role,
    required this.outfitColor,
    required this.accessoryColor,
    required this.speed,
    required this.startOffset,
    required this.dialogue,
    required this.emoji,
  });
}

/// Interactive 2.5D Isometric Dealership Showroom Canvas Widget
/// Transformed into a living Idle Tycoon simulation with animated walking customers,
/// dynamic day/night atmospheric transitions, road traffic, and ambient floating earnings.
class IsometricShowroomCanvas extends ConsumerStatefulWidget {
  const IsometricShowroomCanvas({super.key});

  @override
  ConsumerState<IsometricShowroomCanvas> createState() => _IsometricShowroomCanvasState();
}

class _IsometricShowroomCanvasState extends ConsumerState<IsometricShowroomCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  final List<_TycoonCustomer> _customers = [
    _TycoonCustomer(
      id: 1,
      role: _CustomerRole.businessman,
      outfitColor: const Color(0xFF1E3A8A), // Navy Suit
      accessoryColor: const Color(0xFFD97706), // Gold Briefcase
      speed: 1.0,
      startOffset: 0.0,
      dialogue: 'Ekspertiz raporu temiz mi?',
      emoji: '💼',
    ),
    _TycoonCustomer(
      id: 2,
      role: _CustomerRole.enthusiast,
      outfitColor: const Color(0xFFDC2626), // Sport Red Hoodie
      accessoryColor: const Color(0xFF111827), // Black Cap
      speed: 1.25,
      startOffset: 0.28,
      dialogue: 'Motor sesi harika!',
      emoji: '🔥',
    ),
    _TycoonCustomer(
      id: 3,
      role: _CustomerRole.collector,
      outfitColor: const Color(0xFF047857), // Emerald Coat
      accessoryColor: const Color(0xFFF59E0B), // Watch/Glass
      speed: 0.85,
      startOffset: 0.62,
      dialogue: 'Koleksiyonluk bir parça!',
      emoji: '💎',
    ),
    _TycoonCustomer(
      id: 4,
      role: _CustomerRole.casual,
      outfitColor: const Color(0xFF7C3AED), // Purple Jacket
      accessoryColor: const Color(0xFF06B6D4), // Coffee Cup
      speed: 1.1,
      startOffset: 0.82,
      dialogue: 'Pazarlık payı var mı?',
      emoji: '🤝',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details, Size canvasSize, int maxSlots, List<CarModel> cars) {
    const tileWidth = 78.0;
    const tileHeight = 39.0;
    final origin = Offset(canvasSize.width * 0.44, canvasSize.height * 0.28);

    final touchPoint = details.localPosition;
    final isoPt = IsometricMath.screenToIso(touchPoint, tileWidth, tileHeight, origin);

    final col = isoPt.col.toInt();
    final row = isoPt.row.toInt();

    final gridRows = (maxSlots / 3).ceil();
    if (row >= 0 && row < gridRows && col >= 0 && col < 3) {
      final slotIndex = row * 3 + col;
      if (slotIndex >= 0 && slotIndex < maxSlots) {
        if (slotIndex < cars.length) {
          final selectedCar = cars[slotIndex];
          _showCarDetailsSheet(context, selectedCar);
        } else {
          context.push('/marketplace');
        }
      }
    }
  }

  void _showCarDetailsSheet(BuildContext context, CarModel car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
        final p = themeExt.palette;
        return Container(
          decoration: BoxDecoration(
            color: p.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: p.surfaceBorderColor),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: p.surfaceBorderColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark)),
              const SizedBox(height: 8),
              Text(
                'Değer: ${CurrencyFormatter.format(car.estimatedRealValue)} | Yıl: ${car.modelYear}',
                style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/showroom');
                      },
                      icon: const Icon(Icons.storefront_rounded),
                      label: const Text('Vitrine Git'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: p.surfaceBorderColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/workshop');
                      },
                      icon: const Icon(Icons.build_rounded),
                      label: const Text('Atölyeye Al'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final hour = game.inGameTime.hour;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Showroom Header Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.neonCyan, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'CANLI SHOWROOM & OTOMOTİV MERKEZİ',
                  style: AppTypography.labelSmall(isDark).copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.laserGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.laserGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.laserGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${game.ownedCars.length}/${game.maxGarageSlots} Araç Vitrinde',
                    style: const TextStyle(color: AppColors.laserGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Live Animated Isometric Tycoon Canvas
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 300.0;
                final canvasSize = Size(width, height);

                return GestureDetector(
                  onTapUp: (details) => _handleTapUp(details, canvasSize, game.maxGarageSlots, game.ownedCars),
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.isometricGridDark : AppColors.isometricGridLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.primaryColor.withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: p.primaryColor.withValues(alpha: 0.12),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // 1. Dynamic Parallax Sky & Skyline Layer
                          CustomPaint(
                            size: canvasSize,
                            painter: ParallaxSkylinePainter(
                              cameraOffset: Offset(_animController.value * 120.0, 0),
                              parallaxFactor: 0.3,
                              hour: hour,
                            ),
                          ),

                          // 2. Comprehensive Tycoon Showroom & Customer Simulation Painter
                          CustomPaint(
                            size: canvasSize,
                            painter: _IsometricTycoonPainter(
                              ownedCars: game.ownedCars,
                              maxSlots: game.maxGarageSlots,
                              dealershipName: game.dealershipName,
                              inGameTime: game.inGameTime,
                              animProgress: _animController.value,
                              customers: _customers,
                              p: p,
                            ),
                          ),

                          // 3. Dynamic Idle Speech & Purchase Floating Bubbles
                          ..._buildCustomerSpeechBubbles(width, height, game.ownedCars),

                          // 4. Idle Tycoon Ambient HUD Footer
                          Positioned(
                            bottom: 8,
                            left: 10,
                            right: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left: Customer Footfall
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('👥', style: TextStyle(fontSize: 10)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ziyaretçi: ${_customers.length} Alıcı İncelemede',
                                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right: Live Market Interest Rate
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('⚡', style: TextStyle(fontSize: 10)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Galeri Cazibesi: %${(85 + (math.sin(_animController.value * math.pi * 4) * 10).abs()).toInt()}',
                                        style: const TextStyle(color: AppColors.primaryAmber, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildCustomerSpeechBubbles(double width, double height, List<CarModel> cars) {
    if (cars.isEmpty) return [];

    final widgets = <Widget>[];
    final t = _animController.value;

    for (int i = 0; i < _customers.length; i++) {
      final cust = _customers[i];
      final prog = (t * cust.speed + cust.startOffset) % 1.0;

      // When customer is inspecting a vehicle (prog between 0.35 and 0.75)
      if (prog >= 0.35 && prog <= 0.75) {
        final targetCarIndex = i % cars.length;
        final targetCar = cars[targetCarIndex];

        // Bubble Position mapped near vehicle bays
        final bayX = width * (0.22 + (targetCarIndex % 3) * 0.28);
        final bayY = height * (0.28 + (targetCarIndex ~/ 3) * 0.18);

        final isPurchaseMoment = prog >= 0.65;
        final bubbleText = isPurchaseMoment ? '🎉 Teklif Hazırlanıyor!' : cust.dialogue;
        final bubbleColor = isPurchaseMoment ? AppColors.laserGreen : AppColors.arcadeGold;

        widgets.add(
          Positioned(
            top: bayY - 24 + math.sin(t * math.pi * 6) * 3,
            left: bayX - 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: bubbleColor, width: 1.2),
                boxShadow: [
                  BoxShadow(color: bubbleColor.withValues(alpha: 0.3), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isPurchaseMoment ? '💰' : cust.emoji, style: const TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    '${cust.role.name.toUpperCase()}: "$bubbleText"',
                    style: TextStyle(color: bubbleColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );

        // Ambient Floating Cash Feedback
        if (isPurchaseMoment) {
          final floatOffset = (prog - 0.65) / 0.10 * 30.0;
          widgets.add(
            Positioned(
              top: bayY - 38 - floatOffset,
              left: bayX + 20,
              child: Opacity(
                opacity: (1.0 - (prog - 0.65) / 0.10).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.laserGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${CurrencyFormatter.format(targetCar.estimatedRealValue * 0.05)}',
                    style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }
}

/// CustomPainter rendering 2.5D Isometric Floor, Vehicles, Walking Customers,
/// Flag animation, Highway Traffic, Headlight Cones, and Particle Dust.
class _IsometricTycoonPainter extends CustomPainter {
  final List<CarModel> ownedCars;
  final int maxSlots;
  final String dealershipName;
  final DateTime inGameTime;
  final double animProgress;
  final List<_TycoonCustomer> customers;
  final ThemePaletteModel p;

  _IsometricTycoonPainter({
    required this.ownedCars,
    required this.maxSlots,
    required this.dealershipName,
    required this.inGameTime,
    required this.animProgress,
    required this.customers,
    required this.p,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hour = inGameTime.hour;
    final isNight = hour < 7 || hour >= 20;
    final isSunset = hour >= 17 && hour < 20;

    // 1. Terrain Color Tone
    final Color terrainColor;
    if (isNight) {
      terrainColor = const Color(0xFF0B1120);
    } else if (isSunset) {
      terrainColor = const Color(0xFF2E1A17);
    } else {
      terrainColor = p.isDark ? const Color(0xFF131B2E) : const Color(0xFF3B5E34);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = terrainColor);

    // 2. Bottom Asphalt Highway with Animated Moving Traffic
    _drawHighwayAndTraffic(canvas, size, isNight);

    // 3. Dealership Showroom Isometric Dimensions
    const tileWidth = 78.0;
    const tileHeight = 39.0;
    final origin = Offset(size.width * 0.44, size.height * 0.28);

    final gridRows = (maxSlots / 3).ceil();
    const gridCols = 3;

    // Tight Isometric Dealership Concrete Base Pad
    final padTop = IsometricMath.isoToScreen(-0.8, -0.6, tileWidth, tileHeight, origin);
    final padRight = IsometricMath.isoToScreen(-0.8, gridCols - 0.3, tileWidth, tileHeight, origin);
    final padBottom = IsometricMath.isoToScreen(gridRows - 0.3, gridCols - 0.3, tileWidth, tileHeight, origin);
    final padLeft = IsometricMath.isoToScreen(gridRows - 0.3, -0.6, tileWidth, tileHeight, origin);

    final padPath = Path()
      ..moveTo(padTop.dx, padTop.dy)
      ..lineTo(padRight.dx, padRight.dy)
      ..lineTo(padBottom.dx, padBottom.dy)
      ..lineTo(padLeft.dx, padLeft.dy)
      ..close();

    final padPaint = Paint()
      ..color = isNight
          ? const Color(0xFF172033)
          : (isSunset ? const Color(0xFF382D3D) : const Color(0xFFE2E8F0))
      ..style = PaintingStyle.fill;
    canvas.drawPath(padPath, padPaint);

    final padBorderPaint = Paint()
      ..color = p.primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(padPath, padBorderPaint);

    // 4. Dealership Showroom Building Block at the Rear
    final buildingPos = IsometricMath.isoToScreen(-0.8, 1.2, tileWidth, tileHeight, origin);
    _drawDealershipBuildingBlock(canvas, Offset(buildingPos.dx + 25, buildingPos.dy - 10), isNight);

    // 5. Floor Parking Bays & Vehicles
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        final center = IsometricMath.isoToScreen(r.toDouble(), c.toDouble(), tileWidth, tileHeight, origin);
        final slotIndex = r * 3 + c;
        final hasCar = slotIndex < ownedCars.length;
        final isAvailableSlot = slotIndex < maxSlots;

        if (!isAvailableSlot) continue;

        final tilePath = Path()
          ..moveTo(center.dx, center.dy - tileHeight / 2)
          ..lineTo(center.dx + tileWidth / 2, center.dy)
          ..lineTo(center.dx, center.dy + tileHeight / 2)
          ..lineTo(center.dx - tileWidth / 2, center.dy)
          ..close();

        // Floor Tile Fill & Glow
        final tilePaint = Paint()
          ..color = hasCar
              ? p.primaryColor.withValues(alpha: isNight ? 0.22 : 0.35)
              : (p.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85))
          ..style = PaintingStyle.fill;
        canvas.drawPath(tilePath, tilePaint);

        // Parking Bay Border
        final borderPaint = Paint()
          ..color = hasCar ? p.primaryColor : const Color(0xFF94A3B8).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = hasCar ? 1.5 : 1.0;
        canvas.drawPath(tilePath, borderPaint);

        // Bay Number / Tag
        final slotText = 'BAY-${slotIndex + 1}';
        final textSpan = TextSpan(
          text: slotText,
          style: TextStyle(
            color: hasCar ? p.primaryColor : Colors.grey.shade500,
            fontSize: 8.0,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + tileHeight / 4 - 4));

        // Draw Car / Empty Marker
        if (hasCar) {
          final car = ownedCars[slotIndex];
          _drawIsometricCar(canvas, center, car, isNight);
        } else {
          _drawEmptyBayPlus(canvas, center);
        }
      }
    }

    // 6. Draw Animated Walking Tycoon Customers
    _drawWalkingCustomers(canvas, origin, tileWidth, tileHeight, gridRows);

    // 7. Ambient Sparkles & Light Dust
    _drawShowroomAtmosphereParticles(canvas, size, isNight);
  }

  void _drawHighwayAndTraffic(Canvas canvas, Size size, bool isNight) {
    final roadPaint = Paint()
      ..color = const Color(0xFF1E2430)
      ..style = PaintingStyle.fill;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.84)
      ..lineTo(size.width, size.height * 0.98)
      ..lineTo(0, size.height * 0.92)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Yellow Dashed Lane Line
    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final startPt = Offset(0, size.height * 0.85);
    final endPt = Offset(size.width, size.height * 0.91);

    const dashLength = 14.0;
    const gapLength = 10.0;
    final totalDist = (endPt - startPt).distance;
    final dx = (endPt.dx - startPt.dx) / totalDist;
    final dy = (endPt.dy - startPt.dy) / totalDist;

    double currentDist = 0.0;
    while (currentDist < totalDist) {
      final p1 = Offset(startPt.dx + dx * currentDist, startPt.dy + dy * currentDist);
      final p2 = Offset(
        startPt.dx + dx * math.min(currentDist + dashLength, totalDist),
        startPt.dy + dy * math.min(currentDist + dashLength, totalDist),
      );
      canvas.drawLine(p1, p2, linePaint);
      currentDist += dashLength + gapLength;
    }

    // 4 Moving Highway Vehicles
    final carConfigs = [
      {'speed': 1.6, 'offset': 0.0, 'color': const Color(0xFFEF4444), 'size': 20.0},
      {'speed': 1.1, 'offset': 0.35, 'color': const Color(0xFF3B82F6), 'size': 24.0},
      {'speed': 2.0, 'offset': 0.65, 'color': const Color(0xFF10B981), 'size': 18.0},
      {'speed': 0.9, 'offset': 0.85, 'color': const Color(0xFFF59E0B), 'size': 28.0}, // Yellow Bus/Van
    ];

    for (var cfg in carConfigs) {
      final t = ((animProgress * (cfg['speed'] as double) + (cfg['offset'] as double)) % 1.0);
      final carPos = Offset(
        startPt.dx + (endPt.dx - startPt.dx) * t,
        startPt.dy + (endPt.dy - startPt.dy) * t,
      );

      final carColor = cfg['color'] as Color;
      final carSize = cfg['size'] as double;

      // Car Shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(carPos.dx, carPos.dy + 3), width: carSize + 4, height: 10),
        Paint()..color = Colors.black45,
      );

      // Car Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: carPos, width: carSize, height: 10),
          const Radius.circular(3),
        ),
        Paint()..color = carColor,
      );

      // Night Headlight Cone Beam
      if (isNight) {
        final beamPath = Path()
          ..moveTo(carPos.dx + carSize / 2, carPos.dy)
          ..lineTo(carPos.dx + carSize / 2 + 25, carPos.dy - 6)
          ..lineTo(carPos.dx + carSize / 2 + 25, carPos.dy + 6)
          ..close();

        final beamPaint = Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.4), Colors.transparent],
          ).createShader(Rect.fromLTWH(carPos.dx, carPos.dy - 6, 25, 12));
        canvas.drawPath(beamPath, beamPaint);
      }
    }
  }

  void _drawDealershipBuildingBlock(Canvas canvas, Offset center, bool isNight) {
    // Showroom Main Tower
    final bldPath = Path()
      ..moveTo(center.dx, center.dy - 38)
      ..lineTo(center.dx + 44, center.dy - 16)
      ..lineTo(center.dx + 44, center.dy + 16)
      ..lineTo(center.dx, center.dy + 38)
      ..lineTo(center.dx - 44, center.dy + 16)
      ..lineTo(center.dx - 44, center.dy - 16)
      ..close();

    final bldPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawPath(bldPath, bldPaint);

    // Glass Roof Face
    final roofPath = Path()
      ..moveTo(center.dx, center.dy - 38)
      ..lineTo(center.dx + 44, center.dy - 16)
      ..lineTo(center.dx, center.dy + 6)
      ..lineTo(center.dx - 44, center.dy - 16)
      ..close();

    final roofPaint = Paint()..color = isNight ? const Color(0xFF0F172A) : const Color(0xFF334155);
    canvas.drawPath(roofPath, roofPaint);

    // Animated Waving Flag atop building
    final flagPoleTop = Offset(center.dx, center.dy - 56);
    canvas.drawLine(Offset(center.dx, center.dy - 38), flagPoleTop, Paint()..color = Colors.white70..strokeWidth = 2);

    final flagWave = math.sin(animProgress * math.pi * 4) * 4;
    final flagPath = Path()
      ..moveTo(flagPoleTop.dx, flagPoleTop.dy)
      ..lineTo(flagPoleTop.dx + 16, flagPoleTop.dy + flagWave + 3)
      ..lineTo(flagPoleTop.dx, flagPoleTop.dy + 10)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = AppColors.neonCyan);

    // Dealership Glowing Neon Brand Banner
    final textSpan = TextSpan(
      text: dealershipName.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primaryAmber,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 30));

    // LED "24/7 OPEN" Neon Dot
    final ledPaint = Paint()
      ..color = (animProgress * 5).toInt() % 2 == 0 ? AppColors.laserGreen : Colors.green.shade900
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    canvas.drawCircle(Offset(center.dx + tp.width / 2 + 6, center.dy - 25), 3, ledPaint);
  }

  void _drawIsometricCar(Canvas canvas, Offset center, CarModel car, bool isNight) {
    final carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xff')));

    // Car Shadow with Soft Blur
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isNight ? 0.5 : 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 52, height: 22),
      shadowPaint,
    );

    // Isometric 3D Metallic Car Body
    final carTopCenter = Offset(center.dx, center.dy - 12);
    final bodyPaint = Paint()..color = carColor;

    final bodyPath = Path()
      ..moveTo(carTopCenter.dx, carTopCenter.dy - 10)
      ..lineTo(carTopCenter.dx + 22, carTopCenter.dy + 1)
      ..lineTo(carTopCenter.dx, carTopCenter.dy + 12)
      ..lineTo(carTopCenter.dx - 22, carTopCenter.dy + 1)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Metallic Gloss Reflection Line
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(carTopCenter.dx - 18, carTopCenter.dy),
      Offset(carTopCenter.dx, carTopCenter.dy - 8),
      glossPaint,
    );

    // Car Roof Top Face
    final roofPaint = Paint()..color = Colors.white.withValues(alpha: 0.25);
    final roofPath = Path()
      ..moveTo(carTopCenter.dx, carTopCenter.dy - 8)
      ..lineTo(carTopCenter.dx + 12, carTopCenter.dy - 1)
      ..lineTo(carTopCenter.dx, carTopCenter.dy + 6)
      ..lineTo(carTopCenter.dx - 12, carTopCenter.dy - 1)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Car Name Badge Tag
    final nameSpan = TextSpan(
      text: car.brand,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    );
    final nameTp = TextPainter(text: nameSpan, textDirection: TextDirection.ltr)..layout();
    nameTp.paint(canvas, Offset(center.dx - nameTp.width / 2, center.dy - 28));

    // Night Headlight Halo
    if (isNight) {
      final haloPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(center.dx + 18, center.dy + 2), 4, haloPaint);
    }
  }

  void _drawEmptyBayPlus(Canvas canvas, Offset center) {
    final iconPaint = Paint()
      ..color = p.primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(center.dx - 6, center.dy - 4), Offset(center.dx + 6, center.dy - 4), iconPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 2), iconPaint);
  }

  void _drawWalkingCustomers(Canvas canvas, Offset origin, double tileWidth, double tileHeight, int gridRows) {
    if (ownedCars.isEmpty) return;

    for (int i = 0; i < customers.length; i++) {
      final cust = customers[i];
      final prog = (animProgress * cust.speed + cust.startOffset) % 1.0;

      // Isometric path: from entrance path (row=gridRows, col=0) to target car bay and back
      final targetSlot = i % ownedCars.length;
      final targetRow = (targetSlot ~/ 3).toDouble();
      final targetCol = (targetSlot % 3).toDouble();

      final enterPos = IsometricMath.isoToScreen(gridRows.toDouble(), 1.5, tileWidth, tileHeight, origin);
      final bayPos = IsometricMath.isoToScreen(targetRow, targetCol, tileWidth, tileHeight, origin);

      final Offset currentPos;
      if (prog < 0.35) {
        // Walking to car
        final subT = prog / 0.35;
        currentPos = Offset.lerp(enterPos, Offset(bayPos.dx + 18, bayPos.dy + 6), subT)!;
      } else if (prog < 0.75) {
        // Inspecting car (slight pacing / head tilt)
        final bob = math.sin(prog * math.pi * 8) * 2;
        currentPos = Offset(bayPos.dx + 18 + bob, bayPos.dy + 6);
      } else {
        // Walking back / towards entrance
        final subT = (prog - 0.75) / 0.25;
        currentPos = Offset.lerp(Offset(bayPos.dx + 18, bayPos.dy + 6), enterPos, subT)!;
      }

      // Draw Customer 2D Isometric Character Figure
      _drawCustomerFigure(canvas, currentPos, cust, prog);
    }
  }

  void _drawCustomerFigure(Canvas canvas, Offset pos, _TycoonCustomer cust, double prog) {
    final walkCycle = math.sin(prog * math.pi * 16);

    // 1. Character Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 1), width: 10, height: 5),
      Paint()..color = Colors.black38,
    );

    // 2. Legs (Walking animation)
    final legPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(pos.dx - 1.5, pos.dy - 6),
      Offset(pos.dx - 2.5 + walkCycle * 2, pos.dy),
      legPaint,
    );
    canvas.drawLine(
      Offset(pos.dx + 1.5, pos.dy - 6),
      Offset(pos.dx + 2.5 - walkCycle * 2, pos.dy),
      legPaint,
    );

    // 3. Torso / Outfit
    final bodyRect = Rect.fromCenter(center: Offset(pos.dx, pos.dy - 10), width: 6.5, height: 8);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)), Paint()..color = cust.outfitColor);

    // 4. Head
    canvas.drawCircle(Offset(pos.dx, pos.dy - 16), 3.5, Paint()..color = const Color(0xFFFFDBAC));

    // 5. Hair / Accessory
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 17), width: 7, height: 5),
      math.pi,
      math.pi,
      true,
      Paint()..color = cust.accessoryColor,
    );
  }

  void _drawShowroomAtmosphereParticles(Canvas canvas, Size size, bool isNight) {
    final particlePaint = Paint()
      ..color = isNight
          ? AppColors.primaryAmber.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (int i = 0; i < 12; i++) {
      final seed = i * 47.0;
      final px = (size.width * 0.15 + (seed * 17) % (size.width * 0.7));
      final py = (size.height * 0.2 + (seed * 23 + animProgress * 80) % (size.height * 0.5));
      final pRadius = 1.0 + (i % 3) * 0.5;

      canvas.drawCircle(Offset(px, py), pRadius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IsometricTycoonPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.ownedCars != ownedCars ||
        oldDelegate.inGameTime != inGameTime ||
        oldDelegate.maxSlots != maxSlots;
  }
}
