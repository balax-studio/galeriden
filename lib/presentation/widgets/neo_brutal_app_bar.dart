import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extension.dart';

/// Standard Neo-Brutal App Bar with tactile back button, thick borders and solid typography
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
            SizedBox(
              height: kToolbarHeight,
              child: NavigationToolbar(
                leading: showLeading
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Center(
                          child: InkWell(
                            onTap: onLeadingPressed ?? () {
                              if (context.canPop()) {
                                context.pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 36,
                              height: 36,
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
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
                middle: titleWidget ??
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
                    ),
                trailing: actions != null && actions!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      )
                    : null,
                centerMiddle: true,
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
  Size get preferredSize => const Size.fromHeight(48.0);

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? Theme.of(context).brightness == Brightness.dark;

    final borderColor = p?.surfaceBorderColor ?? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A));
    final activeColor = p?.primaryColor ?? const Color(0xFFEAB308);
    final unselectedTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: activeColor,
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
        labelColor: const Color(0xFF0F172A),
        unselectedLabelColor: unselectedTextColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
        tabs: tabs.map((tabText) => Tab(text: tabText)).toList(),
      ),
    );
  }
}
