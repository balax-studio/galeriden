import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Neo-Brutalist Confirmation Dialog for Rushing Multi-Day Staff Training via AdMob Rewarded Video
class RushTrainingConfirmationDialog extends ConsumerWidget {
  final StaffModel staff;

  const RushTrainingConfirmationDialog({
    super.key,
    required this.staff,
  });

  /// Displays the confirmation dialog modally
  static Future<void> show(BuildContext context, {required StaffModel staff}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => RushTrainingConfirmationDialog(staff: staff),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final roleName = staff.role.getLocalizedTitle(lang);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF131620) : Colors.white,
        borderColor: isDark ? const Color(0xFF2E3748) : const Color(0xFF0F172A),
        borderWidth: 2.8,
        borderRadius: 18,
        shadowOffset: const Offset(5, 5),
        shadowColor: isDark ? Colors.black87 : const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Bar with Category Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('rush_training_dialog_title'),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Trainee Information Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.brutalYellow,
                          width: 1.8,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          color: AppColors.brutalYellow,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$roleName • ${context.tr('staff_training_remaining', {'days': '${staff.trainingDaysRemaining}'})}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Explanatory Message
              Text(
                context.tr('rush_training_dialog_desc'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Action Buttons (Cancel / Watch Ad)
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('cancel'),
                      icon: Icons.arrow_back_rounded,
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: NeoBrutalButton(
                      label: context.tr('rush_training_btn_watch'),
                      icon: Icons.card_membership_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      onPressed: () {
                        final notifier = ref.read(gameProvider.notifier);
                        final successMessage = context.tr(
                          'staff_rush_training_success',
                          {'name': staff.name},
                        );
                        final rootContext = Navigator.of(context, rootNavigator: true).context;
                        Navigator.of(context).pop();
                        AdService.instance.showRewardedAdWithFallback(
                          context: rootContext,
                          onRewardEarned: () {
                            final success = notifier.rushStaffTraining(staff.id);
                            if (success && rootContext.mounted) {
                              NotificationService.showSuccess(
                                rootContext,
                                successMessage,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
