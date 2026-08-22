import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../domain/usecases/special_plate_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class SpecialPlateScreen extends ConsumerStatefulWidget {
  const SpecialPlateScreen({super.key});

  @override
  ConsumerState<SpecialPlateScreen> createState() => _SpecialPlateScreenState();
}

class _SpecialPlateScreenState extends ConsumerState<SpecialPlateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PlateCategory _selectedCategory = PlateCategory.all;

  // Custom Designer State
  String _customCityCode = '34';
  final TextEditingController _lettersController = TextEditingController(text: 'ATA');
  final TextEditingController _digitsController = TextEditingController(text: '1923');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lettersController.dispose();
    _digitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'ÖZEL PLAKA TESCİL MASASI',
      ),
      body: Column(
        children: [
          // 1. Balance & Summary Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: NeoBrutalCard(
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
                          color: const Color(0xFFFFDE59),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.confirmation_number_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kasa Bakiyesi',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(game.balance),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.brutalGreen : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      NeoBrutalBadge(
                        text: '${game.ownedCars.length} ARAÇ GARAJDA',
                        icon: Icons.directions_car_rounded,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 10,
                      ),
                      const SizedBox(width: 6),
                      NeoBrutalBadge(
                        text: '%35E KADAR DEĞER',
                        icon: Icons.trending_up_rounded,
                        backgroundColor: const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Custom Tabs Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                  width: 2.0,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark ? AppColors.brutalYellow : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: isDark ? Colors.black : Colors.white,
                unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_view_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('VİTRİN KATALOĞU'),
                      ],
                    ),
                  ),
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('ÖZEL PLAKA TASARLA'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCatalogTab(isDark, game.balance),
                _buildDesignerTab(isDark, game.balance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: CURATED CATALOG
  // ==========================================
  Widget _buildCatalogTab(bool isDark, double playerBalance) {
    final filteredPlates = SpecialPlateEngine.curatedPlates.where((plate) {
      if (_selectedCategory == PlateCategory.all) return true;
      return plate.category == _selectedCategory;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      physics: const BouncingScrollPhysics(),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildCategoryChip('TÜMÜ', PlateCategory.all, isDark),
              _buildCategoryChip('EFSANEVİ & PRESTİJ', PlateCategory.legendary, isDark),
              _buildCategoryChip('TAKIM & TARAFTAR', PlateCategory.team, isDark),
              _buildCategoryChip('ÖZEL İSİMLER', PlateCategory.names, isDark),
              _buildCategoryChip('SİMETRİK & TEKRAR', PlateCategory.symmetric, isDark),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Plates List
        ...filteredPlates.map((plate) => _buildPlateCard(plate, isDark, playerBalance)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryChip(String label, PlateCategory category, bool isDark) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedCategory = category);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brutalYellow
                : (isDark ? const Color(0xFF141721) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
              width: 1.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlateCard(SpecialPlateItem plate, bool isDark, double playerBalance) {
    final bool canAfford = playerBalance >= plate.price;

    Color rarityColor;
    String rarityBadgeText;

    switch (plate.rarity) {
      case 'legendary':
        rarityColor = AppColors.brutalYellow;
        rarityBadgeText = 'EFSANEVİ TESCİL';
        break;
      case 'symmetric':
        rarityColor = const Color(0xFF38BDF8);
        rarityBadgeText = 'SİMETRİK SERİ';
        break;
      case 'repeated':
        rarityColor = AppColors.brutalOrange;
        rarityBadgeText = 'TEKRARLI RAKAM';
        break;
      default:
        rarityColor = const Color(0xFF94A3B8);
        rarityBadgeText = 'ÖZEL TALEP';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badges & City
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: rarityBadgeText,
                      backgroundColor: rarityColor,
                      textColor: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(width: 6),
                    NeoBrutalBadge(
                      text: '+%${plate.valueBonusPercent} DEĞER',
                      icon: Icons.trending_up_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                Text(
                  '${plate.city} Tescil',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Turkish Plate Display Widget
            _buildTurkishPlateWidget(plate.plateNumber, isDark, isLegendary: plate.rarity == 'legendary'),
            const SizedBox(height: 10),

            // Title & Description
            Text(
              plate.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              plate.description,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Price & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tescil Harcı',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(plate.price),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                NeoBrutalButton(
                  label: canAfford ? 'Satın Al & Araca Tak' : 'YETERSİZ BAKİYE',
                  icon: Icons.check_circle_outline_rounded,
                  backgroundColor: canAfford ? AppColors.brutalGreen : const Color(0xFF334155),
                  textColor: canAfford ? Colors.black : const Color(0xFF94A3B8),
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: canAfford ? () => _openVehicleAssignmentSheet(plate) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: INTERACTIVE CUSTOM DESIGNER
  // ==========================================
  Widget _buildDesignerTab(bool isDark, double playerBalance) {
    final customPlate = SpecialPlateEngine.evaluateCustomPlate(
      cityCode: _customCityCode,
      letters: _lettersController.text,
      digits: _digitsController.text,
    );

    final bool canAfford = playerBalance >= customPlate.price;

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Live Plate Preview
        NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CANLI PLAKA ÖNİZLEMESİ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  NeoBrutalBadge(
                    text: customPlate.rarity == 'legendary'
                        ? 'EFSANEVİ SERİ'
                        : (customPlate.rarity == 'symmetric'
                            ? 'SİMETRİK UYUM'
                            : (customPlate.rarity == 'repeated' ? 'TEKRARLI' : 'STANDART ÖZEL')),
                    backgroundColor: customPlate.rarity == 'legendary'
                        ? AppColors.brutalYellow
                        : (customPlate.rarity == 'symmetric' ? const Color(0xFF38BDF8) : AppColors.brutalGreen),
                    textColor: Colors.black,
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTurkishPlateWidget(
                customPlate.plateNumber,
                isDark,
                isLegendary: customPlate.rarity == 'legendary',
                isLarge: true,
              ),
              const SizedBox(height: 12),
              Text(
                customPlate.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                customPlate.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Custom Inputs Card
        NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLAKA PARAMETRELERİNİ BELİRLE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // City Code Selector
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İl Kodu',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 1.8,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _customCityCode,
                              dropdownColor: isDark ? const Color(0xFF141721) : Colors.white,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_rounded),
                              items: SpecialPlateEngine.cityCodeMap.entries.map((e) {
                                return DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    '${e.key} • ${e.value}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _customCityCode = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Letters Input
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harf Grubu',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _lettersController,
                          maxLength: 4,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 1.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.2),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Digits Input
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rakam Grubu',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _digitsController,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 1.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.2),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fee Breakdown & Action
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF191F2D) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesaplanan Harç Bedeli',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(customPlate.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                    NeoBrutalButton(
                      label: canAfford ? 'Tescil Et & Araca Tak' : 'YETERSİZ BAKİYE',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: canAfford ? AppColors.brutalGreen : const Color(0xFF334155),
                      textColor: canAfford ? Colors.black : const Color(0xFF94A3B8),
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      onPressed: canAfford ? () => _openVehicleAssignmentSheet(customPlate) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================
  // VEHICLE SELECTION BOTTOM SHEET
  // ==========================================
  void _openVehicleAssignmentSheet(SpecialPlateItem plate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.read(gameProvider);
    final ownedCars = game.ownedCars.where((c) => !c.isRented).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.brutalYellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.directions_car_rounded, size: 20, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PLAKAYI ARACA ATA',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Yeni Plaka: ${plate.plateNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.brutalYellow : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (ownedCars.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141721) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.no_crash_rounded, size: 36, color: isDark ? Colors.white38 : Colors.black38),
                        const SizedBox(height: 10),
                        const Text(
                          'Garajında Plaka Takılacak Araç Bulunmuyor!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pazardan veya gümrükten bir araç satın alarak özel plakanı takabilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text(
                    'GARAJDAKİ ARAÇLARIN',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ownedCars.map((car) => _buildCarAssignmentCard(car, plate, isDark)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarAssignmentCard(CarModel car, SpecialPlateItem plate, bool isDark) {
    // Project new market value with target plate
    final tempCarWithNewPlate = car.copyWith(
      plateNumber: plate.plateNumber,
      plateRarity: plate.rarity,
    );
    final double currentValue = car.estimatedRealValue;
    final double projectedValue = tempCarWithNewPlate.estimatedRealValue;
    final double profitGain = projectedValue - currentValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
        borderRadius: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.modelYear} ${car.brand} ${car.modelName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Eski Plaka: ${car.plateNumber}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Değer Artışı: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '+${CurrencyFormatter.formatShort(profitGain)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeoBrutalButton(
              label: 'BU ARACA TAK',
              icon: Icons.check_circle_rounded,
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              fontSize: 11,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop();

                final success = ref.read(gameProvider.notifier).buyAndAssignPlate(
                      carId: car.id,
                      plateNumber: plate.plateNumber,
                      plateRarity: plate.rarity,
                      cost: plate.price,
                      reputationBonus: plate.reputationReward,
                    );

                if (success) {
                  NotificationService.showSuccess(
                    context,
                    '${plate.plateNumber} Plakası ${car.brand} ${car.modelName} Aracına Başarıyla Tescillendi! Değeri Artırıldı!',
                  );
                } else {
                  NotificationService.showError(
                    context,
                    'Plaka tescil işlemi tamamlanamadı. Yetersiz bakiye veya araç durumu uygun değil.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // REALISTIC TURKISH LICENSE PLATE WIDGET
  // ==========================================
  Widget _buildTurkishPlateWidget(
    String plateText,
    bool isDark, {
    bool isLegendary = false,
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 8 : 6, vertical: isLarge ? 6 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLegendary ? const Color(0xFFEAB308) : const Color(0xFF0F172A),
          width: isLegendary ? 2.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isLegendary ? const Color(0xFFEAB308).withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.15),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue TR Stripe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Plate Text
          Text(
            plateText.toUpperCase(),
            style: TextStyle(
              fontSize: isLarge ? 17 : 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: const Color(0xFF0F172A),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
