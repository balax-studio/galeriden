import '../../core/localization/app_localizations.dart';
import 'dart:convert';
import 'dart:io' show HttpClient, HttpHeaders;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/game_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/notification_service.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

enum FeedbackCategory {
  bugReport('feedback_cat_bug', Icons.bug_report_rounded),
  featureRequest('feedback_cat_feature', Icons.auto_awesome_rounded),
  balanceEconomy('feedback_cat_balance', Icons.account_balance_rounded),
  generalIdea('feedback_cat_idea', Icons.lightbulb_rounded);

  final String labelKey;
  final IconData icon;
  const FeedbackCategory(this.labelKey, this.icon);
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
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.postUrl(
        Uri.parse('https://formsubmit.co/ajax/${FeedbackDialog.developerEmail}'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=UTF-8');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'GaleridenTycoon/$version • Dart/Flutter • Mobile');
      request.headers.set('Origin', 'https://galeridentycoon.app');
      request.headers.set('Referer', 'https://galeridentycoon.app');

      final payload = jsonEncode({
        '_subject': 'Galeriden Tycoon Geri Bildirim • $category • $title',
        '_captcha': 'false',
        '_template': 'table',
        'Kategori': category,
        'Konu': title,
        'Mesaj': message,
        'Oyun Surumu': version,
        'Oyuncu Seviyesi': level,
        'Oyun Gunu': day,
        'Zaman': DateTime.now().toString(),
      });

      request.write(payload);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map && (decoded['success'] == 'true' || decoded['success'] == true)) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _sendViaMailApp() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      NotificationService.showWarning(context, context.tr('feedback_fill_required'));
      return;
    }

    final game = ref.read(gameProvider);
    final subject = 'Galeriden Tycoon Geri Bildirim • ${context.tr(_selectedCategory.labelKey)} • $title';
    final body = '''Kategori: ${context.tr(_selectedCategory.labelKey)}
Konu: $title

Mesaj:
$message

----------------------------------------
Sistem Teşhis Bilgileri:
Oyun Sürümü: v${GameConstants.appVersion}
Oyuncu Seviyesi: ${game.level}
Oyun Günü: ${game.currentDay}
Zaman: ${DateTime.now().toLocal()}''';

    final emailUri = Uri(
      scheme: 'mailto',
      path: FeedbackDialog.developerEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallbackUri = Uri.parse(
          'mailto:${FeedbackDialog.developerEmail}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final lastRewardedDate = prefs.getString('last_feedback_xp_date');
      if (lastRewardedDate != todayStr) {
        await prefs.setString('last_feedback_xp_date', todayStr);
        ref.read(gameProvider.notifier).addXP(15);
      }
      if (mounted) {
        Navigator.of(context).pop();
        NotificationService.showSuccess(
          context,
          context.tr('feedback_mail_opened'),
        );
      }
    } catch (_) {
      if (mounted) {
        NotificationService.showError(context, context.tr('feedback_error_occurred'));
      }
    }
  }

  Future<void> _submitFeedback() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final fillRequiredText = context.tr('feedback_fill_required');
    final categoryName = context.tr(_selectedCategory.labelKey);

    if (title.isEmpty || message.isEmpty) {
      NotificationService.showWarning(context, fillRequiredText);
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final game = ref.read(gameProvider);
      final prefs = await SharedPreferences.getInstance();

      final feedbackEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'category': categoryName,
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

      // 2. Dispatch to endpoint with valid headers
      final isSent = await _dispatchToEmailEndpoint(
        category: categoryName,
        title: title,
        message: message,
        version: GameConstants.appVersion,
        level: game.level,
        day: game.currentDay,
      );

      if (isSent) {
        // 3. Thank-you reward for contributing (max once per day)
        final todayStr = DateTime.now().toIso8601String().split('T').first;
        final lastRewardedDate = prefs.getString('last_feedback_xp_date');
        if (lastRewardedDate != todayStr) {
          await prefs.setString('last_feedback_xp_date', todayStr);
          ref.read(gameProvider.notifier).addXP(15);
        }

        if (mounted) {
          Navigator.of(context).pop();
          NotificationService.showSuccess(
            context,
            context.tr('feedback_sent_success'),
          );
        }
      } else {
        // FormSubmit not activated yet or offline fallback
        if (mounted) {
          setState(() => _isSubmitting = false);
          NotificationService.showInfo(
            context,
            context.tr('feedback_fallback_notice'),
          );
          await _sendViaMailApp();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        NotificationService.showError(context, context.tr('feedback_error_occurred'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final game = ref.watch(gameProvider);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 16,
            borderWidth: 2.5,
            shadowOffset: const Offset(4, 4),
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
                            Text(
                              context.tr('feedback_title'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              context.tr('feedback_subtitle'),
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
                  context.tr('feedback_category_label'),
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
                              context.tr(cat.labelKey),
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
                  context.tr('feedback_topic_label'),
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
                    hintText: context.tr('feedback_topic_hint'),
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
                  context.tr('feedback_details_label'),
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
                    hintText: context.tr('feedback_details_hint'),
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
                      text: context.tr('feedback_anon_diag', {'ver': GameConstants.appVersion, 'level': game.level, 'day': game.currentDay}),
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
                        label: context.tr('feedback_btn_cancel'),
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
                        label: _isSubmitting ? context.tr('feedback_btn_submitting') : context.tr('feedback_btn_send'),
                        icon: Icons.send_rounded,
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 11.5,
                        onPressed: _isSubmitting ? null : _submitFeedback,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                NeoBrutalButton(
                  label: context.tr('feedback_btn_email'),
                  icon: Icons.mail_outline_rounded,
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                  textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  fullWidth: true,
                  onPressed: _isSubmitting ? null : _sendViaMailApp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
