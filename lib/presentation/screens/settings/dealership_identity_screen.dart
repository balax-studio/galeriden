import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
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

  final List<Map<String, String>> _emblems = const [
    {'id': 'crown', 'name': 'Taç'},
    {'id': 'shield', 'name': 'Kalkan'},
    {'id': 'star', 'name': 'Yıldız'},
    {'id': 'rare', 'name': 'Elmas'},
    {'id': 'flash', 'name': 'Şimşek'},
    {'id': 'streak', 'name': 'Alev'},
    {'id': 'eagle', 'name': 'Kartal'},
    {'id': 'vintage', 'name': 'Klasik'},
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(gameProvider);
    _nameController = TextEditingController(text: state.playerName);
    _galleryController = TextEditingController(text: state.dealershipName);
    _selectedEmblem = state.logoEmblemId;
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
    );

    NotificationService.showSuccess(context, 'Galeri ve profil bilgileri başarıyla kaydedildi!');

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'GALERİ & PROFİL KİMLİĞİ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
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
                        'Oyuncu: ${_nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim()}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Input Fields
          Text(
            'GENEL BİLGİLER',
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
              labelText: 'Oyuncu Adı (Unvan)',
              filled: true,
              fillColor: isDark ? const Color(0xFF141721) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2),
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
              labelText: 'Galeri Markası / Unvanı',
              filled: true,
              fillColor: isDark ? const Color(0xFF141721) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Emblem Selector
          Text(
            'AMBLEM & LOGO TERCİHİ',
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
                onTap: () => setState(() => _selectedEmblem = e['id']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: isSelected ? 2.2 : 1.2),
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
                        e['name']!,
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

          // 4. Save Button
          NeoBrutalButton(
            label: 'KİMLİK BİLGİLERİNİ KAYDET',
            icon: Icons.check_circle_rounded,
            backgroundColor: AppColors.brutalGreen,
            textColor: Colors.black,
            fontSize: 13,
            fullWidth: true,
            onPressed: _saveIdentity,
          ),
        ],
      ),
    );
  }
}
