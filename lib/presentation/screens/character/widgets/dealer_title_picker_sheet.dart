import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/mega_systems_extensions_model.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';

class DealerTitlePickerSheet extends StatelessWidget {
  final DealerTitle selectedTitle;
  final Function(DealerTitle title) onTitleSelected;

  const DealerTitlePickerSheet({
    super.key,
    required this.selectedTitle,
    required this.onTitleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Color(0xFF333B4F), width: 2.5),
          left: BorderSide(color: Color(0xFF333B4F), width: 2.5),
          right: BorderSide(color: Color(0xFF333B4F), width: 2.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333B4F), width: 2.0),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'GALERİCİ LAKAPLARI & ÜNVANLAR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Sanayi ve piyasada anıldığınız unvanı seçin; aktif perk kazanın.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          ...DealerTitle.values.map((title) {
            final isSelected = title == selectedTitle;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                  onTitleSelected(title);
                },
                borderRadius: BorderRadius.circular(10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFF141721),
                  borderColor: isSelected ? title.color : const Color(0xFF333B4F),
                  borderRadius: 10,
                  borderWidth: isSelected ? 2.5 : 2.0,
                  shadowOffset: isSelected ? const Offset(3, 3) : const Offset(2, 2),
                  child: Row(
                    children: [
                      Icon(title.icon, color: title.color, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.title,
                              style: TextStyle(
                                color: isSelected ? title.color : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title.description,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            NeoBrutalBadge(
                              icon: Icons.bolt_rounded,
                              text: title.perkDescription,
                              backgroundColor: const Color(0xFF1E2330),
                              textColor: title.color,
                              borderColor: title.color,
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: title.color, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
