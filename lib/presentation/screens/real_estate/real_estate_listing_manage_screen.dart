import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../data/models/tenant_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
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
  List<TenantModel>? _candidates;

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

      final baseMonthly = (prop.estimatedRealValue *
              prop.category.dailyRentYieldRate *
              30)
          .roundToDouble();
      _candidates = TenantModel.generateCandidates(
        baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 15000.0,
        count: 3,
      );

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF10B981);
      case 'A':
        return const Color(0xFF3B82F6);
      case 'B':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
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

  void _unlistSaleListing(RealEstateModel prop) {
    HapticFeedback.selectionClick();
    ref.read(gameProvider.notifier).unlistRealEstate(prop.id);
    NotificationService.showInfo(
      context,
      context.tr('real_estate_manage_toast_unlisted'),
    );
    context.pop();
  }

  void _leaseToCandidate(TenantModel candidate, RealEstateModel prop) {
    HapticFeedback.heavyImpact();
    final ok = ref.read(gameProvider.notifier).leaseRealEstateToTenant(
          realEstateId: prop.id,
          tenant: candidate,
        );
    if (ok) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        context.tr('rental_lease_success'),
      );
      context.pop();
    }
  }

  void _confirmEviction(BuildContext ctx, RealEstateModel prop) {
    HapticFeedback.selectionClick();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: Text(
          dialogCtx.tr('rental_evict_confirm_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text(
          dialogCtx.tr('rental_evict_confirm_desc'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              dialogCtx.tr('real_estate_dialog_btn_cancel'),
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final ok =
                  ref.read(gameProvider.notifier).evictTenant(prop.id);
              if (ok) {
                GameSoundHapticService.playCashSuccess();
                NotificationService.showInfo(
                  context,
                  context.tr('rental_evict_success'),
                );
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: Text(
              dialogCtx.tr('rental_btn_evict_tenant'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final prop = game.ownedRealEstates.firstWhere(
      (r) => r.id == widget.propertyId,
    );

    final totalCost =
        prop.currentPurchasePrice + prop.deedFeePaid + prop.commissionPaid;
    final netProfit = _customPrice - totalCost;
    final profitPercent =
        totalCost > 0 ? ((netProfit / totalCost) * 100).round() : 0;

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
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(prop, isDark),
                const SizedBox(height: 14),

                // Maliyet & Piyasa Değeri Kartı
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('real_estate_manage_total_cost'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(totalCost),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('real_estate_manage_estimated_value'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(prop.estimatedRealValue),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // İlan Fiyatı Belirleme Kartı
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
                      const SizedBox(height: 4),
                      Text(
                        context.tr('real_estate_manage_sale_guide',
                            {'val': CurrencyFormatter.format(prop.estimatedRealValue)}),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
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

                      // Hızlı Fiyat Şablonları
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickPriceButton(
                              label: '%5 Hızlı Satış',
                              onTap: () {
                                setState(() {
                                  _customPrice =
                                      prop.estimatedRealValue * 0.95;
                                  _priceController.text =
                                      _customPrice.round().toString();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
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
                                  _customPrice =
                                      prop.estimatedRealValue * 1.10;
                                  _priceController.text =
                                      _customPrice.round().toString();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickPriceButton(
                              label: context.tr('real_estate_manage_quick_luxury'),
                              onTap: () {
                                setState(() {
                                  _customPrice =
                                      prop.estimatedRealValue * 1.20;
                                  _priceController.text =
                                      _customPrice.round().toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),

                      // Canlı Kar Marjı Göstergesi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('real_estate_manage_est_profit'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: netProfit >= 0
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: netProfit >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              '${netProfit >= 0 ? '+' : ''}${CurrencyFormatter.format(netProfit)} • %$profitPercent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: netProfit >= 0
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Showroom Entegrasyon Bilgilendirme Rozeti
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded,
                          color: Color(0xFF2563EB), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('real_estate_manage_showroom_info'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                NeoBrutalButton(
                  text: prop.isListed
                      ? context.tr('real_estate_manage_btn_update')
                      : context.tr('real_estate_manage_btn_list'),
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                  onPressed: () => _publishSaleListing(prop),
                ),
                if (prop.isListed) ...[
                  const SizedBox(height: 10),
                  NeoBrutalButton(
                    text: context.tr('real_estate_manage_btn_unlist'),
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    onPressed: () => _unlistSaleListing(prop),
                  ),
                ],
              ],
            ),
          ),

          // 2. KİRAYA VER SEKMESİ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(prop, isDark),
                const SizedBox(height: 14),

                // Rayiç & Getiri Özeti
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('rental_monthly_rent'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(prop.dailyRentIncome * 30),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('rental_daily_rent'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(prop.dailyRentIncome),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Eğer kirada ise: Aktif Kiracı Kartı
                if (prop.isRented && prop.currentTenant != null) ...[
                  Text(
                    context.tr('rental_active_tenant_header'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  _getGradeColor(prop.currentTenant!.reliabilityGrade)
                                      .withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person_rounded,
                                color: _getGradeColor(
                                    prop.currentTenant!.reliabilityGrade),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prop.currentTenant!.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    prop.currentTenant!.profession,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            NeoBrutalBadge(
                              text: prop.currentTenant!.reliabilityGrade,
                              color: _getGradeColor(
                                  prop.currentTenant!.reliabilityGrade),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aylık Kira: ${CurrencyFormatter.format(prop.currentTenant!.monthlyRent)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Depozito: ${CurrencyFormatter.format(prop.currentTenant!.depositAmount)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalButton(
                    text: context.tr('rental_btn_evict_tenant'),
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    onPressed: () => _confirmEviction(context, prop),
                  ),
                ],

                // Eğer kirada değilse: Kiralık İlanı Aç / Kiracı Seç
                if (!prop.isRented) ...[
                  NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prop.isRentalListed
                                  ? context.tr('rental_status_listed')
                                  : context.tr('rental_status_not_listed'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            NeoBrutalBadge(
                              text: prop.isRentalListed ? 'İlanda' : 'Boş',
                              color: prop.isRentalListed
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prop.isRentalListed
                              ? 'Kiralık ilanı aktif. Teklifler Showroom sekmesine düşecektir.'
                              : 'Kiralık ilanını açarak teklif toplayabilir ya da aşağıdaki adaylardan birini hemen kiralayabilirsiniz.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeoBrutalButton(
                          text: prop.isRentalListed
                              ? context.tr('rental_btn_unlist_rent')
                              : context.tr('rental_btn_list_rent'),
                          backgroundColor: prop.isRentalListed
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF2563EB),
                          textColor: Colors.white,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            if (prop.isRentalListed) {
                              ref
                                  .read(gameProvider.notifier)
                                  .unlistRealEstateFromRent(prop.id);
                              NotificationService.showInfo(
                                context,
                                'Kiralık ilanı kaldırıldı.',
                              );
                            } else {
                              ref
                                  .read(gameProvider.notifier)
                                  .listRealEstateForRent(prop.id);
                              NotificationService.showSuccess(
                                context,
                                'Kiralık ilanı vitrine koyuldu • Teklifler Showroom sekmesine gelecektir.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    context.tr('rental_quick_candidates_title'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_candidates != null)
                    ..._candidates!.map(
                      (cand) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        _getGradeColor(cand.reliabilityGrade)
                                            .withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color:
                                          _getGradeColor(cand.reliabilityGrade),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cand.name,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          cand.profession,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  NeoBrutalBadge(
                                    text: cand.reliabilityGrade,
                                    color:
                                        _getGradeColor(cand.reliabilityGrade),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kira: ${CurrencyFormatter.format(cand.monthlyRent)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  Text(
                                    'Depozito: ${CurrencyFormatter.format(cand.depositAmount)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Risk: %${cand.evictionRiskScore}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: cand.evictionRiskScore > 15
                                          ? const Color(0xFFEF4444)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              NeoBrutalButton(
                                text: context.tr('rental_btn_lease_now'),
                                backgroundColor: const Color(0xFF10B981),
                                textColor: Colors.white,
                                onPressed: () =>
                                    _leaseToCandidate(cand, prop),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
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
