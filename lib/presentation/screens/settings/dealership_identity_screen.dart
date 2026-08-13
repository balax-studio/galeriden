import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_vector_icons.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('GALERİ VE PROFİL KİMLİĞİ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            AppGlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: VectorIconWidget(
                      type: _selectedEmblem,
                      color: p.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _galleryController.text.trim().isEmpty ? 'Miras Oto Galeri' : _galleryController.text.trim(),
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Oyuncu: ${_nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim()}',
                          style: AppTypography.labelSmall(p.isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('GENEL BİLGİLER', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            // Player Name Field
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.outfit(color: p.textPrimaryColor),
              decoration: InputDecoration(
                labelText: 'Oyuncu Adı (Unvan)',
                labelStyle: TextStyle(color: p.textSecondaryColor),
                prefixIcon: Icon(Icons.person_outline, color: p.primaryColor),
                filled: true,
                fillColor: p.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.surfaceBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gallery Name Field
            TextField(
              controller: _galleryController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.outfit(color: p.textPrimaryColor),
              decoration: InputDecoration(
                labelText: 'Galeri Unvanı / Markası',
                labelStyle: TextStyle(color: p.textSecondaryColor),
                prefixIcon: Icon(Icons.storefront_outlined, color: p.primaryColor),
                filled: true,
                fillColor: p.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.surfaceBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('AMBLEM VE LOGO SEÇİMİ', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emblems.map((e) {
                final isSelected = _selectedEmblem == e['id'];
                return ChoiceChip(
                  showCheckmark: false,
                  selected: isSelected,
                  backgroundColor: p.surfaceColor,
                  selectedColor: p.primaryColor.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? p.primaryColor : p.surfaceBorderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VectorIconWidget(
                          type: e['id']!,
                          color: isSelected ? p.primaryColor : p.textSecondaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          e['name']!,
                          style: GoogleFonts.outfit(
                            color: isSelected ? p.primaryColor : p.textSecondaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedEmblem = e['id']!),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveIdentity,
                child: Text(
                  'KİMLİK BİLGİLERİNİ KAYDET',
                  style: AppTypography.titleLarge(false).copyWith(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
