import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../../widgets/neo_brutal_badge.dart';

class RealEstateNegotiationLogBox extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final bool isThinking;
  final String? thinkingText;
  final double height;

  const RealEstateNegotiationLogBox({
    super.key,
    required this.messages,
    this.isThinking = false,
    this.thinkingText,
    this.height = 240,
  });

  @override
  State<RealEstateNegotiationLogBox> createState() =>
      _RealEstateNegotiationLogBoxState();
}

class _RealEstateNegotiationLogBoxState extends State<RealEstateNegotiationLogBox>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(_pulseController);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant RealEstateNegotiationLogBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isThinking != oldWidget.isThinking ||
        widget.thinkingText != oldWidget.thinkingText) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getBadgeBackgroundColor(String? badge) {
    if (badge == null) return const Color(0xFFE2E8F0);
    final upper = badge.toUpperCase();
    if (upper.contains('KABUL') || upper.contains('ANLAŞMA')) {
      return const Color(0xFFD1FAE5);
    }
    if (upper.contains('RET') || upper.contains('MASADAN KALKTI')) {
      return const Color(0xFFFEE2E2);
    }
    if (upper.contains('KARŞI TEKLİF')) {
      return const Color(0xFFFEF3C7);
    }
    if (upper.contains('TEKLİF')) {
      return const Color(0xFFDBEAFE);
    }
    if (upper.contains('TAKTIK')) {
      return const Color(0xFFEDE9FE);
    }
    return const Color(0xFFE2E8F0);
  }

  Color _getBadgeTextColor(String? badge) {
    if (badge == null) return Colors.black;
    final upper = badge.toUpperCase();
    if (upper.contains('KABUL') || upper.contains('ANLAŞMA')) {
      return const Color(0xFF065F46);
    }
    if (upper.contains('RET') || upper.contains('MASADAN KALKTI')) {
      return const Color(0xFF991B1B);
    }
    if (upper.contains('KARŞI TEKLİF')) {
      return const Color(0xFF92400E);
    }
    if (upper.contains('TEKLİF')) {
      return const Color(0xFF1E40AF);
    }
    if (upper.contains('TAKTIK')) {
      return const Color(0xFF5B21B6);
    }
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_edu_rounded, size: 16, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('real_estate_log_box_title'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${widget.messages.length} ${context.tr('real_estate_log_box_records')}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Log List View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: widget.messages.length + (widget.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                // If this is the thinking indicator at the bottom
                if (widget.isThinking && index == widget.messages.length) {
                  return _buildThinkingBubble(isDark);
                }

                final msg = widget.messages[index];

                // Check for system event messages (e.g. table opened, notary records)
                if (msg.id.startsWith('start_') || msg.id.startsWith('system_')) {
                  return _buildSystemBanner(msg);
                }

                final isPlayer = msg.isFromPlayer;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: isPlayer
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller Avatar
                      if (!isPlayer) ...[
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8, top: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(1.5, 1.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.real_estate_agent_rounded,
                            size: 18,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],

                      // Message Bubble Column
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isPlayer
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Sender Name
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                msg.senderName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            // Speech Bubble
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isPlayer
                                    ? const Color(0xFF2563EB)
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2.5, 2.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isPlayer
                                          ? Colors.white
                                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                      height: 1.4,
                                    ),
                                  ),
                                  if (msg.badgeText != null &&
                                      !msg.message.startsWith(msg.badgeText!)) ...[
                                    const SizedBox(height: 6),
                                    NeoBrutalBadge(
                                      text: msg.badgeText!,
                                      backgroundColor:
                                          _getBadgeBackgroundColor(msg.badgeText),
                                      textColor: _getBadgeTextColor(msg.badgeText),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Player Avatar
                      if (isPlayer) ...[
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(1.5, 1.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBanner(ChatMessageModel msg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9C3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gavel_rounded, size: 14, color: Color(0xFF854D0E)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                msg.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF713F12),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingBubble(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              context.tr('real_estate_thinking_evaluating'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD97706), width: 1.8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB45309)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.thinkingText ?? context.tr('real_estate_thinking_default'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBouncingDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBouncingDots() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final shift = (val - (i * 0.25)).clamp(0.0, 1.0);
            final bounce = -3.0 * (1.0 - (shift * 2 - 1).abs());
            return Transform.translate(
              offset: Offset(0, bounce),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 4.5,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFB45309),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 0.8),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
