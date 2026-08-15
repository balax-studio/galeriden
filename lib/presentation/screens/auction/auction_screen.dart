import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/auction_model.dart';
import '../../../domain/usecases/auction_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  const AuctionScreen({super.key});

  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen> with SingleTickerProviderStateMixin {
  late AuctionModel _auction;
  Timer? _timer;
  bool _hasPlayerEnteredBid = false;
  final List<String> _bidLogs = [];
  late AnimationController _pulseController;
  int _closedCountdown = 0;
  bool _isWindowOpen = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _isWindowOpen = AuctionEngine.isAuctionActiveNow();
    _closedCountdown = AuctionEngine.getSecondsUntilNextAuction();

    final game = ref.read(gameProvider);
    _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
    _bidLogs.add('🏛️ Gümrük ve Tasfiye İhale Seansı Başladı!');
    _bidLogs.add('🏷️ Açılış Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
    _startAuctionTimer();
  }

  void _startAuctionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      // Check window active state
      final windowNow = AuctionEngine.isAuctionActiveNow();
      if (windowNow != _isWindowOpen) {
        setState(() {
          _isWindowOpen = windowNow;
        });
      }

      if (!_isWindowOpen) {
        setState(() {
          _closedCountdown = AuctionEngine.getSecondsUntilNextAuction();
        });
        return;
      }

      if (_auction.secondsRemaining <= 1) {
        setState(() {
          _auction = _auction.copyWith(secondsRemaining: 0, status: AuctionStatus.ended);
        });
        _handleAuctionEnd();
        return;
      }

      setState(() {
        _auction = _auction.copyWith(secondsRemaining: _auction.secondsRemaining - 1);
      });

      // Process rival bot bid
      final updated = AuctionEngine.processRivalBid(_auction);
      if (updated != null) {
        setState(() {
          _auction = updated;
          _bidLogs.insert(0, '⚡ ${updated.highestBidderName} teklif yükseltti: ${CurrencyFormatter.formatShort(updated.currentBid)}');
        });
      }
    });
  }

  void _placePlayerBid(double increment) {
    final game = ref.read(gameProvider);
    final nextBid = _auction.currentBid + increment;

    if (game.balance < nextBid) {
      NotificationService.showError(context, 'Yetersiz Bakiye! Bu teklifi veremezsin.');
      return;
    }

    setState(() {
      _hasPlayerEnteredBid = true;
      _auction = _auction.copyWith(
        currentBid: nextBid,
        highestBidderName: '${game.dealershipName} (Sen)',
        isPlayerHighestBidder: true,
        secondsRemaining: (_auction.secondsRemaining < 6) ? 7 : _auction.secondsRemaining,
      );
      _bidLogs.insert(0, '🔥 SENİN TEKLİFİN: ${CurrencyFormatter.formatShort(nextBid)}');
    });
  }

  void _resetAuctionSilently() {
    _timer?.cancel();
    if (!mounted) return;
    final game = ref.read(gameProvider);
    setState(() {
      _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
      _bidLogs.clear();
      _bidLogs.add('🏛️ Yeni Araç İhale Masasında!');
      _bidLogs.add('🏷️ Başlangıç Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
      _hasPlayerEnteredBid = false;
    });
    _startAuctionTimer();
  }

  void _handleAuctionEnd() {
    if (!_hasPlayerEnteredBid && !_auction.isPlayerHighestBidder) {
      setState(() {
        _bidLogs.insert(0, '❌ İhale sona erdi (${_auction.highestBidderName} kazandı).');
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _resetAuctionSilently();
      });
      return;
    }

    if (_auction.isPlayerHighestBidder) {
      ref.read(gameProvider.notifier).buyCarDirectly(_auction.car, _auction.currentBid);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalGreen,
              borderWidth: 2.5,
              borderRadius: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brutalGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'İHALEYİ KAZANDIN!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_auction.car.modelYear} ${_auction.car.brand} ${_auction.car.modelName} aracını ${CurrencyFormatter.formatShort(_auction.currentBid)} kelepir fiyata galerine ekledin!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalBadge(
                    text: 'Piyasa Değeri: ${CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}',
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  NeoBrutalButton(
                    label: 'ARACI SHOWROOM\'A AL',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _resetAuctionSilently();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.errorRed,
              borderWidth: 2.5,
              borderRadius: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'İHALE KAÇIRILDI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İhaleyi ${_auction.highestBidderName} ${CurrencyFormatter.formatShort(_auction.currentBid)} teklifle kazandı.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: 'SONRAKİ İHALEYE BAK',
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _resetAuctionSilently();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final car = _auction.car;
    final isLastSeconds = _auction.secondsRemaining <= 4 && _auction.secondsRemaining > 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CANLI GÜMRÜK İHALESİ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: _isWindowOpen ? 'CANLI YAYIN' : 'KAPALI',
                backgroundColor: _isWindowOpen ? AppColors.errorRed : const Color(0xFF64748B),
                textColor: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      body: !_isWindowOpen
          ? _buildClosedWindowView(isDark)
          : ListView(
              padding: const EdgeInsets.all(14),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. FOMO Timer Card
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isLastSeconds
                      ? AppColors.errorRed.withValues(alpha: 0.2)
                      : (isDark ? const Color(0xFF141721) : Colors.white),
                  borderColor: isLastSeconds ? AppColors.errorRed : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                  borderRadius: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isLastSeconds ? AppColors.errorRed : AppColors.brutalYellow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.4),
                            ),
                            child: Icon(
                              Icons.timer_rounded,
                              color: isLastSeconds ? Colors.white : Colors.black,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KALAN SÜRE: ${_auction.secondsRemaining} SN',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isLastSeconds
                                      ? AppColors.errorRed
                                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                ),
                              ),
                              Text(
                                isLastSeconds ? '⚡ SON ŞANS! TEKLİF VER' : 'Süre bitince en yüksek teklif kazanır',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isLastSeconds
                                      ? AppColors.errorRed
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isLastSeconds)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.15),
                              child: const NeoBrutalBadge(
                                text: 'SON ŞANS!',
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Monolithic Car Detail Card
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 14,
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
                                Text(
                                  '${car.brand} ${car.modelName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${car.modelYear} • ${car.expertise.mileage} KM • ${car.bodyType}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeoBrutalBadge(
                            text: 'Piyasa: ${CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}',
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'GÜNCEL LİDER TEKLİF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatShort(_auction.currentBid),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brutalGreen,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'TEKLİF SAHİBİ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                NeoBrutalBadge(
                                  text: _auction.highestBidderName,
                                  backgroundColor: _auction.isPlayerHighestBidder
                                      ? AppColors.brutalGreen
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  textColor: _auction.isPlayerHighestBidder
                                      ? Colors.black
                                      : (isDark ? Colors.white : Colors.black),
                                  fontSize: 10.5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Quick Bid Buttons
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HIZLI TEKLİF VER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: NeoBrutalButton(
                              label: '+₺5.000',
                              backgroundColor: AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () => _placePlayerBid(5000),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeoBrutalButton(
                              label: '+₺15.000',
                              backgroundColor: AppColors.brutalOrange,
                              textColor: Colors.black,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () => _placePlayerBid(15000),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeoBrutalButton(
                              label: '+₺30.000',
                              backgroundColor: AppColors.brutalGreen,
                              textColor: Colors.black,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () => _placePlayerBid(30000),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Competitors / Rivals
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SALONDAKİ RAKİP ALICILAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._auction.rivals.map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      r.isFolded ? Icons.close_rounded : Icons.person_rounded,
                                      size: 14,
                                      color: r.isFolded ? Colors.red : Colors.blue,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      r.name,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: r.isFolded ? Colors.grey : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                NeoBrutalBadge(
                                  text: r.isFolded ? 'Çekildi' : r.personality,
                                  backgroundColor: r.isFolded
                                      ? Colors.grey.shade400
                                      : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                                  textColor: Colors.black,
                                  fontSize: 9.5,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Live Bidding Logs
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İHALE CANLI AKIŞI',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._bidLogs.take(5).map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.5),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: log.contains('SEN')
                                    ? AppColors.brutalGreen
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildClosedWindowView(bool isDark) {
    final minutes = _closedCountdown ~/ 60;
    final seconds = _closedCountdown % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(24),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.brutalOrange,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.access_time_filled_rounded, color: Colors.black, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'İHALE SALONU ŞU AN KAPALI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gümrük ve icra araç ihaleleri belirli periyotlarla açılmaktadır.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              NeoBrutalBadge(
                text: 'Sonraki Seans: $timeStr',
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: 'GÖREVLİYE SOR & BEKLE',
                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                onPressed: () {
                  NotificationService.showInfo(context, 'Sonraki ihale $timeStr sonra başlayacak!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
