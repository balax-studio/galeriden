import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';

class TurkishHospitalityBar extends StatelessWidget {
  final VoidCallback onTeaTreated;
  final VoidCallback onCoffeeTreated;
  final Function(String cityCode) onPlateGifted;
  final bool isBusy;

  const TurkishHospitalityBar({
    super.key,
    required this.onTeaTreated,
    required this.onCoffeeTreated,
    required this.onPlateGifted,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: const Color(0xFF141721),
      borderColor: AppColors.brutalYellow,
      borderRadius: 12,
      borderWidth: 2.0,
      shadowOffset: const Offset(3, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF333B4F), width: 1.5),
                ),
                child: const Icon(Icons.emoji_food_beverage_rounded, color: Colors.black, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'ESNAF İKRAMI & HATIR KARTLARI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const NeoBrutalBadge(
                text: 'İNAT KIRICI',
                backgroundColor: Color(0xFF10B981),
                textColor: Colors.white,
                fontSize: 8.5,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Tavşan Çay',
                  cost: '₺50',
                  icon: Icons.emoji_food_beverage_rounded,
                  color: AppColors.errorRed,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTeaTreated();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Közde Kahve',
                  cost: '₺150',
                  icon: Icons.local_cafe_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onCoffeeTreated();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Özel Plaka',
                  cost: '₺500',
                  icon: Icons.confirmation_number_rounded,
                  color: const Color(0xFF38BDF8),
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _showPlateDialog(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String title,
    required String cost,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isBusy ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        backgroundColor: const Color(0xFF1E2330),
        borderColor: color,
        borderRadius: 8,
        borderWidth: 1.5,
        shadowOffset: const Offset(2, 2),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              cost,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlateDialog(BuildContext context) {
    final codes = ['06 Ankara', '34 İstanbul', '35 İzmir', '61 Trabzon', '01 Adana', '16 Bursa'];
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: const Color(0xFF0F172A),
          borderColor: const Color(0xFF38BDF8),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF333B4F), width: 1.5),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'MEMLEKET PLAKASI SEÇ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...codes.map((c) {
                final code = c.substring(0, 2);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onPlateGifted(code);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      backgroundColor: const Color(0xFF141721),
                      borderColor: const Color(0xFF333B4F),
                      borderRadius: 8,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(2, 2),
                      child: Row(
                        children: [
                          Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                          const Spacer(),
                          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF38BDF8), size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
