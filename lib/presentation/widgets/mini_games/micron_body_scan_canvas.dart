import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../data/models/expertise_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_card.dart';

class MicronBodyScanCanvasWidget extends StatefulWidget {
  final Map<String, PartStatus> bodyParts;
  final bool isDark;
  final Function(String partName, int microns, PartStatus status)? onPartScanned;

  const MicronBodyScanCanvasWidget({
    super.key,
    required this.bodyParts,
    required this.isDark,
    this.onPartScanned,
  });

  @override
  State<MicronBodyScanCanvasWidget> createState() => _MicronBodyScanCanvasWidgetState();
}

class _MicronBodyScanCanvasWidgetState extends State<MicronBodyScanCanvasWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _sonarController;
  String? _selectedPartKey;
  int? _selectedMicrons;
  PartStatus? _selectedStatus;
  final Set<String> _scannedParts = {};

  int _calculateMicrons(PartStatus status, String partKey) {
    final hash = partKey.hashCode.abs();
    switch (status) {
      case PartStatus.original:
        return 90 + (hash % 30); // 90 - 120 µm
      case PartStatus.painted:
        return 160 + (hash % 60); // 160 - 220 µm
      case PartStatus.changed:
        return 280 + (hash % 90); // 280 - 370 µm
      case PartStatus.damaged:
        return 380 + (hash % 150); // 380 - 530 µm
    }
  }

  @override
  void initState() {
    super.initState();
    _sonarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _sonarController.dispose();
    super.dispose();
  }

  void _selectPart(String partKey, PartStatus status) {
    HapticFeedback.selectionClick();
    final microns = _calculateMicrons(status, partKey);
    _sonarController.forward(from: 0.0);
    setState(() {
      _selectedPartKey = partKey;
      _selectedMicrons = microns;
      _selectedStatus = status;
      _scannedParts.add(partKey);
    });
    widget.onPartScanned?.call(partKey, microns, status);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final totalParts = widget.bodyParts.length;
    final scannedCount = _scannedParts.length;
    final isFullScanned = scannedCount == totalParts && totalParts > 0;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isFullScanned ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
      borderWidth: 2.4,
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Scan Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.radar_rounded, size: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('micron_title'),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: context.tr('micron_progress', {'scanned': '$scannedCount', 'total': '$totalParts'}),
                backgroundColor: isFullScanned ? AppColors.brutalGreen : (isDark ? const Color(0xFF222B3F) : const Color(0xFFE2E8F0)),
                textColor: isFullScanned ? Colors.black : (isDark ? Colors.white : Colors.black),
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Digital LCD Micron Gauge Output Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0D14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedStatus != null
                    ? StatColors.getPartColor(_selectedStatus!.name)
                    : const Color(0xFF222A3C),
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('micron_probe_title'),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                    ),
                    Text(
                      _selectedPartKey != null
                          ? _getLocalizedPartName(context, _selectedPartKey!)
                          : context.tr('micron_probe_hint'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _selectedPartKey != null ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (_selectedMicrons != null && _selectedStatus != null) ...[
                  Row(
                    children: [
                      Text(
                        '$_selectedMicrons µm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalYellow,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeoBrutalBadge(
                        text: StatColors.getPartLabel(_selectedStatus!.name),
                        backgroundColor: StatColors.getPartColor(_selectedStatus!.name),
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2D Interactive Blueprint Grid Canvas
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF080A10) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF263047) : const Color(0xFFCBD5E1), width: 2),
            ),
            child: Stack(
              children: [
                // Custom blueprint vehicle outline
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sonarController,
                    builder: (context, child) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          painter: _CarBlueprintPainter(
                            bodyParts: widget.bodyParts,
                            selectedPartKey: _selectedPartKey,
                            scannedParts: _scannedParts,
                            sonarProgress: _sonarController.value,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Interactive touch targets overlay on body zones
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // 1. Ön Tampon
                          _buildTouchTarget(
                            left: w * 0.04,
                            top: h * 0.32,
                            width: w * 0.09,
                            height: h * 0.36,
                            partName: 'Ön Tampon',
                          ),
                          // 2. Sol Ön Çamurluk
                          _buildTouchTarget(
                            left: w * 0.15,
                            top: h * 0.08,
                            width: w * 0.15,
                            height: h * 0.22,
                            partName: 'Sol Ön Çamurluk',
                          ),
                          // 3. Kaput
                          _buildTouchTarget(
                            left: w * 0.15,
                            top: h * 0.34,
                            width: w * 0.15,
                            height: h * 0.32,
                            partName: 'Kaput',
                          ),
                          // 4. Sağ Ön Çamurluk
                          _buildTouchTarget(
                            left: w * 0.15,
                            top: h * 0.70,
                            width: w * 0.15,
                            height: h * 0.22,
                            partName: 'Sağ Ön Çamurluk',
                          ),
                          // 5. Sol Ön Kapı
                          _buildTouchTarget(
                            left: w * 0.32,
                            top: h * 0.08,
                            width: w * 0.16,
                            height: h * 0.22,
                            partName: 'Sol Ön Kapı',
                          ),
                          // 6. Tavan
                          _buildTouchTarget(
                            left: w * 0.32,
                            top: h * 0.34,
                            width: w * 0.34,
                            height: h * 0.32,
                            partName: 'Tavan',
                          ),
                          // 7. Sağ Ön Kapı
                          _buildTouchTarget(
                            left: w * 0.32,
                            top: h * 0.70,
                            width: w * 0.16,
                            height: h * 0.22,
                            partName: 'Sağ Ön Kapı',
                          ),
                          // 8. Sol Arka Kapı
                          _buildTouchTarget(
                            left: w * 0.50,
                            top: h * 0.08,
                            width: w * 0.16,
                            height: h * 0.22,
                            partName: 'Sol Arka Kapı',
                          ),
                          // 9. Sağ Arka Kapı
                          _buildTouchTarget(
                            left: w * 0.50,
                            top: h * 0.70,
                            width: w * 0.16,
                            height: h * 0.22,
                            partName: 'Sağ Arka Kapı',
                          ),
                          // 10. Sol Arka Çamurluk
                          _buildTouchTarget(
                            left: w * 0.68,
                            top: h * 0.08,
                            width: w * 0.15,
                            height: h * 0.22,
                            partName: 'Sol Arka Çamurluk',
                          ),
                          // 11. Bagaj
                          _buildTouchTarget(
                            left: w * 0.68,
                            top: h * 0.34,
                            width: w * 0.15,
                            height: h * 0.32,
                            partName: 'Bagaj',
                          ),
                          // 12. Sağ Arka Çamurluk
                          _buildTouchTarget(
                            left: w * 0.68,
                            top: h * 0.70,
                            width: w * 0.15,
                            height: h * 0.22,
                            partName: 'Sağ Arka Çamurluk',
                          ),
                          // 13. Arka Tampon
                          _buildTouchTarget(
                            left: w * 0.85,
                            top: h * 0.32,
                            width: w * 0.09,
                            height: h * 0.36,
                            partName: 'Arka Tampon',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Pills fallback list
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.bodyParts.entries.map((entry) {
              final isSelected = _selectedPartKey == entry.key;
              final isScanned = _scannedParts.contains(entry.key);
              final statusColor = StatColors.getPartColor(entry.value.name);

              return InkWell(
                onTap: () => _selectPart(entry.key, entry.value),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.brutalYellow
                        : (isScanned ? statusColor.withValues(alpha: 0.25) : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9))),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black : (isScanned ? statusColor : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A))),
                      width: isSelected ? 2.2 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isScanned)
                        Icon(Icons.check_circle_rounded, size: 12, color: isSelected ? Colors.black : statusColor),
                      if (isScanned) const SizedBox(width: 4),
                      Text(
                        _getLocalizedPartName(context, entry.key),
                        style: TextStyle(
                          fontSize: 10.5,
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
        ],
      ),
    );
  }

  String _getLocalizedPartName(BuildContext context, String partKey) {
    switch (partKey) {
      case 'Ön Tampon':
        return context.tr('part_front_bumper');
      case 'Kaput':
        return context.tr('part_hood');
      case 'Tavan':
        return context.tr('part_roof');
      case 'Bagaj':
      case 'Bagaj Kapağı':
        return context.tr('part_trunk');
      case 'Arka Tampon':
        return context.tr('part_rear_bumper');
      case 'Sol Ön Çamurluk':
        return context.tr('part_left_front_fender');
      case 'Sağ Ön Çamurluk':
        return context.tr('part_right_front_fender');
      case 'Sol Ön Kapı':
        return context.tr('part_left_front_door');
      case 'Sağ Ön Kapı':
        return context.tr('part_right_front_door');
      case 'Sol Arka Kapı':
        return context.tr('part_left_rear_door');
      case 'Sağ Arka Kapı':
        return context.tr('part_right_rear_door');
      case 'Sol Arka Çamurluk':
        return context.tr('part_left_rear_fender');
      case 'Sağ Arka Çamurluk':
        return context.tr('part_right_rear_fender');
      default:
        return partKey;
    }
  }

  Widget _buildTouchTarget({
    required double left,
    required double top,
    required double width,
    required double height,
    required String partName,
  }) {
    final status = widget.bodyParts[partName] ??
        widget.bodyParts.entries
            .firstWhere(
              (e) => e.key.toLowerCase().replaceAll(' ', '').contains(partName.toLowerCase().replaceAll(' ', '')) ||
                  partName.toLowerCase().replaceAll(' ', '').contains(e.key.toLowerCase().replaceAll(' ', '')),
              orElse: () => MapEntry(partName, PartStatus.original),
            )
            .value;

    final isSelected = _selectedPartKey == partName;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _selectPart(partName, status),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brutalYellow.withValues(alpha: 0.35) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _CarBlueprintPainter extends CustomPainter {
  final Map<String, PartStatus> bodyParts;
  final String? selectedPartKey;
  final Set<String> scannedParts;
  final double sonarProgress;
  final bool isDark;

  _CarBlueprintPainter({
    required this.bodyParts,
    required this.selectedPartKey,
    required this.scannedParts,
    required this.sonarProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid blueprint background lines
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF161E2E) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Vehicle Silhouette Outer Body
    final bodyPaint = Paint()
      ..color = isDark ? const Color(0xFF131A26) : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final carRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.03, h * 0.05, w * 0.94, h * 0.90),
      const Radius.circular(16),
    );
    canvas.drawRRect(carRect, bodyPaint);
    canvas.drawRRect(carRect, borderPaint);

    // 1. Ön Tampon
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.04, h * 0.32, w * 0.09, h * 0.36),
      'Ön Tampon',
      'Ön Tamp.',
      borderPaint,
    );

    // 2. Sol Ön Çamurluk (Top)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.15, h * 0.08, w * 0.15, h * 0.22),
      'Sol Ön Çamurluk',
      'Sol Ön Çam.',
      borderPaint,
    );

    // 3. Kaput (Center)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.15, h * 0.34, w * 0.15, h * 0.32),
      'Kaput',
      'Kaput',
      borderPaint,
    );

    // 4. Sağ Ön Çamurluk (Bottom)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.15, h * 0.70, w * 0.15, h * 0.22),
      'Sağ Ön Çamurluk',
      'Sağ Ön Çam.',
      borderPaint,
    );

    // 5. Sol Ön Kapı (Top)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.32, h * 0.08, w * 0.16, h * 0.22),
      'Sol Ön Kapı',
      'Sol Ön K.',
      borderPaint,
    );

    // 6. Tavan (Center Cabin)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.32, h * 0.34, w * 0.34, h * 0.32),
      'Tavan',
      'Tavan',
      borderPaint,
    );

    // 7. Sağ Ön Kapı (Bottom)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.32, h * 0.70, w * 0.16, h * 0.22),
      'Sağ Ön Kapı',
      'Sağ Ön K.',
      borderPaint,
    );

    // 8. Sol Arka Kapı (Top)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.50, h * 0.08, w * 0.16, h * 0.22),
      'Sol Arka Kapı',
      'Sol Arka K.',
      borderPaint,
    );

    // 9. Sağ Arka Kapı (Bottom)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.50, h * 0.70, w * 0.16, h * 0.22),
      'Sağ Arka Kapı',
      'Sağ Arka K.',
      borderPaint,
    );

    // 10. Sol Arka Çamurluk (Top)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.68, h * 0.08, w * 0.15, h * 0.22),
      'Sol Arka Çamurluk',
      'Sol Ark Çam.',
      borderPaint,
    );

    // 11. Bagaj (Center)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.68, h * 0.34, w * 0.15, h * 0.32),
      'Bagaj',
      'Bagaj',
      borderPaint,
    );

    // 12. Sağ Arka Çamurluk (Bottom)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.68, h * 0.70, w * 0.15, h * 0.22),
      'Sağ Arka Çamurluk',
      'Sağ Ark Çam.',
      borderPaint,
    );

    // 13. Arka Tampon
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.85, h * 0.32, w * 0.09, h * 0.36),
      'Arka Tampon',
      'Arka Tamp.',
      borderPaint,
    );

    // Sonar Pulse Ring if a part is selected
    if (selectedPartKey != null) {
      final pulseRadius = 15.0 + sonarProgress * 25.0;
      final pulsePaint = Paint()
        ..color = AppColors.brutalYellow.withValues(alpha: (1.0 - sonarProgress).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final center = Offset(w * 0.50, h * 0.50);
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }

  void _drawPartSection(Canvas canvas, Rect rect, String lookupKey, String displayLabel, Paint border) {
    final status = bodyParts[lookupKey] ??
        bodyParts.entries
            .firstWhere(
              (e) => e.key.toLowerCase().replaceAll(' ', '').contains(lookupKey.toLowerCase().replaceAll(' ', '')) ||
                  lookupKey.toLowerCase().replaceAll(' ', '').contains(e.key.toLowerCase().replaceAll(' ', '')),
              orElse: () => MapEntry(lookupKey, PartStatus.original),
            )
            .value;
    final isScanned = scannedParts.contains(lookupKey) || scannedParts.contains(displayLabel);
    final isSelected = selectedPartKey == lookupKey || selectedPartKey == displayLabel;

    Color fillColor = isDark ? const Color(0xFF1A2232) : const Color(0xFFF8FAFC);
    if (isScanned) {
      fillColor = StatColors.getPartColor(status.name).withValues(alpha: isDark ? 0.40 : 0.30);
    }
    if (isSelected) {
      fillColor = AppColors.brutalYellow.withValues(alpha: 0.65);
    }

    final fillPaint = Paint()..color = fillColor;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, border);

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayLabel,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF334155)),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CarBlueprintPainter oldDelegate) => true;
}
