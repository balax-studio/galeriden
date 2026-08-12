import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/car_icons.dart';
import '../../../data/models/expertise_model.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedFilter = 'all'; // 'all', 'bargain', 'clean', 'affordable'

  @override
  Widget build(BuildContext context) {
    final allListings = ref.watch(marketProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    final marketSenseLevel = game.skills.marketSense;
    final trend = game.marketTrend;

    // Filter listings based on active chip filter
    final listings = allListings.where((item) {
      if (_selectedFilter == 'bargain') {
        return item.sellerTrait.contains('Fırsat') || item.askingPrice < item.car.estimatedRealValue * 0.88;
      } else if (_selectedFilter == 'clean') {
        return item.car.expertise.bodyParts.values.every((v) => v == PartStatus.original) && !item.car.expertise.isMileageTampered;
      } else if (_selectedFilter == 'affordable') {
        return item.askingPrice <= game.balance;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İKİNCİ EL PAZARI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pazarı Yenile',
            onPressed: () {
              ref.read(gameProvider.notifier).refreshMarketTrends();
              ref.read(marketProvider.notifier).refreshMarket();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Trend & Skill Intel Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: p.primaryColor.withValues(alpha: 0.12),
            child: Row(
              children: [
                Icon(Icons.insights_rounded, color: p.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.headline,
                        style: AppTypography.labelSmall(p.isDark).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      if (marketSenseLevel >= 3)
                        Text(
                          'Piyasa Sezgisi (Lv $marketSenseLevel): SUV x${trend.bodyTypeMultipliers['SUV']} | Spor x${trend.bodyTypeMultipliers['Spor']}',
                          style: TextStyle(color: p.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                        )
                      else
                        Text(
                          'Piyasa Sezgisi Lv 3 yükseltilirse segment kâr oranları açılır.',
                          style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tüm Araçlar', Icons.directions_car_rounded, p),
                const SizedBox(width: 8),
                _buildFilterChip('bargain', 'Kelepir Fırsatlar', Icons.local_fire_department_rounded, p),
                const SizedBox(width: 8),
                _buildFilterChip('clean', 'Hasarsız', Icons.verified_user_rounded, p),
                const SizedBox(width: 8),
                _buildFilterChip('affordable', 'Bütçeme Uygun', Icons.account_balance_wallet_rounded, p),
              ],
            ),
          ),

          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: p.surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    VectorIconWidget(type: 'car', color: p.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text('Satılık Araçlar (${listings.length})', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                  ],
                ),
                Text('Sermaye: ${CurrencyFormatter.formatShort(game.balance)}', style: AppTypography.moneyMedium(p.isDark)),
              ],
            ),
          ),
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Text('Aranan kriterde araç bulunamadı.', style: AppTypography.bodyMedium(p.isDark)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      final car = item.car;
                      final exp = car.expertise;
                      final isFlash = item.sellerTrait.contains('Fırsat');
                      final viewerCount = PsychologyEngine.getLiveViewerCount();

                      // Convert hex string to Color
                      Color carColor;
                      try {
                        carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xFF')));
                      } catch (e) {
                        carColor = p.primaryColor;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: car.isRare ? p.secondaryColor : (isFlash ? p.warningColor : p.surfaceBorderColor),
                            width: (car.isRare || isFlash) ? 2.0 : 1.0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/listing-detail', extra: item),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              // Top Tag & Live Viewer FOMO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: p.secondaryColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(car.bodyType, style: AppTypography.labelSmall(p.isDark).copyWith(color: p.secondaryColor)),
                                      ),
                                      if (car.isRare) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: p.secondaryColor,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VectorIconWidget(type: 'rare', color: Colors.white, size: 12),
                                              const SizedBox(width: 4),
                                              const Text('NADİR KOLEKSİYON', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (isFlash) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: p.warningColor,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VectorIconWidget(type: 'flash', color: Colors.white, size: 12),
                                              const SizedBox(width: 4),
                                              const Text('FIRSAT %30 İNDİRİM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.remove_red_eye_rounded, size: 14, color: p.textSecondaryColor),
                                      const SizedBox(width: 4),
                                      Text('$viewerCount kişi bakıyor', style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Car Header: Silhouette Icon + Name
                              Row(
                                children: [
                                  CarSilhouetteWidget(
                                    bodyType: car.bodyType,
                                    color: carColor,
                                    width: 54,
                                    height: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 17)),
                                        Text('${item.sellerCity} • ${car.modelYear} Model', style: AppTypography.labelSmall(p.isDark)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Color-Coded Stat Badges (KM, Engine, Tramer)
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _buildColorBadge(
                                    label: '${(exp.mileage / 1000).toStringAsFixed(0)}K KM',
                                    color: StatColors.getMileageColor(exp.mileage),
                                    tooltip: StatColors.getMileageLabel(exp.mileage),
                                  ),
                                  _buildColorBadge(
                                    label: exp.tramerAmount == 0 ? 'Tramer: 0 ₺' : 'Tramer: ₺${CurrencyFormatter.formatShort(exp.tramerAmount.toDouble())}',
                                    color: StatColors.getTramerColor(exp.tramerAmount),
                                    tooltip: StatColors.getTramerLabel(exp.tramerAmount),
                                  ),
                                  _buildColorBadge(
                                    label: 'Motor: %${exp.engineCondition.round()}',
                                    color: StatColors.getEngineColor(exp.engineCondition),
                                    tooltip: StatColors.getEngineLabel(exp.engineCondition),
                                  ),
                                  if (exp.isMileageTampered && item.isExpertiseCompleted)
                                    _buildColorBadge(
                                      label: 'ŞÜPHELİ KM!',
                                      color: p.errorColor,
                                      tooltip: 'KM Düşürülmüş Olabilir!',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Price & Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('İlan Fiyatı', style: AppTypography.labelSmall(p.isDark)),
                                      Text(CurrencyFormatter.format(item.askingPrice), style: AppTypography.moneyMedium(p.isDark)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: p.primaryColor),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          context.push('/expertise', extra: item);
                                        },
                                        child: Text(
                                          item.isExpertiseCompleted ? 'Rapor' : 'Ekspertiz (₺1.500)',
                                          style: TextStyle(fontSize: 12, color: p.textPrimaryColor),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: p.primaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: game.balance < item.askingPrice
                                            ? null
                                            : () {
                                                final outcome = ref.read(gameProvider.notifier).buyCar(
                                                      car,
                                                      item.askingPrice,
                                                      isExpertiseCompleted: item.isExpertiseCompleted,
                                                    );
                                                if (outcome != null) {
                                                  ref.read(marketProvider.notifier).removeListing(item.id);

                                                  if (outcome.isTrapped) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        backgroundColor: p.surfaceColor,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        title: Row(
                                                          children: [
                                                            Icon(Icons.warning_amber_rounded, color: p.errorColor, size: 28),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                outcome.title,
                                                                style: TextStyle(color: p.errorColor, fontWeight: FontWeight.bold, fontSize: 18),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: Text(
                                                          outcome.description,
                                                          style: TextStyle(color: p.textPrimaryColor, fontSize: 14),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(ctx),
                                                            child: Text('Anladım', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('${car.brand} ${car.modelName} satın alındı ve garajına eklendi!')),
                                                    );
                                                  }
                                                }
                                              },
                                        child: const Text('Satın Al', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon, dynamic p) {
    final isSelected = _selectedFilter == key;
    final activeColor = isSelected ? p.primaryColor : p.surfaceBorderColor;
    final textColor = isSelected ? (p.isDark ? Colors.black : Colors.white) : p.textPrimaryColor;

    return FilterChip(
      showCheckmark: false,
      avatar: Icon(icon, size: 16, color: isSelected ? textColor : p.primaryColor),
      label: Text(label, style: TextStyle(color: textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12)),
      selected: isSelected,
      selectedColor: p.primaryColor,
      backgroundColor: p.surfaceColor,
      side: BorderSide(color: activeColor, width: isSelected ? 1.5 : 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = key;
        });
      },
    );
  }

  Widget _buildColorBadge({required String label, required Color color, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
