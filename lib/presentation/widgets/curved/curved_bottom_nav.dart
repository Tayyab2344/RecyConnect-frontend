import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';

/// Curved bottom navigation bar
/// Features: Wave-shaped top edge, frosted blur, circular highlight animation
class CurvedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CurvedBottomNavItem> items;
  final double height;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool hasBlur;
  final Widget? floatingButton;

  const CurvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = DesignTokens.bottomNavHeight,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.hasBlur = true,
    this.floatingButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkSurface : Colors.white);
    final primaryColor = isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen;
    final activeClr = activeColor ?? primaryColor;
    final inactiveClr = inactiveColor ??
        (isDark ? AppColors.darkTextSecondary : AppColors.mediumGrey);

    return Container(
      height: height + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: hasBlur ? bgColor.withValues(alpha: 0.8) : bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.bottomNavRadius),
          topRight: Radius.circular(DesignTokens.bottomNavRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.bottomNavRadius),
          topRight: Radius.circular(DesignTokens.bottomNavRadius),
        ),
        child: BackdropFilter(
          filter: hasBlur
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(items.length, (index) {
                      // If we have a floating button and this is the middle item
                      if (floatingButton != null && index == items.length ~/ 2) {
                        return SizedBox(
                          width: 60,
                          child: Opacity(
                            opacity: 0,
                            child: _buildNavItem(
                              context,
                              items[index],
                              index,
                              activeClr,
                              inactiveClr,
                            ),
                          ),
                        );
                      }
                      return _buildNavItem(
                        context,
                        items[index],
                        index,
                        activeClr,
                        inactiveClr,
                      );
                    }),
                  ),
                  if (floatingButton != null) floatingButton!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    CurvedBottomNavItem item,
    int index,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated indicator
            AnimatedContainer(
              duration: DesignTokens.animationNormal,
              height: 4,
              width: isSelected ? 20 : 0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Icon
            AnimatedContainer(
              duration: DesignTokens.animationNormal,
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? activeColor : inactiveColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: DesignTokens.animationNormal,
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation item data
class CurvedBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CurvedBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  // Convenience constructor when active icon is same as regular
  const CurvedBottomNavItem.simple({
    required this.icon,
    required this.label,
  }) : activeIcon = icon;
}

/// Floating action button for center of nav
class CurvedNavFAB extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isSelected;

  const CurvedNavFAB({
    super.key,
    this.onTap,
    this.icon = Icons.add,
    this.backgroundColor,
    this.iconColor,
    this.isSelected = false,
  });

  @override
  State<CurvedNavFAB> createState() => _CurvedNavFABState();
}

class _CurvedNavFABState extends State<CurvedNavFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.darkPrimaryGreen : AppColors.primaryGreen);
    final fgColor = widget.iconColor ??
        (isDark ? AppColors.darkBackground : Colors.white);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: widget.isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Icon(
            widget.icon,
            color: fgColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
