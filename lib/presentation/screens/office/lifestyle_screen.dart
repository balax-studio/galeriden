import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/lifestyle_item_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class LifestyleScreen extends ConsumerStatefulWidget {
  const LifestyleScreen({super.key});

  @override
  ConsumerState<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends ConsumerState<LifestyleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    final suits = LifestyleItemModel.allItems.where((i) => i.category == 'suit').toList();
    final accessories = LifestyleItemModel.allItems.where((i) => i.category == 'accessory').toList();
    final officeDecors = LifestyleItemModel.allItems.where((i) => i.category == 'officeDecor').toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: 'KİŞİSEL TARZ & PRESTİJ MASASI',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: CurrencyFormatter.formatShort(game.balance),
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Persona Status & Passive Perks Summary Card
                  NeoBrutalCard(
                    borderColor: const Color(0xFFEAB308),
                    borderWidth: 2.5,
                    backgroundColor: isDark ? const Color(0xFF1E1D11) : const Color(0xFFFEFCE8),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAB308),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.black, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${game.playerName} • ${game.rpgTitle}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kuşanılan Lüks Eşyalar & Aktif Pasif Auralar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF141721) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPerkMetric(
                                'Pazarlık Otoritesi',
                                '+%${(game.lifestyleNegotiationBonus * 100).toInt()}',
                                const Color(0xFF38BDF8),
                                isDark,
                              ),
                              _buildPerkMetric(
                                'Zengin Müşteri',
                                '+%${(game.lifestyleRichCustomerBonus * 100).toInt()}',
                                const Color(0xFFFFDE59),
                                isDark,
                              ),
                              _buildPerkMetric(
                                'Faiz İndirimi',
                                '-%${(game.lifestyleInterestDiscount * 100).toInt()}',
                                const Color(0xFF10B981),
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Neo Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                        width: 2,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: const Color(0xFFFFDE59),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2,
                        ),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
                      tabs: const [
                        Tab(text: 'TAKIM ELBİSE'),
                        Tab(text: 'SAAT & TESBİH'),
                        Tab(text: 'MAKAM & OFİS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildItemsList(suits, game, isDark),
            _buildItemsList(accessories, game, isDark),
            _buildItemsList(officeDecors, game, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkMetric(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<LifestyleItemModel> items, dynamic game, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = game.ownedLifestyleItems.contains(item.id);
        final isEquipped = game.equippedSuitId == item.id ||
            game.equippedAccessoryId == item.id ||
            game.equippedOfficeDecorId == item.id;
        final canAfford = game.balance >= item.price;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NeoBrutalCard(
            borderColor: isEquipped
                ? const Color(0xFFEAB308)
                : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
            borderWidth: isEquipped ? 2.5 : 2,
            backgroundColor: isEquipped
                ? (isDark ? const Color(0xFF1E1D11) : const Color(0xFFFEFCE8))
                : (isDark ? const Color(0xFF141721) : Colors.white),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isEquipped
                            ? const Color(0xFFFFDE59)
                            : (isDark ? const Color(0xFF2A3142) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getItemIcon(item.iconType),
                        color: isEquipped ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (isEquipped)
                                const NeoBrutalBadge(
                                  text: 'KUŞANILDI',
                                  backgroundColor: Color(0xFF10B981),
                                  textColor: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          NeoBrutalBadge(
                            text: '+${item.reputationBonus} İtibar Puanı',
                            backgroundColor: const Color(0xFFFFDE59),
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                // Perk Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (item.negotiationBonus > 0)
                      _buildMiniBadge('Pazarlık: +%${(item.negotiationBonus * 100).toInt()}', const Color(0xFF38BDF8), isDark),
                    if (item.richCustomerBonus > 0)
                      _buildMiniBadge('Zengin Alıcı: +%${(item.richCustomerBonus * 100).toInt()}', const Color(0xFFFFDE59), isDark),
                    if (item.interestDiscount > 0)
                      _buildMiniBadge('Faiz İndirimi: -%${(item.interestDiscount * 100).toInt()}', const Color(0xFF10B981), isDark),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isOwned)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SATIŞ FİYATI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatShort(item.price),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: canAfford
                                  ? (isDark ? const Color(0xFFFFDE59) : const Color(0xFFD97706))
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Koleksiyonunuzda Mevcut',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    if (!isOwned)
                      NeoBrutalButton(
                        label: 'SATIN AL & KUŞAN',
                        backgroundColor: canAfford ? const Color(0xFFFFDE59) : const Color(0xFF64748B),
                        textColor: canAfford ? Colors.black : Colors.white,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        onPressed: canAfford ? () => _buyItem(item) : null,
                      )
                    else if (!isEquipped)
                      NeoBrutalButton(
                        label: 'ÜZERİNE KUŞAN',
                        backgroundColor: const Color(0xFF38BDF8),
                        textColor: Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        onPressed: () => _equipItem(item),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(40) : color.withAlpha(30),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'suit':
        return Icons.dry_cleaning_rounded;
      case 'tasbih':
        return Icons.lens_blur_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'chair':
        return Icons.chair_rounded;
      case 'coffee':
        return Icons.coffee_maker_rounded;
      case 'desk':
        return Icons.table_restaurant_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  void _buyItem(LifestyleItemModel item) {
    HapticFeedback.heavyImpact();
    final success = ref.read(gameProvider.notifier).buyLifestyleItem(item);

    if (success) {
      NotificationService.showSuccess(
        context,
        '${item.name} satın alındı ve üzerinize kuşandı! Karizmanız ve itibarınız arttı.',
      );
    } else {
      NotificationService.showError(context, 'Bütçeniz bu lüks ürün için yetersiz.');
    }
  }

  void _equipItem(LifestyleItemModel item) {
    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).equipLifestyleItem(item);
    NotificationService.showSuccess(context, '${item.name} üzerinize kuşandı.');
  }
}
