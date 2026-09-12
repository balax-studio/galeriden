import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'hazard_stripe_widget.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';
import 'slam_stamp_widget.dart';

/// Fullscreen tactical operation overlay simulating mechanical workshop/scrapyard/notary actions
/// with multi-stage progress, industrial styling, and stamp slamming.
class TactileOperationOverlay extends StatefulWidget {
  final String title;
  final String stage1Text;
  final String stage2Text;
  final String stage3Text;
  final String? stampText;
  final IconData icon;
  final Color accentColor;
  final Duration totalDuration;
  final String? sponsorActionLabel;
  final VoidCallback? onSponsorAction;
  final VoidCallback? onCompleted;

  const TactileOperationOverlay({
    super.key,
    required this.title,
    required this.stage1Text,
    required this.stage2Text,
    required this.stage3Text,
    this.stampText,
    this.icon = Icons.build_circle_outlined,
    this.accentColor = AppColors.toxicLime,
    this.totalDuration = const Duration(milliseconds: 2100),
    this.sponsorActionLabel,
    this.onSponsorAction,
    this.onCompleted,
  });

  /// Static helper to trigger the tactile overlay dialog cleanly
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String stage1Text,
    required String stage2Text,
    required String stage3Text,
    String? stampText,
    IconData icon = Icons.build_circle_outlined,
    Color accentColor = AppColors.toxicLime,
    Duration totalDuration = const Duration(milliseconds: 2100),
    String? sponsorActionLabel,
    VoidCallback? onSponsorAction,
    VoidCallback? onCompleted,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'TactileOperation',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return TactileOperationOverlay(
          title: title,
          stage1Text: stage1Text,
          stage2Text: stage2Text,
          stage3Text: stage3Text,
          stampText: stampText,
          icon: icon,
          accentColor: accentColor,
          totalDuration: totalDuration,
          sponsorActionLabel: sponsorActionLabel,
          onSponsorAction: onSponsorAction,
          onCompleted: onCompleted,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<TactileOperationOverlay> createState() => _TactileOperationOverlayState();
}

class _TactileOperationOverlayState extends State<TactileOperationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _showStamp = false;
  bool _isCompleted = false;
  Timer? _stampTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.totalDuration,
    );

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_showStamp) {
        _triggerStampAndFinish();
      }
    });

    _progressController.forward();
  }

  void _triggerStampAndFinish() {
    if (_isCompleted) return;
    setState(() {
      _showStamp = true;
    });

    _stampTimer?.cancel();
    _stampTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted || _isCompleted) return;
      _isCompleted = true;
      widget.onCompleted?.call();
      Navigator.of(context).pop(true);
    });
  }

  void _handleSponsorInstantFinish() {
    if (_isCompleted) return;
    _progressController.stop();
    widget.onSponsorAction?.call();
    _triggerStampAndFinish();
  }

  @override
  void dispose() {
    _stampTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  int get _currentStageIndex {
    final val = _progressController.value;
    if (val < 0.33) return 0;
    if (val < 0.66) return 1;
    return 2;
  }

  String get _currentStageDescription {
    switch (_currentStageIndex) {
      case 0:
        return widget.stage1Text;
      case 1:
        return widget.stage2Text;
      default:
        return widget.stage3Text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressController.value;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              NeoBrutalCard(
                padding: const EdgeInsets.all(0),
                backgroundColor: AppColors.surfaceDark,
                borderColor: widget.accentColor,
                borderWidth: 2.5,
                borderRadius: 12,
                shadowOffset: const Offset(5.0, 5.0),
                shadowColor: Colors.black,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Industrial Hazard Strip
                    Container(
                      height: 12,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const HazardStripeWidget(
                        height: 12,
                        color1: AppColors.brutalYellow,
                        color2: Colors.black,
                        stripeWidth: 10,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Operation Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.accentColor,
                                  border: Border.all(color: Colors.black, width: 2.0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Progress Bar
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: progress.clamp(0.02, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: widget.accentColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Stage Steps Tracker (1 - 2 - 3)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStepBadge(1, progress >= 0.0, progress >= 0.33),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: progress >= 0.33 ? widget.accentColor : Colors.white12,
                                ),
                              ),
                              _buildStepBadge(2, progress >= 0.33, progress >= 0.66),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: progress >= 0.66 ? widget.accentColor : Colors.white12,
                                ),
                              ),
                              _buildStepBadge(3, progress >= 0.66, progress >= 0.99),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Narrative text box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C0E14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10, width: 1.5),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _currentStageDescription,
                                key: ValueKey<int>(_currentStageIndex),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                            ),
                          ),

                          // Optional Sponsor Quick Finish CTA
                          if (widget.sponsorActionLabel != null && !_showStamp) ...[
                            const SizedBox(height: 14),
                            NeoBrutalButton(
                              text: widget.sponsorActionLabel!,
                              icon: Icons.bolt,
                              backgroundColor: AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 12,
                              onPressed: _handleSponsorInstantFinish,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Slam Stamp
              if (_showStamp && widget.stampText != null)
                Positioned(
                  child: SlamStampWidget(
                    text: widget.stampText!,
                    color: widget.accentColor == AppColors.toxicLime
                        ? const Color(0xFF00E575)
                        : widget.accentColor,
                    fontSize: 20,
                    angle: -0.12,
                    autoPlay: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBadge(int step, bool isActive, bool isDone) {
    final bgColor = isDone
        ? widget.accentColor
        : (isActive
            ? widget.accentColor.withValues(alpha: 0.3)
            : const Color(0xFF1E2433));
    final fgColor =
        isDone ? Colors.black : (isActive ? widget.accentColor : Colors.white38);

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? widget.accentColor : Colors.white24,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check, size: 16, color: Colors.black)
          : Text(
              '$step',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: fgColor,
              ),
            ),
    );
  }
}
