import 'package:flutter/material.dart';
// dart:ui import removed - BackdropFilter no longer used for performance
import '../../../core/theme/marketplace_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isDark;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Compact collapsed width
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? MarketplaceTheme.darkSidebarBg : MarketplaceTheme.lightSidebarBg,
        border: Border(
          right: BorderSide(
            color: isDark
                ? MarketplaceTheme.darkAccentGreen.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      // Performance optimization: Removed BackdropFilter blur for low-end device support
      child: Column(
        children: [
          const SizedBox(height: 40),
          // App Logo / Branding Icon
          _buildLogo(),
          const SizedBox(height: 40),
          
          // Navigation Items
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.storefront_rounded, 'Market'),
          _buildNavItem(2, Icons.add_circle_outline, 'Sell', isHighlight: true),
          _buildNavItem(3, Icons.receipt_long_rounded, 'Orders'),
          _buildNavItem(4, Icons.person_rounded, 'Profile'),
          
          const Spacer(),
          _buildNavItem(5, Icons.settings_rounded, 'Settings'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? MarketplaceTheme.darkAccentGreen.withValues(alpha: 0.1)
            : MarketplaceTheme.lightAccent.withValues(alpha: 0.1),
        border: Border.all(
          color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.eco,
        color: isDark ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.lightAccent,
        size: 24,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isHighlight = false}) {
    final isSelected = selectedIndex == index;
    final color = isDark 
        ? (isSelected ? MarketplaceTheme.darkAccentGreen : MarketplaceTheme.darkTextSecondary)
        : (isSelected ? MarketplaceTheme.lightAccent : MarketplaceTheme.lightTextSecondary);

    return InkWell(
      onTap: () => onItemSelected(index),
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark && isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : const [],
                    )
                  : null,
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
