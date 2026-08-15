import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/expertise_model.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';

/// Mobile (Android / iOS) implementation of Three.js 3D City World via hardware-accelerated WebView.
class ThreeJsCityView extends ConsumerStatefulWidget {
  const ThreeJsCityView({super.key});

  @override
  ConsumerState<ThreeJsCityView> createState() => _ThreeJsCityViewState();
}

class _ThreeJsCityViewState extends ConsumerState<ThreeJsCityView> {
  late final WebViewController _controller;
  bool _isPageLoaded = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJsMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isPageLoaded = true;
            });
            _syncStateToThreeJs();
          },
        ),
      )
      ..loadFlutterAsset('assets/infinitown/index.html');
  }

  void _handleJsMessage(String raw) {
    if (!mounted) return;
    try {
      dynamic data = jsonDecode(raw);
      if (data is Map) {
        final type = data['type'];
        if (type == 'BUILDING_CLICK') {
          final route = data['route'] as String?;
          if (route == null || route.isEmpty) return;

          final game = ref.read(gameProvider);
          final isUnlocked = game.isBuildingUnlocked(route) || route == '/showroom';

          if (isUnlocked) {
            context.push(route);
          } else {
            _showUnlockModal(data);
          }
        }
      }
    } catch (_) {}
  }

  void _showUnlockModal(Map data) {
    final route = data['route'] as String? ?? '';
    final name = data['name'] as String? ?? 'İşletme';
    final shortName = data['shortName'] as String? ?? name;
    final subtitle = data['subtitle'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final emoji = data['emoji'] as String? ?? '🏢';
    final requiredLevel = (data['requiredLevel'] as num?)?.toInt() ?? 1;
    final unlockCost = (data['unlockCost'] as num?)?.toDouble() ?? 0.0;

    final p = ref.read(themeProvider).activePalette;
    final game = ref.read(gameProvider);
    final canAfford = game.balance >= unlockCost;
    final hasLevel = game.level >= requiredLevel;
    final canUnlock = canAfford && hasLevel;

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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: p.surfaceBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: AppTypography.titleLarge(p.isDark).copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'KİLİTLİ',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.surfaceBorderColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  description,
                  style: AppTypography.bodyMedium(p.isDark),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: p.surfaceBorderColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasLevel ? Icons.check_circle_rounded : Icons.lock_rounded,
                            size: 16,
                            color: hasLevel ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text('Gerekli Seviye:', style: AppTypography.bodyMedium(p.isDark)),
                        ],
                      ),
                      Text(
                        'Seviye $requiredLevel (Sen: Lv.${game.level})',
                        style: AppTypography.bodyMedium(p.isDark).copyWith(
                          fontWeight: FontWeight.w900,
                          color: hasLevel ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            canAfford ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 16,
                            color: canAfford ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text('Kilit Açma Bedeli:', style: AppTypography.bodyMedium(p.isDark)),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(unlockCost),
                        style: AppTypography.bodyMedium(p.isDark).copyWith(
                          fontWeight: FontWeight.w900,
                          color: canAfford ? p.primaryColor : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canUnlock ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: canUnlock
                    ? () {
                        Navigator.pop(ctx);
                        ref.read(gameProvider.notifier).unlockBuilding(route, unlockCost);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 $shortName kilidi başarıyla açıldı!'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    : null,
                icon: Icon(canUnlock ? Icons.lock_open_rounded : Icons.lock_outline_rounded),
                label: Text(
                  !hasLevel
                      ? 'Seviye $requiredLevel Gerekli'
                      : !canAfford
                          ? 'Yetersiz Bakiye (${CurrencyFormatter.formatShort(unlockCost)})'
                          : '${CurrencyFormatter.formatShort(unlockCost)} ile Kilidi Aç',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncStateToThreeJs() {
    if (!_isPageLoaded) return;
    final game = ref.read(gameProvider);

    final int damagedCars = game.ownedCars.where((c) =>
      c.expertise.bodyParts.values.any((s) => s == PartStatus.damaged) ||
      c.expertise.engineCondition < 80
    ).length;
    final int incomingOffersCount = game.incomingOffers.length;
    final int activeRentalsCount = game.activeRentals.length;
    final int scrapCount = game.scrapyardCars.length;
    final int blackMarketCount = game.blackMarketCars.length;

    final badges = <String, String?>{
      '/workshop': damagedCars > 0 ? '$damagedCars Hasarlı Araç' : null,
      '/marketplace': incomingOffersCount > 0 ? '$incomingOffersCount Yeni Teklif' : null,
      '/rent-a-car': activeRentalsCount > 0 ? '$activeRentalsCount Araç Kirada' : null,
      '/scrapyard': scrapCount > 0 ? '$scrapCount Hurda Araç' : null,
      '/black-market': blackMarketCount > 0 ? '$blackMarketCount Gizli Araç' : null,
    };

    final payload = {
      'type': 'UPDATE_CITY_STATE',
      'hour': game.inGameTime.hour,
      'playerLevel': game.level,
      'playerBalance': game.balance,
      'unlockedBuildings': game.unlockedBuildings.toList(),
      'badges': badges,
    };

    try {
      _controller.runJavaScript("window.updateCityFromFlutter(${jsonEncode(payload)});");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncStateToThreeJs();
    });

    return WebViewWidget(controller: _controller);
  }
}
