import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class RealEstateListingManageScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const RealEstateListingManageScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<RealEstateListingManageScreen> createState() =>
      _RealEstateListingManageScreenState();
}

class _RealEstateListingManageScreenState
    extends ConsumerState<RealEstateListingManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _priceController;
  bool _isInitialized = false;
  double _customPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final game = ref.read(gameProvider);
      final prop = game.ownedRealEstates.firstWhere(
        (r) => r.id == widget.propertyId,
      );
      _customPrice = prop.customListingPrice ?? prop.estimatedRealValue;
      _priceController =
          TextEditingController(text: _customPrice.round().toString());
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _publishSaleListing(RealEstateModel prop) {
    HapticFeedback.heavyImpact();
    ref
        .read(gameProvider.notifier)
        .listRealEstateForSale(prop.id, _customPrice);
    GameSoundHapticService.playCashSuccess();
    NotificationService.showSuccess(
      context,
      context.tr('real_estate_manage_toast_listed'),
    );
    context.pop();
  }

  void _publishRentListing(RealEstateModel prop) {
    HapticFeedback.heavyImpact();
    ref.read(gameProvider.notifier).toggleRealEstateRent(prop.id);
    GameSoundHapticService.playCashSuccess();
    NotificationService.showSuccess(
      context,
      prop.isRented
          ? context.tr('real_estate_manage_toast_evicted')
          : context.tr('real_estate_manage_toast_rented'),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final prop = game.ownedRealEstates.firstWhere(
      (r) => r.id == widget.propertyId,
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: context.tr('real_estate_manage_app_title'),
        onLeadingPressed: () => context.pop(),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: [
            Tab(text: context.tr('real_estate_manage_tab_sell')),
            Tab(text: context.tr('real_estate_manage_tab_rent')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. SATIŞA ÇIKAR SEKMESİ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(prop, isDark),
                const SizedBox(height: 16),
                NeoBrutalCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('real_estate_manage_sale_header'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('real_estate_manage_sale_guide',
                            {'val': CurrencyFormatter.format(prop.estimatedRealValue)}),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('real_estate_manage_input_label'),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          setState(() {
                            _customPrice = parsed;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQuickPriceButton(
                            label: context.tr('real_estate_manage_quick_market'),
                            onTap: () {
                              setState(() {
                                _customPrice = prop.estimatedRealValue;
                                _priceController.text =
                                    _customPrice.round().toString();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickPriceButton(
                            label: context.tr('real_estate_manage_quick_premium'),
                            onTap: () {
                              setState(() {
                                _customPrice = prop.estimatedRealValue * 1.10;
                                _priceController.text =
                                    _customPrice.round().toString();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickPriceButton(
                            label: context.tr('real_estate_manage_quick_discount'),
                            onTap: () {
                              setState(() {
                                _customPrice = prop.estimatedRealValue * 0.95;
                                _priceController.text =
                                    _customPrice.round().toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                NeoBrutalButton(
                  text: prop.isListed
                      ? context.tr('real_estate_manage_btn_update')
                      : context.tr('real_estate_manage_btn_list'),
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                  onPressed: () => _publishSaleListing(prop),
                ),
              ],
            ),
          ),

          // 2. KİRAYA VER SEKMESİ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(prop, isDark),
                const SizedBox(height: 16),
                NeoBrutalCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('real_estate_manage_rent_header'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('real_estate_manage_rent_daily'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            CurrencyFormatter.format(prop.dailyRentIncome),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('real_estate_manage_rent_monthly'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            CurrencyFormatter.format(prop.dailyRentIncome * 30),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        context.tr('real_estate_manage_rent_desc'),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                NeoBrutalButton(
                  text: prop.isRented
                      ? context.tr('real_estate_manage_btn_evict')
                      : context.tr('real_estate_manage_btn_rent'),
                  backgroundColor: prop.isRented
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF2563EB),
                  textColor: Colors.white,
                  onPressed: () => _publishRentListing(prop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader(RealEstateModel prop, bool isDark) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_work_rounded,
                color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  '${prop.city} • ${prop.district} • ${prop.squareMeters} m² • ${prop.roomCount}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPriceButton(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8)),
        ),
      ),
    );
  }
}
