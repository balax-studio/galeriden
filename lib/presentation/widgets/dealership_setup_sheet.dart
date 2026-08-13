import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../../core/theme/app_colors.dart';
import 'app_vector_icons.dart';

class DealershipSetupSheet extends ConsumerStatefulWidget {
  const DealershipSetupSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const DealershipSetupSheet(),
      ),
    );
  }

  @override
  ConsumerState<DealershipSetupSheet> createState() => _DealershipSetupSheetState();
}

class _DealershipSetupSheetState extends ConsumerState<DealershipSetupSheet> {
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

  void _save(bool isSkip) {
    if (!isSkip) {
      ref.read(gameProvider.notifier).updateDealershipIdentity(
        playerName: _nameController.text.trim().isEmpty ? 'Kaptan' : _nameController.text.trim(),
        dealershipName: _galleryController.text.trim().isEmpty ? 'Miras Oto Galeri' : _galleryController.text.trim(),
        logoEmblemId: _selectedEmblem,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: VectorIconWidget(
                  type: _selectedEmblem,
                  color: AppColors.primaryAmber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Galeri Kimliğini Oluştur',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Player Name Field
          TextField(
            controller: _nameController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Oyuncu Adı (Unvan)',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryAmber),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryAmber),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Gallery Name Field
          TextField(
            controller: _galleryController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Galeri Adı / Marka',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.primaryAmber),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryAmber),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Amblem & Logo Seçimi',
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emblems.map((e) {
              final isSelected = _selectedEmblem == e['id'];
              return ChoiceChip(
                showCheckmark: false,
                selected: isSelected,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: AppColors.primaryAmber.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryAmber : Colors.white12,
                  ),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VectorIconWidget(
                      type: e['id']!,
                      color: isSelected ? AppColors.primaryAmber : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e['name']!,
                      style: GoogleFonts.outfit(
                        color: isSelected ? AppColors.primaryAmber : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                onSelected: (_) => setState(() => _selectedEmblem = e['id']!),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _save(true),
                  child: Text(
                    'Varsayılanla Atla',
                    style: GoogleFonts.outfit(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAmber,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _save(false),
                  child: Text(
                    'Kurulumu Kaydet',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
