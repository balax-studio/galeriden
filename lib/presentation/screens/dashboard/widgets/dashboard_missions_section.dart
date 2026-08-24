import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/contract_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/floating_money_overlay.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

/// Daily Missions List
class DashboardMissionsList extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardMissionsList({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;

    if (game.activeMissions.isEmpty) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        child: Center(
          child: Text(
            context.tr('all_missions_done'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      children: game.activeMissions.map((mission) {
        final targetGoal = mission.targetGoal > 0 ? mission.targetGoal : 1;
        final progressRatio =
            (mission.currentProgress / targetGoal).clamp(0.0, 1.0);
        final isCompleted = mission.isCompleted == true;
        final isClaimed = mission.isClaimed == true;
        final isDiscovery = mission.isDiscoveryMission == true;
        final title = mission.titleKey != null
            ? context.tr(mission.titleKey!)
            : mission.title;
        final desc = mission.descriptionKey != null
            ? context.tr(
                mission.descriptionKey!,
                mission.templateParams
                    ?.map((k, v) => MapEntry(k, v.toString())))
            : mission.description;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isDiscovery) ...[
                            NeoBrutalBadge(
                              text: context.tr('mission_discovery_badge'),
                              backgroundColor: const Color(0xFF8B5CF6),
                              textColor: Colors.white,
                              fontSize: 9.0,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          NeoBrutalBadge(
                            text:
                                '+${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} • +${mission.rewardXP}XP',
                            backgroundColor: const Color(0xFFFFDE59),
                            textColor: Colors.black,
                            fontSize: 9.5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? const Color(0xFF00E575)
                                : palette.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClaimed) ...[
                  const SizedBox(width: 10),
                  NeoBrutalBadge(
                    text: context.tr('claimed_badge'),
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    fontSize: 10,
                  ),
                ] else if (progressRatio >= 1.0) ...[
                  const SizedBox(width: 10),
                  NeoBrutalButton(
                    label: context.tr('claim_action'),
                    icon: Icons.check_circle_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 11,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: () {
                      final success = ref
                          .read(gameProvider.notifier)
                          .claimMissionReward(mission.id);
                      if (success) {
                        FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                          mission.rewardMoney.toDouble(),
                          label: 'OK',
                        );
                        NotificationService.showSuccess(
                          context,
                          '$title • +${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())}',
                        );
                      }
                    },
                  ),
                ] else if (mission.featureRoute != null) ...[
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => context.push(mission.featureRoute!),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('mission_tap_to_open'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// VIP Aranan Araç Sözleşmeleri Bölümü
class DashboardWantedContractsSection extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardWantedContractsSection({
    super.key,
    required this.game,
    required this.palette,
  });

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: palette.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 8),
                    NeoBrutalBadge(
                      text: badgeText,
                      backgroundColor: badgeColor ?? palette.primaryColor,
                      textColor: Colors.black,
                      fontSize: 9.5,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFulfillContractDialog(
    BuildContext context,
    WidgetRef ref,
    WantedCarContract contract,
    List<CarModel> matchingCars,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: Color(0xFF333B4F), width: 2.0),
              left: BorderSide(color: Color(0xFF333B4F), width: 2.0),
              right: BorderSide(color: Color(0xFF333B4F), width: 2.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${contract.clientName} - ${context.tr('deliver_action')}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...matchingCars.map((car) {
                  final profit = (contract.budget + contract.rewardBonus) -
                      car.currentPurchasePrice;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: const Color(0xFF1E2330),
                      borderColor: const Color(0xFF333B4F),
                      borderRadius: 10,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${car.brand} ${car.modelName} • ${car.modelYear}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${CurrencyFormatter.formatShort(profit)}',
                                  style: const TextStyle(
                                      color: Color(0xFF00E575),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          NeoBrutalButton(
                            label: context.tr('deliver_action'),
                            backgroundColor: const Color(0xFF00E575),
                            textColor: Colors.black,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            onPressed: () {
                              Navigator.pop(ctx);
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .fulfillWantedCarContract(
                                      contract.id, car.id);
                              if (success) {
                                FloatingMoneyOverlay.of(context)
                                    ?.showMoneyPopUp(
                                  contract.budget + contract.rewardBonus,
                                  label: 'OK',
                                );
                                NotificationService.showSuccess(
                                  context,
                                  '${contract.clientName} +${CurrencyFormatter.formatShort(contract.budget + contract.rewardBonus)}',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (game.activeContracts.isEmpty) return const SizedBox.shrink();
    final isDark = palette.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: context.tr('wanted_contracts_title'),
          subtitle: context.tr('wanted_contracts_sub'),
          badgeText: '${game.activeContracts.length}',
          badgeColor: const Color(0xFFFF7A00),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        ...game.activeContracts.map((contract) {
          final matchingCars = game.ownedCars.where((car) {
            if (car.brand.toLowerCase() != contract.targetBrand.toLowerCase()) {
              return false;
            }
            if (contract.targetBodyType != null &&
                car.bodyType != contract.targetBodyType) {
              return false;
            }
            if (car.modelYear < contract.minYear) {
              return false;
            }
            if (car.expertise.mileage > contract.maxMileage) {
              return false;
            }
            if (car.isLockedInShowcase == true) {
              return false;
            }
            return true;
          }).toList();

          final totalPayout = contract.budget + contract.rewardBonus;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor:
                  isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFF7A00),
                        child: Text(
                          contract.clientName.isNotEmpty
                              ? contract.clientName[0]
                              : 'V',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.clientName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${contract.targetBrand} • Min. ${contract.minYear} • Max. ${contract.maxMileage ~/ 1000}k km',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      NeoBrutalBadge(
                        text:
                            '${contract.deadlineDays} ${context.tr('hud_day')}',
                        backgroundColor: contract.deadlineDays <= 2
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${CurrencyFormatter.formatShort(totalPayout)} • +${CurrencyFormatter.formatShort(contract.rewardBonus)}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00E575)),
                          ),
                        ],
                      ),
                      if (matchingCars.isNotEmpty)
                        NeoBrutalButton(
                          label:
                              '${context.tr('deliver_action')} • ${matchingCars.length}',
                          icon: Icons.local_shipping_rounded,
                          backgroundColor: const Color(0xFF00E575),
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: () => _showFulfillContractDialog(
                              context, ref, contract, matchingCars),
                        )
                      else
                        NeoBrutalButton(
                          label: context.tr('find_in_market'),
                          icon: Icons.search_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: () => context.push('/marketplace'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
      ],
    );
  }
}
