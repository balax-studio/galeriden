import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/part_order_model.dart';
import '../../../../domain/usecases/repair_engine.dart';
import '../../../widgets/neo_brutal_button.dart';

class OrderPartsSheet extends StatefulWidget {
  final CarModel car;
  final DealershipModel game;
  final Function(
          String partName, OrderType type, double cost, int durationSeconds)
      onOrderConfirmed;

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
    required Function(
            String partName, OrderType type, double cost, int durationSeconds)
        onOrderConfirmed,
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
  List<String> get _availableParts =>
      RepairEngine.getNeededPartsForCar(widget.car);

  late String _selectedPart;
  late List<String> _partsList;
  OrderType _selectedType = OrderType.newOemPart;
  bool _isSubmitting = false;

  bool _isPartPending(String partName) {
    return widget.game.pendingOrders.any((o) =>
        o.carId == widget.car.id &&
        (o.partName.toLowerCase().trim() == partName.toLowerCase().trim() ||
            RepairEngine.resolveBodyPartKey(
                    widget.car.expertise.bodyParts, o.partName) ==
                RepairEngine.resolveBodyPartKey(
                    widget.car.expertise.bodyParts, partName)));
  }

  @override
  void initState() {
    super.initState();
    _partsList = _availableParts;
    final unassigned = _partsList.where((p) => !_isPartPending(p)).toList();
    if (unassigned.isNotEmpty) {
      _selectedPart = unassigned.first;
    } else if (_partsList.isNotEmpty) {
      _selectedPart = _partsList.first;
    } else {
      _selectedPart = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if vehicle has no needed parts or all parts are already in cargo
    final hasNoNeededParts = _partsList.isEmpty;
    final carPendingOrders = widget.game.pendingOrders
        .where((o) => o.carId == widget.car.id)
        .toList();
    final allPartsInCargo =
        !hasNoNeededParts && _partsList.every((p) => _isPartPending(p));

    if (hasNoNeededParts) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('order_parts_sheet_title'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brutalGreen, width: 2.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 44, color: AppColors.brutalGreen),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('order_parts_no_need_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF065F46),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.car.brand} ${widget.car.modelName} • ${widget.car.modelYear}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('order_parts_no_need_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              NeoBrutalButton(
                label: context.tr('order_parts_btn_no_need'),
                icon: Icons.check_circle_outline_rounded,
                backgroundColor:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFCBD5E1),
                textColor: isDark ? Colors.white54 : Colors.black54,
                fullWidth: true,
                onPressed: null,
              ),
            ],
          ),
        ),
      );
    }

    if (allPartsInCargo) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('order_parts_sheet_title'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A1B4E).withValues(alpha: 0.3)
                      : const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFA855F7), width: 2.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_shipping_rounded,
                        size: 42, color: Color(0xFFA855F7)),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('order_parts_all_pending_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF581C87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.car.brand} ${widget.car.modelName} • ${carPendingOrders.length} Sipariş',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('order_parts_all_pending_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B21A8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...carPendingOrders.map((o) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2330)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o.partName,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                              Text('${o.remainingSeconds} s',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brutalOrange)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              NeoBrutalButton(
                label: context.tr('order_parts_btn_all_pending'),
                icon: Icons.hourglass_top_rounded,
                backgroundColor:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFCBD5E1),
                textColor: isDark ? Colors.white54 : Colors.black54,
                fullWidth: true,
                onPressed: null,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate dynamic discount from perks
    double discountFactor = 1.0;
    if ((widget.game.districtMarketShare['İkitelli Sanayi'] ?? 0.0) >= 0.50) {
      discountFactor *= 0.85; // İkitelli Sanayi %15 İndirim
    }
    if (widget.game.purchasedAcademyCourses
        .contains('course_mechanic_master')) {
      discountFactor *= 0.90; // Personel Akademisi Usta İndirimi %10
    }
    if (widget.game.specializationPath == SpecializationPath.restorer) {
      discountFactor *= 0.80; // Restoratör Usta Sınıf Bonusu %20
    }

    final cost = _selectedPart.isNotEmpty
        ? RepairEngine.calculatePartRepairCost(
            widget.car, _selectedPart, _selectedType,
            discountFactor: discountFactor)
        : 0.0;

    // Duration calculation (Academy mechanic master speeds up by 30%)
    final baseDuration = _selectedType == OrderType.quickPatch
        ? 30
        : (_selectedType == OrderType.masterRepair
            ? 60
            : (_selectedType == OrderType.salvagedScrap ? 20 : 120));
    final durationSeconds =
        widget.game.purchasedAcademyCourses.contains('course_mechanic_master')
            ? (baseDuration * 0.70).round()
            : baseDuration;

    final hasScrapParts = widget.game.salvagedParts.isNotEmpty;
    final isPending = _isPartPending(_selectedPart);
    final canAfford = _selectedType == OrderType.salvagedScrap
        ? widget.game.salvagedParts.isNotEmpty
        : (widget.game.balance >= cost);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    context.tr('order_parts_sheet_title'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                  )),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.brutalYellow, width: 1.5),
                ),
                child: Text(
                  context.tr('order_parts_filter_badge'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.brutalYellow
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(context.tr('order_parts_select_part'),
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPart.isNotEmpty ? _selectedPart : null,
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF1E2330) : Colors.white,
                    items: _partsList.map((p) {
                      final conditionDesc =
                          RepairEngine.getPartConditionDescription(
                              widget.car, p);
                      final pending = _isPartPending(p);

                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$p • $conditionDesc',
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (pending) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA855F7)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFA855F7),
                                      width: 1),
                                ),
                                child: Text(
                                  context.tr('order_parts_badge_pending'),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFA855F7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPart = val);
                      }
                    },
                  ),
                ),
              ),
              if (_selectedPart.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.brutalYellow
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mevcut: ${RepairEngine.getPartConditionDescription(widget.car, _selectedPart)} • Hedef: ${_selectedType == OrderType.newOemPart ? "Orijinal Sıfır • %100" : (_selectedType == OrderType.salvagedScrap ? "Çıkma Orijinal • %90" : (_selectedType == OrderType.masterRepair ? "Boyalı • %95 Usta" : "Geçici Onarım • %75"))}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(context.tr('order_parts_select_quality'),
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (hasScrapParts) ...[
                    _buildOrderTypeTile(
                      title: context.tr('order_parts_salvaged'),
                      time: '$durationSeconds s',
                      type: OrderType.salvagedScrap,
                      selected: _selectedType,
                      isDark: isDark,
                      onTap: () => setState(
                          () => _selectedType = OrderType.salvagedScrap),
                    ),
                    const SizedBox(width: 6),
                  ],
                  _buildOrderTypeTile(
                    title: context.tr('order_parts_quick'),
                    time: '30 s',
                    type: OrderType.quickPatch,
                    selected: _selectedType,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _selectedType = OrderType.quickPatch),
                  ),
                  const SizedBox(width: 6),
                  _buildOrderTypeTile(
                    title: context.tr('order_parts_master'),
                    time: '60 s',
                    type: OrderType.masterRepair,
                    selected: _selectedType,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _selectedType = OrderType.masterRepair),
                  ),
                  const SizedBox(width: 6),
                  _buildOrderTypeTile(
                    title: context.tr('order_parts_oem'),
                    time: '120 s',
                    type: OrderType.newOemPart,
                    selected: _selectedType,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _selectedType = OrderType.newOemPart),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('order_parts_cost_label'),
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B))),
                        Text(
                          _selectedType == OrderType.salvagedScrap
                              ? '0 • Stock'
                              : CurrencyFormatter.format(cost),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        context.tr('order_parts_delivery_time',
                            {'sec': durationSeconds}),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brutalOrange),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: isPending
                    ? context.tr('order_card_already_pending')
                    : (_selectedType == OrderType.salvagedScrap
                        ? context.tr('order_parts_btn_salvage')
                        : context.tr('order_parts_btn_confirm')),
                icon: isPending
                    ? Icons.hourglass_top_rounded
                    : Icons.shopping_cart_checkout_rounded,
                backgroundColor: isPending
                    ? (isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFCBD5E1))
                    : AppColors.brutalGreen,
                textColor: isPending
                    ? (isDark ? Colors.white60 : Colors.black54)
                    : Colors.black,
                fullWidth: true,
                onPressed: (!isPending && canAfford && !_isSubmitting)
                    ? () {
                        setState(() => _isSubmitting = true);
                        widget.onOrderConfirmed(_selectedPart, _selectedType,
                            cost, durationSeconds);
                      }
                    : null,
              ),
            ],
          ),
        ),
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
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.brutalYellow
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel
                  ? const Color(0xFF0F172A)
                  : (isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFFCBD5E1)),
              width: isSel ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSel
                      ? const Color(0xFF0F172A)
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSel
                      ? const Color(0xFF0F172A).withValues(alpha: 0.7)
                      : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
