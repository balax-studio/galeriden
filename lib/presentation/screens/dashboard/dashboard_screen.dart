import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('GALERİSİNDEN', style: AppTypography.titleLarge(isDark).copyWith(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance & Level Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAmber.withOpacity(0.25),
                    AppColors.surfaceDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryAmber.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MEVCUT SERMAYE', style: AppTypography.labelSmall(isDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Seviye ${game.level}',
                          style: AppTypography.labelSmall(false).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(game.balance),
                    style: AppTypography.moneyLarge(isDark).copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('Toplam Kâr', CurrencyFormatter.formatShort(game.totalProfit), isDark),
                      _buildStat('Satılan Araç', '${game.carsSold} Adet', isDark),
                      _buildStat('Galeri Kapasitesi', '${game.ownedCars.length}/${game.maxGarageSlots}', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('HIZLI MENÜ', style: AppTypography.labelSmall(isDark)),
            const SizedBox(height: 12),

            // Main Hub Buttons Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  context,
                  title: 'İkinci El Pazarı',
                  subtitle: 'Araç İlanlarını İncele',
                  icon: Icons.storefront_rounded,
                  color: AppColors.primaryAmber,
                  onTap: () => context.push('/marketplace'),
                ),
                _buildActionCard(
                  context,
                  title: 'Showroom / İlanlarım',
                  subtitle: 'Gelen Teklifler (${game.incomingOffers.length})',
                  icon: Icons.garage_rounded,
                  color: AppColors.secondarySage,
                  badge: game.incomingOffers.isNotEmpty ? '${game.incomingOffers.length}' : null,
                  onTap: () => context.push('/showroom'),
                ),
                _buildActionCard(
                  context,
                  title: 'Tamir Atölyesi',
                  subtitle: 'Araç Değerini Artır',
                  icon: Icons.build_rounded,
                  color: AppColors.infoBlue,
                  onTap: () => context.push('/workshop'),
                ),
                _buildActionCard(
                  context,
                  title: 'Ekspertiz Merkezi',
                  subtitle: 'Kusurları Tespiti Et',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.warningOrange,
                  onTap: () => context.push('/marketplace'),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Text('SON TEKLİFLER VE AKTİVİTELER', style: AppTypography.labelSmall(isDark)),
            const SizedBox(height: 12),

            if (game.incomingOffers.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Henüz gelen teklif yok. Pazardan araç alıp ilana koyduğunda alıcı teklifleri burada görünecektir.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(isDark),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: game.incomingOffers.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final offer = game.incomingOffers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.secondarySage,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(offer.buyerName, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                      subtitle: Text(offer.buyerMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        CurrencyFormatter.format(offer.offeredAmount),
                        style: AppTypography.moneyMedium(isDark),
                      ),
                      onTap: () => context.push('/showroom'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall(isDark)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.monoSpec(isDark).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.labelSmall(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
