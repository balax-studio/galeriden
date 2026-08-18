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
                  const Text(
                    '2D KAPORTA & BOYA RADARI',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: '$scannedCount/$totalParts PARÇA TARANDI',
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
                    const Text(
                      'DİJİTAL MİKRON PROBU:',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                    ),
                    Text(
                      _selectedPartKey ?? 'Parçaya dokunup probu temas ettir',
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

          // 2D Interactive Blueprint Blueprint Grid Canvas
          Container(
            height: 200,
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
                      return CustomPaint(
                        painter: _CarBlueprintPainter(
                          bodyParts: widget.bodyParts,
                          selectedPartKey: _selectedPartKey,
                          scannedParts: _scannedParts,
                          sonarProgress: _sonarController.value,
                          isDark: isDark,
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
                          // 1. Kaput (Front Hood)
                          _buildTouchTarget(
                            left: w * 0.12,
                            top: h * 0.30,
                            width: w * 0.22,
                            height: h * 0.40,
                            partName: 'Kaput',
                          ),
                          // 2. Tavan (Roof)
                          _buildTouchTarget(
                            left: w * 0.40,
                            top: h * 0.28,
                            width: w * 0.24,
                            height: h * 0.44,
                            partName: 'Tavan',
                          ),
                          // 3. Bagaj (Trunk)
                          _buildTouchTarget(
                            left: w * 0.70,
                            top: h * 0.32,
                            width: w * 0.18,
                            height: h * 0.36,
                            partName: 'Bagaj',
                          ),
                          // 4. Sol Ön Çamurluk / Kapı
                          _buildTouchTarget(
                            left: w * 0.20,
                            top: h * 0.06,
                            width: w * 0.26,
                            height: h * 0.20,
                            partName: 'Sol Ön Çamurluk',
                          ),
                          // 5. Sağ Ön Çamurluk / Kapı
                          _buildTouchTarget(
                            left: w * 0.20,
                            top: h * 0.74,
                            width: w * 0.26,
                            height: h * 0.20,
                            partName: 'Sağ Ön Çamurluk',
                          ),
                          // 6. Sol Arka Çamurluk / Kapı
                          _buildTouchTarget(
                            left: w * 0.54,
                            top: h * 0.06,
                            width: w * 0.26,
                            height: h * 0.20,
                            partName: 'Sol Arka Çamurluk',
                          ),
                          // 7. Sağ Arka Çamurluk / Kapı
                          _buildTouchTarget(
                            left: w * 0.54,
                            top: h * 0.74,
                            width: w * 0.26,
                            height: h * 0.20,
                            partName: 'Sağ Arka Çamurluk',
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
                        entry.key,
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
              (e) => e.key.toLowerCase().contains(partName.toLowerCase()) || partName.toLowerCase().contains(e.key.toLowerCase()),
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
      ..strokeWidth = 2.4;

    final carRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.20, w * 0.80, h * 0.60),
      const Radius.circular(20),
    );
    canvas.drawRRect(carRect, bodyPaint);
    canvas.drawRRect(carRect, borderPaint);

    // Front Hood (Kaput)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.22, h * 0.44),
      'Kaput',
      borderPaint,
    );

    // Cabin / Roof (Tavan)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.38, h * 0.25, w * 0.26, h * 0.50),
      'Tavan',
      borderPaint,
    );

    // Trunk (Bagaj)
    _drawPartSection(
      canvas,
      Rect.fromLTWH(w * 0.68, h * 0.28, w * 0.20, h * 0.44),
      'Bagaj',
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

  void _drawPartSection(Canvas canvas, Rect rect, String label, Paint border) {
    final status = bodyParts[label] ?? PartStatus.original;
    final isScanned = scannedParts.contains(label);
    final isSelected = selectedPartKey == label;

    Color fillColor = isDark ? const Color(0xFF1A2232) : const Color(0xFFF8FAFC);
    if (isScanned) {
      fillColor = StatColors.getPartColor(status.name).withValues(alpha: isDark ? 0.35 : 0.25);
    }
    if (isSelected) {
      fillColor = AppColors.brutalYellow.withValues(alpha: 0.6);
    }

    final fillPaint = Paint()..color = fillColor;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, border);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
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
