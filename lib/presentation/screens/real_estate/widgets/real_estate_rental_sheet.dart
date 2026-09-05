import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/real_estate_category.dart';
import '../../../../data/models/real_estate_model.dart';
import '../../../../data/models/tenant_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class RealEstateRentalSheet extends ConsumerStatefulWidget {
  final RealEstateModel property;

  const RealEstateRentalSheet({
    super.key,
    required this.property,
  });

  static Future<void> show({
    required BuildContext context,
    required RealEstateModel property,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RealEstateRentalSheet(property: property),
    );
  }

  @override
  ConsumerState<RealEstateRentalSheet> createState() =>
      _RealEstateRentalSheetState();
}

class _RealEstateRentalSheetState extends ConsumerState<RealEstateRentalSheet> {
  late List<TenantModel> _candidates;
  bool _candidatesGenerated = false;

  @override
  void initState() {
    super.initState();
    _initCandidates();
  }

  void _initCandidates() {
    final baseMonthly = (widget.property.estimatedRealValue *
            widget.property.category.dailyRentYieldRate *
            30)
        .roundToDouble();
    _candidates = TenantModel.generateCandidates(
      baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 15000.0,
      count: 3,
    );
    _candidatesGenerated = true;
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

    final currentProp = game.ownedRealEstates.firstWhere(
      (p) => p.id == widget.property.id,
      orElse: () => widget.property,
    );

    final tenant = currentProp.currentTenant;
    final estimatedMonthly =
        (currentProp.estimatedRealValue * currentProp.category.dailyRentYieldRate * 30)
            .roundToDouble();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('rental_portal_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentProp.title} • ${currentProp.city} - ${currentProp.district}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: context.tr('real_estate_dialog_btn_cancel'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable body
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Rayiç ve Getiri Özeti
                NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('rental_monthly_rent'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(
                                currentProp.isRented && tenant != null
                                    ? tenant.monthlyRent
                                    : estimatedMonthly,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1.5,
                        color: Colors.black26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('rental_daily_rent'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(
                                currentProp.dailyRentIncome,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. KİRADA İSE: Aktif Kiracı Kartı
                if (currentProp.isRented && tenant != null) ...[
                  Text(
                    context.tr('rental_active_tenant_header'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getGradeColor(tenant.reliabilityGrade)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getGradeColor(tenant.reliabilityGrade),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: _getGradeColor(tenant.reliabilityGrade),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tenant.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    tenant.profession,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getGradeColor(tenant.reliabilityGrade),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                '${context.tr('rental_tenant_grade')} • ${tenant.reliabilityGrade}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatColumn(
                              label: context.tr('rental_tenant_rent'),
                              value: CurrencyFormatter.format(tenant.monthlyRent),
                              isDark: isDark,
                            ),
                            _buildStatColumn(
                              label: context.tr('rental_tenant_deposit'),
                              value:
                                  CurrencyFormatter.format(tenant.depositAmount),
                              isDark: isDark,
                            ),
                            _buildStatColumn(
                              label: context.tr('rental_tenant_risk'),
                              value: '%${tenant.evictionRiskScore}',
                              isDark: isDark,
                              valueColor: tenant.evictionRiskScore > 15
                                  ? const Color(0xFFEF4444)
                                  : null,
                            ),
                          ],
                        ),
                        if (tenant.unpaidRentDays > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFEF4444), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFDC2626), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${context.tr('rental_unpaid_warning')} • ${tenant.unpaidRentDays} ${context.tr('day')}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Birikmiş kira varsa tahsil et butonu
                  if (currentProp.pendingRentIncome > 0) ...[
                    NeoBrutalButton(
                      text:
                          '${context.tr('rental_btn_collect_rent')} • ${CurrencyFormatter.format(currentProp.pendingRentIncome)}',
                      backgroundColor: const Color(0xFF10B981),
                      textColor: Colors.white,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        final collected = ref
                            .read(gameProvider.notifier)
                            .collectRent(currentProp.id);
                        if (collected > 0) {
                          GameSoundHapticService.playCashSuccess();
                          NotificationService.showSuccess(
                            context,
                            '₺${collected.round()} kira geliri tahsil edildi.',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Kiracıyı tahliye et butonu
                  NeoBrutalButton(
                    text: context.tr('rental_btn_evict_tenant'),
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    onPressed: () => _confirmEviction(context, currentProp),
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. KİRADA DEĞİLSE: İlan Açma / Kapatma & Doğrudan Kiracı Adayları
                if (!currentProp.isRented) ...[
                  // Vitrin İlan Durumu Kartı
                  NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentProp.isRentalListed
                                  ? context.tr('rental_status_listed')
                                  : context.tr('rental_status_not_listed'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            NeoBrutalBadge(
                              text: currentProp.isRentalListed
                                  ? context.tr('real_estate_badge_for_sale')
                                  : context.tr('badge_awaiting_offers'),
                              color: currentProp.isRentalListed
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentProp.isRentalListed
                              ? 'İlanınız kiralık vitrininde aktif. Gelen teklifler Showroom üzerinden değerlendirilebilir.'
                              : 'İlan açarak piyasadan teklif toplayabilir veya aşağıdaki adayları doğrudan kiralayabilirsiniz.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        NeoBrutalButton(
                          text: currentProp.isRentalListed
                              ? context.tr('rental_btn_unlist_rent')
                              : context.tr('rental_btn_list_rent'),
                          backgroundColor: currentProp.isRentalListed
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF2563EB),
                          textColor: Colors.white,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            if (currentProp.isRentalListed) {
                              ref
                                  .read(gameProvider.notifier)
                                  .unlistRealEstateFromRent(currentProp.id);
                              NotificationService.showInfo(
                                context,
                                'Kiralık ilanı yayından kaldırıldı.',
                              );
                            } else {
                              ref
                                  .read(gameProvider.notifier)
                                  .listRealEstateForRent(currentProp.id);
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

                  // Doğrudan Kiracı Adayları Başlığı
                  Text(
                    context.tr('rental_quick_candidates_title'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('rental_quick_candidates_desc'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Aday Kartları
                  if (_candidatesGenerated)
                    ..._candidates.map(
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
                                    radius: 16,
                                    backgroundColor:
                                        _getGradeColor(cand.reliabilityGrade)
                                            .withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color:
                                          _getGradeColor(cand.reliabilityGrade),
                                      size: 18,
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
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          cand.profession,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark
                                                ? Colors.white70
                                                : const Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          _getGradeColor(cand.reliabilityGrade),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: Colors.black, width: 1.2),
                                    ),
                                    child: Text(
                                      cand.reliabilityGrade,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('rental_tenant_rent'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                            cand.monthlyRent),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('rental_tenant_deposit'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                            cand.depositAmount),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('rental_tenant_risk'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '%${cand.evictionRiskScore}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: cand.evictionRiskScore > 15
                                              ? const Color(0xFFEF4444)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              NeoBrutalButton(
                                text: context.tr('rental_btn_lease_now'),
                                backgroundColor: const Color(0xFF10B981),
                                textColor: Colors.white,
                                onPressed: () =>
                                    _leaseToCandidate(cand, currentProp),
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

  Widget _buildStatColumn({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: valueColor ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
