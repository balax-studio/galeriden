import 'dart:convert';
import 'dart:io' show HttpClient, HttpHeaders;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_model.dart';

/// Service responsible for fetching, parsing, caching, and serving real-time
/// foreign exchange (USD, EUR) and gold (Gram Altin) prices.
class ForexMarketService {
  static const String primaryUrl = 'https://finans.truncgil.com/today.json';
  static const String fallbackOpenErUrl = 'https://open.er-api.com/v6/latest/USD';
  static const String fallbackGoldApiUrl = 'https://api.gold-api.com/price/XAU';

  static const String prefKeyRates = 'cached_real_forex_rates_v1';
  static const String prefKeyTimestamp = 'cached_real_forex_timestamp_v1';
  static const Duration cacheDuration = Duration(minutes: 30);

  /// Helper to parse Turkish or international decimal strings into double.
  /// Handles "6.764,13", "48,5021", "48.5", numbers, nulls, etc.
  static double parseTrNumber(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    final str = val.toString().trim();
    if (str.isEmpty) return 0.0;

    // Replace dots if they act as thousand separators, then replace comma with dot
    String sanitized = str;
    if (sanitized.contains(',') && sanitized.contains('.')) {
      sanitized = sanitized.replaceAll('.', '').replaceAll(',', '.');
    } else if (sanitized.contains(',')) {
      sanitized = sanitized.replaceAll(',', '.');
    }

    return double.tryParse(sanitized) ?? 0.0;
  }

  /// Parses JSON from the primary endpoint (finans.truncgil.com)
  static List<ForexGoldModel> parseTruncgilJson(Map<String, dynamic> json) {
    final List<ForexGoldModel> list = [];

    // USD
    final usdData = json['USD'] as Map<String, dynamic>?;
    final double usdBuy = parseTrNumber(usdData?['Satış'] ?? usdData?['Alış']);
    final double usdSell = parseTrNumber(usdData?['Alış'] ?? usdData?['Satış']);
    final double finalUsdBuy = usdBuy > 0 ? usdBuy : 48.50;
    final double finalUsdSell = usdSell > 0 ? usdSell : (finalUsdBuy * 0.992);

    list.add(ForexGoldModel(
      symbol: 'USD',
      name: 'Amerikan Doları',
      buyRate: (finalUsdBuy * 100).roundToDouble() / 100.0,
      sellRate: (finalUsdSell * 100).roundToDouble() / 100.0,
      previousRate: (finalUsdBuy * 0.998 * 100).roundToDouble() / 100.0,
      rateHistory: [
        finalUsdBuy * 0.995,
        finalUsdBuy * 0.997,
        finalUsdBuy * 0.998,
        finalUsdBuy,
      ],
    ));

    // EUR
    final eurData = json['EUR'] as Map<String, dynamic>?;
    final double eurBuy = parseTrNumber(eurData?['Satış'] ?? eurData?['Alış']);
    final double eurSell = parseTrNumber(eurData?['Alış'] ?? eurData?['Satış']);
    final double finalEurBuy = eurBuy > 0 ? eurBuy : 56.45;
    final double finalEurSell = eurSell > 0 ? eurSell : (finalEurBuy * 0.992);

    list.add(ForexGoldModel(
      symbol: 'EUR',
      name: 'Euro',
      buyRate: (finalEurBuy * 100).roundToDouble() / 100.0,
      sellRate: (finalEurSell * 100).roundToDouble() / 100.0,
      previousRate: (finalEurBuy * 0.998 * 100).roundToDouble() / 100.0,
      rateHistory: [
        finalEurBuy * 0.995,
        finalEurBuy * 0.997,
        finalEurBuy * 0.998,
        finalEurBuy,
      ],
    ));

    // Gram Altin
    final goldData = (json['gram-altin'] ?? json['gram-has-altin']) as Map<String, dynamic>?;
    final double goldBuy = parseTrNumber(goldData?['Satış'] ?? goldData?['Alış']);
    final double goldSell = parseTrNumber(goldData?['Alış'] ?? goldData?['Satış']);
    final double finalGoldBuy = goldBuy > 0 ? goldBuy : 6765.0;
    final double finalGoldSell = goldSell > 0 ? goldSell : (finalGoldBuy * 0.991);

    list.add(ForexGoldModel(
      symbol: 'GOLD',
      name: 'Gram Altın • 24 Ayar',
      buyRate: (finalGoldBuy * 10).roundToDouble() / 10.0,
      sellRate: (finalGoldSell * 10).roundToDouble() / 10.0,
      previousRate: (finalGoldBuy * 0.997 * 10).roundToDouble() / 10.0,
      rateHistory: [
        finalGoldBuy * 0.992,
        finalGoldBuy * 0.995,
        finalGoldBuy * 0.997,
        finalGoldBuy,
      ],
    ));

    return list;
  }

