import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'dart:ui';

class NotificationService {
  static void showSuccess(BuildContext context, String message) {
    _showGlassToast(
      context: context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.greenAccent,
      borderColor: Colors.greenAccent.withValues(alpha: 0.5),
    );
  }

  static void showError(BuildContext context, String message) {
    _showGlassToast(
      context: context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.redAccent,
      borderColor: Colors.redAccent.withValues(alpha: 0.5),
      durationSeconds: 4,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showGlassToast(
      context: context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: Colors.blueAccent,
      borderColor: Colors.blueAccent.withValues(alpha: 0.5),
    );
  }

  static void showCarSold(BuildContext context, String message) {
    _showGlassToast(
      context: context,
      message: message,
      icon: Icons.monetization_on_rounded,
      iconColor: Colors.amber,
      borderColor: Colors.amber.withValues(alpha: 0.6),
      durationSeconds: 4,
    );
  }
  
  static void showReward(BuildContext context, String message) {
    _showGlassToast(
      context: context,
      message: message,
      icon: Icons.star_rounded,
      iconColor: Colors.amberAccent,
      borderColor: Colors.amberAccent.withValues(alpha: 0.6),
      durationSeconds: 4,
    );
  }

  static void _showGlassToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    int durationSeconds = 3,
  }) {
    toastification.showCustom(
      context: context,
      autoCloseDuration: Duration(seconds: durationSeconds),
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 500),
      builder: (BuildContext context, ToastificationItem holder) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        // Premium görünüm için renkler
        final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC);
        final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
        final glowColor = iconColor.withValues(alpha: 0.25);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.6), 
                    width: 1.0,
                  ),
                  boxShadow: [
                    // Ana derinlik gölgesi
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    // Etrafındaki renkli parlama (Glow)
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 16,
                      spreadRadius: -2,
                    )
                  ],
                  // Lüks bir hissiyat için iç gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgColor.withValues(alpha: 0.85),
                      bgColor.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon için lüks, detaylı çerçeve
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            iconColor.withValues(alpha: 0.25),
                            iconColor.withValues(alpha: 0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
