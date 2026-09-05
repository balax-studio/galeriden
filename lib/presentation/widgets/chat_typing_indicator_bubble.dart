import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/usecases/real_estate_chat_negotiation_engine.dart';

/// WhatsApp benzeri 3 zıplayan noktalı, gerçekçi gerilim sohbet gösterge balonu
class ChatTypingIndicatorBubble extends StatefulWidget {
  final String senderName;
  final String? statusText;
  final ChatSenderRole? role;
  final bool isDark;

  const ChatTypingIndicatorBubble({
    super.key,
    required this.senderName,
    this.statusText,
    this.role,
    this.isDark = false,
  });

  @override
  State<ChatTypingIndicatorBubble> createState() =>
      _ChatTypingIndicatorBubbleState();
}

class _ChatTypingIndicatorBubbleState extends State<ChatTypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _dot1Anim;
  late Animation<double> _dot2Anim;
  late Animation<double> _dot3Anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _dot1Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
    _dot2Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    );
    _dot3Anim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  IconData _getRoleIcon() {
    switch (widget.role) {
      case ChatSenderRole.contractor:
        return Icons.engineering_rounded;
      case ChatSenderRole.subcontractor:
        return Icons.construction_rounded;
      case ChatSenderRole.buyer:
        return Icons.person_search_rounded;
      case ChatSenderRole.tenant:
        return Icons.key_rounded;
      case ChatSenderRole.seller:
        return Icons.store_rounded;
      case ChatSenderRole.player:
      default:
        return Icons.person_rounded;
    }
  }

  Widget _buildBouncingDot(Animation<double> anim, Color color) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final val = anim.value;
        final bounce = math.sin(val * math.pi);
        final offsetY = -5.0 * bounce;
        final scale = 0.85 + (0.25 * bounce);

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 6.5,
              height: 6.5,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final dotColor =
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final text = widget.statusText ?? context.tr('chat_status_typing');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(),
                  size: 13,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.senderName,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBouncingDot(_dot1Anim, dotColor),
                    _buildBouncingDot(_dot2Anim, dotColor),
                    _buildBouncingDot(_dot3Anim, dotColor),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
