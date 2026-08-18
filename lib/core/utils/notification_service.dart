import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NotificationService {
  static void showSuccess(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'BAŞARILI',
      icon: Icons.check_circle_rounded,
      accentColor: const Color(0xFF00E575), // Brutal Green
      textColor: Colors.black,
      durationSeconds: 2,
    );
  }

  static void showError(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'HATA / UYARI',
      icon: Icons.dangerous_rounded,
      accentColor: const Color(0xFFFF3366), // Brutal Red
      textColor: Colors.white,
      durationSeconds: 2,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'BİLGİLENDİRME',
      icon: Icons.info_rounded,
      accentColor: const Color(0xFF38BDF8), // Brutal Blue
      textColor: Colors.black,
      durationSeconds: 2,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'DİKKAT',
      icon: Icons.warning_amber_rounded,
      accentColor: const Color(0xFFFFDE59), // Brutal Yellow
      textColor: Colors.black,
      durationSeconds: 2,
    );
  }

  static void showCarSold(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'ARAÇ SATILDI!',
      icon: Icons.monetization_on_rounded,
      accentColor: const Color(0xFFFFDE59),
      textColor: Colors.black,
      durationSeconds: 2,
    );
  }

  static void showReward(BuildContext context, String message) {
    _showNeoBrutalToast(
      context: context,
      message: message,
      title: 'ÖDÜL KAZANDIN!',
      icon: Icons.stars_rounded,
      accentColor: const Color(0xFFA855F7), // Brutal Violet
      textColor: Colors.white,
      durationSeconds: 2,
    );
  }

  static void _showNeoBrutalToast({
    required BuildContext context,
    required String message,
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color textColor,
    int durationSeconds = 2,
  }) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: Duration(seconds: durationSeconds),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 250),
      builder: (BuildContext context, ToastificationItem holder) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Box with hard border
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.black, size: 22),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                // Close button
                GestureDetector(
                  onTap: () => toastification.dismiss(holder),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
