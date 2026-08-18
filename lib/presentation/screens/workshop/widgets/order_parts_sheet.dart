import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/part_order_model.dart';
import '../../../../domain/usecases/repair_engine.dart';
import '../../../widgets/neo_brutal_button.dart';

class OrderPartsSheet extends StatefulWidget {
  final CarModel car;
  final DealershipModel game;
  final Function(String partName, OrderType type, double cost, int durationSeconds) onOrderConfirmed;

  const OrderPartsSheet({
    super.key,
    required this.car,
    required this.game,
    required this.onOrderConfirmed,
  });

  static void show({
    required BuildContext context,
    required CarModel car,
    required DealershipModel game,
    required Function(String partName, OrderType type, double cost, int durationSeconds) onOrderConfirmed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return OrderPartsSheet(
          car: car,
          game: game,
          onOrderConfirmed: (partName, type, cost, duration) {
            Navigator.pop(ctx);
            onOrderConfirmed(partName, type, cost, duration);
          },
        );
      },
    );
  }

  @override
  State<OrderPartsSheet> createState() => _OrderPartsSheetState();
}

class _OrderPartsSheetState extends State<OrderPartsSheet> {
  static const List<String> _allParts = [
    'Ön Kaput',
    'Ön Tampon',
    'Tavan',
    'Sol Ön Kapı',
    'Sağ Ön Kapı',
    'Sol Çamurluk',
    'Sağ Çamurluk',
    'Bagaj Kapağı',
    'Motor Bloğu & Piston',
    'Şanzıman & Debriyaj',
  ];

  List<String> get _availableParts {
    final needed = <String>[];
    widget.car.expertise.bodyParts.forEach((part, status) {
      if (status == PartStatus.changed || status == PartStatus.damaged || status == PartStatus.painted) {
        needed.add(part);
      }
    });
    if (widget.car.expertise.engineCondition < 95.0) {
      needed.add('Motor Bloğu & Piston');
    }
    if (widget.car.expertise.transmissionCondition < 95.0) {
      needed.add('Şanzıman & Debriyaj');
    }

    if (needed.isNotEmpty) {
      return needed;
    }
    return _allParts;
  }

  late String _selectedPart;
  late List<String> _partsList;
  OrderType _selectedType = OrderType.newOemPart;

  @override
  void initState() {
    super.initState();
    _partsList = _availableParts;
    _selectedPart = _partsList.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFiltered = _partsList.length < _allParts.length;

    // Calculate dynamic discount from perks
    double discountFactor = 1.0;
    if ((widget.game.districtMarketShare['İkitelli Sanayi'] ?? 0.0) >= 0.50) {
      discountFactor *= 0.85; // İkitelli Sanayi %15 İndirim
    }
    if (widget.game.purchasedAcademyCourses.contains('course_mechanic_master')) {
      discountFactor *= 0.90; // Personel Akademisi Usta İndirimi %10
    }
    if (widget.game.specializationPath == SpecializationPath.restorer) {
      discountFactor *= 0.80; // Restoratör Usta Sınıf Bonusu %20
    }

    final cost = RepairEngine.calculatePartRepairCost(widget.car, _selectedPart, _selectedType, discountFactor: discountFactor);

    // Duration calculation (Academy mechanic master speeds up by 30%)
    final baseDuration = _selectedType == OrderType.quickPatch ? 30 : (_selectedType == OrderType.masterRepair ? 60 : (_selectedType == OrderType.salvagedScrap ? 20 : 120));
    final durationSeconds = widget.game.purchasedAcademyCourses.contains('course_mechanic_master')
        ? (baseDuration * 0.70).round()
        : baseDuration;

    final hasScrapParts = widget.game.salvagedParts.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YEDEK PARÇA SİPARİŞİ VER',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (isFiltered) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brutalYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brutalYellow, width: 1.5),
              ),
              child: Text(
                'DİNAMİK FİLTRE • Sadece hasarlı, boyalı veya değişen parçalar listeleniyor',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.brutalYellow : const Color(0xFF92400E),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Text('Parça Seçin:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPart,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E2330) : Colors.white,
                items: _partsList.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPart = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Tedarik / Parça Kalitesi:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (hasScrapParts) ...[
                _buildOrderTypeTile(
                  title: 'Çıkma Depo',
                  time: '$durationSeconds sn • ₺0',
                  type: OrderType.salvagedScrap,
                  selected: _selectedType,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedType = OrderType.salvagedScrap),
                ),
                const SizedBox(width: 6),
              ],
              _buildOrderTypeTile(
                title: 'Geçici Yama',
                time: '30 sn',
                type: OrderType.quickPatch,
                selected: _selectedType,
                isDark: isDark,
                onTap: () => setState(() => _selectedType = OrderType.quickPatch),
              ),
              const SizedBox(width: 6),
              _buildOrderTypeTile(
                title: 'Usta / Çıkma',
                time: '60 sn',
                type: OrderType.masterRepair,
                selected: _selectedType,
                isDark: isDark,
                onTap: () => setState(() => _selectedType = OrderType.masterRepair),
              ),
              const SizedBox(width: 6),
              _buildOrderTypeTile(
                title: 'Sıfır OEM',
                time: '120 sn',
                type: OrderType.newOemPart,
                selected: _selectedType,
                isDark: isDark,
                onTap: () => setState(() => _selectedType = OrderType.newOemPart),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sipariş Maliyeti', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                    Text(
                      _selectedType == OrderType.salvagedScrap ? '₺0 • Stoktan' : CurrencyFormatter.format(cost),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                    ),
                  ],
                ),
                Text(
                  'Teslimat: $durationSeconds Saniye',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalOrange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NeoBrutalButton(
            label: _selectedType == OrderType.salvagedScrap ? 'ÇIKMA PARÇAYI MONTE ET' : 'SİPARİŞİ ONAYLA VE GÖNDER',
            icon: Icons.shopping_cart_checkout_rounded,
            backgroundColor: AppColors.brutalGreen,
            textColor: Colors.black,
            fullWidth: true,
            onPressed: () => widget.onOrderConfirmed(_selectedPart, _selectedType, cost, durationSeconds),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeTile({
    required String title,
    required String time,
    required OrderType type,
    required OrderType selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSel = type == selected;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: isSel ? 2.0 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isSel ? Colors.black : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.black87 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
