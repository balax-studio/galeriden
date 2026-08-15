import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

import 'dashboard_quick_finance_card.dart';

class DashboardOfficeView extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardOfficeView({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Reputation Block
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: const Icon(Icons.star_rounded, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bayi İtibarı & Puanı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Müşteri memnuniyet skoru: %${game.reputationScore}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Financial Summary Card
        DashboardQuickFinanceCard(game: game, palette: palette),
        const SizedBox(height: 12),

        // Staff Management
        _buildOfficeItem(
          icon: Icons.people_alt_rounded,
          color: const Color(0xFFA855F7),
          title: 'Personel Kadrosu',
          subtitle: '${game.hiredStaff.length} Aktif Usta / Danışman',
          actionLabel: 'Yönet',
          onTap: () => context.push('/staff'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Customer Reviews
        _buildOfficeItem(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFFFFDE59),
          title: 'Müşteri Yorumları',
          subtitle: '${game.customerReviews.length} Toplam Değerlendirme',
          actionLabel: 'İncele',
          onTap: () => context.push('/reviews'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Sales History
        _buildOfficeItem(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF3B82F6),
          title: 'Satış & İşlem Geçmişi',
          subtitle: '${game.salesHistory.length} Tamamlanan Satış Defteri',
          actionLabel: 'Görüntüle',
          onTap: () => context.push('/history'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Character Growth
        _buildOfficeItem(
          icon: Icons.bolt_rounded,
          color: const Color(0xFF00E575),
          title: 'Yetenek Ağacı & Başarımlar',
          subtitle: 'Seviye ${game.level} • Yetenek Puanlarını Yönet',
          actionLabel: 'Geliştir',
          onTap: () => context.push('/character-growth'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Theme Store
        _buildOfficeItem(
          icon: Icons.palette_rounded,
          color: const Color(0xFFFF54B0),
          title: 'Tema Mağazası',
          subtitle: 'Görsel paletleri ve stilleri özelleştir',
          actionLabel: 'Mağaza',
          onTap: () => context.push('/theme-store'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildOfficeItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Icon(icon, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          NeoBrutalButton(
            label: actionLabel,
            backgroundColor: color,
            textColor: Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
