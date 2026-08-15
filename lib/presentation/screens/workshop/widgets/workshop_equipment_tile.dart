import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class WorkshopEquipmentTile extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double cost;
  final bool isOwned;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onBuy;

  const WorkshopEquipmentTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.isOwned,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
            ),
            child: Icon(icon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (isOwned)
                      const NeoBrutalBadge(
                        text: 'SAHİPSİN',
                        backgroundColor: Color(0xFF00E575),
                        textColor: Colors.black,
                        fontSize: 9,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwned ? 'Atölyeye kuruldu' : 'Fiyat: ${CurrencyFormatter.format(cost)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isOwned ? const Color(0xFF64748B) : const Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isOwned)
            NeoBrutalButton(
              label: 'SATIN AL',
              icon: Icons.shopping_cart_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 10.5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onPressed: onBuy,
            ),
        ],
      ),
    );
  }
}
