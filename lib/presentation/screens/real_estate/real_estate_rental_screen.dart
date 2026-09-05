import 'dart:async';
import 'dart:math';
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
  int _selectedLeaseDurationYears = 1;
  final Map<String, List<TenantModel>> _candidatesCache = {};
  Timer? _inspectionTimer;

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.propertyId;
    _startInspectionTimer();
  }

  @override
  void dispose() {
    _inspectionTimer?.cancel();
    super.dispose();
  }

  void _startInspectionTimer() {
    _inspectionTimer?.cancel();
    _inspectionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      bool stateChanged = false;

      for (final list in _candidatesCache.values) {
        for (int i = 0; i < list.length; i++) {
          final c = list[i];
          if (c.evaluationStatus == TenantEvaluationStatus.evaluating) {
            if (c.inspectionRemainingSeconds > 1) {
              list[i] = c.copyWith(
                inspectionRemainingSeconds: c.inspectionRemainingSeconds - 1,
              );
              stateChanged = true;
            } else {
              final random = Random();
              final isAccepted = random.nextDouble() < 0.65;
              list[i] = c.copyWith(
                inspectionRemainingSeconds: 0,
                evaluationStatus: isAccepted
                    ? TenantEvaluationStatus.accepted
                    : (random.nextBool()
                        ? TenantEvaluationStatus.counterOffer
                        : TenantEvaluationStatus.rejected),
                evaluationThought: isAccepted
                    ? 'İncelemeyi tamamladım • Mülkün durumu çok iyi ve şartlar uygun, anlaşabiliriz.'
                    : 'İnceleme sonrası kira bedelini yüksek buldum • Fiyatta pazarlık edilmeli.',
              );
              stateChanged = true;
            }
          }
        }
      }

      if (mounted && stateChanged) {
        setState(() {});
      }
    });
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
        buildingAge: prop.buildingAge,
        propertyTitle: prop.title,
      );
    }
    return _candidatesCache[prop.id]!;
  }

  void _instantInspectCandidate(TenantModel candidate, RealEstateModel prop) {
    HapticFeedback.selectionClick();
    final list = _candidatesCache[prop.id];
    if (list != null) {
      final index = list.indexWhere((c) => c.id == candidate.id);
      if (index != -1) {
        final random = Random();
        final isAccepted = random.nextDouble() < 0.65;
        list[index] = candidate.copyWith(
          inspectionRemainingSeconds: 0,
          evaluationStatus: isAccepted
              ? TenantEvaluationStatus.accepted
              : (random.nextBool()
                  ? TenantEvaluationStatus.counterOffer
                  : TenantEvaluationStatus.rejected),
          evaluationThought: isAccepted
              ? 'Hızlı inceleme tamamlandı • Mülkün durumu çok iyi ve şartlar uygun, anlaşabiliriz.'
              : 'Hızlı inceleme tamamlandı • Kira ve depozito şartları için pazarlık masasına oturmalıyız.',
        );
        setState(() {});
      }
    }
  }

  void _dismissCandidate(TenantModel candidate, RealEstateModel prop) {
    HapticFeedback.selectionClick();
    final list = _candidatesCache[prop.id];
    if (list != null) {
      final baseMonthly = (prop.estimatedRealValue *
              prop.category.dailyRentYieldRate *
              30)
          .roundToDouble();
      final newCandidates = TenantModel.generateCandidates(
        baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 15000.0,
        count: 1,
        buildingAge: prop.buildingAge,
        propertyTitle: prop.title,
      );
      final index = list.indexWhere((c) => c.id == candidate.id);
      if (index != -1 && newCandidates.isNotEmpty) {
        list[index] = newCandidates.first;
      }
      setState(() {});
    }
  }

  void _openNegotiationChat(TenantModel candidate, RealEstateModel prop) async {
    HapticFeedback.selectionClick();
    final result = await context.push<bool>(
      '/emlak-kiraci-pazarlik/${prop.id}/${candidate.id}',
      extra: candidate,
    );
    if (result == true && mounted) {
      setState(() {
        _candidatesCache.remove(prop.id);
      });
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
        onLeadingPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: allOwned.isEmpty
            ? _buildEmptyState(theme)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterBar(theme, allOwned),
                  _buildPropertySelectorStrip(theme, filtered, activeProp),
                  Expanded(
                    child: activeProp == null
                        ? _buildNoSelectionState(theme)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildPropertyHeaderCard(theme, activeProp),
                                const SizedBox(height: 14),
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
            context.tr('rental_filter_all'),
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
            _buildFilterTab(label: context.tr('rental_filter_all'), count: allOwned.length, mode: RentalFilterMode.all, bgColor: const Color(0xFFFEF08A)),
            const SizedBox(width: 8),
            _buildFilterTab(label: context.tr('rental_filter_rented'), count: rentedCount, mode: RentalFilterMode.rented, bgColor: const Color(0xFFBBF7D0)),
            const SizedBox(width: 8),
            _buildFilterTab(label: context.tr('rental_filter_vacant'), count: vacantCount, mode: RentalFilterMode.vacant, bgColor: const Color(0xFFBAE6FD)),
            const SizedBox(width: 8),
            _buildFilterTab(label: context.tr('rental_filter_ineligible'), count: ineligibleCount, mode: RentalFilterMode.ineligible, bgColor: const Color(0xFFFED7AA)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({required String label, required int count, required RentalFilterMode mode, required Color bgColor}) {
    final isSelected = _filterMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() { _filterMode = mode; });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isSelected ? Colors.white : Colors.black)),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.black, borderRadius: BorderRadius.circular(4)), child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.black : Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelectorStrip(ThemeData theme, List<RealEstateModel> properties, RealEstateModel? activeProp) {
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
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() { _selectedPropertyId = prop.id; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1.5)),
              child: Center(child: Text(prop.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : Colors.black))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyHeaderCard(ThemeData theme, RealEstateModel prop) {
    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prop.city} • ${prop.district}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              NeoBrutalBadge(
                text: prop.isRented
                    ? context.tr('rental_filter_rented')
                    : (prop.canBeRented
                        ? context.tr('rental_filter_vacant')
                        : context.tr('rental_filter_ineligible')),
                backgroundColor: prop.isRented
                    ? const Color(0xFFBBF7D0)
                    : (prop.canBeRented
                        ? const Color(0xFFBAE6FD)
                        : const Color(0xFFFED7AA)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFeatureChip(
                Icons.category_rounded,
                context.tr(prop.category.localizationKey),
                const Color(0xFFDDD6FE),
              ),
              _buildFeatureChip(
                Icons.calendar_today_rounded,
                '${prop.buildingAge} Yaşında',
                const Color(0xFFE2E8F0),
              ),
              _buildFeatureChip(
                Icons.meeting_room_rounded,
                prop.roomCount,
                const Color(0xFFFEF08A),
              ),
              if (prop.isRenovated)
                _buildFeatureChip(
                  Icons.auto_awesome_rounded,
                  'Yenilenmiş',
                  const Color(0xFFBBF7D0),
                ),
              if (prop.squareMeters > 0)
                _buildFeatureChip(
                  Icons.square_foot_rounded,
                  '${prop.squareMeters.toInt()} m²',
                  const Color(0xFFD1FAE5),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              GestureDetector(
                onTap: () => context.push('/emlak-ilan/${prop.id}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront_rounded, size: 12, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 4),
                      Text(context.tr('real_estate_nav_sale_desk'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/showroom?tab=1'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer_rounded, size: 12, color: Color(0xFF7E22CE)),
                      const SizedBox(width: 4),
                      Text(context.tr('real_estate_nav_showroom_offers'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF7E22CE))),
                    ],
                  ),
                ),
              ),
              if (prop.category == RealEstateCategory.land)
                GestureDetector(
                  onTap: () => context.push('/emlak-insaat/${prop.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.construction_rounded, size: 12, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(context.tr('real_estate_nav_construction_site'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.black)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7AA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.landscape_rounded,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('rental_ineligible_land'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('rental_ineligible_listed_desc'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          NeoBrutalButton(
            label: context.tr('rental_action_go_construction'),
            icon: Icons.construction_rounded,
            backgroundColor: const Color(0xFFFEF08A),
            fullWidth: true,
            onPressed: () {
              HapticFeedback.selectionClick();
              context.push('/emlak-insaat/${prop.id}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherIneligibleCard(ThemeData theme, RealEstateModel prop) {
    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7AA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('rental_filter_ineligible'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('rental_ineligible_listed_desc'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        NeoBrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBF7D0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant?.name ?? context.tr('rental_tenant_header'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          context.tr('rental_tenant_header'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tenant != null)
                    NeoBrutalBadge(
                      text: tenant.reliabilityGrade,
                      backgroundColor: _getGradeColor(tenant.reliabilityGrade)
                          .withValues(alpha: 0.2),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Column(
                  children: [
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
                      color: pendingRent > 0
                          ? const Color(0xFFD97706)
                          : Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.tr('rental_actions_header'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        NeoBrutalButton(
          label: context.tr('rental_btn_collect_rent'),
          icon: Icons.payments_rounded,
          backgroundColor: const Color(0xFF10B981),
          fullWidth: true,
          onPressed: pendingRent > 0 ? () => _collectRent(prop) : null,
        ),
        const SizedBox(height: 8),
        NeoBrutalButton(
          label: context.tr('rental_btn_apply_tufe'),
          icon: Icons.trending_up_rounded,
          backgroundColor: const Color(0xFF60A5FA),
          fullWidth: true,
          onPressed: () => _applyTufeIncrease(prop),
        ),
        const SizedBox(height: 8),
        NeoBrutalButton(
          label: context.tr('rental_btn_evict_tenant'),
          icon: Icons.exit_to_app_rounded,
          backgroundColor: const Color(0xFFEF4444),
          fullWidth: true,
          onPressed: () => _confirmEviction(prop),
        ),
      ],
    );
  }

  Widget _buildVacantRentalView(ThemeData theme, RealEstateModel prop) {
    final baseMonthly =
        (prop.estimatedRealValue * prop.category.dailyRentYieldRate * 30)
            .roundToDouble();
    final annualYieldRate =
        (prop.category.dailyRentYieldRate * 365 * 100).toStringAsFixed(1);
    final candidates = _getCandidatesFor(prop);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoBrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('rental_valuation_header'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('rental_est_monthly_rent'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(baseMonthly),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('rental_est_annual_yield'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '%$annualYieldRate',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    context.tr('rental_contract_type_header'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  _buildDurationPill(
                    1,
                    context.tr('rental_lease_duration_1yr'),
                  ),
                  const SizedBox(width: 8),
                  _buildDurationPill(
                    2,
                    context.tr('rental_lease_duration_2yr'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('rental_candidates_subtitle'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            Text(
              '${candidates.length} Aday',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...candidates.map((c) => _buildCandidateCard(theme, prop, c)),
      ],
    );
  }

  Widget _buildDurationPill(int years, String label) {
    final isSelected = _selectedLeaseDurationYears == years;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedLeaseDurationYears = years;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.black,
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
    final isEvaluating =
        candidate.evaluationStatus == TenantEvaluationStatus.evaluating;
    final isAccepted =
        candidate.evaluationStatus == TenantEvaluationStatus.accepted;
    final isCounter =
        candidate.evaluationStatus == TenantEvaluationStatus.counterOffer;
    final isRejected =
        candidate.evaluationStatus == TenantEvaluationStatus.rejected;

    String statusLabel;
    Color statusBgColor;
    Color statusBorderColor;
    IconData statusIcon;

    switch (candidate.evaluationStatus) {
      case TenantEvaluationStatus.evaluating:
        statusLabel = context.tr('rental_candidate_evaluating');
        statusBgColor = const Color(0xFFFEF3C7);
        statusBorderColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case TenantEvaluationStatus.accepted:
        statusLabel = context.tr('rental_candidate_accepted');
        statusBgColor = const Color(0xFFD1FAE5);
        statusBorderColor = const Color(0xFF059669);
        statusIcon = Icons.check_circle_rounded;
        break;
      case TenantEvaluationStatus.counterOffer:
        statusLabel = context.tr('rental_candidate_counter');
        statusBgColor = const Color(0xFFFEF08A);
        statusBorderColor = const Color(0xFFCA8A04);
        statusIcon = Icons.compare_arrows_rounded;
        break;
      case TenantEvaluationStatus.rejected:
        statusLabel = context.tr('rental_candidate_rejected');
        statusBgColor = const Color(0xFFFEE2E2);
        statusBorderColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        break;
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getGradeColor(candidate.reliabilityGrade)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: candidate.reliabilityGrade,
                  backgroundColor: _getGradeColor(candidate.reliabilityGrade)
                      .withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12, width: 1),
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
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (isEvaluating) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusBorderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFD97706),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Text(
                            '${candidate.inspectionRemainingSeconds}s',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      candidate.evaluationThought,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              NeoBrutalButton(
                label: context.tr('rental_btn_instant_inspect'),
                icon: Icons.flash_on_rounded,
                backgroundColor: const Color(0xFFBAE6FD),
                fullWidth: true,
                onPressed: () => _instantInspectCandidate(candidate, prop),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusBorderColor, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(statusIcon, size: 20, color: statusBorderColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: statusBorderColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            candidate.evaluationThought,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (isAccepted)
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: NeoBrutalButton(
                        label: context.tr('rental_btn_sign_lease'),
                        icon: Icons.drive_file_rename_outline_rounded,
                        backgroundColor: const Color(0xFF10B981),
                        onPressed: () => _leaseToCandidate(candidate, prop),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: NeoBrutalButton(
                        label: context.tr('rental_btn_chat_negotiate'),
                        icon: Icons.forum_rounded,
                        backgroundColor: const Color(0xFFDDD6FE),
                        onPressed: () => _openNegotiationChat(candidate, prop),
                      ),
                    ),
                  ],
                )
              else if (isCounter)
                NeoBrutalButton(
                  label: context.tr('rental_btn_chat_negotiate'),
                  icon: Icons.forum_rounded,
                  backgroundColor: const Color(0xFF8B5CF6),
                  fullWidth: true,
                  onPressed: () => _openNegotiationChat(candidate, prop),
                )
              else if (isRejected)
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('rental_btn_chat_negotiate'),
                        icon: Icons.forum_rounded,
                        backgroundColor: const Color(0xFFFBBF24),
                        onPressed: () => _openNegotiationChat(candidate, prop),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('rental_btn_dismiss_candidate'),
                        icon: Icons.person_search_rounded,
                        backgroundColor: const Color(0xFFE2E8F0),
                        onPressed: () => _dismissCandidate(candidate, prop),
                      ),
                    ),
                  ],
                ),
            ],
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

