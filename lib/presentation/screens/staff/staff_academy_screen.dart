import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

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
  final List<StaffCourseOption> _courses = const [
    StaffCourseOption(
      id: 'course_sales_master',
      title: 'İleri Satış İkna & Pazarlık Sertifikası',
      description: 'Müşterilerle yapılan pazarlıklarda araç satış teklifi kabul oranını +%25 artırır.',
      cost: 12000,
      icon: Icons.handshake_rounded,
      color: Colors.amber,
    ),
    StaffCourseOption(
      id: 'course_mechanic_master',
      title: 'Ağır Motor & Şanzıman Ustalık Eğitimi',
      description: 'Atölyedeki tamir ve parça değişim maliyetlerini %30 düşürür, süreyi yarıya indirir.',
      cost: 18000,
      icon: Icons.build_rounded,
      color: Colors.orangeAccent,
    ),
    StaffCourseOption(
      id: 'course_expertise_cert',
      title: 'Resmi Lisanslı Başeksper Sertifikası',
      description: 'Araç ekspertiz raporlarında boyalı ve değişen parçaların %100 kusursuz tespit edilmesini sağlar.',
      cost: 25000,
      icon: Icons.verified_rounded,
      color: Colors.cyanAccent,
    ),
    StaffCourseOption(
      id: 'course_vip_concierge',
      title: '5 Yıldızlı VIP Müşteri İlişkileri Eğitimi',
      description: 'Her satış sonrası müşteri memnuniyet yorumlarını ve bayi itibar puanını yükseltir.',
      cost: 15000,
      icon: Icons.star_rounded,
      color: Colors.purpleAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final staffList = game.hiredStaff;

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'PERSONEL AKADEMİSİ & EĞİTİM',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            AppGlassContainer(
              padding: const EdgeInsets.all(18),
              borderColor: Colors.purpleAccent.withValues(alpha: 0.5),
              glowColor: Colors.purpleAccent.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.purpleAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kurumsal Personel Gelişimi', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Ustalarını ve danışmanlarını akredite sertifika programlarına göndererek kârını katla.',
                          style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('PERSONEL KADROSU (${staffList.length} Aktif)', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            if (staffList.isEmpty)
              AppGlassContainer(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text('Henüz İşe Alınmış Personel Bulunmuyor.', style: AppTypography.bodyMedium(p.isDark)),
                ),
              )
            else
              Column(
                children: staffList.map((staff) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: p.surfaceBorderColor),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: p.primaryColor.withValues(alpha: 0.2),
                          child: Icon(Icons.person_rounded, color: p.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                              Text(
                                staff.role.title,
                                style: TextStyle(color: p.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            Text('AKADEMİ SERTİFİKA PROGRAMLARI', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppDoubleBezelCard(
                    accentColor: course.color,
                    outerRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: course.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(course.icon, color: course.color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(course.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(course.description, style: AppTypography.bodyMedium(p.isDark)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Eğitim Ücreti: ₺${CurrencyFormatter.formatShort(course.cost)}',
                              style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                            ),
                            AppTactileButton(
                              onPressed: () {
                                if (game.balance < course.cost) {
                                  NotificationService.showError(context, 'Yetersiz Bakiye!');
                                  return;
                                }

                                ref.read(gameProvider.notifier).deductBalance(course.cost);
                                NotificationService.showSuccess(context, '${course.title} Tamamlandı! Personellerine Sertifika Tanımlandı.');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: course.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Eğitime Gönder',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
