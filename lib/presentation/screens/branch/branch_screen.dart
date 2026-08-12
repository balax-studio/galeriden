import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/branch_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class BranchScreen extends ConsumerWidget {
  const BranchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final game = ref.watch(gameProvider);
    final branches = BranchModel.getAllBranches(game.maxGarageSlots);

    return Scaffold(
      backgroundColor: p.backgroundColor,
      appBar: AppBar(
        backgroundColor: p.surfaceColor,
        title: const Text('🏢 GALERİ ŞUBE İMPARATORLUĞU'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p.secondaryColor.withValues(alpha: 0.25), p.surfaceColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.secondaryColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MEVCUT GALERİ DÜZEYİ', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 4),
                  Text('Öz Galeri Motor Plaza', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 22)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTile('Kapasite', '${game.maxGarageSlots} Araç Slotu', p.isDark),
                      _buildInfoTile('Sermaye', CurrencyFormatter.formatShort(game.balance), p.isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('ŞUBE LOKASYONLARI VE GENİŞLEME', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ...branches.map((b) {
              final isCurrent = game.maxGarageSlots == b.maxGarageSlots;
              final canAfford = game.balance >= b.requiredBalance;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent ? p.primaryColor : (b.isUnlocked ? p.surfaceBorderColor : Colors.grey.withValues(alpha: 0.3)),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: (isCurrent || b.isUnlocked) ? p.primaryColor.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                          child: VectorIconWidget(type: b.vectorIcon, color: (isCurrent || b.isUnlocked) ? p.primaryColor : Colors.grey, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                              Text(b.locationName, style: AppTypography.labelSmall(p.isDark)),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: p.primaryColor, borderRadius: BorderRadius.circular(10)),
                            child: const Text('MEVCUT ŞUBE', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• Araç Kapasitesi: ${b.maxGarageSlots} Araç', style: AppTypography.labelSmall(p.isDark)),
                        Text('• Kâr Çarpanı: ${b.profitMultiplier}x', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (!isCurrent && !b.isUnlocked)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? p.secondaryColor : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: canAfford
                              ? () {
                                  ref.read(gameProvider.notifier).expandGarageSlot(b.maxGarageSlots, b.requiredBalance);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${b.name} Şubesi Açıldı! Kapasite ${b.maxGarageSlots} Araç Oldu.')),
                                  );
                                }
                              : null,
                          child: Text(
                            canAfford ? 'Şubeyi Aç (₺${CurrencyFormatter.formatShort(b.requiredBalance)})' : 'Yetersiz Bakiye (₺${CurrencyFormatter.formatShort(b.requiredBalance)})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelSmall(isDark).copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
      ],
    );
  }
}
