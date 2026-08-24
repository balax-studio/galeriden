import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/dealership_model.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

/// Reusable Neo-Brutal Screen/Card Gate when a feature or screen is locked by Level/Branch tier
class NeoBrutalLockedFeatureView extends StatelessWidget {
  final String route;
  final String featureTitle;
  final String? customDescription;
  final IconData icon;

  const NeoBrutalLockedFeatureView({
    super.key,
    required this.route,
    required this.featureTitle,
    this.customDescription,
    this.icon = Icons.lock_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reqLevel = DealershipModel.getRequiredLevel(route);
    final reqBranch = DealershipModel.getRequiredBranchName(route);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderWidth: 2.5,
          borderRadius: 16,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A1D1D)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.errorRed,
                    width: 2.0,
                  ),
                ),
                child: Icon(icon, color: AppColors.errorRed, size: 38),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('locked_feature_title', {'title': featureTitle}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeoBrutalBadge(
                    text:
                        context.tr('level_required_badge', {'level': reqLevel}),
                    backgroundColor: AppColors.errorRed,
                    textColor: Colors.white,
                    fontSize: 11,
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalBadge(
                    text: context.tr('special_property_badge'),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                customDescription ??
                    context.tr('locked_feature_desc', {'branch': reqBranch}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              NeoBrutalButton(
                label: context.tr('btn_unlock_branches'),
                icon: Icons.store_mall_directory_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  context.push('/branches');
                },
              ),
              const SizedBox(height: 10),
              NeoBrutalButton(
                label: context.tr('btn_go_back'),
                icon: Icons.arrow_back_rounded,
                backgroundColor:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/dashboard');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
