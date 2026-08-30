import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'scrapyard_install_dialog.dart';

class ScrapyardSalvagedPartsTab extends ConsumerStatefulWidget {
  const ScrapyardSalvagedPartsTab({super.key});

  @override
  ConsumerState<ScrapyardSalvagedPartsTab> createState() =>
      _ScrapyardSalvagedPartsTabState();
}

class _ScrapyardSalvagedPartsTabState
    extends ConsumerState<ScrapyardSalvagedPartsTab> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<(String id, String trKey, IconData icon)> _partCategories =
      const [
    ('all', 'scrap_cat_all', Icons.apps_rounded),
    ('engine', 'scrap_cat_engine', Icons.speed_rounded),
    ('transmission', 'scrap_cat_transmission', Icons.settings_input_component_rounded),
    ('ecu', 'scrap_cat_ecu', Icons.memory_rounded),
    ('brakes', 'scrap_cat_brakes', Icons.disc_full_rounded),
    ('bodywork', 'scrap_cat_bodywork', Icons.directions_car_rounded),
  ];

  Color _getTierColor(PartQualityTier tier) {
    switch (tier) {
      case PartQualityTier.worn:
        return const Color(0xFFEF4444);
      case PartQualityTier.usable:
        return const Color(0xFFF59E0B);
      case PartQualityTier.good:
        return const Color(0xFF3B82F6);
      case PartQualityTier.pristine:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salvagedParts = game.salvagedParts;

    final filteredParts = salvagedParts.where((part) {
      final matchesCat = _selectedCategory == 'all' ||
          (_selectedCategory == 'engine' &&
              (part.category == 'engine' ||
                  part.category == 'turbo' ||
                  part.category == 'radiator')) ||
          (_selectedCategory == 'transmission' &&
              part.category == 'transmission') ||
          (_selectedCategory == 'ecu' && part.category == 'ecu') ||
          (_selectedCategory == 'brakes' &&
              (part.category == 'brakes' || part.category == 'suspension')) ||
          (_selectedCategory == 'bodywork' &&
              (part.category == 'bodywork' ||
                  part.category == 'wheels' ||
                  part.category == 'headlights' ||
                  part.category == 'seats'));

      final matchesSearch = _searchQuery.isEmpty ||
          part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          part.carModelName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Search and Category Filter Bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          color: isDark ? const Color(0xFF12151E) : Colors.white,
          child: Column(
            children: [
              // Search box
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: context.tr('scrap_search_hint'),
                    hintStyle: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Categories horizontal bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _partCategories.map((cat) {
                    final isSelected = _selectedCategory == cat.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brutalYellow
                                : (isDark
                                    ? const Color(0xFF1A1F2C)
                                    : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.$3,
                                size: 13,
                                color: isSelected
                                    ? Colors.black
                                    : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF334155)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.tr(cat.$2),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark
                                          ? Colors.white70
                                          : const Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Parts List
        Expanded(
          child: filteredParts.isEmpty
              ? Center(
                  child: NeoBrutalCard(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(28),
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFF0F172A),
                    borderRadius: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_rounded,
                            color: Color(0xFF64748B), size: 40),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('scrap_no_parts_found'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedCategory == 'all' && _searchQuery.isEmpty
                              ? context.tr('scrap_no_parts_desc_all')
                              : context.tr('scrap_no_parts_desc_filter'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredParts.length,
                  itemBuilder: (context, index) {
                    final part = filteredParts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(12),
                        backgroundColor:
                            isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFF0F172A),
                        borderRadius: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    part.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                NeoBrutalBadge(
                                  text: part.tierName,
                                  backgroundColor: _getTierColor(part.tier),
                                  textColor: Colors.white,
                                  fontSize: 9.5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Model: ${part.carModelName} • Kondisyon: %${part.conditionPercent}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    CurrencyFormatter.formatShort(
                                        part.estimatedValue),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brutalGreen),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (part.canRefurbish) ...[
                                      NeoBrutalButton(
                                        label: context.tr(
                                            'scrap_btn_refurbish', {
                                          'cost':
                                              '₺${part.refurbishCost.toInt()}'
                                        }),
                                        icon: Icons.auto_fix_high_rounded,
                                        backgroundColor:
                                            AppColors.brutalPurple,
                                        textColor: Colors.white,
                                        fontSize: 10,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        onPressed: () {
                                          if (game.balance <
                                              part.refurbishCost) {
                                            NotificationService.showError(
                                              context,
                                              context.tr(
                                                  'toast_insufficient_balance_needed',
                                                  {
                                                    'cost': CurrencyFormatter
                                                        .formatShort(
                                                            part.refurbishCost)
                                                  }),
                                            );
                                            return;
                                          }
                                          final success = ref
                                              .read(gameProvider.notifier)
                                              .refurbishSalvagedPart(part.id);
                                          if (success) {
                                            NotificationService.showSuccess(
                                              context,
                                              context.tr(
                                                  'scrapyard_toast_refurbish_done'),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    NeoBrutalButton(
                                      label: context.tr('scrap_btn_install'),
                                      icon: Icons.handyman_rounded,
                                      backgroundColor: isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0),
                                      textColor:
                                          isDark ? Colors.white : Colors.black,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      onPressed: () =>
                                          ScrapyardInstallDialog.show(
                                              context, ref, part),
                                    ),
                                    const SizedBox(width: 6),
                                    NeoBrutalButton(
                                      label: context.tr('scrap_btn_sell'),
                                      icon: Icons.attach_money_rounded,
                                      backgroundColor: AppColors.brutalGreen,
                                      textColor: Colors.black,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      onPressed: () {
                                        final success = ref
                                            .read(gameProvider.notifier)
                                            .sellSalvagedPart(part.id);
                                        if (success) {
                                          NotificationService.showSuccess(
                                            context,
                                            '${part.name} ${CurrencyFormatter.formatShort(part.estimatedValue)} karşılığı satıldı!',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
