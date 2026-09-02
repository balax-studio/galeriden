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
import '../../providers/tutorial_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/dealership_logo_badge.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/tutorial_pulse_target.dart';
import '../../widgets/neo_brutal_card.dart';

class DealershipIdentityScreen extends ConsumerStatefulWidget {
  const DealershipIdentityScreen({super.key});

  @override
  ConsumerState<DealershipIdentityScreen> createState() =>
      _DealershipIdentityScreenState();
}

class _DealershipIdentityScreenState
    extends ConsumerState<DealershipIdentityScreen> {
  late TextEditingController _nameController;
  late TextEditingController _galleryController;
  late TextEditingController _taglineController;
  late String _selectedEmblem;
  late String _selectedShape;
  late String _selectedColor;
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
    {'id': 'turbo', 'key': 'emblem_turbo'},
    {'id': 'race_flag', 'key': 'emblem_race_flag'},
    {'id': 'piston', 'key': 'emblem_piston'},
    {'id': 'bull', 'key': 'emblem_bull'},
    {'id': 'lion', 'key': 'emblem_lion'},
    {'id': 'cobra', 'key': 'emblem_cobra'},
    {'id': 'trophy', 'key': 'emblem_trophy'},
    {'id': 'compass', 'key': 'emblem_compass'},
    {'id': 'crescent', 'key': 'emblem_crescent'},
    {'id': 'swords', 'key': 'emblem_swords'},
  ];

  final List<Map<String, String>> _shapes = const [
    {'id': 'square', 'key': 'badge_shape_square'},
    {'id': 'circle', 'key': 'badge_shape_circle'},
    {'id': 'shield', 'key': 'badge_shape_shield'},
    {'id': 'hexagon', 'key': 'badge_shape_hexagon'},
    {'id': 'laurel', 'key': 'badge_shape_laurel'},
  ];

  final List<Map<String, dynamic>> _colors = const [
    {'id': 'yellow', 'key': 'badge_color_yellow', 'color': Color(0xFFFFDE59)},
    {'id': 'blue', 'key': 'badge_color_blue', 'color': Color(0xFF3B82F6)},
    {'id': 'red', 'key': 'badge_color_red', 'color': Color(0xFFEF4444)},
    {'id': 'green', 'key': 'badge_color_green', 'color': Color(0xFF10B981)},
    {'id': 'purple', 'key': 'badge_color_purple', 'color': Color(0xFFA855F7)},
    {'id': 'dark', 'key': 'badge_color_dark', 'color': Color(0xFF1E293B)},
    {'id': 'cyan', 'key': 'badge_color_cyan', 'color': Color(0xFF06B6D4)},
    {'id': 'orange', 'key': 'badge_color_orange', 'color': Color(0xFFF97316)},
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
    _taglineController = TextEditingController(text: state.dealershipTagline);
    _selectedEmblem = state.logoEmblemId;
    _selectedShape = state.logoBadgeShape;
    _selectedColor = state.logoBadgeColor;
    _selectedOrigin = state.characterOrigin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _galleryController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  void _saveIdentity() {
    final newPlayerName = _nameController.text.trim().isEmpty
        ? 'Kaptan'
        : _nameController.text.trim();
    final newGalleryName = _galleryController.text.trim().isEmpty
        ? 'Miras Oto Galeri'
        : _galleryController.text.trim();
    final newTagline = _taglineController.text.trim();

    ref.read(gameProvider.notifier).updateDealershipIdentity(
          playerName: newPlayerName,
          dealershipName: newGalleryName,
          logoEmblemId: _selectedEmblem,
          logoBadgeShape: _selectedShape,
          logoBadgeColor: _selectedColor,
          dealershipTagline: newTagline,
          characterOrigin: _selectedOrigin,
        );

    NotificationService.showSuccess(
        context, context.tr('identity_saved_success'));

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

    final currentTagline = _taglineController.text.trim();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('identity_screen_title'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: NeoBrutalButton(
              label: context.tr('identity_skip_to_dashboard_btn'),
              backgroundColor: isDark
                  ? const Color(0xFF1E2330)
                  : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white70 : const Color(0xFF0F172A),
              borderColor: isDark
                  ? const Color(0xFF333B4F)
                  : const Color(0xFF0F172A),
              fontSize: 10.5,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: () {
                ref.read(gameProvider.notifier).skipTutorial();
                ref.read(tutorialProvider.notifier).skipTutorial();
                context.go('/dashboard');
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Live Identity Preview Showcase Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DealershipLogoBadge(
                  emblemId: _selectedEmblem,
                  badgeShape: _selectedShape,
                  badgeColor: _selectedColor,
                  size: 56,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _galleryController.text.trim().isEmpty
                            ? 'Miras Oto Galeri'
                            : _galleryController.text.trim(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentTagline.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          currentTagline,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: DealershipLogoBadge.getBackgroundColor(
                                _selectedColor),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        '${state.corporateTierTitle} • ${_nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim()}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B)),
                      ),
                      if (state.dynastyGeneration > 1) ...[
                        const SizedBox(height: 4),
                        NeoBrutalBadge(
                          text: context.tr('dynasty_generation_heritage',
                              {'gen': state.dynastyGeneration}),
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

          // 2. Input Fields: Owner Name & Dealership Name
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
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.brutalYellow, width: 2.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.brutalYellow, width: 2.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Tagline / Motto Field + Quick Presets
          Text(
            context.tr('identity_tagline_label'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _taglineController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            decoration: InputDecoration(
              hintText: context.tr('identity_tagline_hint'),
              filled: true,
              fillColor: isDark ? const Color(0xFF141721) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.brutalYellow, width: 2.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPresetChip(context.tr('tagline_preset_1'), isDark),
              _buildPresetChip(context.tr('tagline_preset_2'), isDark),
              _buildPresetChip(context.tr('tagline_preset_3'), isDark),
              _buildPresetChip(context.tr('tagline_preset_4'), isDark),
            ],
          ),
          const SizedBox(height: 18),

          // 4. Badge Shape Selector
          Text(
            context.tr('badge_shape_title'),
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
            children: _shapes.map((s) {
              final isSelected = _selectedShape == s['id'];
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedShape = s['id']!);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : (isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A)),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DealershipLogoBadge(
                        emblemId: _selectedEmblem,
                        badgeShape: s['id']!,
                        badgeColor: _selectedColor,
                        size: 22,
                        showShadow: false,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(s['key']!),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // 5. Badge & Brand Accent Color Selector
          Text(
            context.tr('badge_color_title'),
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
            children: _colors.map((c) {
              final isSelected = _selectedColor == c['id'];
              final colorVal = c['color'] as Color;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedColor = c['id'] as String);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF1E2638)
                            : const Color(0xFFFEF9C3))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brutalYellow
                          : (isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A)),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorVal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.tr(c['key'] as String),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // 6. Emblem Selector (18 Popular Logos)
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : (isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A)),
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
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 7. Character Origin Selector (§2.1)
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
                        ? (isDark
                            ? const Color(0xFF1E2638)
                            : const Color(0xFFFEF9C3))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderColor: isSelected
                        ? AppColors.brutalYellow
                        : (isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFF0F172A)),
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
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(item['icon'] as IconData,
                              color: Colors.white, size: 24),
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
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    NeoBrutalBadge(
                                      text: context
                                          .tr('lifestyle_equipped_badge'),
                                      backgroundColor: AppColors.brutalGreen,
                                      textColor: Colors.black,
                                      fontSize: 10,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr(item['descKey'] as String),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0C0E14)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2A3142)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  context.tr(item['perkKey'] as String),
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brutalGreen),
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
          const SizedBox(height: 24),

          // 8. Save Button
          TutorialPulseTarget(
            isEnabled: !ref.watch(gameProvider).tutorialCompleted,
            pulseColor: AppColors.brutalGreen,
            child: NeoBrutalButton(
              label: context.tr('identity_save_btn'),
              icon: Icons.check_circle_rounded,
              backgroundColor: AppColors.brutalGreen,
              textColor: Colors.black,
              fontSize: 13,
              fullWidth: true,
              onPressed: _saveIdentity,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String text, bool isDark) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _taglineController.text = text;
        setState(() {});
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
