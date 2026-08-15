import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the active bottom navigation tab in the DashboardScreen
/// 0: Ana Sayfa
/// 1: Galeri (Showroom)
/// 2: İhale (Auction)
/// 3: Ofis (Office)
final dashboardTabProvider = StateProvider<int>((ref) => 0);
