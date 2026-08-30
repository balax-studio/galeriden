import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/dialogs/rush_training_confirmation_dialog.dart';

class StaffCourseOption {
  final String id;
  final String title;
  final String description;
  final double cost;
  final IconData icon;
  final Color color;

  const StaffCourseOption({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
  });
}

class StaffAcademyScreen extends ConsumerStatefulWidget {
  const StaffAcademyScreen({super.key});

  @override
  ConsumerState<StaffAcademyScreen> createState() => _StaffAcademyScreenState();
}

class _StaffAcademyScreenState extends ConsumerState<StaffAcademyScreen> {
  StaffRole? _selectedRoleFilter;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ??
        (Theme.of(context).brightness == Brightness.dark);

    if (!game.isFeatureUnlocked('/staff-academy')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar:
            NeoBrutalAppBar(title: context.tr('staff_academy_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/staff-academy',
          featureTitle: context.tr('staff_academy_screen_title'),
          icon: Icons.school_rounded,
        ),
      );
    }

    final staffList = game.hiredStaff;
    final allCourses = StaffRoleSpecializations.allCourses;
    final filteredCourses = _selectedRoleFilter == null
        ? allCourses
        : allCourses.where((c) => c.role == _selectedRoleFilter).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('staff_academy_screen_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Header Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('academy_header_title'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('academy_header_desc'),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Role Filter Chips
          Text(
            context.tr('academy_select_role_title'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildRoleFilterChip(
                  label: context.tr('academy_all_roles'),
                  isSelected: _selectedRoleFilter == null,
                  onTap: () => setState(() => _selectedRoleFilter = null),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                ...StaffRole.values.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildRoleFilterChip(
                      label: role.getLocalizedTitle(lang),
                      isSelected: _selectedRoleFilter == role,
                      onTap: () => setState(() => _selectedRoleFilter = role),
                      isDark: isDark,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Courses List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                context.tr('academy_courses_count',
                    {'count': '${filteredCourses.length}'}),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              )),
            ],
          ),
          const SizedBox(height: 10),

          ...filteredCourses.map((course) {
            final matchingStaff =
                staffList.where((s) => s.role == course.role).toList();
            final hasStaff = matchingStaff.isNotEmpty;
            final isFacilityUnlocked =
                game.isFeatureUnlocked(course.role.requiredFeatureRoute);

            // Check if any matching staff is currently under training for this course
            final staffInThisTraining = matchingStaff
                .where((s) =>
                    s.isUnderTraining && s.currentTrainingCourseId == course.id)
                .toList();
            final isTrainingActive = staffInThisTraining.isNotEmpty;
            final activeTrainee =
                isTrainingActive ? staffInThisTraining.first : null;

            // Check if any matching staff completed this course
            final trainedStaff = matchingStaff
                .where((s) => s.completedCourseIds.contains(course.id))
                .toList();
            final isCompletedByAllHired =
                hasStaff && trainedStaff.length == matchingStaff.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isCompletedByAllHired
                    ? AppColors.brutalGreen
                    : (isTrainingActive
                        ? AppColors.brutalYellow
                        : (!isFacilityUnlocked
                            ? AppColors.brutalOrange
                            : (isDark
                                ? const Color(0xFF2A3142)
                                : const Color(0xFF0F172A)))),
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
                                  color: course.color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF333B4F)
                                        : const Color(0xFF0F172A),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(course.icon,
                                    color: Colors.black, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.getLocalizedTitle(lang),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      context.tr('academy_target_role', {
                                        'role':
                                            course.role.getLocalizedTitle(lang)
                                      }),
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompletedByAllHired)
                          NeoBrutalBadge(
                            text: context.tr('academy_graduated'),
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else if (isTrainingActive)
                          NeoBrutalBadge(
                            text: context.tr('staff_status_training'),
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else if (!isFacilityUnlocked)
                          NeoBrutalBadge(
                            text: context.tr('staff_badge_facility_locked'),
                            backgroundColor: AppColors.brutalOrange,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: course.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            context.tr('academy_bonus_label',
                                {'bonus': course.bonusSummary}),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFFCBD5E1),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                context.tr('staff_training_duration_badge',
                                    {'days': '${course.durationDays}'}),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isTrainingActive && activeTrainee != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.brutalYellow,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${activeTrainee.name} • ${context.tr('staff_training_remaining', {
                                        'days':
                                            '${activeTrainee.trainingDaysRemaining}'
                                      })}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '%${(activeTrainee.trainingProgress * 100).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: activeTrainee.trainingProgress,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFD97706)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          isCompletedByAllHired
                              ? context.tr('academy_graduated')
                              : CurrencyFormatter.formatShort(course.cost),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isCompletedByAllHired
                                ? const Color(0xFF64748B)
                                : AppColors.brutalGreen,
                          ),
                        )),
                        if (isCompletedByAllHired)
                          NeoBrutalButton(
                            label: context.tr('academy_cert_active'),
                            icon: Icons.check_circle_rounded,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0),
                            textColor: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            onPressed: null,
                          )
                        else if (isTrainingActive && activeTrainee != null)
                          NeoBrutalButton(
                            label: context.tr('staff_btn_rush_training'),
                            icon: Icons.bolt_rounded,
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            onPressed: () {
                              RushTrainingConfirmationDialog.show(context,
                                  staff: activeTrainee);
                            },
                          )
                        else if (!isFacilityUnlocked)
                          NeoBrutalButton(
                            label: context.tr('academy_facility_required'),
                            icon: Icons.lock_rounded,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0),
                            textColor: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            onPressed: () {
                              NotificationService.showInfo(
                                context,
                                context.tr('academy_facility_required_toast', {
                                  'facility': course.role.requiredFacilityName
                                }),
                              );
                            },
                          )
                        else if (!hasStaff)
                          NeoBrutalButton(
                            label: context.tr('academy_no_staff_badge'),
                            icon: Icons.person_off_rounded,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0),
                            textColor: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            onPressed: () {
                              NotificationService.showInfo(
                                context,
                                context.tr('academy_hire_first_toast', {
                                  'role': course.role.getLocalizedTitle(lang)
                                }),
                              );
                            },
                          )
                        else
                          NeoBrutalButton(
                            label: context.tr('academy_btn_send_training'),
                            icon: Icons.school_rounded,
                            backgroundColor: course.color,
                            textColor: Colors.black,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            onPressed: () {
                              // Find staff who hasn't finished this course and isn't currently under training
                              final candidateStaff = matchingStaff.firstWhere(
                                (s) =>
                                    !s.completedCourseIds.contains(course.id) &&
                                    !s.isUnderTraining,
                                orElse: () => matchingStaff.first,
                              );

                              if (candidateStaff.isUnderTraining) {
                                NotificationService.showInfo(
                                  context,
                                  context.tr('staff_under_training_warning'),
                                );
                                return;
                              }

                              if (game.balance < course.cost) {
                                NotificationService.showError(context,
                                    context.tr('insufficient_balance'));
                                return;
                              }

                              final success = ref
                                  .read(gameProvider.notifier)
                                  .trainStaffMember(candidateStaff.id, course);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr(
                                      'academy_training_started_toast', {
                                    'name': candidateStaff.name,
                                    'course': course.getLocalizedTitle(lang),
                                    'days': '${course.durationDays}'
                                  }),
                                );
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
      ),
    );
  }

  Widget _buildRoleFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA855F7)
              : (isDark ? const Color(0xFF141721) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA855F7)
                : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }
}
