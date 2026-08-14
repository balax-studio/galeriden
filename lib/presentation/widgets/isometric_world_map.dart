import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/theme_palette_model.dart';
import '../providers/game_provider.dart';
import 'parallax_skyline_painter.dart';

/// ---------------------------------------------------------------------------
/// Isometric World Constants & Coordinate Helpers
/// ---------------------------------------------------------------------------
class IsoWorld {
  IsoWorld._();

  // Logical world canvas dimensions (the pannable map area).
  static const double worldWidth = 1600.0;
  static const double worldHeight = 1300.0;

  // Isometric tile dimensions.
  static const double tileW = 82.0;
  static const double tileH = 41.0;

  // World origin: everything is drawn relative to this point.
  static Offset get origin => const Offset(worldWidth * 0.5, worldHeight * 0.36);

  static Offset isoToScreen(double row, double col) {
    final x = (col - row) * (tileW / 2) + origin.dx;
    final y = (col + row) * (tileH / 2) + origin.dy;
    return Offset(x, y);
  }
}

/// A tappable business building placed on the isometric world.
class WorldBuilding {
  final String route;
  final String name;
  final String shortName;
  final String subtitle;
  final String description;
  final String emoji;
  final Color color;
  final double row;
  final double col;
  final double footprint; // half-width in screen px
  final int requiredLevel;
  final double unlockCost;

  const WorldBuilding({
    required this.route,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.color,
    required this.row,
    required this.col,
    this.footprint = 42,
    this.requiredLevel = 1,
    this.unlockCost = 0,
  });

  Offset get screenCenter => IsoWorld.isoToScreen(row, col);

  /// Clickable region covering the building sprite (base diamond + tower + rooftop sign).
  Rect get hitRect {
    final c = screenCenter;
    // Generous top bound to cover tall walls (≤66) + rooftop sign board.
    return Rect.fromLTRB(
      c.dx - footprint - 6,
      c.dy - footprint * 2.7,
      c.dx + footprint + 6,
      c.dy + footprint * 0.5 + 20, // include name pill below
    );
  }
}

/// The full city layout. Commerce buildings flank a central showroom plaza.
const List<WorldBuilding> kWorldBuildings = [
  // ---- Kuzeybatı / Araç Hattı ----
  WorldBuilding(
    route: '/marketplace',
    name: 'İkinci El Pazar',
    shortName: 'Oto Pazar',
    subtitle: 'Araç Al · Pazarlık',
    description: 'Sahibinden araç bul, ekspertiz iste ve pazarlıkla en iyi fiyata kap.',
    emoji: '🚗',
    color: Color(0xFF3B82F6),
    row: -4.0,
    col: -6.0,
    requiredLevel: 1,
    unlockCost: 0,
  ),
  WorldBuilding(
    route: '/workshop',
    name: 'Tamir Atölyesi',
    shortName: 'Atölye',
    subtitle: 'Hasar Onarımı',
    description: 'Aracın hasarlı parçalarını onar, değerini yükselt ve satışa hazırla.',
    emoji: '🔧',
    color: Color(0xFFF59E0B),
    row: 0.0,
    col: -6.0,
    requiredLevel: 1,
    unlockCost: 0,
  ),
  WorldBuilding(
    route: '/car-wash',
    name: 'Oto Yıkama',
    shortName: 'Oto Yıkama',
    subtitle: 'Detaylı Temizlik',
    description: 'Detaylı yıkama ve pasta-cila ile aracın ilk izlenimini güçlendir.',
    emoji: '🚿',
    color: Color(0xFF06B6D4),
    row: 4.0,
    col: -6.0,
    requiredLevel: 2,
    unlockCost: 15000,
  ),
  WorldBuilding(
    route: '/tuning-studio',
    name: 'VIP Tuning',
    shortName: 'VIP Tuning',
    subtitle: 'Performans',
    description: 'Araçları modifiye et, performans paketleriyle premium fiyata sat.',
    emoji: '⚡',
    color: Color(0xFFEAB308),
    row: 8.0,
    col: -6.0,
    requiredLevel: 5,
    unlockCost: 120000,
  ),
  // ---- Kuzeydoğu / Finans Hattı ----
  WorldBuilding(
    route: '/finance',
    name: 'Banka & Finans',
    shortName: 'Banka',
    subtitle: 'Kredi · Çek · Vadeli',
    description: 'Kredi çek, çek/senet tahsil et, vadeli satış sözleşmelerini yönet.',
    emoji: '🏦',
    color: Color(0xFF10B981),
    row: -6.0,
    col: -4.0,
    requiredLevel: 3,
    unlockCost: 35000,
  ),
  WorldBuilding(
    route: '/bank-investments',
    name: 'Yatırım Merkezi',
    shortName: 'Yatırım',
    subtitle: 'Fon · Altın',
    description: 'Birikimini fon ve altında değerlendir, uzun vadeli servet kur.',
    emoji: '💰',
    color: Color(0xFFD97706),
    row: -6.0,
    col: 0.0,
    requiredLevel: 6,
    unlockCost: 180000,
  ),
  WorldBuilding(
    route: '/stock-market',
    name: 'Borsa',
    shortName: 'Borsa',
    subtitle: 'Hisse Yatırımı',
    description: 'Otomotiv hisselerine yatırım yap, piyasa dalgalarından kâr et.',
    emoji: '📈',
    color: Color(0xFF6366F1),
    row: -6.0,
    col: 4.0,
    requiredLevel: 7,
    unlockCost: 250000,
  ),
  WorldBuilding(
    route: '/rent-a-car',
    name: 'Rent a Car',
    shortName: 'Rent a Car',
    subtitle: 'Filo Kiralama',
    description: 'Araçlarını kiraya ver, günlük düzenli kira geliri elde et.',
    emoji: '🔑',
    color: Color(0xFF14B8A6),
    row: -6.0,
    col: 8.0,
    requiredLevel: 4,
    unlockCost: 75000,
  ),
  // ---- Güneybatı / Riziko Hattı ----
  WorldBuilding(
    route: '/auction',
    name: 'Canlı İhale',
    shortName: 'Canlı İhale',
    subtitle: 'Açık Artırma',
    description: 'Rakip galericilere karşı teklif ver, nadir araçları kap.',
    emoji: '🔨',
    color: Color(0xFFEF4444),
    row: 8.0,
    col: -2.0,
    requiredLevel: 4,
    unlockCost: 60000,
  ),
  WorldBuilding(
    route: '/scrapyard',
    name: 'Hurdalık',
    shortName: 'Hurdalık',
    subtitle: 'Parça Söküm',
    description: 'Kazalı araçları sök, değerli yedek parçaları stokla ve sat.',
    emoji: '🛞',
    color: Color(0xFFF97316),
    row: 8.0,
    col: 2.0,
    requiredLevel: 3,
    unlockCost: 40000,
  ),
  WorldBuilding(
    route: '/black-market',
    name: 'Karaborsa',
    shortName: 'Karaborsa',
    subtitle: 'Riskli Oto',
    description: 'Yüksek riskli, yüksek kârlı gri piyasa araçları. Dikkatli ol!',
    emoji: '🕶️',
    color: Color(0xFF475569),
    row: 8.0,
    col: 6.0,
    requiredLevel: 8,
    unlockCost: 350000,
  ),
  // ---- Güneydoğu / Büyüme Hattı ----
  WorldBuilding(
    route: '/branches',
    name: 'Şube İmparatorluğu',
    shortName: 'Şubeler',
    subtitle: 'Kapasite & Galeri',
    description: 'Yeni şubeler aç, vitrin kapasiteni ve prestijini büyüt.',
    emoji: '🏢',
    color: Color(0xFFC9A96E),
    row: -2.0,
    col: 8.0,
    requiredLevel: 5,
    unlockCost: 100000,
  ),
  WorldBuilding(
    route: '/staff',
    name: 'Personel Ofisi',
    shortName: 'Personel',
    subtitle: 'Kadro Yönetimi',
    description: 'Usta ve satış danışmanı işe al, ekibini eğit ve verimi artır.',
    emoji: '👔',
    color: Color(0xFFA855F7),
    row: 2.0,
    col: 8.0,
    requiredLevel: 2,
    unlockCost: 20000,
  ),
  WorldBuilding(
    route: '/side-businesses',
    name: 'Yan İşletme',
    shortName: 'Yan İşletme',
    subtitle: 'Pasif Gelir',
    description: 'Ek işletmeler aç, sen uyurken bile kasaya para aksın.',
    emoji: '🏪',
    color: Color(0xFF8B5CF6),
    row: 6.0,
    col: 8.0,
    requiredLevel: 6,
    unlockCost: 150000,
  ),
];

