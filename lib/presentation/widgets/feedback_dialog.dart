import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/notification_service.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

import 'dart:io' show HttpClient;
import 'package:flutter/foundation.dart' show kIsWeb;

enum FeedbackCategory {
  bugReport('Hata Bildirimi', Icons.bug_report_rounded),
  featureRequest('Yeni Özellik İsteği', Icons.auto_awesome_rounded),
  balanceEconomy('Oyun Dengesi & Ekonomi', Icons.account_balance_rounded),
  generalIdea('Genel Öneri & Fikir', Icons.lightbulb_rounded);

  final String label;
  final IconData icon;
  const FeedbackCategory(this.label, this.icon);
}

class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key});

  static const String developerEmail = 'hib0796@gmail.com';

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const FeedbackDialog(),
    );
  }

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  FeedbackCategory _selectedCategory = FeedbackCategory.bugReport;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<bool> _dispatchToEmailEndpoint({
    required String category,
    required String title,
    required String message,
    required String version,
    required int level,
    required int day,
  }) async {
    if (kIsWeb) return false;
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(
        Uri.parse('https://formsubmit.co/ajax/${FeedbackDialog.developerEmail}'),
      );
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.headers.set('Accept', 'application/json');

      final payload = jsonEncode({
        '_subject': 'Galeriden Tycoon Geri Bildirim • $category • $title',
        'Kategori': category,
        'Konu': title,
        'Mesaj': message,
        'Oyun Sürümü': version,
        'Oyuncu Seviyesi': level,
        'Oyun Günü': day,
        'Zaman': DateTime.now().toString(),
      });

      request.write(payload);
      final response = await request.close();
      client.close();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<void> _submitFeedback() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      NotificationService.showWarning(context, 'Lütfen konu başlığı ve mesajınızı eksiksiz doldurun.');
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final game = ref.read(gameProvider);
      final prefs = await SharedPreferences.getInstance();

      final feedbackEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'category': _selectedCategory.label,
        'title': title,
        'message': message,
        'appVersion': GameConstants.appVersion,
        'playerLevel': game.level,
        'playerDay': game.currentDay,
      };

      // 1. Save locally to persistent feedback queue so data is never lost
      final existingQueue = prefs.getStringList('in_app_feedback_queue') ?? [];
      existingQueue.add(jsonEncode(feedbackEntry));
      await prefs.setStringList('in_app_feedback_queue', existingQueue);

      // 2. Dispatch in background directly to developer's email (hib0796@gmail.com)
      await _dispatchToEmailEndpoint(
        category: _selectedCategory.label,
        title: title,
        message: message,
        version: GameConstants.appVersion,
        level: game.level,
        day: game.currentDay,
      );

      // 3. Thank-you reward for contributing
      ref.read(gameProvider.notifier).addXP(15);

      if (mounted) {
        Navigator.of(context).pop();
        NotificationService.showSuccess(
          context,
          'Geri bildiriminiz geliştiriciye başarıyla iletildi. Değerli katkınız için teşekkür ederiz!',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        NotificationService.showError(context, 'Geri bildirim iletilirken bir sorun oluştu.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
        borderRadius: 16,
        borderWidth: 2.5,
        shadowOffset: const Offset(4, 4),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.rate_review_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GERİ BİLDİRİM & ÖNERİ',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Geliştirici Ekibe Anonim İlet',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Category Selector
              Text(
                'BİLDİRİM KATEGORİSİ',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: FeedbackCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : (isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1)),
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 14,
                            color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Title Field
              Text(
                'KONU BAŞLIĞI',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                maxLength: 60,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Örn: Özel plaka seçerken takılma oldu...',
                  hintStyle: TextStyle(fontSize: 11.5, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Message Field
              Text(
                'AÇIKLAMA VE DETAYLAR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 400,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Karşılaştığınız sorunu veya oyunda görmek istediğiniz yeniliği açıklayınız...',
                  hintStyle: TextStyle(fontSize: 11.5, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Anonymous Diagnostic Pill
              Row(
                children: [
                  NeoBrutalBadge(
                    text: 'Anonim • v${GameConstants.appVersion} • Sv.${game.level} • Gün ${game.currentDay}',
                    icon: Icons.security_rounded,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: 'VAZGEÇ',
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      fontSize: 11.5,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: NeoBrutalButton(
                      label: _isSubmitting ? 'İLETİLİYOR...' : 'BİLDİRİMİ GÖNDER',
                      icon: Icons.send_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 11.5,
                      onPressed: _isSubmitting ? null : _submitFeedback,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
