import 'package:flutter/material.dart';

enum NeoBrutalBannerType {
  info,
  warning,
  error,
  success,
}

class NeoBrutalNotificationBanner extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final NeoBrutalBannerType type;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NeoBrutalNotificationBanner({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.type = NeoBrutalBannerType.info,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case NeoBrutalBannerType.info:
        return const Color(0xFFE0F2FE);
      case NeoBrutalBannerType.warning:
        return const Color(0xFFFEF08A);
      case NeoBrutalBannerType.error:
        return const Color(0xFFFEE2E2);
      case NeoBrutalBannerType.success:
        return const Color(0xFFD1FAE5);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case NeoBrutalBannerType.info:
        return Colors.black;
      case NeoBrutalBannerType.warning:
        return Colors.black;
      case NeoBrutalBannerType.error:
        return const Color(0xFFDC2626);
      case NeoBrutalBannerType.success:
        return Colors.black;
    }
  }

  Color _getAccentColor() {
    switch (type) {
      case NeoBrutalBannerType.info:
        return const Color(0xFF0284C7);
      case NeoBrutalBannerType.warning:
        return const Color(0xFFD97706);
      case NeoBrutalBannerType.error:
        return const Color(0xFFDC2626);
      case NeoBrutalBannerType.success:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final accentColor = _getAccentColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            InkWell(
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close_rounded, size: 18, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
