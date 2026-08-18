import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/stock_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class StockMarketScreen extends ConsumerStatefulWidget {
  const StockMarketScreen({super.key});

  @override
  ConsumerState<StockMarketScreen> createState() => _StockMarketScreenState();
}

class _StockMarketScreenState extends ConsumerState<StockMarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSector = 'TÜMÜ';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- TRADING DIALOG FOR STOCKS ---
  void _openStockTradeDialog(BuildContext context, StockModel stock, PlayerStockModel? owned) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lotController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final int lotAmount = int.tryParse(lotController.text) ?? 0;
            final double grossCost = lotAmount * stock.currentPrice;
            final double commission = grossCost * 0.002;
            final double totalCost = grossCost + commission;
            final int maxBuyable = (game.balance / (stock.currentPrice * 1.002)).floor();
            final int sharesOwned = owned?.quantity ?? 0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141721) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${stock.symbol} • ${stock.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Birim Fiyat: ${CurrencyFormatter.formatShort(stock.currentPrice)} • %${(stock.dividendYield * 100).toStringAsFixed(1)} Temettü',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeoBrutalBadge(
                          text: '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: stock.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                          textColor: stock.isUp ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'İŞLEM ADEDİ • LOT:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lotController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Lot Miktarı',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.5),
                        ),
                        suffixText: 'LOT',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.w900),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    // Quick Percent / Lot Buttons
                    Row(
                      children: [
                        _buildQuickChip('%25', () {
                          final count = (maxBuyable * 0.25).floor().clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('%50', () {
                          final count = (maxBuyable * 0.50).floor().clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('%75', () {
                          final count = (maxBuyable * 0.75).floor().clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('MAX • $maxBuyable', () {
                          lotController.text = maxBuyable.toString();
                          setDialogState(() {});
                        }, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Hisse Tutarı:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(CurrencyFormatter.formatShort(grossCost), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Borsa Komisyonu • %0.2:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text(CurrencyFormatter.formatShort(commission), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Divider(height: 12, thickness: 1, color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Toplam Tutar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                              Text(
                                CurrencyFormatter.formatShort(totalCost),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: 'LOT SATIN AL',
                            icon: Icons.add_shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              if (lotAmount <= 0) {
                                NotificationService.showError(context, 'Lütfen geçerli bir lot miktarı girin.');
                                return;
                              }
                              final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, lotAmount);
                              if (success) {
                                Navigator.pop(dialogCtx);
                                NotificationService.showSuccess(context, '$lotAmount Lot ${stock.symbol} satın alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz bakiye!');
                              }
                            },
                          ),
                        ),
                        if (sharesOwned > 0) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeoBrutalButton(
                              label: 'SAT • $sharesOwned',
                              icon: Icons.sell_rounded,
                              backgroundColor: AppColors.errorRed,
                              textColor: Colors.white,
                              onPressed: () {
                                final sellCount = lotAmount > sharesOwned ? sharesOwned : lotAmount;
                                final success = ref.read(gameProvider.notifier).sellStock(stock.symbol, sellCount);
                                if (success) {
                                  Navigator.pop(dialogCtx);
                                  NotificationService.showSuccess(context, '$sellCount Lot ${stock.symbol} satıldı!');
                                } else {
                                  NotificationService.showError(context, 'Satış işlemi yapılamadı!');
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => lotController.dispose());
  }

  // --- TRADING DIALOG FOR FOREX / GOLD ---
  void _openForexTradeDialog(BuildContext context, ForexGoldModel forex, PlayerForexModel? owned) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController = TextEditingController(text: forex.symbol == 'GOLD' ? '5' : '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double amount = double.tryParse(amountController.text) ?? 0.0;
            final double buyCost = amount * forex.buyRate;
            final double sellRevenue = amount * forex.sellRate;
            final double maxBuyable = (game.balance / forex.buyRate);
            final double currentOwned = owned?.amount ?? 0.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141721) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${forex.symbol} • ${forex.name}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Alış: ₺${forex.buyRate.toStringAsFixed(2)} | Satış: ₺${forex.sellRate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text: '${forex.isUp ? '+' : ''}${forex.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: forex.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                          textColor: forex.isUp ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MİKTAR • ${forex.symbol == 'GOLD' ? 'GRAM' : 'BİRİM'}:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Miktar giriniz',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        suffixText: forex.symbol == 'GOLD' ? 'GR' : forex.symbol,
                        suffixStyle: const TextStyle(fontWeight: FontWeight.w900),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQuickChip(forex.symbol == 'GOLD' ? '+5' : '+100', () {
                          final step = forex.symbol == 'GOLD' ? 5 : 100;
                          amountController.text = (amount + step).toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip(forex.symbol == 'GOLD' ? '+25' : '+500', () {
                          final step = forex.symbol == 'GOLD' ? 25 : 500;
                          amountController.text = (amount + step).toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('MAX AL', () {
                          amountController.text = maxBuyable.toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        if (currentOwned > 0) ...[
                          const SizedBox(width: 6),
                          _buildQuickChip('TÜMÜNÜ SAT', () {
                            amountController.text = currentOwned.toStringAsFixed(0);
                            setDialogState(() {});
                          }, isDark),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Alış Maliyeti:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(CurrencyFormatter.formatShort(buyCost), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.brutalGreen)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Satış Geliri:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(CurrencyFormatter.formatShort(sellRevenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.errorRed)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: 'SATIN AL',
                            icon: Icons.add_circle_outline_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              if (amount <= 0) {
                                NotificationService.showError(context, 'Geçerli bir miktar girin.');
                                return;
                              }
                              final success = ref.read(gameProvider.notifier).buyForex(forex.symbol, amount);
                              if (success) {
                                Navigator.pop(dialogCtx);
                                NotificationService.showSuccess(context, '${amount.toStringAsFixed(0)} ${forex.symbol} alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz bakiye!');
                              }
                            },
                          ),
                        ),
                        if (currentOwned > 0) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeoBrutalButton(
                              label: 'BOZDUR',
                              icon: Icons.currency_exchange_rounded,
                              backgroundColor: AppColors.errorRed,
                              textColor: Colors.white,
                              onPressed: () {
                                final sellAmount = amount > currentOwned ? currentOwned : amount;
                                final success = ref.read(gameProvider.notifier).sellForex(forex.symbol, sellAmount);
                                if (success) {
                                  Navigator.pop(dialogCtx);
                                  NotificationService.showSuccess(context, '${sellAmount.toStringAsFixed(0)} ${forex.symbol} bozduruldu!');
                                } else {
                                  NotificationService.showError(context, 'İşlem başarısız!');
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => amountController.dispose());
  }

  // --- QUICK CHIP BUILDER ---
  static Widget _buildQuickChip(String label, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/stock-market')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'BORSA & YATIRIM MERKEZİ'),
        body: const NeoBrutalLockedFeatureView(
          route: '/stock-market',
          featureTitle: 'BORSA & FON PİYASASI',
          icon: Icons.candlestick_chart_rounded,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: 'BORSA & YATIRIM MERKEZİ',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: 'Gün ${game.currentDay}',
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: isDark ? Colors.white70 : const Color(0xFF64748B),
          indicatorColor: Colors.black,
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
          tabs: const [
            Tab(text: 'BİST HİSSELERİ'),
            Tab(text: 'PORTFÖY & TEMETTÜ'),
            Tab(text: 'DÖVİZ & ALTIN'),
            Tab(text: 'HALKA ARZ • IPO'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: AppColors.brutalYellow,
        strokeWidth: 2.5,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 300));
          ref.read(gameProvider.notifier).refreshStockMarket();
          if (context.mounted) {
            NotificationService.showInfo(context, 'Piyasa ve kurlar güncellendi.');
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStocksTab(game, isDark),
            _buildPortfolioTab(game, isDark),
            _buildForexTab(game, isDark),
            _buildIpoTab(game, isDark),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BİST HİSSELERİ & ENDEKS
  // ==========================================
  Widget _buildStocksTab(dynamic game, bool isDark) {
    final bistIndex = BistIndexModel.calculateIndex(game.marketStocks);
    final sectors = ['TÜMÜ', 'Otomotiv & Üretim', 'Yedek Parça & Sanayi', 'Teknoloji & Yazılım', 'Enerji & Akaryakıt'];

    final filteredStocks = _selectedSector == 'TÜMÜ'
        ? game.marketStocks
        : game.marketStocks.where((s) => s.sectorCategory == _selectedSector).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // 1. BIST-OTO ENDEKS KARTI
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bistIndex.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 2.0),
                ),
                child: Icon(
                  bistIndex.isUp ? Icons.candlestick_chart_rounded : Icons.trending_down_rounded,
                  color: bistIndex.isUp ? Colors.black : Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BIST-OTO ENDEKSİ',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        NeoBrutalBadge(
                          text: bistIndex.trendName,
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${bistIndex.points.toStringAsFixed(1)} Puan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBrutalBadge(
                          text: '${bistIndex.isUp ? '+' : ''}${bistIndex.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: bistIndex.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                          textColor: bistIndex.isUp ? Colors.black : Colors.white,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. SECTOR FILTER CHIPS
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sectors.map((sector) {
              final isSelected = _selectedSector == sector;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(sector, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87))),
                  selected: isSelected,
                  selectedColor: AppColors.brutalYellow,
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black, width: 1.5)),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSector = sector);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 3. STOCKS LIST
        ...filteredStocks.map((stock) {
          final owned = findFirstWhere<PlayerStockModel>(game.ownedStocks, (s) => s.symbol == stock.symbol);
          final int sharesOwned = owned?.quantity ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                NeoBrutalBadge(
                                  text: stock.symbol,
                                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                  textColor: isDark ? Colors.white : Colors.black,
                                  fontSize: 11,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    stock.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  stock.sectorCategory,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                NeoBrutalBadge(
                                  text: '%${(stock.dividendYield * 100).toStringAsFixed(1)} Temettü',
                                  backgroundColor: AppColors.brutalCyan,
                                  textColor: Colors.black,
                                  fontSize: 9,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatShort(stock.currentPrice),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          NeoBrutalBadge(
                            text: '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(1)}%',
                            backgroundColor: stock.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                            textColor: stock.isUp ? Colors.black : Colors.white,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. SPARKLINE CHART
                  if (stock.priceHistory.isNotEmpty) ...[
                    Container(
                      height: 38,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CustomPaint(
                        painter: SparklinePainter(
                          history: stock.priceHistory,
                          isUp: stock.isUp,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (sharesOwned > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Portföy: $sharesOwned Lot', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                          Text(
                            'Değer: ${CurrencyFormatter.formatShort((sharesOwned * stock.currentPrice).toDouble())}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  NeoBrutalButton(
                    label: 'AL / SAT & İŞLEM YAP',
                    icon: Icons.candlestick_chart_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    fullWidth: true,
                    onPressed: () => _openStockTradeDialog(context, stock, owned),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 2: PORTFÖYÜM & TEMETTÜ AKIŞI
  // ==========================================
  Widget _buildPortfolioTab(dynamic game, bool isDark) {
    double totalPortfolioValue = 0.0;
    double totalCostBasis = 0.0;
    double dailyDividendFlow = ref.read(gameProvider.notifier).calculateDailyStockDividends();

    for (var owned in game.ownedStocks) {
      final currentStock = findFirstWhere<StockModel>(game.marketStocks, (s) => s.symbol == owned.symbol);
      final currentPrice = currentStock?.currentPrice ?? owned.averageCost;
      totalPortfolioValue += owned.quantity * currentPrice;
      totalCostBasis += owned.quantity * owned.averageCost;
    }

    final double totalProfitLoss = totalPortfolioValue - totalCostBasis;
    final bool isOverallProfitable = totalProfitLoss >= 0;

    if (game.ownedStocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Color(0xFF64748B)),
              const SizedBox(height: 16),
              Text(
                'HENÜZ PORTFÖYÜNDE HİSSE YOK',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 6),
              const Text(
                'BİST Hisseleri sekmesinden temettü verimi yüksek otomotiv hisselerine yatırım yaparak günlük pasif nakit akışı oluşturabilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // 1. PORTFOLIO SUMMARY CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOPLAM PORTFÖY DEĞERİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                  NeoBrutalBadge(
                    text: '${isOverallProfitable ? '+' : ''}${CurrencyFormatter.formatShort(totalProfitLoss)}',
                    backgroundColor: isOverallProfitable ? AppColors.brutalGreen : AppColors.errorRed,
                    textColor: isOverallProfitable ? Colors.black : Colors.white,
                    fontSize: 10.5,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatShort(totalPortfolioValue),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const Divider(height: 20, thickness: 1),
              // Daily dividend stream box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brutalCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brutalCyan, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.waterfall_chart_rounded, color: AppColors.brutalBlue, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GÜNLÜK TEMETTÜ NAKİT AKIŞI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                          Text(
                            '+${CurrencyFormatter.formatShort(dailyDividendFlow)} / Gün',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                          Text(
                            'Yıllık Beklenen: ${CurrencyFormatter.formatShort(dailyDividendFlow * 365)}',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
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
        const SizedBox(height: 14),

        Text('ELDEKİ HİSSELER • ${game.ownedStocks.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),

        ...game.ownedStocks.map((owned) {
          final stock = findFirstWhere<StockModel>(game.marketStocks, (s) => s.symbol == owned.symbol);
          final double curPrice = stock?.currentPrice ?? owned.averageCost;
          final double posVal = owned.quantity * curPrice;
          final double posCost = owned.quantity * owned.averageCost;
          final double posPl = posVal - posCost;
          final bool posProfit = posPl >= 0;
          final double dailyDiv = ((posVal * (stock?.dividendYield ?? 0.0)) / 365.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeoBrutalBadge(text: owned.symbol, backgroundColor: AppColors.brutalYellow, textColor: Colors.black, fontSize: 11),
                          const SizedBox(width: 8),
                          Text('${owned.quantity} Lot', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Text(CurrencyFormatter.formatShort(posVal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Maliyet: ${CurrencyFormatter.formatShort(owned.averageCost)} | Fiyat: ${CurrencyFormatter.formatShort(curPrice)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                      Text(
                        '${posProfit ? '+' : ''}${CurrencyFormatter.formatShort(posPl)}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: posProfit ? AppColors.brutalGreen : AppColors.errorRed),
                      ),
                    ],
                  ),
                  if (dailyDiv >= 0.1) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.payments_rounded, size: 13, color: AppColors.brutalBlue),
                        const SizedBox(width: 4),
                        Text('Günlük Temettü Getirisi: +₺${dailyDiv.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10.5, color: AppColors.brutalBlue, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (stock != null)
                    NeoBrutalButton(
                      label: 'İŞLEM YAP / SAT',
                      icon: Icons.swap_horiz_rounded,
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      fullWidth: true,
                      onPressed: () => _openStockTradeDialog(context, stock, owned),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 3: DÖVİZ & GRAM ALTIN (FOREX)
  // ==========================================
  Widget _buildForexTab(dynamic game, bool isDark) {
    final List<ForexGoldModel> forexList = game.marketForex.isNotEmpty ? game.marketForex : ForexGoldModel.defaultForex;

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // Forex Hedging Info Card
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: AppColors.brutalYellow.withValues(alpha: 0.2),
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.black87, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Döviz ve Gram Altın yatırımları, piyasa krizlerinde ve ithal araç fiyat artışlarında kasanızı koruyan güvenli limandır.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...forexList.map((item) {
          final owned = findFirstWhere<PlayerForexModel>(game.ownedForex, (f) => f.symbol == item.symbol);
          final double ownedAmount = owned?.amount ?? 0.0;
          final double totalValue = ownedAmount * item.sellRate;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.symbol == 'GOLD' ? AppColors.brutalYellow : (item.symbol == 'USD' ? AppColors.brutalGreen : AppColors.brutalCyan),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Icon(
                              item.symbol == 'GOLD' ? Icons.monetization_on_rounded : Icons.attach_money_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.symbol} • ${item.name}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Alış: ₺${item.buyRate.toStringAsFixed(2)} | Satış: ₺${item.sellRate.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: '${item.isUp ? '+' : ''}${item.changePercentage.toStringAsFixed(1)}%',
                        backgroundColor: item.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                        textColor: item.isUp ? Colors.black : Colors.white,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Mini sparkline for forex
                  if (item.rateHistory.isNotEmpty) ...[
                    Container(
                      height: 32,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: CustomPaint(
                        painter: SparklinePainter(
                          history: item.rateHistory,
                          isUp: item.isUp,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (ownedAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Varlık: ${ownedAmount.toStringAsFixed(1)} ${item.symbol == 'GOLD' ? 'Gr' : item.symbol}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                          Text('Değer: ${CurrencyFormatter.formatShort(totalValue)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  NeoBrutalButton(
                    label: 'DÖVİZ / ALTIN İŞLEMİ YAP',
                    icon: Icons.currency_exchange_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    fullWidth: true,
                    onPressed: () => _openForexTradeDialog(context, item, owned),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // TAB 4: HALKA ARZ (IPO) TALEP TOPLAMA
  // ==========================================
  Widget _buildIpoTab(dynamic game, bool isDark) {
    final List<IpoOfferModel> ipoList = game.activeIpos.isNotEmpty ? game.activeIpos : IpoOfferModel.defaultIpos(game.currentDay);
    final List<PlayerIpoRequestModel> requests = game.playerIpoRequests;

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: AppColors.brutalCyan.withValues(alpha: 0.2),
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: const Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: AppColors.brutalBlue, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Halka Arzlara erkenden talep toplayarak katıl. Borsa listeleme günü tavan serisi ile yüksek getiri sağla!',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...ipoList.map((ipo) {
          final userReq = findFirstWhere<PlayerIpoRequestModel>(requests, (r) => r.ipoId == ipo.id);
          final bool hasRequested = userReq != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeoBrutalBadge(text: ipo.symbol, backgroundColor: AppColors.brutalYellow, textColor: Colors.black, fontSize: 11),
                          const SizedBox(width: 8),
                          Text(ipo.companyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: ipo.isListed ? 'BORSADA İŞLEMDE' : '${ipo.daysUntilListing} GÜN KALDI',
                        backgroundColor: ipo.isListed ? AppColors.brutalGreen : AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ipo.description,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lot Fiyatı: ₺${ipo.lotPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      NeoBrutalBadge(
                        text: 'Beklenen: ${ipo.listingMultiplier.toStringAsFixed(1)}x Tavan',
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (hasRequested) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brutalGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.brutalGreen, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Talep: ${userReq.requestedLots} Lot • ₺${userReq.totalSpent.round()}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                          Row(
                            children: const [
                              Icon(Icons.check_circle_rounded, size: 14, color: AppColors.brutalGreen),
                              SizedBox(width: 4),
                              Text('ONAYLANDI', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (!ipo.isListed) ...[
                    NeoBrutalButton(
                      label: 'HALKA ARZA KATIL & TALEP VER',
                      icon: Icons.how_to_reg_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 11.5,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      fullWidth: true,
                      onPressed: () {
                        _showIpoRequestSheet(context, ipo);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showIpoRequestSheet(BuildContext context, IpoOfferModel ipo) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lotCtrl = TextEditingController(text: ipo.maxLotPerUser.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final int requestedLots = int.tryParse(lotCtrl.text) ?? 0;
            final double totalCost = requestedLots * ipo.lotPrice;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(dialogCtx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141721) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 2.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HALKA ARZ TALEBİ • ${ipo.symbol}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Maksimum Talep Sınırı: ${ipo.maxLotPerUser} Lot', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lotCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Lot Miktarı',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixText: 'LOT',
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text('Toplam Talep Bedeli: ₺${totalCost.round()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                    const SizedBox(height: 16),
                    NeoBrutalButton(
                      label: 'TALEBİ ONAYLA',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        if (requestedLots <= 0 || requestedLots > ipo.maxLotPerUser) {
                          NotificationService.showError(context, 'Maksimum ${ipo.maxLotPerUser} lot talep edebilirsiniz.');
                          return;
                        }
                        if (game.balance < totalCost) {
                          NotificationService.showError(context, 'Yetersiz bakiye!');
                          return;
                        }
                        final success = ref.read(gameProvider.notifier).requestIpo(ipo.id, requestedLots);
                        if (success) {
                          Navigator.pop(dialogCtx);
                          NotificationService.showSuccess(context, '${ipo.symbol} halka arz talebiniz iletildi!');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => lotCtrl.dispose());
  }
}

// ==========================================
// CUSTOM PAINTER: SPARKLINE MINI-CHART
// ==========================================
class SparklinePainter extends CustomPainter {
  final List<double> history;
  final bool isUp;
  final bool isDark;

  SparklinePainter({
    required this.history,
    required this.isUp,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final double minVal = history.reduce((a, b) => a < b ? a : b);
    final double maxVal = history.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final linePaint = Paint()
      ..color = isUp ? AppColors.brutalGreen : AppColors.errorRed
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (history.length - 1);

    for (int i = 0; i < history.length; i++) {
      final double normalizedY = 1.0 - ((history[i] - minVal) / range);
      final double y = (normalizedY * (size.height - 6)) + 3;
      final double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == history.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Gradient fill under sparkline
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isUp ? AppColors.brutalGreen : AppColors.errorRed).withValues(alpha: 0.35),
          (isUp ? AppColors.brutalGreen : AppColors.errorRed).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => true;
}
