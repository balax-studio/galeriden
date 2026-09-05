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

enum RentalFilterMode {
  all,
  rented,
  vacant,
  ineligible,
}

class RealEstateRentalScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const RealEstateRentalScreen({
    super.key,
    this.propertyId,
  });

  @override
  ConsumerState<RealEstateRentalScreen> createState() =>
      _RealEstateRentalScreenState();
}

class _RealEstateRentalScreenState extends ConsumerState<RealEstateRentalScreen> {
  RentalFilterMode _filterMode = RentalFilterMode.all;
  String? _selectedPropertyId;
  int _selectedLeaseDurationYears = 1; // 1 or 2
  final Map<String, List<TenantModel>> _candidatesCache = {};

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.propertyId;
  }

  List<TenantModel> _getCandidatesFor(RealEstateModel prop) {
    if (!_candidatesCache.containsKey(prop.id)) {
      final baseMonthly = (prop.estimatedRealValue *
              prop.category.dailyRentYieldRate *
              30)
          .roundToDouble();
      _candidatesCache[prop.id] = TenantModel.generateCandidates(
        baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 15000.0,
        count: 3,
      );
    }
    return _candidatesCache[prop.id]!;
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
      setState(() {
        _candidatesCache.remove(prop.id);
      });
    }
  }

  void _collectRent(RealEstateModel prop) {
    HapticFeedback.selectionClick();
    final collected = ref.read(gameProvider.notifier).collectRent(prop.id);
    if (collected > 0) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        '${context.tr('rental_btn_collect_rent')} • ${CurrencyFormatter.format(collected)}',
      );
    }
  }

  void _applyTufeIncrease(RealEstateModel prop) {
    HapticFeedback.heavyImpact();
    final ok = ref
        .read(gameProvider.notifier)
        .applyRentIndexIncrease(prop.id, rate: 0.25);
    if (ok) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        '${context.tr('rental_btn_apply_tufe')} • %25',
      );
    }
  }

  void _confirmEviction(RealEstateModel prop) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
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
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final ok = ref.read(gameProvider.notifier).evictTenant(prop.id);
              if (ok) {
                GameSoundHapticService.playWarningVibration();
                NotificationService.showSuccess(
                  context,
                  context.tr('rental_evict_success'),
                );
              }
            },
            child: Text(
              dialogCtx.tr('rental_btn_evict_tenant'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final allOwned = game.ownedRealEstates;

    // Filter properties according to active tab
    final filtered = allOwned.where((p) {
      switch (_filterMode) {
        case RentalFilterMode.all:
          return true;
        case RentalFilterMode.rented:
          return p.isRented;
        case RentalFilterMode.vacant:
          return p.canBeRented && !p.isRented;
        case RentalFilterMode.ineligible:
          return !p.canBeRented && !p.isRented;
      }
    }).toList();

    // Select active property
    RealEstateModel? activeProp;
    if (_selectedPropertyId != null) {
      final match = allOwned.where((p) => p.id == _selectedPropertyId);
      if (match.isNotEmpty) {
        activeProp = match.first;
      }
    }
    if (activeProp == null && filtered.isNotEmpty) {
      activeProp = filtered.first;
    } else if (activeProp == null && allOwned.isNotEmpty) {
      activeProp = allOwned.first;
    }

    return Scaffold(
      appBar: NeoBrutalAppBar(
        title: context.tr('rental_screen_title'),
        subtitle: context.tr('rental_screen_subtitle'),
      ),
      body: SafeArea(
        child: allOwned.isEmpty
            ? _buildEmptyState(theme)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter Tabs
                  _buildFilterBar(theme, allOwned),

                  // Property Selection Strip
                  _buildPropertySelectorStrip(theme, filtered, activeProp),

                  // Main Content for Selected Property
                  Expanded(
                    child: activeProp == null
                        ? _buildNoSelectionState(theme)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Selected Property Overview Header Card
                                _buildPropertyHeaderCard(theme, activeProp),
                                const SizedBox(height: 14),

                                // State-based Body
                                if (activeProp.category == RealEstateCategory.land)
                                  _buildLandIneligibleCard(theme, activeProp)
                                else if (!activeProp.canBeRented && !activeProp.isRented)
                                  _buildOtherIneligibleCard(theme, activeProp)
                                else if (activeProp.isRented)
                                  _buildActiveRentedView(theme, activeProp)
                                else
                                  _buildVacantRentalView(theme, activeProp),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeoBrutalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.real_estate_agent_rounded, size: 48, color: Colors.black54),
              const SizedBox(height: 12),
              Text(
                context.tr('real_estate_portfolio_empty'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('real_estate_tab_portfolio'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSelectionState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeoBrutalCard(
          child: Text(
            context.tr('real_estate_filter_all'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, List<RealEstateModel> allOwned) {
    final rentedCount = allOwned.where((p) => p.isRented).length;
    final vacantCount = allOwned.where((p) => p.canBeRented && !p.isRented).length;
    final ineligibleCount = allOwned.where((p) => !p.canBeRented && !p.isRented).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterTab(
              label: context.tr('rental_filter_all'),
              count: allOwned.length,
              mode: RentalFilterMode.all,
              bgColor: const Color(0xFFFEF08A),
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              label: context.tr('rental_filter_rented'),
              count: rentedCount,
              mode: RentalFilterMode.rented,
              bgColor: const Color(0xFFBBF7D0),
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              label: context.tr('rental_filter_vacant'),
              count: vacantCount,
              mode: RentalFilterMode.vacant,
              bgColor: const Color(0xFFBAE6FD),
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              label: context.tr('rental_filter_ineligible'),
              count: ineligibleCount,
              mode: RentalFilterMode.ineligible,
              bgColor: const Color(0xFFFED7AA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required RentalFilterMode mode,
    required Color bgColor,
  }) {
    final isSelected = _filterMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _filterMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: isSelected
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelectorStrip(
    ThemeData theme,
    List<RealEstateModel> properties,
    RealEstateModel? activeProp,
  ) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 52,
      color: const Color(0xFFF1F5F9),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: properties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prop = properties[index];
          final isSelected = activeProp?.id == prop.id;
          final isLand = prop.category == RealEstateCategory.land;

          Color pillColor = const Color(0xFFDBEAFE);
          if (isLand) {
            pillColor = const Color(0xFFFEF3C7);
          } else if (prop.isRented) {
            pillColor = const Color(0xFFD1FAE5);
          } else if (!prop.canBeRented) {
            pillColor = const Color(0xFFF1F5F9);
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedPropertyId = prop.id;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : pillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      prop.category.icon,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prop.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyHeaderCard(ThemeData theme, RealEstateModel prop) {
    final isLand = prop.category == RealEstateCategory.land;

    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prop.category.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: prop.category.accentColor, width: 2),
                ),
                child: Icon(prop.category.icon, color: prop.category.accentColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prop.city} • ${prop.district}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              NeoBrutalBadge(
                text: '${prop.squareMeters} m²',
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: prop.roomCount,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              if (isLand)
                NeoBrutalBadge(
                  text: context.tr('rental_ineligible_land'),
                  backgroundColor: const Color(0xFFFEF3C7),
                )
              else if (prop.isRented)
                NeoBrutalBadge(
                  text: context.tr('rental_filter_rented'),
                  backgroundColor: const Color(0xFFD1FAE5),
                )
              else if (prop.canBeRented)
                NeoBrutalBadge(
                  text: context.tr('rental_filter_vacant'),
                  backgroundColor: const Color(0xFFDBEAFE),
                )
              else
                NeoBrutalBadge(
                  text: context.tr('rental_filter_ineligible'),
                  backgroundColor: const Color(0xFFFED7AA),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLandIneligibleCard(ThemeData theme, RealEstateModel prop) {
    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD97706), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.terrain_rounded, size: 28, color: Color(0xFFD97706)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('rental_ineligible_land'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('rental_ineligible_land_desc'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // High-Conversion CTA: Start Construction Project on Land
          NeoBrutalButton(
            label: context.tr('rental_action_go_construction'),
            icon: Icons.foundation_rounded,
            backgroundColor: const Color(0xFFF59E0B),
            fullWidth: true,
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.push('/emlak-insaat/${prop.id}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherIneligibleCard(ThemeData theme, RealEstateModel prop) {
    String reasonKey = prop.rentalIneligibilityReasonKey ?? 'rental_filter_ineligible';
    String descKey = prop.rentalIneligibilityDescKey ?? 'rental_ineligible_listed_desc';

    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF4444), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_clock_rounded, size: 26, color: Color(0xFFDC2626)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(reasonKey),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(descKey),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRentedView(ThemeData theme, RealEstateModel prop) {
    final tenant = prop.currentTenant;
    final monthlyRent = tenant?.monthlyRent ?? 0.0;
    final deposit = tenant?.depositAmount ?? 0.0;
    final pendingRent = prop.pendingRentIncome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Active Tenant Dossier Card
        NeoBrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('rental_tenant_header'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  if (tenant != null)
                    NeoBrutalBadge(
                      text: tenant.reliabilityGrade,
                      backgroundColor: _getGradeColor(tenant.reliabilityGrade).withValues(alpha: 0.2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (tenant != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.person_rounded, size: 24, color: Colors.black),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tenant.profession,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Financial Breakdown Row
                _buildInfoRow(
                  context.tr('rental_label_monthly_rent'),
                  CurrencyFormatter.format(monthlyRent),
                  color: const Color(0xFF059669),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  context.tr('rental_label_deposit_held'),
                  CurrencyFormatter.format(deposit),
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  context.tr('rental_label_pending_accumulated'),
                  CurrencyFormatter.format(pendingRent),
                  color: pendingRent > 0 ? const Color(0xFFD97706) : Colors.black54,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Management Actions Card
        NeoBrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('rental_actions_header'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              // Collect Pending Rent Button
              NeoBrutalButton(
                label: context.tr('rental_btn_collect_rent'),
                icon: Icons.payments_rounded,
                backgroundColor: const Color(0xFF10B981),
                fullWidth: true,
                onPressed: pendingRent > 0 ? () => _collectRent(prop) : null,
              ),
              const SizedBox(height: 8),

              // Apply TÜFE Increase Button
              NeoBrutalButton(
                label: context.tr('rental_btn_apply_tufe'),
                icon: Icons.trending_up_rounded,
                backgroundColor: const Color(0xFF60A5FA),
                fullWidth: true,
                onPressed: () => _applyTufeIncrease(prop),
              ),
              const SizedBox(height: 8),

              // Evict Tenant Button
              NeoBrutalButton(
                label: context.tr('rental_btn_evict_tenant'),
                icon: Icons.exit_to_app_rounded,
                backgroundColor: const Color(0xFFEF4444),
                fullWidth: true,
                onPressed: () => _confirmEviction(prop),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVacantRentalView(ThemeData theme, RealEstateModel prop) {
    final baseMonthly = (prop.estimatedRealValue *
            prop.category.dailyRentYieldRate *
            30)
        .roundToDouble();
    final annualYieldRate =
        (prop.category.dailyRentYieldRate * 365 * 100).toStringAsFixed(1);
    final candidates = _getCandidatesFor(prop);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Market Valuation & Yield Card
        NeoBrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, size: 20, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('rental_valuation_header'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                context.tr('rental_est_monthly_rent'),
                CurrencyFormatter.format(baseMonthly),
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                context.tr('rental_est_annual_yield'),
                '%$annualYieldRate',
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Lease Duration Selector
              Text(
                context.tr('rental_contract_type_header'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDurationPill(
                      label: context.tr('rental_lease_duration_1yr'),
                      years: 1,
                      bgColor: const Color(0xFFFEF08A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationPill(
                      label: context.tr('rental_lease_duration_2yr'),
                      years: 2,
                      bgColor: const Color(0xFFBBF7D0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tenant Candidates Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('rental_candidates_header'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            NeoBrutalBadge(
              text: '${candidates.length} Aday',
              backgroundColor: const Color(0xFFDDD6FE),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('rental_candidates_subtitle'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),

        // Candidates List
        ...candidates.map((candidate) => _buildCandidateCard(theme, prop, candidate)),
      ],
    );
  }

  Widget _buildDurationPill({
    required String label,
    required int years,
    required Color bgColor,
  }) {
    final isSelected = _selectedLeaseDurationYears == years;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedLeaseDurationYears = years;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: isSelected
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(
    ThemeData theme,
    RealEstateModel prop,
    TenantModel candidate,
  ) {
    String riskLabel;
    Color riskColor;
    if (candidate.reliabilityScore >= 90) {
      riskLabel = context.tr('rental_risk_score_low');
      riskColor = const Color(0xFF10B981);
    } else if (candidate.reliabilityScore >= 80) {
      riskLabel = context.tr('rental_risk_score_low');
      riskColor = const Color(0xFF3B82F6);
    } else {
      riskLabel = context.tr('rental_risk_score_med');
      riskColor = const Color(0xFFF59E0B);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        candidate.profession,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: candidate.reliabilityGrade,
                  backgroundColor: _getGradeColor(candidate.reliabilityGrade).withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Financials
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context.tr('rental_label_monthly_rent'),
                    CurrencyFormatter.format(candidate.monthlyRent),
                    color: const Color(0xFF059669),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    context.tr('rental_label_deposit_held'),
                    CurrencyFormatter.format(candidate.depositAmount),
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    context.tr('rental_label_risk_status'),
                    riskLabel,
                    color: riskColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Sign Lease Button
            NeoBrutalButton(
              label: context.tr('rental_btn_sign_lease'),
              icon: Icons.drive_file_rename_outline_rounded,
              backgroundColor: const Color(0xFF10B981),
              fullWidth: true,
              onPressed: () => _leaseToCandidate(candidate, prop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