  /// Parses rates from fallback open.er-api + gold-api
  static List<ForexGoldModel> parseFallbackJson({
    required Map<String, dynamic> openErData,
    required double goldUsdPrice,
  }) {
    final rates = openErData['rates'] as Map<String, dynamic>? ?? {};
    final double usdTry = parseTrNumber(rates['TRY']);
    final double usdEur = parseTrNumber(rates['EUR']);
    final double finalUsd = usdTry > 0 ? usdTry : 48.50;
    final double eurTry = usdEur > 0 ? (finalUsd / usdEur) : (finalUsd * 1.16);

    // 1 Troy Ounce = 31.1034768 Grams
    final double goldGramTry = goldUsdPrice > 0
        ? (goldUsdPrice * finalUsd) / 31.1034768
        : 6765.0;

    return [
      ForexGoldModel(
        symbol: 'USD',
        name: 'Amerikan Doları',
        buyRate: (finalUsd * 100).roundToDouble() / 100.0,
        sellRate: (finalUsd * 0.992 * 100).roundToDouble() / 100.0,
        previousRate: (finalUsd * 0.998 * 100).roundToDouble() / 100.0,
        rateHistory: [finalUsd * 0.998, finalUsd],
      ),
      ForexGoldModel(
        symbol: 'EUR',
        name: 'Euro',
        buyRate: (eurTry * 100).roundToDouble() / 100.0,
        sellRate: (eurTry * 0.992 * 100).roundToDouble() / 100.0,
        previousRate: (eurTry * 0.998 * 100).roundToDouble() / 100.0,
        rateHistory: [eurTry * 0.998, eurTry],
      ),
      ForexGoldModel(
        symbol: 'GOLD',
        name: 'Gram Altın • 24 Ayar',
        buyRate: (goldGramTry * 10).roundToDouble() / 10.0,
        sellRate: (goldGramTry * 0.991 * 10).roundToDouble() / 10.0,
        previousRate: (goldGramTry * 0.997 * 10).roundToDouble() / 10.0,
        rateHistory: [goldGramTry * 0.997, goldGramTry],
      ),
    ];
  }

  /// Fetches live rates from network with caching and offline fallback.
  static Future<List<ForexGoldModel>?> fetchLiveForexRates({bool force = false}) async {
    if (kIsWeb) return ForexGoldModel.defaultForex;

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ForexMarketService SharedPreferences init error: $e');
    }

    final lastSyncMs = prefs?.getInt(prefKeyTimestamp) ?? 0;
    final cachedJsonStr = prefs?.getString(prefKeyRates);

    final isExpired = DateTime.now().millisecondsSinceEpoch - lastSyncMs > cacheDuration.inMilliseconds;

    if (!force && !isExpired && cachedJsonStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJsonStr) as List<dynamic>;
        return decoded.map((e) => ForexGoldModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        // Ignore cache parse error, continue to fetch
      }
    }

    try {
      // 1. Try Primary Endpoint
      final primaryRates = await _fetchPrimary();
      if (primaryRates != null && primaryRates.isNotEmpty) {
        if (prefs != null) await _saveToCache(prefs, primaryRates);
        return primaryRates;
      }

      // 2. Try Fallback Endpoints
      final fallbackRates = await _fetchFallback();
      if (fallbackRates != null && fallbackRates.isNotEmpty) {
        if (prefs != null) await _saveToCache(prefs, fallbackRates);
        return fallbackRates;
      }

      // 3. If network fails, return cached if available
      if (cachedJsonStr != null) {
        final List<dynamic> decoded = jsonDecode(cachedJsonStr) as List<dynamic>;
        return decoded.map((e) => ForexGoldModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('ForexMarketService fetch error: $e');
    }

    // 4. Guaranteed offline baseline: defaultForex
    return ForexGoldModel.defaultForex;
  }

  static Future<List<ForexGoldModel>?> _fetchPrimary() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse(primaryUrl));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Mobile; GaleridenTycoon)');

      final response = await request.close().timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
        return parseTruncgilJson(data);
      }
    } catch (e) {
      debugPrint('ForexMarketService primary endpoint failed: $e');
    } finally {
      client?.close(force: true);
    }
    return null;
  }

  static Future<List<ForexGoldModel>?> _fetchFallback() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final openErReq = await client.getUrl(Uri.parse(fallbackOpenErUrl));
      openErReq.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final openErRes = await openErReq.close().timeout(const Duration(seconds: 5));
      if (openErRes.statusCode != 200) return null;

      final openErBody = await openErRes.transform(utf8.decoder).join();
      final Map<String, dynamic> openErData = jsonDecode(openErBody) as Map<String, dynamic>;

      double goldUsdPrice = 0.0;
      try {
        final goldReq = await client.getUrl(Uri.parse(fallbackGoldApiUrl));
        goldReq.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final goldRes = await goldReq.close().timeout(const Duration(seconds: 4));
        if (goldRes.statusCode == 200) {
          final goldBody = await goldRes.transform(utf8.decoder).join();
          final Map<String, dynamic> goldData = jsonDecode(goldBody) as Map<String, dynamic>;
          goldUsdPrice = parseTrNumber(goldData['price']);
        }
      } catch (_) {
        goldUsdPrice = 4330.0; // Realistic recent reference if gold api is down
      }

      return parseFallbackJson(
        openErData: openErData,
        goldUsdPrice: goldUsdPrice > 0 ? goldUsdPrice : 4330.0,
      );
    } catch (e) {
      debugPrint('ForexMarketService fallback endpoint failed: $e');
    } finally {
      client?.close(force: true);
    }
    return null;
  }

  static Future<void> _saveToCache(SharedPreferences prefs, List<ForexGoldModel> rates) async {
    try {
      final jsonStr = jsonEncode(rates.map((e) => e.toJson()).toList());
      await prefs.setString(prefKeyRates, jsonStr);
      await prefs.setInt(prefKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }
}
