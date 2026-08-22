import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class DealershipIdentityScreen extends ConsumerStatefulWidget {
  const DealershipIdentityScreen({super.key});

  @override
  ConsumerState<DealershipIdentityScreen> createState() => _DealershipIdentityScreenState();
}

class _DealershipIdentityScreenState extends ConsumerState<DealershipIdentityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _galleryController;
  late String _selectedEmblem;
  late CharacterOrigin _selectedOrigin;

  final List<Map<String, String>> _emblems = const [
    {'id': 'crown', 'key': 'emblem_crown'},
    {'id': 'shield', 'key': 'emblem_shield'},
    {'id': 'star', 'key': 'emblem_star'},
    {'id': 'rare', 'key': 'emblem_diamond'},
    {'id': 'flash', 'key': 'emblem_flash'},
    {'id': 'streak', 'key': 'emblem_fire'},
    {'id': 'eagle', 'key': 'emblem_eagle'},
    {'id': 'vintage', 'key': 'emblem_vintage'},
  ];

  final List<Map<String, dynamic>> _origins = const [
    {
      'origin': CharacterOrigin.sanayiCiragi,
      'titleKey': 'origin_sanayi_title',
      'icon': Icons.build_circle_rounded,
      'color': Color(0xFFF97316),
      'descKey': 'origin_sanayi_desc',
      'perkKey': 'origin_sanayi_perk',
    },
    {
      'origin': CharacterOrigin.tuccarTorunu,
      'titleKey': 'origin_tuccar_title',
      'icon': Icons.handshake_rounded,
      'color': AppColors.brutalGreen,
      'descKey': 'origin_tuccar_desc',
      'perkKey': 'origin_tuccar_perk',
    },
    {
      'origin': CharacterOrigin.sehirliYatirimci,
      'titleKey': 'origin_sehirli_title',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF3B82F6),
      'descKey': 'origin_sehirli_desc',
      'perkKey': 'origin_sehirli_perk',
    },
    {
      'origin': CharacterOrigin.koleksiyoncuYegeni,
      'titleKey': 'origin_koleksiyoncu_title',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFFA855F7),
      'descKey': 'origin_koleksiyoncu_desc',
      'perkKey': 'origin_koleksiyoncu_perk',
    },
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(gameProvider);
    _nameController = TextEditingController(text: state.playerName);
    _galleryController = TextEditingController(text: state.dealershipName);
    _selectedEmblem = state.logoEmblemId;
    _selectedOrigin = state.characterOrigin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  void _saveIdentity() {
    final newPlayerName = _nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim();
    final newGalleryName = _galleryController.text.trim().isEmpty ? 'Miras Oto Galeri' : _galleryController.text.trim();

    ref.read(gameProvider.notifier).updateDealershipIdentity(
      playerName: newPlayerName,
      dealershipName: newGalleryName,
      logoEmblemId: _selectedEmblem,
      characterOrigin: _selectedOrigin,
    );

    NotificationService.showSuccess(context, context.tr('identity_saved_success'));

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('identity_screen_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Preview Identity Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: VectorIconWidget(
                    type: _selectedEmblem,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _galleryController.text.trim().isEmpty ? 'Miras Oto Galeri' : _galleryController.text.trim(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.rpgTitle} • ${_nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim()}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                      if (state.dynastyGeneration > 1) ...[
                        const SizedBox(height: 4),
                        NeoBrutalBadge(
                          text: context.tr('dynasty_generation_heritage', {'gen': state.dynastyGeneration}),
                          backgroundColor: const Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Input Fields
          Text(
            context.tr('identity_player_name_label'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            decoration: InputDecoration(
              labelText: context.tr('identity_player_name_label'),
              filled: true,
              fillColor: isDark ? const Color(0xFF141721) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _galleryController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            decoration: InputDecoration(
              labelText: context.tr('identity_dealership_name_label'),
              filled: true,
              fillColor: isDark ? const Color(0xFF141721) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Character Origin Selector (§2.1)
          Text(
            context.tr('identity_origin_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: _origins.map((item) {
              final CharacterOrigin orig = item['origin'] as CharacterOrigin;
              final isSelected = _selectedOrigin == orig;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedOrigin = orig),
                  borderRadius: BorderRadius.circular(12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isSelected
                        ? (isDark ? const Color(0xFF1E2638) : const Color(0xFFFEF9C3))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderColor: isSelected
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                    borderRadius: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    context.tr(item['titleKey'] as String),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    NeoBrutalBadge(
                                      text: context.tr('lifestyle_equipped_badge'),
                                      backgroundColor: AppColors.brutalGreen,
                                      textColor: Colors.black,
                                      fontSize: 10,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr(item['descKey'] as String),
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  context.tr(item['perkKey'] as String),
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 4. Emblem Selector
          Text(
            context.tr('identity_emblem_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emblems.map((e) {
              final isSelected = _selectedEmblem == e['id'];
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedEmblem = e['id']!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0F172A) : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VectorIconWidget(
                        type: e['id']!,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.tr(e['key']!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 5. Save Button
          NeoBrutalButton(
            label: context.tr('identity_save_btn'),
            icon: Icons.check_circle_rounded,
            backgroundColor: AppColors.brutalGreen,
            textColor: Colors.black,
            fontSize: 13,
            fullWidth: true,
            onPressed: _saveIdentity,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
