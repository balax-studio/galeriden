import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

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
          'PERSONEL & EKİP YÖNETİMİ',
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
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.black, size: 24),
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
                        '${game.hiredStaff.length} / ${StaffRole.values.length} Personel İşe Alındı',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                          border: Border.all(color: Colors.black, width: 1.5),
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
                  label: 'EĞİT',
                  backgroundColor: const Color(0xFFA855F7),
                  textColor: Colors.white,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () => context.push('/staff-academy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'PERSONEL KADROSU LİSTESİ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Staff Roles
          ...StaffRole.values.map((role) {
            final matches = game.hiredStaff.where((s) => s.role == role);
            final hired = matches.isEmpty ? null : matches.first;
            final isHired = hired != null;

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.title,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Günlük Maaş: ₺${CurrencyFormatter.formatShort(role.dailySalary)}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                              ),
                            ],
                          ),
                        ),
                        NeoBrutalButton(
                          label: isHired ? 'İŞTEN ÇIKAR' : 'İŞE AL',
                          backgroundColor: isHired ? AppColors.errorRed : AppColors.brutalGreen,
                          textColor: isHired ? Colors.white : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          onPressed: () {
                            if (isHired) {
                              ref.read(gameProvider.notifier).fireStaff(hired.id);
                              NotificationService.showSuccess(context, '${role.title} İşten Çıkarıldı.');
                            } else {
                              final newStaff = StaffModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: '${role.title} Sorumlusu',
                                role: role,
                                hiredAt: DateTime.now(),
                              );
                              final success = ref.read(gameProvider.notifier).hireStaff(newStaff);
                              if (success) {
                                NotificationService.showSuccess(context, '${role.title} Ekibe Katıldı!');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role.description,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
