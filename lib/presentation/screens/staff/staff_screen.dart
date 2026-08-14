import 'package:go_router/go_router.dart';
import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/staff_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/app_double_bezel_card.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('PERSONEL & EKİP YÖNETİMİ'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people_alt_rounded, color: p.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AKTİF EKİP BÜYÜKLÜĞÜ', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 2),
                        Text(
                          '${game.hiredStaff.length} / ${StaffRole.values.length} Personel İşe Alındı',
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Staff Academy Navigation Banner Card
            AppGlassContainer(
              padding: const EdgeInsets.all(14),
              borderColor: Colors.purpleAccent.withValues(alpha: 0.5),
              glowColor: Colors.purpleAccent.withValues(alpha: 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.purpleAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personel Akademisi & Sertifikalar', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Satış ikna, Motor ustalık & VIP sertifikası', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/staff-academy'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white),
                    child: const Text('Eğit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('KİRALANABİLİR PERSONEL KADROSU', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: StaffRole.values.length,
              itemBuilder: (context, index) {
                final role = StaffRole.values[index];
                final matches = game.hiredStaff.where((s) => s.role == role);
                final hired = matches.isEmpty ? null : matches.first;
                final isHired = hired != null;

                return AppDoubleBezelCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  outerRadius: 18,
                  accentColor: isHired ? p.primaryColor : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isHired ? p.primaryColor.withValues(alpha: 0.2) : p.surfaceBorderColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: VectorIconWidget(
                              type: role.iconType,
                              color: isHired ? p.primaryColor : p.textSecondaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(role.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  'Günlük Maaş: ₺${CurrencyFormatter.formatShort(role.dailySalary)}',
                                  style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHired ? p.errorColor : p.primaryColor,
                              foregroundColor: isHired ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () {
                              if (isHired) {
                                ref.read(gameProvider.notifier).fireStaff(hired.id);
                                NotificationService.showSuccess(context, '${role.title} İşten Çıkarıldı.');
                              } else {
                                final newStaff = StaffModel(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: 'Usta ${index + 1}',
                                  role: role,
                                  hiredAt: DateTime.now(),
                                );
                                final success = ref.read(gameProvider.notifier).hireStaff(newStaff);
                                if (success) {
                                  NotificationService.showSuccess(context, '${role.title} Ekibe Katıldı!');
                                }
                              }
                            },
                            child: Text(isHired ? 'İşten Çıkar' : 'İşe Al'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(role.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 12)),
                    ],
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
