import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/mega_systems_extensions_model.dart';
import '../../../widgets/neo_brutal_card.dart';

class ChipTuningModal extends StatelessWidget {
  final CarModel car;
  final Function(ChipTuningStage stage) onStageSelected;
  final VoidCallback onBodykitSelected;

  const ChipTuningModal({
    super.key,
    required this.car,
    required this.onStageSelected,
    required this.onBodykitSelected,
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
                child: const Icon(Icons.tune_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${car.brand} ${car.modelName} — TUNING',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStageCard(
            context,
            stage: ChipTuningStage.stage1,
            title: 'Stage 1 ECU Yazılım Remap',
            desc: '+35 HP Ekstra Güç & +%10 Araç Piyasa Değeri',
            cost: '₺4.500',
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 10),
          _buildStageCard(
            context,
            stage: ChipTuningStage.stage2,
            title: 'Stage 2 ECU + Downpipe & Popbang',
            desc: '+75 HP Ekstra Güç & +%22 Araç Piyasa Değeri',
            cost: '₺9.500',
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              onBodykitSelected();
            },
            borderRadius: BorderRadius.circular(10),
            child: const NeoBrutalCard(
              padding: EdgeInsets.all(12),
              backgroundColor: Color(0xFF141721),
              borderColor: Color(0xFFA855F7),
              borderRadius: 10,
              borderWidth: 2.0,
              shadowOffset: Offset(3, 3),
              child: Row(
                children: [
                  Icon(Icons.directions_car_filled_rounded, color: Color(0xFFA855F7), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Karbon Bodykit & Film', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                        Text('Agresif spoiler & 2 numara film • +%8 Değer', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('₺3.500', style: TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStageCard(
    BuildContext context, {
    required ChipTuningStage stage,
    required String title,
    required String desc,
    required String cost,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onStageSelected(stage);
      },
      borderRadius: BorderRadius.circular(10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFF141721),
        borderColor: color,
        borderRadius: 10,
        borderWidth: 2.0,
        shadowOffset: const Offset(3, 3),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                  Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
            ),
            Text(cost, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
