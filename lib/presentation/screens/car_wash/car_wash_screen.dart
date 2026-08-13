import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/car_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/car_icons.dart';

class CarWashScreen extends ConsumerStatefulWidget {
  const CarWashScreen({super.key});

  @override
  ConsumerState<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends ConsumerState<CarWashScreen> {
  CarModel? _selectedCar;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    final ownedCars = game.ownedCars;
    if (_selectedCar == null && ownedCars.isNotEmpty) {
      _selectedCar = ownedCars.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTO YIKAMA & DETAY STÜDYOSU'),
      ),
      body: ownedCars.isEmpty
          ? Center(
              child: Text(
                'Garajında henüz araç yok!',
                style: AppTypography.bodyMedium(p.isDark),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('İŞLEM YAPILACAK ARAÇ SEÇİMİ', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 10),

                  // Car Picker Dropdown/Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ownedCars.map((car) {
                        final isSelected = _selectedCar?.id == car.id;
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
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
                            label: Text(
                              '${car.brand} ${car.modelName}',
                              style: TextStyle(
                                color: isSelected ? p.primaryColor : p.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            onSelected: (_) => setState(() => _selectedCar = car),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_selectedCar != null) ...[
                    // Vehicle Preview Card
                    AppGlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Center(
                            child: CarSilhouetteWidget(
                              bodyType: _selectedCar!.bodyType,
                              color: Color(int.parse(_selectedCar!.colorHex.replaceFirst('#', '0xff'))),
                              width: 180,
                              height: 90,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${_selectedCar!.brand} ${_selectedCar!.modelName} (${_selectedCar!.modelYear})',
                            style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                backgroundColor: _selectedCar!.isWashed ? p.primaryColor.withValues(alpha: 0.2) : p.surfaceBorderColor,
                                label: Text(
                                  _selectedCar!.isWashed ? '🧼 Köpük Yıkama Yapıldı' : '🚿 Kirli',
                                  style: TextStyle(fontSize: 12, color: _selectedCar!.isWashed ? p.primaryColor : p.textSecondaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                backgroundColor: _selectedCar!.isPolished ? p.secondaryColor.withValues(alpha: 0.2) : p.surfaceBorderColor,
                                label: Text(
                                  _selectedCar!.isPolished ? '✨ Cila Parlatıldı' : '🌫️ Mat',
                                  style: TextStyle(fontSize: 12, color: _selectedCar!.isPolished ? p.secondaryColor : p.textSecondaryColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('BAKIM VE PARLATMA İŞLEMLERİ', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 12),

                    // Action 1: Foam Wash
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 28),
                        title: Text('Köpüklü İç-Dış Yıkama', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                        subtitle: const Text('Maliyet: ₺300 — Araç pırıl pırıl temizlenir.'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          onPressed: _selectedCar!.isWashed
                              ? null
                              : () {
                                  final success = ref.read(gameProvider.notifier).washAndPolishCar(_selectedCar!.id, wash: true, polish: false);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Araç köpükle yıkandı ve temizlendi!')),
                                    );
                                    setState(() {
                                      _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id);
                                    });
                                  }
                                },
                          child: Text(_selectedCar!.isWashed ? 'Temiz' : 'Yıka'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action 2: Pasta Cila Polish
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 28),
                        title: Text('Nano Seramik Pasta-Cila', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                        subtitle: const Text('Maliyet: ₺800 — Aracın boyasını parlatır (Değer +%7).'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                          onPressed: _selectedCar!.isPolished
                              ? null
                              : () {
                                  final success = ref.read(gameProvider.notifier).washAndPolishCar(_selectedCar!.id, wash: false, polish: true);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pasta-cila yapıldı, araç ayna gibi parlıyor!')),
                                    );
                                    setState(() {
                                      _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id);
                                    });
                                  }
                                },
                          child: Text(_selectedCar!.isPolished ? 'Parlak' : 'Cila At'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
