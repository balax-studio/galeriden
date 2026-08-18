import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  void _showRoleTrainingSheet(BuildContext context, WidgetRef ref, StaffModel staff) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.read(gameProvider);
    final courses = StaffRoleSpecializations.coursesForRole(staff.role);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${staff.name} • Uzmanlık Eğitimi',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  NeoBrutalBadge(
                    text: staff.role.title,
                    backgroundColor: const Color(0xFFA855F7),
                    textColor: Colors.white,
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Personelinize role özel uzmanlık modülleri aldırarak verimliliğini, hızını ve kârlılığını kalıcı olarak yükseltin.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...courses.map((course) {
                final isCompleted = staff.completedCourseIds.contains(course.id);
                final canAfford = game.balance >= course.cost;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDark ? const Color(0xFF0F121C) : const Color(0xFFF8FAFC),
                    borderColor: isCompleted
                        ? AppColors.brutalGreen
                        : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                    borderRadius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(course.icon, color: course.color, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  course.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            if (isCompleted)
                              const NeoBrutalBadge(
                                text: 'TAMAMLANDI',
                                backgroundColor: AppColors.brutalGreen,
                                textColor: Colors.black,
                                fontSize: 9.5,
                              )
                            else
                              Text(
                                CurrencyFormatter.format(course.cost),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course.description,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: course.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.bonusSummary,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: course.color),
                              ),
                            ),
                            if (!isCompleted)
                              NeoBrutalButton(
                                label: 'EĞİTİME GÖNDER',
                                backgroundColor: canAfford ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                                textColor: canAfford ? Colors.black : (isDark ? Colors.white38 : Colors.black38),
                                fontSize: 10,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                onPressed: canAfford
                                    ? () {
                                        final success = ref.read(gameProvider.notifier).trainStaffMember(staff.id, course);
                                        Navigator.of(ctx).pop();
                                        if (success) {
                                          NotificationService.showSuccess(
                                            context,
                                            '${staff.name} • ${course.title} eğitimini başarıyla tamamladı!',
                                          );
                                        }
                                      }
                                    : null,
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
      },
    );
  }

  void _showBonusSheet(BuildContext context, WidgetRef ref, StaffModel staff) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.read(gameProvider);
    final bonusAmounts = [3000.0, 7500.0, 15000.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${staff.name} İçin Prim Belirle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const NeoBrutalBadge(text: '+50 Moral & Bağlılık', backgroundColor: AppColors.brutalGreen, textColor: Colors.black, fontSize: 10),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personele başarı primi vermek morali anında tazeler ve bayi tecrübe puanını artırır.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...bonusAmounts.map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NeoBrutalButton(
                    label: '${CurrencyFormatter.format(amt)} Prim Dağıt',
                    backgroundColor: game.balance >= amt ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                    textColor: game.balance >= amt ? Colors.black : (isDark ? Colors.white38 : Colors.black38),
                    fullWidth: true,
                    onPressed: game.balance >= amt
                        ? () {
                            ref.read(gameProvider.notifier).giveStaffBonus(staff.id, amt);
                            Navigator.of(ctx).pop();
                            NotificationService.showSuccess(
                              context,
                              '${staff.name} personeline ${CurrencyFormatter.format(amt)} prim dağıtıldı! Morali %100\'e yükseldi.',
                            );
                          }
                        : null,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ?? (Theme.of(context).brightness == Brightness.dark);

    if (!game.isFeatureUnlocked('/staff')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'PERSONEL & EKİP YÖNETİMİ'),
        body: const NeoBrutalLockedFeatureView(
          route: '/staff',
          featureTitle: 'PERSONEL KADROSU',
          icon: Icons.groups_rounded,
        ),
      );
    }

    final synergies = TeamSynergyEngine.calculateSynergies(game.hiredStaff);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'PERSONEL & EKİP YÖNETİMİ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Status Header Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.groups_rounded, color: Colors.black, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AKTİF EKİP KADROSU',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${game.hiredStaff.length} / ${StaffRole.values.length} Personel Görevde',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1.1 Team Synergies Section
          if (synergies.isNotEmpty) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalGreen,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.brutalGreen, size: 18),
                          SizedBox(width: 6),
                          Text('AKTİF DEPARTMAN SİNERJİLERİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: '${synergies.length} Sinerji Aktif',
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...synergies.map((syn) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(syn.vectorIcon, size: 14, color: AppColors.brutalGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${syn.title}: ${syn.description}',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 2. Academy Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personel Akademisi & Sertifikalar',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Satış ikna, Motor ustalık & VIP sertifikası',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: game.isFeatureUnlocked('/staff-academy') ? 'EĞİT' : 'KİLİTLİ',
                  backgroundColor: game.isFeatureUnlocked('/staff-academy')
                      ? const Color(0xFFA855F7)
                      : const Color(0xFF64748B),
                  textColor: Colors.white,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () {
                    if (game.isFeatureUnlocked('/staff-academy')) {
                      context.push('/staff-academy');
                    } else {
                      NotificationService.showInfo(
                        context,
                        'Kilitli Özellik! Personel Akademisi ${DealershipModel.getRequiredBranchName('/staff-academy')} satın alındığında açılır.',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'TÜM PERSONEL ROLLERİ & KADRO • ${StaffRole.values.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Staff Roles List
          ...StaffRole.values.map((role) {
            final matches = game.hiredStaff.where((s) => s.role == role);
            final hired = matches.isEmpty ? null : matches.first;
            final isHired = hired != null;
            final isFacilityUnlocked = game.isFeatureUnlocked(role.requiredFeatureRoute);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isHired
                    ? AppColors.brutalGreen
                    : (!isFacilityUnlocked
                        ? AppColors.brutalOrange
                        : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))),
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
                                  color: isHired
                                      ? AppColors.brutalGreen
                                      : (!isFacilityUnlocked
                                          ? AppColors.brutalOrange.withValues(alpha: 0.2)
                                          : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isHired
                                        ? AppColors.brutalGreen
                                        : (!isFacilityUnlocked
                                            ? AppColors.brutalOrange
                                            : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A))),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _getRoleIcon(role),
                                  color: isHired
                                      ? Colors.black
                                      : (!isFacilityUnlocked
                                          ? AppColors.brutalOrange
                                          : (isDark ? Colors.white70 : Colors.black87)),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHired ? hired.name : role.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      isHired
                                          ? '${hired.masteryTitle} • ${role.title}'
                                          : (!isFacilityUnlocked
                                              ? 'Tesis Kilitli • ${role.requiredFacilityName}'
                                              : 'Açık Kadro'),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: !isFacilityUnlocked && !isHired
                                            ? AppColors.brutalOrange
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeoBrutalBadge(
                          text: isHired
                              ? 'GÖREVDE'
                              : (!isFacilityUnlocked ? 'TESİS KİLİTLİ' : 'KADRO BOŞ'),
                          backgroundColor: isHired
                              ? AppColors.brutalGreen
                              : (!isFacilityUnlocked
                                  ? AppColors.brutalOrange
                                  : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))),
                          textColor: isHired
                              ? Colors.black
                              : (!isFacilityUnlocked
                                  ? Colors.black
                                  : (isDark ? Colors.white54 : Colors.black54)),
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role.description,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),

                    if (isHired) ...[
                      // Morale Bar & Perk Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('Moral & Enerji: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              Text(
                                '%${hired.morale}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: hired.morale > 75
                                      ? AppColors.brutalGreen
                                      : (hired.morale > 40 ? AppColors.brutalYellow : AppColors.errorRed),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (hired.completedCourseIds.isNotEmpty) ...[
                                NeoBrutalBadge(
                                  text: '${hired.completedCourseIds.length} Uzmanlık',
                                  backgroundColor: const Color(0xFFA855F7),
                                  textColor: Colors.white,
                                  fontSize: 9.5,
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (hired.perk != null)
                                NeoBrutalBadge(
                                  text: '${hired.perk!.icon} ${hired.perk!.title}',
                                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                  textColor: isDark ? Colors.white : Colors.black,
                                  fontSize: 9.5,
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (hired.morale / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: hired.morale > 75
                                  ? AppColors.brutalGreen
                                  : (hired.morale > 40 ? AppColors.brutalYellow : AppColors.errorRed),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Career summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kariyer: ${hired.tasksCompleted} Görev • ${CurrencyFormatter.format(hired.dailySalary)}/Gün',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                          ),
                          InkWell(
                            onTap: () => ref.read(gameProvider.notifier).fireStaff(hired.id),
                            child: const Text(
                              'İŞTEN ÇIKAR',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.errorRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // RPG Treat Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.local_cafe_rounded,
                              label: 'Çay • ₺500',
                              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                              textColor: isDark ? Colors.white : Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).treatStaffTea(hired.id);
                                if (success) {
                                  NotificationService.showSuccess(context, '${hired.name} çayını yudumladı • +15 Moral!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz bakiye!');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.restaurant_rounded,
                              label: 'Kebap • ₺1.5k',
                              backgroundColor: AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).treatStaffMeal(hired.id);
                                if (success) {
                                  NotificationService.showSuccess(context, '${hired.name} öğle yemeğini yedi • +35 Moral!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz bakiye!');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.payments_rounded,
                              label: 'Prim Ver',
                              backgroundColor: AppColors.brutalGreen,
                              textColor: Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: () => _showBonusSheet(context, ref, hired),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Role-based training action
                      SizedBox(
                        width: double.infinity,
                        child: NeoBrutalButton(
                          icon: Icons.school_rounded,
                          label: 'UZMANLIK EĞİTİMİ VER',
                          backgroundColor: const Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          onPressed: () => _showRoleTrainingSheet(context, ref, hired),
                        ),
                      ),
                    ] else ...[
                      if (!isFacilityUnlocked) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brutalOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brutalOrange, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_rounded, size: 14, color: AppColors.brutalOrange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Gerekli Tesis: ${role.requiredFacilityName} • Kilitli',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.brutalOrange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${CurrencyFormatter.format(role.dailySalary)} / Gün',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                          if (isFacilityUnlocked)
                            NeoBrutalButton(
                              label: 'İŞE AL',
                              icon: Icons.person_add_alt_1_rounded,
                              backgroundColor: AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              onPressed: () {
                                final random = Random();
                                final names = [
                                  'Murat Usta',
                                  'Ahmet Can',
                                  'Burak Danışman',
                                  'Cemil Usta',
                                  'Zeynep Hanım',
                                  'Kadir Eksper',
                                  'Volkan Avukat',
                                ];
                                final perks = StaffPerk.values;
                                final newStaff = StaffModel(
                                  id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
                                  name: names[random.nextInt(names.length)],
                                  role: role,
                                  hiredAt: DateTime.now(),
                                  perk: perks[random.nextInt(perks.length)],
                                );
                                final success = ref.read(gameProvider.notifier).hireStaff(newStaff);
                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    '${newStaff.name} • ${role.title} ekibe katıldı!',
                                  );
                                }
                              },
                            )
                          else
                            NeoBrutalButton(
                              label: 'KİLİTLİ',
                              icon: Icons.lock_rounded,
                              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                              textColor: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              onPressed: () {
                                NotificationService.showInfo(
                                  context,
                                  'Bu personeli işe almak için ${role.requiredFacilityName} tesisini açmalısınız.',
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.washer:
        return Icons.local_car_wash_rounded;
      case StaffRole.apprentice:
        return Icons.handyman_rounded;
      case StaffRole.salesman:
        return Icons.handshake_rounded;
      case StaffRole.masterMechanic:
        return Icons.build_circle_rounded;
      case StaffRole.appraiser:
        return Icons.fact_check_rounded;
      case StaffRole.marketer:
        return Icons.campaign_rounded;
      case StaffRole.legalAdvisor:
        return Icons.gavel_rounded;
    }
  }
}
