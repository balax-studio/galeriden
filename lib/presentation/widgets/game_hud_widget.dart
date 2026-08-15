import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/game_provider.dart';

/// Floating Game HUD overlay widget - Neo-Brutalist Monolithic Stats Bar
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          // GÜN Pill
          _buildPill(
            context,
            icon: Icons.calendar_month_rounded,
            accentColor: const Color(0xFFFFB703),
            title: 'GÜN',
            value: '${game.currentDay}',
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // KASA Pill (Interactive -> Finance)
          _buildPill(
            context,
            icon: Icons.account_balance_wallet_rounded,
            accentColor: const Color(0xFF00E575),
            title: 'KASA',
            value: CurrencyFormatter.formatShort(game.balance),
            bold: true,
            onTap: () => context.push('/finance'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // GARAJ STOK Pill (Interactive -> Showroom)
          _buildPill(
            context,
            icon: Icons.directions_car_rounded,
            accentColor: const Color(0xFF00F0FF),
            title: 'GARAJ',
            value: '${game.ownedCars.length}/${game.maxGarageSlots}',
            onTap: () => context.push('/showroom'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // İTİBAR Pill (Interactive -> Branch Empire)
          _buildPill(
            context,
            icon: Icons.star_rounded,
            accentColor: const Color(0xFFFFDE59),
            title: 'İTİBAR',
            value: '%${game.reputationScore}',
            onTap: () => context.push('/branch'),
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // GÖREV Pill
          _buildPill(
            context,
            icon: Icons.task_alt_rounded,
            accentColor: const Color(0xFFA855F7),
            title: 'GÖREV',
            value: '${game.activeMissions.where((m) => m.isCompleted).length}/${game.activeMissions.length}',
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
    bool bold = false,
  }) {
    final bgColor = isDark ? const Color(0xFF141721) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);
    final shadowColor = isDark ? const Color(0xFF000000) : const Color(0xFF0F172A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(2.0, 2.0),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 1.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark ? Colors.black38 : const Color(0xFF0F172A),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(icon, size: 12, color: Colors.black),
                ),
                const SizedBox(width: 6),
                Text(
                  '$title ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
