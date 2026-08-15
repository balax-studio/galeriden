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

  // Expansive world canvas dimensions for organic neighborhood sprawl.
  static const double worldWidth = 2200.0;
  static const double worldHeight = 1800.0;

  // Isometric tile dimensions.
  static const double tileW = 82.0;
  static const double tileH = 41.0;

  // World origin: Miras Oto Showroom & Plaza sits in the center.
  static Offset get origin => const Offset(worldWidth * 0.5, worldHeight * 0.46);

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
    this.footprint = 44,
    this.requiredLevel = 1,
    this.unlockCost = 0,
  });

  Offset get screenCenter => IsoWorld.isoToScreen(row, col);

  /// Clickable region covering the building sprite (base diamond + tower + rooftop sign).
  Rect get hitRect {
    final c = screenCenter;
    return Rect.fromLTRB(
      c.dx - footprint - 8,
      c.dy - footprint * 3.0,
      c.dx + footprint + 8,
      c.dy + footprint * 0.6 + 22,
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4 Thematic Neighborhoods Layout (Organically dispersed around central plaza)
/// ---------------------------------------------------------------------------
const List<WorldBuilding> kWorldBuildings = [
  // ==========================================
  // 1. SANAYİ & ATÖLYE BÖLGESİ (Kuzeybatı)
  // ==========================================
  WorldBuilding(
    route: '/workshop',
    name: 'Tamir Atölyesi',
    shortName: 'Tamirhane',
    subtitle: 'Motor & Kaporta Onarımı',
    description: 'Aracın hasarlı parçalarını onar, değerini yükselt ve satışa hazırla.',
    emoji: '🔧',
    color: Color(0xFFF59E0B),
    row: -6.0,
    col: -7.0,
    footprint: 46,
    requiredLevel: 1,
    unlockCost: 0,
  ),
  WorldBuilding(
    route: '/car-wash',
    name: 'Oto Yıkama & Detailing',
    shortName: 'Oto Yıkama',
    subtitle: 'Pasta Cila & Detaylı Temizlik',
    description: 'Detaylı yıkama ve pasta-cila ile aracın ilk izlenimini ve cazibesini artır.',
    emoji: '🚿',
    color: Color(0xFF06B6D4),
    row: -3.0,
    col: -8.5,
    footprint: 42,
    requiredLevel: 2,
    unlockCost: 15000,
  ),
  WorldBuilding(
    route: '/tuning-studio',
    name: 'VIP Tuning Garajı',
    shortName: 'VIP Tuning',
    subtitle: 'Performans & Modifiye',
    description: 'Araçları modifiye et, performans ve body kit paketleriyle servet kazan.',
    emoji: '⚡',
    color: Color(0xFFEAB308),
    row: -9.0,
    col: -4.0,
    footprint: 44,
    requiredLevel: 5,
    unlockCost: 120000,
  ),

  // ==========================================
  // 2. FIRSAT, HURDA & RİSK BÖLGESİ (Güneybatı)
  // ==========================================
  WorldBuilding(
    route: '/marketplace',
    name: 'İkinci El Açık Oto Pazarı',
    shortName: 'Oto Pazar',
    subtitle: 'Araç Alım & Pazarlık',
    description: 'Sahibinden ve esnaftan araç bul, ekspertiz iste ve sıkı pazarlıkla ucuza kapat.',
    emoji: '🚗',
    color: Color(0xFF3B82F6),
    row: 3.5,
    col: -5.0,
    footprint: 48,
    requiredLevel: 1,
    unlockCost: 0,
  ),
  WorldBuilding(
    route: '/auction',
    name: 'Canlı İhale Salonu',
    shortName: 'Canlı İhale',
    subtitle: 'Açık Artırma & Fırsat',
    description: 'Rakip galericilere karşı anlık teklif artır, kelepir ve nadir araçları kap.',
    emoji: '🔨',
    color: Color(0xFFEF4444),
    row: 5.5,
    col: -1.5,
    footprint: 45,
    requiredLevel: 4,
    unlockCost: 60000,
  ),
  WorldBuilding(
    route: '/scrapyard',
    name: 'Hurdalık & Parça Söküm',
    shortName: 'Hurdalık',
    subtitle: 'Pert Araç & Yedek Parça',
    description: 'Kazalı araçları ucuza alıp parçala, değerli orijinal yedek parçaları sat.',
    emoji: '🛞',
    color: Color(0xFFF97316),
    row: 7.5,
    col: -7.5,
    footprint: 46,
    requiredLevel: 3,
    unlockCost: 40000,
  ),
  WorldBuilding(
    route: '/black-market',
    name: 'Yeraltı Karaborsa Deposu',
    shortName: 'Karaborsa',
    subtitle: 'Riskli & Çalıntı Araçlar',
    description: 'Yüksek riskli, devasa kârlı gayriresmi araç ticareti. Polis baskınlarına dikkat et!',
    emoji: '🕶️',
    color: Color(0xFF475569),
    row: 9.5,
    col: -3.5,
    footprint: 44,
    requiredLevel: 8,
    unlockCost: 350000,
  ),

  // ==========================================
  // 3. FİNANS & BORSA BÖLGESİ (Kuzeydoğu)
  // ==========================================
  WorldBuilding(
    route: '/finance',
    name: 'Banka & Finans Merkezi',
    shortName: 'Banka',
    subtitle: 'Kredi · Çek · Vadeli Satış',
    description: 'Ticari kredi kullan, vadeli satış senetlerini tahsil et ve likiditeyi yönet.',
    emoji: '🏦',
    color: Color(0xFF10B981),
    row: -7.5,
    col: 4.0,
    footprint: 46,
    requiredLevel: 3,
    unlockCost: 35000,
  ),
  WorldBuilding(
    route: '/stock-market',
    name: 'Otomotiv Borsası',
    shortName: 'Borsa',
    subtitle: 'Hisse Senedi & Yatırım',
    description: 'Global otomotiv ve teknoloji devlerinin hisselerini al-sat, temettü topla.',
    emoji: '📈',
    color: Color(0xFF6366F1),
    row: -4.5,
    col: 8.5,
    footprint: 44,
    requiredLevel: 7,
    unlockCost: 250000,
  ),
  WorldBuilding(
    route: '/bank-investments',
    name: 'Yatırım & Altın Fonu',
    shortName: 'Yatırım Fonu',
    subtitle: 'Mevduat · Altın · Tahvil',
    description: 'Boşta duran nakdini vadeli faiz ve güvenli altın fonlarında büyüterek değerlendir.',
    emoji: '💰',
    color: Color(0xFFD97706),
    row: -8.5,
    col: 8.0,
    footprint: 44,
    requiredLevel: 6,
    unlockCost: 180000,
  ),

  // ==========================================
  // 4. KURUMSAL & BÜYÜME BÖLGESİ (Güneydoğu)
  // ==========================================
  WorldBuilding(
    route: '/rent-a-car',
    name: 'Rent a Car Filo Merkezi',
    shortName: 'Rent a Car',
    subtitle: 'Günlük & Aylık Kiralama',
    description: 'Boştaki araçları kiralık filoya bağla, her oyun günü düzenli pasif kira geliri kazan.',
    emoji: '🔑',
    color: Color(0xFF14B8A6),
    row: 3.0,
    col: 5.5,
    footprint: 44,
    requiredLevel: 4,
    unlockCost: 75000,
  ),
  WorldBuilding(
    route: '/branches',
    name: 'Şube İmparatorluğu',
    shortName: 'Şubeler',
    subtitle: 'Galeri Genişletme & Prestij',
    description: 'Mega showroomlar ve yeni şubeler açarak galeri vitrin kapasiteni katla.',
    emoji: '🏢',
    color: Color(0xFFC9A96E),
    row: 7.0,
    col: 3.5,
    footprint: 46,
    requiredLevel: 5,
    unlockCost: 100000,
  ),
  WorldBuilding(
    route: '/staff',
    name: 'Personel & Akademi Ofisi',
    shortName: 'Personel',
    subtitle: 'Satış Danışmanı & Usta',
    description: 'Uzman ekspertiz, usta tamirci ve yetenekli satış danışmanları işe alıp eğit.',
    emoji: '👔',
    color: Color(0xFFA855F7),
    row: 5.0,
    col: 9.0,
    footprint: 44,
    requiredLevel: 2,
    unlockCost: 20000,
  ),
  WorldBuilding(
    route: '/side-businesses',
    name: 'Yan İşletmeler Kompleksi',
    shortName: 'Yan İşletme',
    subtitle: 'Otopark · Cafe · Sigorta',
    description: 'Galeri yanına otopark, kafe ve sigorta acentesi kurarak pasif kâr akışı sağla.',
    emoji: '🏪',
    color: Color(0xFF8B5CF6),
    row: 9.0,
    col: 7.0,
    footprint: 44,
    requiredLevel: 6,
    unlockCost: 150000,
  ),
];

/// ---------------------------------------------------------------------------
/// Decorative Residential Houses (Placed to make the world lively)
/// ---------------------------------------------------------------------------
class _HouseSpec {
  final double row;
  final double col;
  final Color roofColor;
  final Color wallColor;
  final bool hasChimney;
  const _HouseSpec(this.row, this.col, this.roofColor, this.wallColor, {this.hasChimney = true});
}

const List<_HouseSpec> _kDecorativeHouses = [
  _HouseSpec(-11.0, -1.0, Color(0xFFC2410C), Color(0xFFFEF3C7), hasChimney: true),
  _HouseSpec(-10.5, 2.0, Color(0xFFB91C1C), Color(0xFFF3F4F6), hasChimney: false),
  _HouseSpec(-1.0, -11.5, Color(0xFF0F766E), Color(0xFFE0E7FF), hasChimney: true),
  _HouseSpec(1.5, -10.0, Color(0xFF854D0E), Color(0xFFFEF9C3), hasChimney: false),
  _HouseSpec(11.0, -1.0, Color(0xFF9A3412), Color(0xFFFFFBEB), hasChimney: true),
  _HouseSpec(10.5, 2.5, Color(0xFF1E3A8A), Color(0xFFF1F5F9), hasChimney: false),
  _HouseSpec(-1.0, 11.5, Color(0xFF4338CA), Color(0xFFEDE9FE), hasChimney: true),
  _HouseSpec(1.5, 11.0, Color(0xFF15803D), Color(0xFFDCFCE7), hasChimney: true),
];

/// Living tycoon customer persona (walks around the plaza).
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
    // Perfect scale fit: 0.70x to 1.1x depending on device width.
    final scale = (viewport.width / 1380).clamp(0.72, 1.05);
    final focus = IsoWorld.isoToScreen(0.5, 0.5);
    final dx = viewport.width / 2 - focus.dx * scale;
    final dy = viewport.height / 2 - focus.dy * scale;
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _handleTapUp(TapUpDetails details, DealershipModel game, ThemePaletteModel p) {
    final pt = details.localPosition;

    // 1. Building hit-test (front-most first -> reverse depth order).
    final sorted = [...kWorldBuildings]..sort((a, b) => b.screenCenter.dy.compareTo(a.screenCenter.dy));
    for (final b in sorted) {
      if (b.hitRect.contains(pt)) {
        _showBuildingSheet(b, game, p);
        return;
      }
    }

    // 2. Parking bay hit-test -> open car detail or send to marketplace.
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
                    Text(
                      CurrencyFormatter.format(b.unlockCost),
                      style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.w900),
                    ),
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
                      icon: const Icon(Icons.meeting_room_rounded),
                      label: Text('${b.shortName} İçine Gir', style: const TextStyle(fontWeight: FontWeight.w800)),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
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
            boundaryMargin: const EdgeInsets.all(180),
            minScale: 0.65, // Strictly bounded zoom-out to keep world in frame
            maxScale: 2.2,  // Rich zoom-in for architectural inspection
            child: SizedBox(
              width: IsoWorld.worldWidth,
              height: IsoWorld.worldHeight,
              child: RepaintBoundary(
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
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: ParallaxSkylinePainter(
                                  cameraOffset: Offset(_anim.value * 120, 0),
                                  parallaxFactor: 0.25,
                                  hour: hour,
                                ),
                              ),
                            ),
                          ),
                          // The living isometric world with custom architectural models.
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
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// World Painter: Organic Roads, Thematic Architecture, Houses, Trees, Cars
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

  /// Organic road segments (row0, col0, row1, col1, halfWidth) connecting the 4 districts.
  static const List<List<double>> kRoadSegments = [
    // Central Plaza Ring
    [-2, -3, -2, 4, 20],
    [-2, 4, 4, 4, 20],
    [4, 4, 4, -3, 20],
    [4, -3, -2, -3, 20],

    // Kuzeybatı Sanayi Bulvarı
    [-2, -3, -11, -3, 18],
    [-6, -3, -6, -9, 16],
    [-3, -3, -3, -10, 15],

    // Güneybatı Fırsat & Hurda Yolu
    [4, -3, 11, -3, 18],
    [4, -3, 4, -9, 16],
    [8, -3, 8, -9, 15],

    // Kuzeydoğu Finans & Borsa Caddesi
    [-2, 4, -11, 4, 18],
    [-7, 4, -7, 10, 16],
    [-4, 4, -4, 10, 15],

    // Güneydoğu Kurumsal & Şubeler Bulvarı
    [4, 4, 11, 4, 18],
    [4, 4, 4, 10, 16],
    [8, 4, 8, 10, 15],

    // Çevre Otoyol Bağlantıları
    [-11, -3, -11, 4, 16],
    [11, -3, 11, 4, 16],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    _drawRoads(canvas);
    _drawStreetFurniture(canvas);
    _drawPlaza(canvas);
    _drawShowroomTower(canvas);

    // Depth-sorted drawables (houses + buildings + cars + customers) -> back-to-front.
    final drawables = <_Drawable>[];

    // 1. Decorative Residential Houses
    for (final h in _kDecorativeHouses) {
      final center = IsoWorld.isoToScreen(h.row, h.col);
      drawables.add(_Drawable(center.dy, () => _drawHouse(canvas, center, h)));
    }

    // 2. Thematic Business Buildings
    for (final b in kWorldBuildings) {
      final c = b.screenCenter;
      drawables.add(_Drawable(c.dy, () => _drawThematicBuilding(canvas, b)));
    }

    // 3. Showroom Plaza Car Parking Slots
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

    // 4. Moving Customers
    if (ownedCars.isNotEmpty) {
      for (int i = 0; i < _customers.length; i++) {
        final pos = _customerPos(i, gridRows);
        drawables.add(_Drawable(pos.dy, () => _drawCustomer(canvas, pos, _customers[i], i)));
      }
    }

    // 5. Ambient Driving Cars on Highways
    _drawAmbientCars(canvas, drawables);

    // Sort by Y-coordinate depth and paint
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
    for (double x = 0; x < size.width; x += 140) {
      for (double y = 0; y < size.height; y += 140) {
        if (((x ~/ 140) + (y ~/ 140)) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 140, 140), tilePaint);
        }
      }
    }

    // Natural trees and flower beds scattered organically around the landscape.
    final rnd = math.Random(13);
    for (int i = 0; i < 110; i++) {
      final tx = rnd.nextDouble() * size.width;
      final ty = rnd.nextDouble() * size.height;
      if (_treeBlocked(Offset(tx, ty))) continue;
      final treeType = i % 4;
      if (treeType == 0) {
        _drawPineTree(canvas, Offset(tx, ty));
      } else if (treeType == 1) {
        _drawOakTree(canvas, Offset(tx, ty));
      } else if (treeType == 2) {
        _drawCypressTree(canvas, Offset(tx, ty));
      } else {
        _drawFlowerBushCluster(canvas, Offset(tx, ty));
      }
    }
  }

  // Tree Variations
  void _drawOakTree(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 3), width: 16, height: 7),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 6), width: 3.5, height: 10),
      Paint()..color = const Color(0xFF6B4423),
    );
    canvas.drawCircle(Offset(base.dx, base.dy - 16), 10, Paint()..color = const Color(0xFF2F7D32));
    canvas.drawCircle(Offset(base.dx - 6, base.dy - 12), 7, Paint()..color = const Color(0xFF388E3C));
    canvas.drawCircle(Offset(base.dx + 6, base.dy - 12), 7, Paint()..color = const Color(0xFF2C6E30));
  }

  void _drawPineTree(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 3), width: 14, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 5), width: 3, height: 8),
      Paint()..color = const Color(0xFF5A381E),
    );
    // 3 tiered pine needles
    for (int tier = 0; tier < 3; tier++) {
      final ty = base.dy - 10 - tier * 8;
      final w = 18.0 - tier * 4.0;
      final p = Path()
        ..moveTo(base.dx, ty - 10)
        ..lineTo(base.dx + w / 2, ty)
        ..lineTo(base.dx - w / 2, ty)
        ..close();
      canvas.drawPath(p, Paint()..color = tier == 2 ? const Color(0xFF1E5E24) : const Color(0xFF1B4D20));
    }
  }

  void _drawCypressTree(Canvas canvas, Offset base) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 10, height: 5),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
    final p = Path()
      ..moveTo(base.dx, base.dy - 32)
      ..quadraticBezierTo(base.dx + 6, base.dy - 16, base.dx + 4, base.dy - 2)
      ..lineTo(base.dx - 4, base.dy - 2)
      ..quadraticBezierTo(base.dx - 6, base.dy - 16, base.dx, base.dy - 32)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFF194D26));
  }

  void _drawFlowerBushCluster(Canvas canvas, Offset base) {
    canvas.drawCircle(Offset(base.dx, base.dy - 3), 7, Paint()..color = const Color(0xFF2E7D32));
    canvas.drawCircle(Offset(base.dx - 5, base.dy - 1), 5, Paint()..color = const Color(0xFF388E3C));
    canvas.drawCircle(Offset(base.dx + 5, base.dy - 1), 5, Paint()..color = const Color(0xFF43A047));
    // Red / Pink / Yellow blossoms
    canvas.drawCircle(Offset(base.dx - 2, base.dy - 5), 2.2, Paint()..color = const Color(0xFFEC4899));
    canvas.drawCircle(Offset(base.dx + 3, base.dy - 4), 2.2, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(Offset(base.dx - 4, base.dy - 1), 2.0, Paint()..color = const Color(0xFFEF4444));
  }

  // ---- Roads ----
  void _drawRoads(Canvas canvas) {
    final roadPaint = Paint()..color = AppColors.beneloilAsphaltRoad;
    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final curbPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    void avenue(double r0, double c0, double r1, double c1, double halfW) {
      final a = IsoWorld.isoToScreen(r0, c0);
      final b = IsoWorld.isoToScreen(r1, c1);
      final dir = (b - a);
      final len = dir.distance;
      if (len < 1) return;
      final nx = -dir.dy / len, ny = dir.dx / len;
      final path = Path()
        ..moveTo(a.dx + nx * halfW, a.dy + ny * halfW)
        ..lineTo(b.dx + nx * halfW, b.dy + ny * halfW)
        ..lineTo(b.dx - nx * halfW, b.dy - ny * halfW)
        ..lineTo(a.dx - nx * halfW, a.dy - ny * halfW)
        ..close();
      canvas.drawPath(path, roadPaint);
      canvas.drawPath(path, curbPaint);

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

  // ---- Central Concrete Plaza ----
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

  // ---- Face geometry helpers ----
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

  // ---- Showroom: Mega Glass Car Gallery behind the plaza ----
  void _drawShowroomTower(Canvas canvas) {
    final base = IsoWorld.isoToScreen(-2.0, -2.0);
    const w = 84.0;
    const h = 98.0;
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

    // Big glass curtain on the right (front) face - showroom window.
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    final glass = isNight ? const Color(0xFF0E3A44) : const Color(0xFF7FC8E8);
    _panel(canvas, o, uAxis, vAxis, 0.10, 0.92, 0.12, 0.84, Paint()..color = glass);
    // Mullions.
    for (double a = 0.22; a < 0.92; a += 0.18) {
      canvas.drawLine(_facePt(o, uAxis, vAxis, a, 0.12), _facePt(o, uAxis, vAxis, a, 0.84),
          Paint()..color = wall.withValues(alpha: 0.7)..strokeWidth = 2);
    }
    if (isNight) {
      _panel(canvas, o, uAxis, vAxis, 0.10, 0.92, 0.12, 0.5, Paint()..color = AppColors.neonCyan.withValues(alpha: 0.22));
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

  // ---- Decorative Residential Houses ----
  void _drawHouse(Canvas canvas, Offset center, _HouseSpec h) {
    const w = 32.0;
    final hh = w * 0.5;
    const height = 30.0;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 3), width: w * 2.0, height: hh * 1.3),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );

    final L = Offset(center.dx - w, center.dy);
    final R = Offset(center.dx + w, center.dy);
    final B = Offset(center.dx, center.dy + hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - height);

    // Walls
    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(h.wallColor, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = h.wallColor);

    // Pitched Gable Roof
    final apex = Offset(center.dx, center.dy - height - 16);
    // Left roof slope
    final roofLeft = Path()
      ..moveTo(up(L).dx, up(L).dy)
      ..lineTo(apex.dx, apex.dy)
      ..lineTo(up(B).dx, up(B).dy)
      ..close();
    canvas.drawPath(roofLeft, Paint()..color = _darken(h.roofColor, 0.15));

    // Right roof slope
    final roofRight = Path()
      ..moveTo(up(B).dx, up(B).dy)
      ..lineTo(apex.dx, apex.dy)
      ..lineTo(up(R).dx, up(R).dy)
      ..close();
    canvas.drawPath(roofRight, Paint()..color = h.roofColor);

    // Chimney
    if (h.hasChimney) {
      final chim = Offset(center.dx - 10, apex.dy + 2);
      canvas.drawRect(Rect.fromLTWH(chim.dx, chim.dy - 8, 4, 10), Paint()..color = const Color(0xFF78350F));
      // Smoke puff
      canvas.drawCircle(Offset(chim.dx + 2, chim.dy - 12), 2.5, Paint()..color = Colors.white54);
      canvas.drawCircle(Offset(chim.dx + 4, chim.dy - 16), 3.5, Paint()..color = Colors.white38);
    }

    // Windows & Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + 4, center.dy - 10, 8, 12), const Radius.circular(1)),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 18, center.dy - 14, 8, 8),
      Paint()..color = isNight ? const Color(0xFFFFD54F) : const Color(0xFF93C5FD),
    );
  }

  // ===========================================================================
  // THEMATIC CUSTOM BUILDING PAINTERS (Architectural Specialization)
  // ===========================================================================
  void _drawThematicBuilding(Canvas canvas, WorldBuilding b) {
    final center = b.screenCenter;
    final w = b.footprint;
    final hh = w * 0.5;
    final isLocked = !game.isBuildingUnlocked(b.route);

    // Paved plot under the building
    final pw = w * 1.35, ph = pw * 0.5;
    _quad(
      canvas,
      Offset(center.dx, center.dy - ph),
      Offset(center.dx + pw, center.dy),
      Offset(center.dx, center.dy + ph),
      Offset(center.dx - pw, center.dy),
      Paint()..color = isNight ? const Color(0xFF243247) : const Color(0xFFD9D2C2),
    );

    // Soft Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: w * 2.1, height: hh * 1.4),
      Paint()
        ..color = Colors.black.withValues(alpha: isNight ? 0.38 : 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Route-specific specialized architectural rendering
    switch (b.route) {
      case '/workshop':
        _paintWorkshopBuilding(canvas, center, w, hh, b);
        break;
      case '/car-wash':
        _paintCarWashBuilding(canvas, center, w, hh, b);
        break;
      case '/tuning-studio':
        _paintTuningBuilding(canvas, center, w, hh, b);
        break;
      case '/marketplace':
        _paintMarketplaceBuilding(canvas, center, w, hh, b);
        break;
      case '/auction':
        _paintAuctionBuilding(canvas, center, w, hh, b);
        break;
      case '/scrapyard':
        _paintScrapyardBuilding(canvas, center, w, hh, b);
        break;
      case '/black-market':
        _paintBlackMarketBuilding(canvas, center, w, hh, b);
        break;
      case '/finance':
        _paintFinanceBankBuilding(canvas, center, w, hh, b);
        break;
      case '/stock-market':
        _paintStockMarketBuilding(canvas, center, w, hh, b);
        break;
      case '/bank-investments':
        _paintInvestmentVaultBuilding(canvas, center, w, hh, b);
        break;
      case '/rent-a-car':
        _paintRentACarBuilding(canvas, center, w, hh, b);
        break;
      case '/branches':
      case '/staff':
      case '/side-businesses':
      default:
        _paintCorporatePlazaBuilding(canvas, center, w, hh, b);
        break;
    }

    // Name label pill below
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
    canvas.drawRRect(RRect.fromRectAndRadius(labelRect, const Radius.circular(9)), Paint()..color = b.color.withValues(alpha: 0.95));
    labelTp.paint(canvas, Offset(center.dx - labelTp.width / 2, center.dy + hh + 3.5));

    // Live status badge
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
      final by = center.dy - 56;
      final badgeRect = Rect.fromCenter(center: Offset(bx, by), width: badgeTp.width + 10, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)), Paint()..color = AppColors.errorRed);
      canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(8)),
          Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 1);
      badgeTp.paint(canvas, Offset(bx - badgeTp.width / 2, by - badgeTp.height / 2));
    }

    // Locked overlay
    if (isLocked) {
      final overlayRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - 28),
        width: w * 2.2,
        height: 80,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(overlayRect, const Radius.circular(12)),
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      );
      final lockTp = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 22)),
        textDirection: TextDirection.ltr,
      )..layout();
      lockTp.paint(canvas, Offset(center.dx - lockTp.width / 2, center.dy - 44));

      final costText = b.unlockCost >= 1000 ? '₺${(b.unlockCost / 1000).toStringAsFixed(0)}K' : '₺${b.unlockCost.toInt()}';
      final costTp = TextPainter(
        text: TextSpan(
          text: 'Lv.${b.requiredLevel} · $costText',
          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final costRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - 10),
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

  // 1. Tamir Atölyesi (Factory Sawtooth Roof + Smokestack + Garage Door)
  void _paintWorkshopBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 48.0;
    final wall = isNight ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);

    // Roll-up industrial garage door
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    _panel(canvas, o, uAxis, vAxis, 0.20, 0.80, 0.0, 0.65, Paint()..color = const Color(0xFF475569));
    for (double y = 0.1; y < 0.65; y += 0.12) {
      canvas.drawLine(_facePt(o, uAxis, vAxis, 0.20, y), _facePt(o, uAxis, vAxis, 0.80, y),
          Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1.5);
    }

    // Industrial Sawtooth / Orange Roof
    final apex1 = Offset(c.dx - w * 0.3, c.dy - h - 18);
    final apex2 = Offset(c.dx + w * 0.3, c.dy - h - 18);
    final roofP = Path()
      ..moveTo(up(L).dx, up(L).dy)
      ..lineTo(apex1.dx, apex1.dy)
      ..lineTo(c.dx, c.dy - h - 4)
      ..lineTo(apex2.dx, apex2.dy)
      ..lineTo(up(R).dx, up(R).dy)
      ..lineTo(up(B).dx, up(B).dy)
      ..close();
    canvas.drawPath(roofP, Paint()..color = b.color);

    // Smokestack with exhaust smoke
    final chimney = Offset(c.dx - w * 0.6, c.dy - h - 6);
    canvas.drawRect(Rect.fromLTWH(chimney.dx, chimney.dy - 16, 6, 18), Paint()..color = const Color(0xFF334155));
    canvas.drawCircle(Offset(chimney.dx + 3, chimney.dy - 20), 3.0, Paint()..color = Colors.white60);
    canvas.drawCircle(Offset(chimney.dx + 5, chimney.dy - 26), 4.5, Paint()..color = Colors.white38);

    _drawRoofSign(canvas, c, h + 14, b);
  }

  // 2. Oto Yıkama (Water Arch Tunnel + Foam Sprayers + Puddle)
  void _paintCarWashBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 42.0;
    final wall = isNight ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.1));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = b.color);

    // Transparent Cyan Wash Tunnel Arch on Front Face
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    _panel(canvas, o, uAxis, vAxis, 0.15, 0.85, 0.0, 0.70, Paint()..color = const Color(0xFF0284C7));
    // Water Spray / Glass Effect
    _panel(canvas, o, uAxis, vAxis, 0.25, 0.75, 0.08, 0.62, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.7));

    // Blue water puddle in front
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx + 8, c.dy + hh + 4), width: 22, height: 9),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.55),
    );

    _drawRoofSign(canvas, c, h, b);
  }

  // 3. VIP Tuning (Matte Black / Carbon + Yellow Neon Strip)
  void _paintTuningBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 45.0;
    const wall = Color(0xFF18181B);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = const Color(0xFF09090B));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF27272A));

    // Glowing Yellow Neon Accent Lines
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    final neonPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 2.5;
    canvas.drawLine(_facePt(o, uAxis, vAxis, 0.0, 0.88), _facePt(o, uAxis, vAxis, 1.0, 0.88), neonPaint);
    canvas.drawLine(_facePt(o, uAxis, vAxis, 0.0, 0.05), _facePt(o, uAxis, vAxis, 1.0, 0.05), neonPaint);

    // Carbon fiber hatch door
    _panel(canvas, o, uAxis, vAxis, 0.20, 0.80, 0.08, 0.65, Paint()..color = const Color(0xFF27272A));

    _drawRoofSign(canvas, c, h, b);
  }

  // 4. İkinci El Pazar (Açık Araç Pazarı + Renkli Gölgelik Tenteler)
  void _paintMarketplaceBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 36.0;
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = const Color(0xFFCBD5E1));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = const Color(0xFFE2E8F0));

    // Striped market canopy awning roof
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF2563EB));
    final awningStripe = Paint()..color = Colors.white;
    canvas.drawLine(up(T), up(B), awningStripe..strokeWidth = 3);
    canvas.drawLine(
        Offset.lerp(up(T), up(L), 0.5)!, Offset.lerp(up(B), up(L), 0.5)!, awningStripe..strokeWidth = 3);
    canvas.drawLine(
        Offset.lerp(up(T), up(R), 0.5)!, Offset.lerp(up(B), up(R), 0.5)!, awningStripe..strokeWidth = 3);

    // Mini demo display cars inside lot
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx + 4, c.dy - 12, 16, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFEF4444),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - 18, c.dy - 10, 16, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFEAB308),
    );

    _drawRoofSign(canvas, c, h, b);
  }

  // 5. Canlı İhale (Stepped Amphitheater Roof + Auction Gavel)
  void _paintAuctionBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 50.0;
    final wall = isNight ? const Color(0xFF3B1E1E) : const Color(0xFFFEE2E2);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.15));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);

    // 2-tier stepped roof
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFFDC2626));
    final tier2 = Offset(0, -10);
    _quad(
      canvas,
      up(T) + tier2,
      Offset.lerp(up(T), up(R), 0.75)! + tier2,
      Offset.lerp(up(T), up(B), 0.75)! + tier2,
      Offset.lerp(up(T), up(L), 0.75)! + tier2,
      Paint()..color = const Color(0xFFB91C1C),
    );

    _drawRoofSign(canvas, c, h + 10, b);
  }

  // 6. Hurdalık (Rusty Scrap Piles + Crane Arm)
  void _paintScrapyardBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    // Crushed car metal cube stacks
    final scrapColors = [const Color(0xFFB45309), const Color(0xFF78350F), const Color(0xFF991B1B), const Color(0xFF1E3A8A)];
    for (int i = 0; i < 4; i++) {
      final sx = c.dx - 18 + (i % 2) * 18.0;
      final sy = c.dy - 12 - (i ~/ 2) * 14.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy, 16, 12), const Radius.circular(2)),
        Paint()..color = scrapColors[i],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy, 16, 12), const Radius.circular(2)),
        Paint()..color = Colors.black38..style = PaintingStyle.stroke..strokeWidth = 1,
      );
    }

    // Crane Tower Arm
    final craneBase = Offset(c.dx + 16, c.dy - 4);
    canvas.drawLine(craneBase, Offset(craneBase.dx, craneBase.dy - 40), Paint()..color = const Color(0xFFEAB308)..strokeWidth = 3);
    canvas.drawLine(Offset(craneBase.dx, craneBase.dy - 40), Offset(craneBase.dx - 22, craneBase.dy - 32),
        Paint()..color = const Color(0xFFEAB308)..strokeWidth = 2.5);
    // Magnet
    canvas.drawCircle(Offset(craneBase.dx - 22, craneBase.dy - 20), 4, Paint()..color = const Color(0xFF334155));

    _drawRoofSign(canvas, c, 38, b);
  }

  // 7. Karaborsa (Dark Secret Warehouse + Barbed Fence)
  void _paintBlackMarketBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 44.0;
    const wall = Color(0xFF1E293B);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = const Color(0xFF0F172A));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF334155));

    // Secret purple glow & shutter door
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    _panel(canvas, o, uAxis, vAxis, 0.30, 0.70, 0.05, 0.55, Paint()..color = const Color(0xFF09090B));
    _panel(canvas, o, uAxis, vAxis, 0.35, 0.65, 0.10, 0.20, Paint()..color = const Color(0xFFA855F7).withValues(alpha: 0.5));

    // Barbed wire fencing posts in front
    for (double i = -14; i <= 14; i += 14) {
      canvas.drawLine(Offset(c.dx + i, c.dy + hh), Offset(c.dx + i, c.dy + hh - 12),
          Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2);
    }

    _drawRoofSign(canvas, c, h, b);
  }

  // 8. Banka & Finans (Neoclassical Pillars + Marble Pediment)
  void _paintFinanceBankBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 54.0;
    final wall = isNight ? const Color(0xFF1E3A2E) : const Color(0xFFF0FDF4);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);

    // Classical Marble Columns on front face
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    final colPaint = Paint()..color = isNight ? const Color(0xFF4ADE80) : const Color(0xFFCBD5E1)..strokeWidth = 3.5;
    for (double a = 0.20; a <= 0.80; a += 0.20) {
      canvas.drawLine(_facePt(o, uAxis, vAxis, a, 0.05), _facePt(o, uAxis, vAxis, a, 0.75), colPaint);
    }

    // Triangular Pediment / Green Roof
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF059669));
    // Gold Emblem
    canvas.drawCircle(Offset(c.dx, c.dy - h - 6), 4.5, Paint()..color = const Color(0xFFFBBF24));

    _drawRoofSign(canvas, c, h + 8, b);
  }

  // 9. Borsa (Glass High-Rise + Ticker Ribbon)
  void _paintStockMarketBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 68.0; // Tallest modern tower
    final wall = isNight ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.15));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF4F46E5));

    // Glass Windows Grid
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    for (double y = 0.20; y < 0.85; y += 0.16) {
      _panel(canvas, o, uAxis, vAxis, 0.15, 0.85, y, y + 0.08, Paint()..color = const Color(0xFF818CF8).withValues(alpha: 0.6));
    }

    // Green / Red Stock Ticker Line
    final ticker = Paint()..color = const Color(0xFF22C55E)..strokeWidth = 2.0;
    canvas.drawLine(_facePt(o, uAxis, vAxis, 0.0, 0.50), _facePt(o, uAxis, vAxis, 1.0, 0.50), ticker);

    _drawRoofSign(canvas, c, h, b);
  }

  // 10. Yatırım Fonu (Secure Gold Vault + Amber Windows)
  void _paintInvestmentVaultBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 46.0;
    final wall = isNight ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFFD97706));

    // Gold Vault Door Circle
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    _panel(canvas, o, uAxis, vAxis, 0.30, 0.70, 0.15, 0.65, Paint()..color = const Color(0xFFF59E0B));

    _drawRoofSign(canvas, c, h, b);
  }

  // 11. Rent a Car (Teal Reception + Key Symbol)
  void _paintRentACarBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 42.0;
    final wall = isNight ? const Color(0xFF134E4A) : const Color(0xFFF0FDFA);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = const Color(0xFF0D9488));

    // Wide glass customer reception
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    _panel(canvas, o, uAxis, vAxis, 0.15, 0.85, 0.15, 0.70, Paint()..color = const Color(0xFF5EEAD4).withValues(alpha: 0.6));

    _drawRoofSign(canvas, c, h, b);
  }

  // 12. Corporate Plaza (Şubeler, Personel, Yan İşletmeler)
  void _paintCorporatePlazaBuilding(Canvas canvas, Offset c, double w, double hh, WorldBuilding b) {
    const h = 52.0;
    final wall = isNight ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
    final L = Offset(c.dx - w, c.dy), R = Offset(c.dx + w, c.dy), B = Offset(c.dx, c.dy + hh), T = Offset(c.dx, c.dy - hh);
    Offset up(Offset o) => Offset(o.dx, o.dy - h);

    _quad(canvas, L, B, up(B), up(L), Paint()..color = _darken(wall, 0.12));
    _quad(canvas, B, R, up(R), up(B), Paint()..color = wall);
    _quad(canvas, up(T), up(R), up(B), up(L), Paint()..color = b.color);

    // Modern glass windows
    final o = B, uAxis = R - B, vAxis = const Offset(0, -h);
    for (double y = 0.15; y < 0.80; y += 0.22) {
      _panel(canvas, o, uAxis, vAxis, 0.20, 0.45, y, y + 0.14, Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.65));
      _panel(canvas, o, uAxis, vAxis, 0.55, 0.80, y, y + 0.14, Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.65));
    }

    _drawRoofSign(canvas, c, h, b);
  }

  void _drawRoofSign(Canvas canvas, Offset center, double h, WorldBuilding b) {
    final roofCenter = Offset(center.dx, center.dy - h);
    final signC = Offset(center.dx, roofCenter.dy - 24);
    canvas.drawLine(roofCenter, Offset(signC.dx, signC.dy + 10), Paint()..color = _darken(b.color, 0.25)..strokeWidth = 3);
    final board = Rect.fromCenter(center: signC, width: 32, height: 28);
    canvas.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(8)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(board, const Radius.circular(8)),
        Paint()..color = b.color..style = PaintingStyle.stroke..strokeWidth = 2.2);
    final emojiTp = TextPainter(
      text: TextSpan(text: b.emoji, style: const TextStyle(fontSize: 17)),
      textDirection: TextDirection.ltr,
    )..layout();
    emojiTp.paint(canvas, Offset(signC.dx - emojiTp.width / 2, signC.dy - emojiTp.height / 2));
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

  // ---- Street Furniture & Flower Beds ----
  void _drawStreetFurniture(Canvas canvas) {
    final plaza = IsoWorld.isoToScreen(1, 1);

    Offset inward(Offset pt, double amount) {
      final d = plaza - pt;
      final len = d.distance;
      if (len < 0.01) return pt;
      return Offset(pt.dx + d.dx / len * amount, pt.dy + d.dy / len * amount);
    }

    for (int i = 0; i < 4; i++) {
      final s = kRoadSegments[i];
      final a = IsoWorld.isoToScreen(s[0], s[1]);
      final b = IsoWorld.isoToScreen(s[2], s[3]);

      for (final t in const [0.25, 0.5, 0.75]) {
        _drawLamppost(canvas, inward(Offset.lerp(a, b, t)!, 32));
      }
      _drawBench(canvas, inward(Offset.lerp(a, b, 0.5)!, 54));
      _drawFlowerBed(canvas, inward(a, 36));
    }
  }

  void _drawLamppost(Canvas canvas, Offset base) {
    final poleColor = isNight ? const Color(0xFF5A6474) : const Color(0xFF37474F);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 18), width: 3, height: 32),
      Paint()..color = poleColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 35), width: 14, height: 7),
        const Radius.circular(3),
      ),
      Paint()..color = poleColor,
    );
    if (isNight) {
      canvas.drawCircle(
        Offset(base.dx, base.dy - 32),
        18,
        Paint()
          ..color = const Color(0xFFFFE082).withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        Offset(base.dx, base.dy - 34),
        5,
        Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.9),
      );
    } else {
      canvas.drawCircle(
        Offset(base.dx, base.dy - 34),
        4,
        Paint()..color = const Color(0xFFE0E0E0),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 10, height: 5),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );
  }

  void _drawBench(Canvas canvas, Offset base) {
    final wood = isNight ? const Color(0xFF4E3B28) : const Color(0xFF8D6E48);
    final leg = isNight ? const Color(0xFF3A3A3A) : const Color(0xFF555555);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: 22, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawRect(Rect.fromLTWH(base.dx - 8, base.dy - 4, 2, 6), Paint()..color = leg);
    canvas.drawRect(Rect.fromLTWH(base.dx + 6, base.dy - 4, 2, 6), Paint()..color = leg);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 5), width: 22, height: 5),
        const Radius.circular(1.5),
      ),
      Paint()..color = wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 10), width: 20, height: 4),
        const Radius.circular(1),
      ),
      Paint()..color = _darken(wood, 0.08),
    );
  }

  void _drawFlowerBed(Canvas canvas, Offset base) {
    final stoneColor = isNight ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    // Stone planter border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: base, width: 22, height: 12), const Radius.circular(3)),
      Paint()..color = stoneColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: base, width: 18, height: 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFF451A03), // soil
    );
    // Flowers
    final colors = [const Color(0xFFEC4899), const Color(0xFFFBBF24), const Color(0xFFA855F7), const Color(0xFFEF4444)];
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(base.dx - 6 + i * 4, base.dy - 2 + (i % 2 == 0 ? -1 : 1)),
        2.5,
        Paint()..color = colors[i],
      );
    }
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

  void _drawAmbientCars(Canvas canvas, List<_Drawable> drawables) {
    // 3 driving cars along the outer loop highways
    final carSpecs = [
      (const Color(0xFFEF4444), 0.0, 1.0, -11.0, -3.0, -11.0, 4.0),
      (const Color(0xFF3B82F6), 0.35, 1.2, 11.0, 4.0, 11.0, -3.0),
      (const Color(0xFF10B981), 0.7, 0.9, -6.0, -9.0, -6.0, -3.0),
    ];

    for (final spec in carSpecs) {
      final t = (anim * spec.$3 + spec.$2) % 1.0;
      final start = IsoWorld.isoToScreen(spec.$4, spec.$5);
      final end = IsoWorld.isoToScreen(spec.$6, spec.$7);
      final pos = Offset.lerp(start, end, t)!;

      drawables.add(
        _Drawable(pos.dy, () {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(pos.dx, pos.dy + 2), width: 28, height: 12),
            Paint()..color = Colors.black38,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(pos.dx, pos.dy - 4), width: 22, height: 10), const Radius.circular(3)),
            Paint()..color = spec.$1,
          );
          // Headlights at night
          if (isNight) {
            canvas.drawCircle(Offset(pos.dx + 10, pos.dy - 4), 3, Paint()..color = const Color(0xFFFEF08A));
          }
        }),
      );
    }
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
    for (int i = 0; i < 24; i++) {
      final seed = i * 53.0;
      final px = (IsoWorld.origin.dx - 350 + (seed * 23) % 700);
      final py = (IsoWorld.origin.dy - 160 + (seed * 29 + anim * 90) % 450);
      canvas.drawCircle(Offset(px, py), 1.0 + (i % 3) * 0.5, paint);
    }
  }

  double _distToSegment(Offset pt, Offset a, Offset b) {
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final lenSq = dx * dx + dy * dy;
    if (lenSq < 0.01) return (pt - a).distance;
    var t = ((pt.dx - a.dx) * dx + (pt.dy - a.dy) * dy) / lenSq;
    t = t.clamp(0.0, 1.0);
    return (pt - Offset(a.dx + dx * t, a.dy + dy * t)).distance;
  }

  bool _treeBlocked(Offset pt) {
    if ((pt - IsoWorld.isoToScreen(1, 1)).distance < 220) return true;
    if ((pt - IsoWorld.isoToScreen(-2, -2)).distance < 200) return true;
    for (final b in kWorldBuildings) {
      if ((pt - b.screenCenter).distance < 115) return true;
    }
    for (final h in _kDecorativeHouses) {
      if ((pt - IsoWorld.isoToScreen(h.row, h.col)).distance < 75) return true;
    }
    for (final s in kRoadSegments) {
      final a = IsoWorld.isoToScreen(s[0], s[1]);
      final e = IsoWorld.isoToScreen(s[2], s[3]);
      if (_distToSegment(pt, a, e) < s[4] + 16) return true;
    }
    return false;
  }

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