/// ---------------------------------------------------------------------------
/// Living tycoon customer persona (walks around the plaza).
/// ---------------------------------------------------------------------------
class _Customer {
  final Color outfit;
  final Color accent;
  final double speed;
  final double offset;
  const _Customer(this.outfit, this.accent, this.speed, this.offset);
}

const List<_Customer> _customers = [
  _Customer(Color(0xFF1E3A8A), Color(0xFFD97706), 1.0, 0.0),
  _Customer(Color(0xFFDC2626), Color(0xFF111827), 1.25, 0.28),
  _Customer(Color(0xFF047857), Color(0xFFF59E0B), 0.85, 0.62),
  _Customer(Color(0xFF7C3AED), Color(0xFF06B6D4), 1.1, 0.82),
];

/// ---------------------------------------------------------------------------
/// Full-Screen Interactive Isometric Tycoon World Map
/// ---------------------------------------------------------------------------
class IsometricWorldMap extends ConsumerStatefulWidget {
  const IsometricWorldMap({super.key});

  @override
  ConsumerState<IsometricWorldMap> createState() => _IsometricWorldMapState();
}

class _IsometricWorldMapState extends ConsumerState<IsometricWorldMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final TransformationController _transform = TransformationController();
  bool _centered = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _centerOnShowroom(Size viewport) {
    if (_centered) return;
    _centered = true;
    // The building ring spans ~1270px wide; fit it to the viewport with padding.
    final scale = (viewport.width / 1420).clamp(0.42, 1.0);
    final focus = IsoWorld.isoToScreen(1.0, 1.0);
    final dx = viewport.width / 2 - focus.dx * scale;
    final dy = viewport.height / 2 - focus.dy * scale;
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _handleTapUp(TapUpDetails details, DealershipModel game, ThemePaletteModel p) {
    final pt = details.localPosition;

    // 1. Building hit-test (front-most first → reverse depth order).
    final sorted = [...kWorldBuildings]..sort((a, b) => b.screenCenter.dy.compareTo(a.screenCenter.dy));
    for (final b in sorted) {
      if (b.hitRect.contains(pt)) {
        _showBuildingSheet(b, game, p);
        return;
      }
    }

    // 2. Parking bay hit-test → open car detail or send to marketplace.
    final maxSlots = game.maxGarageSlots;
    final gridRows = (maxSlots / 3).ceil();
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < 3; c++) {
        final center = IsoWorld.isoToScreen(r.toDouble(), c.toDouble());
        final diamond = Path()
          ..moveTo(center.dx, center.dy - IsoWorld.tileH / 2)
          ..lineTo(center.dx + IsoWorld.tileW / 2, center.dy)
          ..lineTo(center.dx, center.dy + IsoWorld.tileH / 2)
          ..lineTo(center.dx - IsoWorld.tileW / 2, center.dy)
          ..close();
        if (diamond.contains(pt)) {
          final slot = r * 3 + c;
          if (slot >= maxSlots) return;
          if (slot < game.ownedCars.length) {
            _showCarSheet(game.ownedCars[slot], p);
          } else {
            context.push('/marketplace');
          }
          return;
        }
      }
    }
  }

  void _showBuildingSheet(WorldBuilding b, DealershipModel game, ThemePaletteModel p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: p.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: b.color.withValues(alpha: 0.5), width: 1.2),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: p.surfaceBorderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: b.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: b.color.withValues(alpha: 0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(b.emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.name, style: AppTypography.titleLarge(p.isDark)),
                      const SizedBox(height: 2),
                      Text(
                        b.subtitle.toUpperCase(),
                        style: AppTypography.labelSmall(p.isDark).copyWith(
                          color: b.color,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              b.description,
              style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 13, height: 1.4),
            ),
            if (!game.isBuildingUnlocked(b.route)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: p.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.surfaceBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: p.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Text('Seviye ${b.requiredLevel}', style: AppTypography.labelSmall(p.isDark).copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Icon(Icons.account_balance_wallet_rounded, color: p.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(CurrencyFormatter.format(b.unlockCost), style: AppTypography.labelSmall(p.isDark).copyWith(fontWeight: FontWeight.w800, color: p.primaryColor)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: game.isBuildingUnlocked(b.route)
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: b.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(b.route);
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: Text('${b.name} · Giriş Yap', style: const TextStyle(fontWeight: FontWeight.w800)),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: game.level >= b.requiredLevel
                            ? AppColors.successGreen
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: game.level >= b.requiredLevel && game.balance >= b.unlockCost
                          ? () {
                              Navigator.pop(ctx);
                              ref.read(gameProvider.notifier).unlockBuilding(b.route, b.unlockCost);
                            }
                          : null,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: Text(
                        game.level < b.requiredLevel
                            ? 'Seviye ${b.requiredLevel} Gerekli'
                            : '${CurrencyFormatter.formatShort(b.unlockCost)} ile Aç',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCarSheet(CarModel car, ThemePaletteModel p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: p.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: p.surfaceBorderColor),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: p.surfaceBorderColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark)),
            const SizedBox(height: 6),
            Text(
              'Değer: ${CurrencyFormatter.format(car.estimatedRealValue)}  ·  ${car.modelYear}',
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
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/showroom');
                    },
                    icon: const Icon(Icons.storefront_rounded),
                    label: const Text('Vitrine Koy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: p.surfaceBorderColor),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/workshop');
                    },
                    icon: const Icon(Icons.build_rounded),
                    label: const Text('Atölyeye Al'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final hour = game.inGameTime.hour;

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerOnShowroom(constraints.biggest);
        });

        return ClipRect(
          child: InteractiveViewer(
            transformationController: _transform,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(400),
            minScale: 0.35,
            maxScale: 2.2,
            child: SizedBox(
              width: IsoWorld.worldWidth,
              height: IsoWorld.worldHeight,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) => _handleTapUp(d, game, p),
                    child: Stack(
                      children: [
                        // Sky / skyline backdrop.
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ParallaxSkylinePainter(
                              cameraOffset: Offset(_anim.value * 120, 0),
                              parallaxFactor: 0.3,
                              hour: hour,
                            ),
                          ),
                        ),
                        // The living isometric world.
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WorldPainter(
                              ownedCars: game.ownedCars,
                              maxSlots: game.maxGarageSlots,
                              dealershipName: game.dealershipName,
                              hour: hour,
                              anim: _anim.value,
                              p: p,
                              game: game,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// World Painter: grass, roads, showroom plaza, cars, buildings, customers.
/// ---------------------------------------------------------------------------
class _WorldPainter extends CustomPainter {
  final List<CarModel> ownedCars;
  final int maxSlots;
  final String dealershipName;
  final int hour;
  final double anim;
  final ThemePaletteModel p;
  final DealershipModel game;

  _WorldPainter({
    required this.ownedCars,
    required this.maxSlots,
    required this.dealershipName,
    required this.hour,
    required this.anim,
    required this.p,
    required this.game,
  });

  bool get isNight => hour < 7 || hour >= 20;
  bool get isSunset => hour >= 17 && hour < 20;

  /// Ring road + plaza spurs + outward exits, as (row0, col0, row1, col1, halfWidth).
  static const List<List<double>> kRoadSegments = [
    // Diamond ring road around the central plaza.
    [-4, -4, -4, 6, 22],
    [-4, 6, 6, 6, 22],
    [6, 6, 6, -4, 22],
    [6, -4, -4, -4, 22],
    // Short spurs connecting the plaza to the ring.
    [-1, 1, -4, 1, 14],
    [3, 1, 6, 1, 14],
    [1, -1, 1, -4, 14],
    [1, 3, 1, 6, 14],
    // Outward exits through the north/south gaps in the building ring.
    [-4, -4, -14, -14, 20],
    [6, 6, 16, 16, 20],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    _drawRoads(canvas);
    _drawStreetFurniture(canvas);
    _drawPlaza(canvas);
    _drawShowroomTower(canvas);

    // Depth-sorted drawables (buildings + cars + customers) → back-to-front.
    final drawables = <_Drawable>[];

    for (final b in kWorldBuildings) {
      final c = b.screenCenter;
      drawables.add(_Drawable(c.dy, () => _drawBuilding(canvas, b)));
    }

    final gridRows = (maxSlots / 3).ceil();
    for (int r = 0; r < gridRows; r++) {
      for (int col = 0; col < 3; col++) {
        final slot = r * 3 + col;
        if (slot >= maxSlots) continue;
        final center = IsoWorld.isoToScreen(r.toDouble(), col.toDouble());
        if (slot < ownedCars.length) {
          final car = ownedCars[slot];
          drawables.add(_Drawable(center.dy + 1, () => _drawCar(canvas, center, car)));
        } else {
          drawables.add(_Drawable(center.dy, () => _drawEmptyBay(canvas, center)));
        }
      }
    }

    if (ownedCars.isNotEmpty) {
      for (int i = 0; i < _customers.length; i++) {
        final pos = _customerPos(i, gridRows);
        drawables.add(_Drawable(pos.dy, () => _drawCustomer(canvas, pos, _customers[i], i)));
      }
    }

    drawables.sort((a, b) => a.depth.compareTo(b.depth));
    for (final d in drawables) {
      d.paint();
    }

    _drawAmbientParticles(canvas, size);
  }

  // ---- Ground ----
  void _drawGround(Canvas canvas, Size size) {
    final Color grass;
    if (isNight) {
      grass = const Color(0xFF1A2E1E);
    } else if (isSunset) {
      grass = const Color(0xFF5C6B3A);
    } else {
      grass = p.isDark ? const Color(0xFF243B2A) : AppColors.beneloilGrassGreen;
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = grass);

    // Subtle checkerboard field texture.
    final tilePaint = Paint()..color = Colors.black.withValues(alpha: 0.04);
    for (double x = 0; x < size.width; x += 160) {
      for (double y = 0; y < size.height; y += 160) {
        if (((x ~/ 160) + (y ~/ 160)) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 160, 160), tilePaint);
        }
      }
    }

    // Decorative trees scattered around the edges.
    final rnd = math.Random(7);
    for (int i = 0; i < 90; i++) {
      final tx = rnd.nextDouble() * size.width;
      final ty = rnd.nextDouble() * size.height;
      if (_treeBlocked(Offset(tx, ty))) continue;
      _drawTree(canvas, Offset(tx, ty));
    }
  }

  void _drawTree(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 3), width: 16, height: 7),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 6), width: 3, height: 10),
      Paint()..color = const Color(0xFF6B4423),
    );
    canvas.drawCircle(Offset(base.dx, base.dy - 14), 9, Paint()..color = const Color(0xFF2F7D32));
    canvas.drawCircle(Offset(base.dx - 5, base.dy - 10), 6, Paint()..color = const Color(0xFF357A38));
    canvas.drawCircle(Offset(base.dx + 5, base.dy - 10), 6, Paint()..color = const Color(0xFF2C6E30));
  }

  // ---- Roads ----
  void _drawRoads(Canvas canvas) {
    final roadPaint = Paint()..color = AppColors.beneloilAsphaltRoad;
    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    void avenue(double r0, double c0, double r1, double c1, double halfW) {
      final a = IsoWorld.isoToScreen(r0, c0);
      final b = IsoWorld.isoToScreen(r1, c1);
      final dir = (b - a);
      final len = dir.distance;
      final nx = -dir.dy / len, ny = dir.dx / len;
      final path = Path()
        ..moveTo(a.dx + nx * halfW, a.dy + ny * halfW)
        ..lineTo(b.dx + nx * halfW, b.dy + ny * halfW)
        ..lineTo(b.dx - nx * halfW, b.dy - ny * halfW)
        ..lineTo(a.dx - nx * halfW, a.dy - ny * halfW)
        ..close();
      canvas.drawPath(path, roadPaint);
      // dashed center line
      const dash = 18.0, gap = 14.0;
      double t = 0;
      final ux = dir.dx / len, uy = dir.dy / len;
      while (t < len) {
        final p1 = Offset(a.dx + ux * t, a.dy + uy * t);
        final e = math.min(t + dash, len);
        final p2 = Offset(a.dx + ux * e, a.dy + uy * e);
        canvas.drawLine(p1, p2, linePaint);
        t += dash + gap;
      }
    }

    for (final s in kRoadSegments) {
      avenue(s[0], s[1], s[2], s[3], s[4]);
    }
  }

  // ---- Central concrete plaza ----
  void _drawPlaza(Canvas canvas) {
    final gridRows = (maxSlots / 3).ceil();
    final padTop = IsoWorld.isoToScreen(-0.9, -0.7);
    final padRight = IsoWorld.isoToScreen(-0.9, 2.7);
    final padBottom = IsoWorld.isoToScreen(gridRows - 0.3, 2.7);
    final padLeft = IsoWorld.isoToScreen(gridRows - 0.3, -0.7);

    final pad = Path()
      ..moveTo(padTop.dx, padTop.dy)
      ..lineTo(padRight.dx, padRight.dy)
      ..lineTo(padBottom.dx, padBottom.dy)
      ..lineTo(padLeft.dx, padLeft.dy)
      ..close();
    canvas.drawPath(
      pad,
      Paint()
        ..color = isNight
            ? const Color(0xFF1B2436)
            : (isSunset ? const Color(0xFF473A43) : const Color(0xFFE2E8F0)),
    );
    canvas.drawPath(
      pad,
      Paint()
        ..color = p.primaryColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Parking bay outlines.
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < 3; c++) {
        final slot = r * 3 + c;
        if (slot >= maxSlots) continue;
        final center = IsoWorld.isoToScreen(r.toDouble(), c.toDouble());
        final hasCar = slot < ownedCars.length;
        final tile = Path()
          ..moveTo(center.dx, center.dy - IsoWorld.tileH / 2)
          ..lineTo(center.dx + IsoWorld.tileW / 2, center.dy)
          ..lineTo(center.dx, center.dy + IsoWorld.tileH / 2)
          ..lineTo(center.dx - IsoWorld.tileW / 2, center.dy)
          ..close();
        canvas.drawPath(
          tile,
          Paint()
            ..color = hasCar
                ? p.primaryColor.withValues(alpha: isNight ? 0.22 : 0.32)
                : (p.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8)),
        );
        canvas.drawPath(
          tile,
          Paint()
            ..color = hasCar ? p.primaryColor : const Color(0xFF94A3B8).withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = hasCar ? 1.6 : 1.0,
        );
      }
    }
  }

  // ---- Face geometry helpers (isometric parallelogram panels) ----
  Offset _facePt(Offset o, Offset u, Offset v, double a, double b) =>
      Offset(o.dx + u.dx * a + v.dx * b, o.dy + u.dy * a + v.dy * b);

  void _quad(Canvas canvas, Offset p0, Offset p1, Offset p2, Offset p3, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close(),
      paint,
    );
  }

  /// Fills a rectangular sub-region of an isometric face defined by origin [o]
  /// and axes [u] (along the wall base) and [v] (vertical, pointing up).
  void _panel(Canvas canvas, Offset o, Offset u, Offset v, double a0, double a1, double b0, double b1, Paint paint) {
    _quad(
      canvas,
      _facePt(o, u, v, a0, b0),
      _facePt(o, u, v, a1, b0),
      _facePt(o, u, v, a1, b1),
      _facePt(o, u, v, a0, b1),
      paint,
    );
  }

  // ---- Showroom: big glass car gallery behind the plaza ----
  void _drawShowroomTower(Canvas canvas) {
    final base = IsoWorld.isoToScreen(-2.0, -2.0);
    const w = 80.0;
    const h = 95.0;
    final hh = w * 0.5;

    final wallDay = const Color(0xFF223049);
    final wallNight = const Color(0xFF141C2E);
    final wall = isNight ? wallNight : wallDay;

    final L = Offset(base.dx - w, base.dy);
    final R = Offset(base.dx + w, base.dy);
    final B = Offset(base.dx, base.dy + hh);
    final T = Offset(base.dx, base.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 6), width: w * 2.2, height: hh * 1.5),
      Paint()
        ..color = Colors.black.withValues(alpha: isNight ? 0.42 : 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Walls.
    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);

    // Big glass curtain on the right (front) face — the showroom window.
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    final glass = isNight ? const Color(0xFF0E3A44) : const Color(0xFF7FC8E8);
    _panel(canvas, o, uAxis, vAxis, 0.12, 0.92, 0.14, 0.82, Paint()..color = glass);
    // Mullions.
    for (double a = 0.24; a < 0.92; a += 0.18) {
      canvas.drawLine(_facePt(o, uAxis, vAxis, a, 0.14), _facePt(o, uAxis, vAxis, a, 0.82),
          Paint()..color = wall.withValues(alpha: 0.7)..strokeWidth = 2);
    }
    if (isNight) {
      _panel(canvas, o, uAxis, vAxis, 0.12, 0.92, 0.14, 0.5, Paint()..color = AppColors.neonCyan.withValues(alpha: 0.18));
    }

    // Roof + neon parapet.
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = _lighten(wall, 0.06));
    _quad(canvas, up(T), up(R), up(B), up(L),
        Paint()..color = p.primaryColor.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Rooftop billboard with dealership name.
    final signC = Offset(base.dx, base.dy - h - 24);
    final tp = TextPainter(
      text: TextSpan(
        text: dealershipName.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final boardRect = Rect.fromCenter(center: signC, width: tp.width + 22, height: 26);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(7)), Paint()..color = p.primaryColor);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(7)),
        Paint()..color = Colors.white.withValues(alpha: 0.85)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    tp.paint(canvas, Offset(signC.dx - tp.width / 2, signC.dy - tp.height / 2));

    // Flag.
    final poleTop = Offset(base.dx + w * 0.7, base.dy - h - 34);
    canvas.drawLine(Offset(poleTop.dx, base.dy - h + 4), poleTop, Paint()..color = Colors.white70..strokeWidth = 2);
    final wave = math.sin(anim * math.pi * 4) * 4;
    canvas.drawPath(
      Path()
        ..moveTo(poleTop.dx, poleTop.dy)
        ..lineTo(poleTop.dx + 18, poleTop.dy + wave + 4)
        ..lineTo(poleTop.dx, poleTop.dy + 12)
        ..close(),
      Paint()..color = p.primaryColor,
    );
  }

  // ---- Cute detailed business building ----
  void _drawBuilding(Canvas canvas, WorldBuilding b) {
    final center = b.screenCenter;
    final w = b.footprint;
    final hh = w * 0.5;
    // Height varies per building for a lively skyline.
    final h = 42.0 + (b.route.hashCode.abs() % 3) * 12.0;
    final accent = b.color;
    final isLocked = !game.isBuildingUnlocked(b.route);

    // Wall + window palette (day / night).
    final wall = isNight ? const Color(0xFF3A4152) : const Color(0xFFF6EFDF);
    final glass = isNight ? const Color(0xFFFFD98A) : const Color(0xFFBFE3F5);

    // 1. Paved plot under the building.
    final pw = w * 1.32, ph = pw * 0.5;
    _quad(
      canvas,
      Offset(center.dx, center.dy - ph),
      Offset(center.dx + pw, center.dy),
      Offset(center.dx, center.dy + ph),
      Offset(center.dx - pw, center.dy),
      Paint()..color = isNight ? const Color(0xFF243247) : const Color(0xFFD9D2C2),
    );

    // 2. Soft shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: w * 2.1, height: hh * 1.4),
      Paint()
        ..color = Colors.black.withValues(alpha: isNight ? 0.38 : 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Base corners.
    final L = Offset(center.dx - w, center.dy);
    final R = Offset(center.dx + w, center.dy);
    final B = Offset(center.dx, center.dy + hh);
    final T = Offset(center.dx, center.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    // 3. Walls.
    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.10)); // left face (shaded)
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall); // right face (lit)

    // 4. Windows & door on faces.
    final vAxis = Offset(0, -h);
    final frame = Paint()..color = _darken(accent, 0.15);
    final glassPaint = Paint()..color = glass;

    // Left face windows (2).
    final lo = L, lu = B - L;
    for (final a in [0.20, 0.58]) {
      _panel(canvas, lo, lu, vAxis, a, a + 0.22, 0.42, 0.74, frame);
      _panel(canvas, lo, lu, vAxis, a + 0.03, a + 0.19, 0.46, 0.70, glassPaint);
    }

    // Right (front) face: awning + door + window.
    final ro = B, ru = R - B;
    // Awning stripe.
    _panel(canvas, ro, ru, vAxis, 0.30, 0.72, 0.40, 0.50, Paint()..color = accent);
    // Door.
    _panel(canvas, ro, ru, vAxis, 0.40, 0.62, 0.0, 0.40, Paint()..color = _darken(accent, 0.28));
    _panel(canvas, ro, ru, vAxis, 0.44, 0.58, 0.04, 0.37, Paint()..color = _darken(accent, 0.12));
    // Side window on front face.
    _panel(canvas, ro, ru, vAxis, 0.12, 0.30, 0.16, 0.42, frame);
    _panel(canvas, ro, ru, vAxis, 0.14, 0.28, 0.19, 0.39, glassPaint);
    // Upper front window.
    _panel(canvas, ro, ru, vAxis, 0.40, 0.62, 0.56, 0.80, frame);
    _panel(canvas, ro, ru, vAxis, 0.43, 0.59, 0.59, 0.77, glassPaint);

    // 5. Roof (accent) with lighter inset + trim.
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = accent);
    final inset = 0.72;
    Offset lerpC(Offset o) => Offset(center.dx + (o.dx - center.dx) * inset, (center.dy - h) + (o.dy - (center.dy - h)) * inset);
    _quad(canvas, lerpC(up(T)), lerpC(up(R)), lerpC(up(B)), lerpC(up(L)), Paint()..color = _lighten(accent, 0.12));
    _quad(canvas, up(T), up(R), up(B), up(L),
        Paint()..color = _darken(accent, 0.22)..style = PaintingStyle.stroke..strokeWidth = 1.6);

    // 6. Rooftop sign board (post + emoji billboard).
    final roofCenter = Offset(center.dx, center.dy - h);
    final signC = Offset(center.dx, roofCenter.dy - 26);
    canvas.drawLine(roofCenter, Offset(signC.dx, signC.dy + 10), Paint()..color = _darken(accent, 0.2)..strokeWidth = 3);
    final board = Rect.fromCenter(center: signC, width: 32, height: 28);
    canvas.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(8)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(8)),
        Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2.2);
    final emojiTp = TextPainter(
      text: TextSpan(text: b.emoji, style: const TextStyle(fontSize: 17)),
      textDirection: TextDirection.ltr,
    )..layout();
    emojiTp.paint(canvas, Offset(signC.dx - emojiTp.width / 2, signC.dy - emojiTp.height / 2));

    // 7. Little bushes flanking the door.
    _drawBush(canvas, Offset(center.dx + w * 0.5, center.dy + hh * 0.55));
    _drawBush(canvas, Offset(center.dx - w * 0.5, center.dy + hh * 0.55));

    // 8. Name pill below.
    final labelTp = TextPainter(
      text: TextSpan(
        text: b.shortName,
        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 130);
    final labelRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + hh + 12),
      width: labelTp.width + 16,
      height: 18,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(9)), Paint()..color = accent.withValues(alpha: 0.95));
    labelTp.paint(canvas, Offset(center.dx - labelTp.width / 2, center.dy + hh + 3.5));

    // 9. Live status badge (game-state driven).
    final badge = _buildingBadge(b);
    if (badge != null) {
      final badgeTp = TextPainter(
        text: TextSpan(
          text: badge,
          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final bx = center.dx + w * 0.6;
      final by = center.dy - h - 6;
      final badgeRect = Rect.fromCenter(center: Offset(bx, by), width: badgeTp.width + 10, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)),
          Paint()..color = AppColors.errorRed);
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)),
          Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 1);
      badgeTp.paint(canvas, Offset(bx - badgeTp.width / 2, by - badgeTp.height / 2));
    }

    // 10. Locked overlay.
    if (isLocked) {
      // Dark overlay on the whole building area.
      final overlayRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - h * 0.35),
        width: w * 2.2,
        height: h + hh + 40,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(overlayRect, const Radius.circular(12)),
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      );
      // Lock icon.
      final lockTp = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 22)),
        textDirection: TextDirection.ltr,
      )..layout();
      lockTp.paint(canvas, Offset(center.dx - lockTp.width / 2, center.dy - h * 0.5 - lockTp.height / 2));
      // Cost pill below the lock.
      final costText = b.unlockCost >= 1000 ? '₺${(b.unlockCost / 1000).toStringAsFixed(0)}K' : '₺${b.unlockCost.toInt()}';
      final costTp = TextPainter(
        text: TextSpan(
          text: 'Lv.${b.requiredLevel} · $costText',
          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final costRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - h * 0.5 + 18),
        width: costTp.width + 14,
        height: 17,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(costRect, const Radius.circular(8)),
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.9),
      );
      costTp.paint(canvas, Offset(center.dx - costTp.width / 2, costRect.top + 1.5));
    }
  }

  String? _buildingBadge(WorldBuilding b) {
    switch (b.route) {
      case '/workshop':
        final inRepair = game.ownedCars.where((c) => c.expertise.engineCondition < 80 || c.expertise.transmissionCondition < 80).length;
        return inRepair > 0 ? '$inRepair tamirde' : null;
      case '/marketplace':
        final listed = game.ownedCars.where((c) => c.isListed).length;
        return listed > 0 ? '$listed ilan' : null;
      case '/rent-a-car':
        final rented = game.activeRentals.length;
        return rented > 0 ? '$rented kirada' : null;
      case '/staff':
        final staff = game.hiredStaff.length;
        return staff > 0 ? '$staff kişi' : null;
      case '/finance':
        final loans = game.activeLoans.length;
        return loans > 0 ? '$loans kredi' : null;
      case '/stock-market':
        final stocks = game.ownedStocks.length;
        return stocks > 0 ? '$stocks hisse' : null;
      case '/side-businesses':
        final biz = game.sideBusinesses.where((s) => s.isOwned).length;
        return biz > 0 ? '$biz aktif' : null;
      case '/scrapyard':
        final parts = game.salvagedParts.length;
        return parts > 0 ? '$parts parça' : null;
      case '/auction':
        final offers = game.incomingOffers.length;
        return offers > 0 ? '$offers teklif' : null;
      default:
        return null;
    }
  }

  // ---- Street furniture: lampposts, benches, flower pots ----
  void _drawStreetFurniture(Canvas canvas) {
    final plaza = IsoWorld.isoToScreen(1, 1);

    /// Nudges a point on the ring toward the plaza so furniture sits on the
    /// inner sidewalk, never on the road or on a building plot.
    Offset inward(Offset pt, double amount) {
      final d = plaza - pt;
      final len = d.distance;
      if (len < 0.01) return pt;
      return Offset(pt.dx + d.dx / len * amount, pt.dy + d.dy / len * amount);
    }

    // The first four segments of kRoadSegments are the ring itself.
    for (int i = 0; i < 4; i++) {
      final s = kRoadSegments[i];
      final a = IsoWorld.isoToScreen(s[0], s[1]);
      final b = IsoWorld.isoToScreen(s[2], s[3]);

      // Three lampposts per ring edge.
      for (final t in const [0.2, 0.5, 0.8]) {
        _drawLamppost(canvas, inward(Offset.lerp(a, b, t)!, 34));
      }
      // One bench mid-edge, set further back from the kerb.
      _drawBench(canvas, inward(Offset.lerp(a, b, 0.5)!, 58));
      // Flower pot at each ring corner.
      _drawFlowerPot(canvas, inward(a, 40));
    }
  }

  void _drawLamppost(Canvas canvas, Offset base) {
    final poleColor = isNight ? const Color(0xFF5A6474) : const Color(0xFF37474F);
    // Pole.
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 18), width: 3, height: 32),
      Paint()..color = poleColor,
    );
    // Lamp head (wider cap).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 35), width: 14, height: 7),
        const Radius.circular(3),
      ),
      Paint()..color = poleColor,
    );
    // Light glow (night only).
    if (isNight) {
      canvas.drawCircle(
        Offset(base.dx, base.dy - 32),
        18,
        Paint()
          ..color = const Color(0xFFFFE082).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        Offset(base.dx, base.dy - 34),
        5,
        Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.85),
      );
    } else {
      canvas.drawCircle(
        Offset(base.dx, base.dy - 34),
        4,
        Paint()..color = const Color(0xFFE0E0E0),
      );
    }
    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 10, height: 5),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
  }

  void _drawBench(Canvas canvas, Offset base) {
    final wood = isNight ? const Color(0xFF4E3B28) : const Color(0xFF8D6E48);
    final leg = isNight ? const Color(0xFF3A3A3A) : const Color(0xFF555555);
    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 22, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    // Legs.
    canvas.drawRect(Rect.fromLTWH(base.dx - 8, base.dy - 4, 2, 6), Paint()..color = leg);
    canvas.drawRect(Rect.fromLTWH(base.dx + 6, base.dy - 4, 2, 6), Paint()..color = leg);
    // Seat.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 5), width: 22, height: 5),
        const Radius.circular(1.5),
      ),
      Paint()..color = wood,
    );
    // Backrest.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 10), width: 20, height: 4),
        const Radius.circular(1),
      ),
      Paint()..color = _darken(wood, 0.08),
    );
  }

  void _drawFlowerPot(Canvas canvas, Offset base) {
    final potColor = isNight ? const Color(0xFF6B3A2A) : const Color(0xFFC67A4A);
    // Shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 14, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    // Pot (trapezoid approximated as rect).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 2), width: 12, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = potColor,
    );
    // Flowers: 3 colorful circles.
    final colors = [const Color(0xFFE91E63), const Color(0xFFFF9800), const Color(0xFFE040FB)];
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(base.dx - 4 + i * 4, base.dy - 9 - (i == 1 ? 2 : 0)),
        3.2,
        Paint()..color = isNight ? _darken(colors[i], 0.25) : colors[i],
      );
    }
    // Green leaves.
    canvas.drawCircle(Offset(base.dx - 2, base.dy - 7), 2.5, Paint()..color = const Color(0xFF4CAF50));
    canvas.drawCircle(Offset(base.dx + 2, base.dy - 7), 2.5, Paint()..color = const Color(0xFF388E3C));
  }

  void _drawBush(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 12, height: 5),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    canvas.drawCircle(Offset(base.dx, base.dy - 3), 5, Paint()..color = const Color(0xFF3B8A3E));
    canvas.drawCircle(Offset(base.dx - 3, base.dy - 1), 3.5, Paint()..color = const Color(0xFF43A047));
    canvas.drawCircle(Offset(base.dx + 3, base.dy - 1), 3.5, Paint()..color = const Color(0xFF357A38));
  }

  void _drawCar(Canvas canvas, Offset center, CarModel car) {
    final carColor = _parseColor(car.colorHex);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 54, height: 22),
      Paint()
        ..color = Colors.black.withValues(alpha: isNight ? 0.5 : 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final top = Offset(center.dx, center.dy - 12);
    final body = Path()
      ..moveTo(top.dx, top.dy - 10)
      ..lineTo(top.dx + 23, top.dy + 1)
      ..lineTo(top.dx, top.dy + 13)
      ..lineTo(top.dx - 23, top.dy + 1)
      ..close();
    canvas.drawPath(body, Paint()..color = carColor);

    final roof = Path()
      ..moveTo(top.dx, top.dy - 8)
      ..lineTo(top.dx + 12, top.dy - 1)
      ..lineTo(top.dx, top.dy + 6)
      ..lineTo(top.dx - 12, top.dy - 1)
      ..close();
    canvas.drawPath(roof, Paint()..color = Colors.white.withValues(alpha: 0.25));

    canvas.drawLine(
      Offset(top.dx - 18, top.dy),
      Offset(top.dx, top.dy - 8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 1.2,
    );

    final nameTp = TextPainter(
      text: TextSpan(
        text: car.brand,
        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, shadows: [
          Shadow(color: Colors.black, blurRadius: 4),
        ]),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    nameTp.paint(canvas, Offset(center.dx - nameTp.width / 2, center.dy - 30));

    if (isNight) {
      canvas.drawCircle(
        Offset(center.dx + 18, center.dy + 2),
        4,
        Paint()
          ..color = AppColors.neonCyan.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _drawEmptyBay(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = p.primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(Offset(center.dx - 6, center.dy - 3), Offset(center.dx + 6, center.dy - 3), paint);
    canvas.drawLine(Offset(center.dx, center.dy - 9), Offset(center.dx, center.dy + 3), paint);
  }

  Offset _customerPos(int i, int gridRows) {
    final cust = _customers[i];
    final prog = (anim * cust.speed + cust.offset) % 1.0;
    final targetSlot = i % math.max(1, ownedCars.length);
    final targetRow = (targetSlot ~/ 3).toDouble();
    final targetCol = (targetSlot % 3).toDouble();
    final enter = IsoWorld.isoToScreen(gridRows.toDouble(), 1.5);
    final bay = IsoWorld.isoToScreen(targetRow, targetCol);
    final inspect = Offset(bay.dx + 18, bay.dy + 6);
    if (prog < 0.35) {
      return Offset.lerp(enter, inspect, prog / 0.35)!;
    } else if (prog < 0.75) {
      final bob = math.sin(prog * math.pi * 8) * 2;
      return Offset(inspect.dx + bob, inspect.dy);
    } else {
      return Offset.lerp(inspect, enter, (prog - 0.75) / 0.25)!;
    }
  }

  void _drawCustomer(Canvas canvas, Offset pos, _Customer cust, int i) {
    final prog = (anim * cust.speed + cust.offset) % 1.0;
    final walk = math.sin(prog * math.pi * 16);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy + 1), width: 10, height: 5),
      Paint()..color = Colors.black38,
    );
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(pos.dx - 1.5, pos.dy - 6), Offset(pos.dx - 2.5 + walk * 2, pos.dy), legPaint);
    canvas.drawLine(Offset(pos.dx + 1.5, pos.dy - 6), Offset(pos.dx + 2.5 - walk * 2, pos.dy), legPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(pos.dx, pos.dy - 10), width: 6.5, height: 8), const Radius.circular(2)),
      Paint()..color = cust.outfit,
    );
    canvas.drawCircle(Offset(pos.dx, pos.dy - 16), 3.5, Paint()..color = const Color(0xFFFFDBAC));
    canvas.drawArc(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 17), width: 7, height: 5),
      math.pi,
      math.pi,
      true,
      Paint()..color = cust.accent,
    );
  }

  void _drawAmbientParticles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isNight ? AppColors.primaryAmber.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    for (int i = 0; i < 18; i++) {
      final seed = i * 53.0;
      final px = (IsoWorld.origin.dx - 260 + (seed * 17) % 520);
      final py = (IsoWorld.origin.dy - 120 + (seed * 23 + anim * 90) % 320);
      canvas.drawCircle(Offset(px, py), 1.0 + (i % 3) * 0.5, paint);
    }
  }

  /// Shortest distance from point [pt] to the segment a→b.
  double _distToSegment(Offset pt, Offset a, Offset b) {
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final lenSq = dx * dx + dy * dy;
    if (lenSq < 0.01) return (pt - a).distance;
    var t = ((pt.dx - a.dx) * dx + (pt.dy - a.dy) * dy) / lenSq;
    t = t.clamp(0.0, 1.0);
    return (pt - Offset(a.dx + dx * t, a.dy + dy * t)).distance;
  }

  /// True when a decorative tree would land on a building plot, the plaza or a road.
  bool _treeBlocked(Offset pt) {
    if ((pt - IsoWorld.isoToScreen(1, 1)).distance < 210) return true;
    if ((pt - IsoWorld.isoToScreen(-2, -2)).distance < 190) return true;
    for (final b in kWorldBuildings) {
      if ((pt - b.screenCenter).distance < 110) return true;
    }
    for (final s in kRoadSegments) {
      final a = IsoWorld.isoToScreen(s[0], s[1]);
      final e = IsoWorld.isoToScreen(s[2], s[3]);
      if (_distToSegment(pt, a, e) < s[4] + 18) return true;
    }
    return false;
  }

  // ---- helpers ----
  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFF64748B);
    }
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _WorldPainter old) {
    return old.anim != anim || old.ownedCars != ownedCars || old.hour != hour || old.maxSlots != maxSlots || old.game != game;
  }
}

class _Drawable {
  final double depth;
  final VoidCallback paint;
  _Drawable(this.depth, this.paint);
}
