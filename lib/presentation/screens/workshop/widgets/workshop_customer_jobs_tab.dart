import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/staff_model.dart';
import '../../../../data/models/workshop_job_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class WorkshopCustomerJobsTab extends ConsumerStatefulWidget {
  final List<CustomerRepairJob> initialJobs;

  const WorkshopCustomerJobsTab({
    super.key,
    required this.initialJobs,
  });

  @override
  ConsumerState<WorkshopCustomerJobsTab> createState() =>
      _WorkshopCustomerJobsTabState();
}

class _WorkshopCustomerJobsTabState
    extends ConsumerState<WorkshopCustomerJobsTab> {
  late List<CustomerRepairJob> _customerJobs;

  @override
  void initState() {
    super.initState();
    _customerJobs = List.from(widget.initialJobs);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMechanic =
        game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);

    if (!hasMechanic) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: AppColors.brutalOrange,
        borderRadius: 14,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brutalOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brutalOrange, width: 2),
              ),
              child: const Icon(Icons.build_circle_rounded,
                  size: 36, color: AppColors.brutalOrange),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('workshop_locked_service_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('workshop_locked_service_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            NeoBrutalButton(
              label: context.tr('workshop_btn_hire_mechanic'),
              icon: Icons.person_add_rounded,
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              fontSize: 11,
              onPressed: () {
                if (game.isFeatureUnlocked('/staff')) {
                  context.push('/staff');
                } else {
                  NotificationService.showInfo(
                    context,
                    context.tr('cashflow_locked_feature_toast', {
                      'branch': DealershipModel.getRequiredBranchName(
                          '/staff', context)
                    }),
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.tr('workshop_customer_repairs_title'),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
            NeoBrutalButton(
              label: context.tr('workshop_btn_scan_jobs'),
              icon: Icons.refresh_rounded,
              backgroundColor:
                  isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white : Colors.black,
              fontSize: 10,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onPressed: () {
                setState(() {
                  _customerJobs =
                      CustomerRepairJob.generateRandomJobs(count: 4);
                });
                NotificationService.showSuccess(
                    context, context.tr('workshop_toast_new_requests'));
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_customerJobs.isEmpty)
          NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 12,
            child: Center(
              child: Text(context.tr('workshop_no_customer_jobs')),
            ),
          )
        else
          ..._customerJobs.map((job) {
            final netProfit = job.laborReward - job.partsCost;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.brutalGreen,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: Icon(job.jobType.icon,
                                    color: Colors.black, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.customerName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      job.carModelName,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (job.isUrgent) ...[
                          const SizedBox(width: 8),
                          NeoBrutalBadge(
                            icon: Icons.bolt_rounded,
                            text: context.tr('workshop_badge_urgent'),
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                            fontSize: 9.5,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0C0E14)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${job.customerStory}"',
                        style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('workshop_parts_cost', {
                                  'cost': CurrencyFormatter.formatShort(
                                      job.partsCost)
                                }),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                context.tr('workshop_net_profit', {
                                  'profit': CurrencyFormatter.format(netProfit)
                                }),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brutalGreen),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBrutalButton(
                          label: context.tr('workshop_repair_earn_btn'),
                          icon: Icons.handshake_rounded,
                          backgroundColor: AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          onPressed: () {
                            final success = ref
                                .read(gameProvider.notifier)
                                .completeCustomerRepairJob(job);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('toast_job_completed_profit', {
                                  'customer': job.customerName,
                                  'profit': CurrencyFormatter.format(netProfit),
                                  'xp': '${job.masteryXpReward}',
                                }),
                              );
                              setState(() {
                                _customerJobs
                                    .removeWhere((j) => j.id == job.id);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
