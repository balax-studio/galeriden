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

  String _getCharacterTitle(int level) {
    if (level < 3) return 'Stajyer Galerici';
    if (level < 6) return 'Çırak Al-Satçı';
    if (level < 10) return 'Usta Galerici';
    if (level < 15) return 'Oto Galeri Patronu';
    return '👑 Galerici Kralı';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final game = ref.watch(gameProvider);
    final branches = BranchModel.getAllBranches(game.maxGarageSlots);
    final skills = game.skills;
    final title = _getCharacterTitle(game.level);

    final xpInCurrentLevel = skills.xp % 100;
    final xpProgress = xpInCurrentLevel / 100.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: p.backgroundColor,
        appBar: AppBar(
          backgroundColor: p.surfaceColor,
          title: const Text('🏢 ŞUBE İMPARATORLUĞU & GELİŞİM'),
          bottom: TabBar(
            labelColor: p.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: p.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.store_rounded, size: 20), text: 'Şubeler'),
              Tab(icon: Icon(Icons.bolt_rounded, size: 20), text: 'Yetenekler'),
              Tab(icon: Icon(Icons.emoji_events_rounded, size: 20), text: 'Başarımlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Branch Empire Tiers
            SingleChildScrollView(
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
                            _buildInfoTile('Galeri İtibarı', '⭐ ${game.reputationScore} Puan', p.isDark),
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

            // TAB 2: Character Skills Tree
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: p.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.surfaceBorderColor),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: p.primaryColor.withValues(alpha: 0.2),
                          child: VectorIconWidget(type: 'craftsman', color: p.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18)),
                              const SizedBox(height: 4),
                              Text('Seviye ${game.level} • XP: ${skills.xp}', style: AppTypography.labelSmall(p.isDark)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: xpProgress,
                                  minHeight: 8,
                                  backgroundColor: p.surfaceBorderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(p.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('YETENEK AĞACI & PERKLER', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 12),

                  _buildSkillTile(context, ref, title: 'İkna & Pazarlık', level: skills.negotiationLevel, cost: 5000.0 * skills.negotiationLevel, vectorType: 'negotiation', p: p, onUpgrade: () => ref.read(gameProvider.notifier).upgradeSkill('negotiation')),
                  _buildSkillTile(context, ref, title: 'Ekspertiz Sezgisi', level: skills.eyeForDetail, cost: 5000.0 * skills.eyeForDetail, vectorType: 'expertise', p: p, onUpgrade: () => ref.read(gameProvider.notifier).upgradeSkill('eyeForDetail')),
                  _buildSkillTile(context, ref, title: 'Piyasa Tahmini', level: skills.marketSense, cost: 5000.0 * skills.marketSense, vectorType: 'flash', p: p, onUpgrade: () => ref.read(gameProvider.notifier).upgradeSkill('marketSense')),
                  _buildSkillTile(context, ref, title: 'Galeri İtibarı', level: skills.reputation, cost: 5000.0 * skills.reputation, vectorType: 'rare', p: p, onUpgrade: () => ref.read(gameProvider.notifier).upgradeSkill('reputation')),
                ],
              ),
            ),

            // TAB 3: Achievements Grid
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BAŞARIMLAR VE ROZETLER', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: game.achievements.length,
                    itemBuilder: (context, index) {
                      final ach = game.achievements[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ach.isUnlocked ? p.warningColor : p.surfaceBorderColor,
                            width: ach.isUnlocked ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: ach.isUnlocked ? p.warningColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
                              child: VectorIconWidget(type: 'rare', color: ach.isUnlocked ? p.warningColor : Colors.grey, size: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ach.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ach.isUnlocked ? p.textPrimaryColor : Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ach.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTile(BuildContext context, WidgetRef ref, {required String title, required int level, required double cost, required String vectorType, required dynamic p, required VoidCallback onUpgrade}) {
    final game = ref.watch(gameProvider);
    final canAfford = game.balance >= cost && level < 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: p.primaryColor.withValues(alpha: 0.15),
            child: VectorIconWidget(type: vectorType, color: p.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                Text('Seviye $level / 10', style: AppTypography.labelSmall(p.isDark)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? p.primaryColor : Colors.grey,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: canAfford ? onUpgrade : null,
            child: Text(level >= 10 ? 'MAX' : '₺${CurrencyFormatter.formatShort(cost)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.labelSmall(isDark).copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 14)),
      ],
    );
  }
}
