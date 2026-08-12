import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/auction_model.dart';
import '../../../domain/usecases/auction_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  const AuctionScreen({super.key});

  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen> {
  late AuctionModel _auction;
  Timer? _timer;
  final List<String> _bidLogs = [];

  @override
  void initState() {
    super.initState();
    final game = ref.read(gameProvider);
    _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
    _bidLogs.add('🏁 Gümrük ve İcra Araç İhalesi Başladı!');
    _bidLogs.add('Başlangıç Teklifi: ₺${CurrencyFormatter.formatShort(_auction.startingPrice)}');
    _startAuctionTimer();
  }

  void _startAuctionTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_auction.secondsRemaining <= 1) {
        _timer?.cancel();
        setState(() {
          _auction = _auction.copyWith(secondsRemaining: 0, status: AuctionStatus.ended);
        });
        _handleAuctionEnd();
        return;
      }

      setState(() {
        _auction = _auction.copyWith(secondsRemaining: _auction.secondsRemaining - 1);
      });

      // Process rival bid
      final updated = AuctionEngine.processRivalBid(_auction);
      if (updated != null) {
        setState(() {
          _auction = updated;
          _bidLogs.insert(0, '🔥 ${updated.highestBidderName} teklifi artırdı: ₺${CurrencyFormatter.formatShort(updated.currentBid)}');
        });
      }
    });
  }

  void _placePlayerBid(double increment) {
    final game = ref.read(gameProvider);
    final nextBid = _auction.currentBid + increment;

    if (game.balance < nextBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz Sermaye! Bu teklifi veremezsiniz.')),
      );
      return;
    }

    setState(() {
      _auction = _auction.copyWith(
        currentBid: nextBid,
        highestBidderName: 'Öz Galeri (Sen)',
        isPlayerHighestBidder: true,
        secondsRemaining: (_auction.secondsRemaining < 8) ? 8 : _auction.secondsRemaining,
      );
      _bidLogs.insert(0, '⚡ SEN TEKLİF VERDİN: ₺${CurrencyFormatter.formatShort(nextBid)}');
    });
  }

  void _handleAuctionEnd() {
    if (_auction.isPlayerHighestBidder) {
      // Player won! Deduct balance and add car to garage
      ref.read(gameProvider.notifier).buyCarDirectly(_auction.car, _auction.currentBid);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('🎉 İHALEYİ KAZANDIN!'),
          content: Text(
            'Tebrikler! ${_auction.car.brand} ${_auction.car.modelName} aracını ₺${CurrencyFormatter.formatShort(_auction.currentBid)} fiyata ihaleden kaptın!\n\nPiyasa Değeri: ₺${CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Galeriye Git'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('❌ İHALE SONLANDI'),
          content: Text('İhaleyi ${_auction.highestBidderName} ₺${CurrencyFormatter.formatShort(_auction.currentBid)} teklifle kazandı.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Ayrıl'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final car = _auction.car;

    return Scaffold(
      backgroundColor: p.backgroundColor,
      appBar: AppBar(
        backgroundColor: p.surfaceColor,
        title: const Text('🔨 CANLI GÜMRÜK İHALESİ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer & Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _auction.secondsRemaining < 8 ? p.errorColor.withValues(alpha: 0.15) : p.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _auction.secondsRemaining < 8 ? p.errorColor : p.primaryColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      VectorIconWidget(type: 'flash', color: _auction.secondsRemaining < 8 ? p.errorColor : p.primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'KALAN SÜRE: ${_auction.secondsRemaining}s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _auction.secondsRemaining < 8 ? p.errorColor : p.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Piyasa: ₺${CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}',
                    style: AppTypography.labelSmall(p.isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Car Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: p.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: VectorIconWidget(type: 'craftsman', color: p.primaryColor, size: 36),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                        Text('${car.modelYear} • ${car.expertise.mileage} KM • ${car.bodyType}', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 6),
                        Text(
                          'EN YÜKSEK TEKLİF: ₺${CurrencyFormatter.format(_auction.currentBid)}',
                          style: AppTypography.moneyMedium(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold),
                        ),
                        Text('Lider: ${_auction.highestBidderName}', style: TextStyle(fontSize: 12, color: _auction.isPlayerHighestBidder ? p.successColor : Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Auction Feed Logs
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.surfaceBorderColor),
                ),
                child: ListView.builder(
                  itemCount: _bidLogs.length,
                  itemBuilder: (context, idx) {
                    final log = _bidLogs[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(log, style: AppTypography.monoSpec(p.isDark).copyWith(fontSize: 13)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (_auction.status == AuctionStatus.active)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _placePlayerBid(5000),
                      child: const Text('+₺5.000 Teklif', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _placePlayerBid(15000),
                      child: const Text('+₺15.000 Teklif', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
