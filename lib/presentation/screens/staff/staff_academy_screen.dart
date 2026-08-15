import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

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
      color: AppColors.brutalYellow,
    ),
    StaffCourseOption(
      id: 'course_mechanic_master',
      title: 'Ağır Motor & Şanzıman Ustalık Eğitimi',
      description: 'Atölyedeki tamir ve parça değişim maliyetlerini %30 düşürür, süreyi yarıya indirir.',
      cost: 18000,
      icon: Icons.build_rounded,
      color: AppColors.brutalOrange,
    ),
    StaffCourseOption(
      id: 'course_expertise_cert',
      title: 'Resmi Lisanslı Başeksper Sertifikası',
      description: 'Araç ekspertiz raporlarında boyalı ve değişen parçaların %100 kusursuz tespit edilmesini sağlar.',
      cost: 25000,
      icon: Icons.verified_rounded,
      color: Color(0xFF06B6D4),
    ),
    StaffCourseOption(
      id: 'course_vip_concierge',
      title: '5 Yıldızlı VIP Müşteri İlişkileri Eğitimi',
      description: 'Her satış sonrası müşteri memnuniyet yorumlarını ve bayi itibar puanını yükseltir.',
      cost: 15000,
      icon: Icons.star_rounded,
      color: Color(0xFFA855F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final staffList = game.hiredStaff;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PERSONEL AKADEMİSİ & EĞİTİM',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Header Overview Card
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
                    color: const Color(0xFFA855F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KURUMSAL PERSONEL AKADEMİSİ',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ustalarını ve danışmanlarını akredite sertifika programlarına göndererek kârını katla.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Hired Staff Quick List
          Text(
            'EĞİTİLECEK PERSONEL (${staffList.length} Aktif)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          if (staffList.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Henüz işe alınmış personel bulunmuyor.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...staffList.map((staff) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 18, color: AppColors.brutalYellow),
                          const SizedBox(width: 8),
                          Text(
                            staff.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: staff.role.title,
                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),

          // 3. Courses List
          Text(
            'AKADEMİ SERTİFİKA PROGRAMLARI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          ..._courses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: course.color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1.4),
                              ),
                              child: Icon(course.icon, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              course.title,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.formatShort(course.cost),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                        NeoBrutalButton(
                          label: 'EĞİTİME GÖNDER',
                          icon: Icons.school_rounded,
                          backgroundColor: course.color,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          onPressed: () {
                            if (game.balance < course.cost) {
                              NotificationService.showError(context, 'Yetersiz Bakiye!');
                              return;
                            }

                            ref.read(gameProvider.notifier).deductBalance(course.cost);
                            NotificationService.showSuccess(
                              context,
                              '${course.title} Tamamlandı! Personellerine Sertifika Tanımlandı.',
                            );
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
}
