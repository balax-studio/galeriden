import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extension.dart';

/// Standard Neo-Brutal App Bar with tactile back button strictly aligned to the left,
/// solid typography, and responsive action buttons.
class NeoBrutalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;
  final bool showLeading;
  final PreferredSizeWidget? bottom;
  final double elevation;

  const NeoBrutalAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.onLeadingPressed,
    this.showLeading = true,
    this.bottom,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? Theme.of(context).brightness == Brightness.dark;

    final bgColor = p?.surfaceColor ?? (isDark ? const Color(0xFF141721) : Colors.white);
    final borderColor = p?.surfaceBorderColor ?? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A));
    final textColor = p?.textPrimaryColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 2.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Middle / Centered Title section
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: titleWidget ??
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                    ),
                  ),

                  // Far-left: Strict Leading Back Button with expanded hit area
                  if (showLeading)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (onLeadingPressed != null) {
                            onLeadingPressed!();
                          } else if (context.canPop()) {
                            context.pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0), // increased hit area
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: borderColor,
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: borderColor,
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Far-right: Action items
                  if (actions != null && actions!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                    ),
                ],
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

/// Neo-Brutal Styled TabBar with crisp pill containers and solid contrast active indicator
class NeoBrutalTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const NeoBrutalTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? Theme.of(context).brightness == Brightness.dark;

    final borderColor = p?.surfaceBorderColor ?? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A));

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0E14) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: (index) {
          HapticFeedback.selectionClick();
          if (onTap != null) onTap!(index);
        },
        padding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: p?.primaryColor ?? const Color(0xFFFFD000),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        labelColor: const Color(0xFF0F172A),
        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        tabs: tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
      ),
    );
  }
}
