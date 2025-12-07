import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import 'wave_painter.dart';

/// Curved header - Wave-shaped header component
/// Composition: Uses WavePainter for wave, accepts any child
class CurvedHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final Gradient? gradient;
  final Color? color;
  final double waveHeight;
  final EdgeInsets contentPadding;
  final bool useSafeArea;

  const CurvedHeader({
    super.key,
    required this.child,
    this.height = 200,
    this.gradient,
    this.color,
    this.waveHeight = DesignTokens.headerWaveHeight,
    this.contentPadding = const EdgeInsets.all(DesignTokens.spacing24),
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = color ?? AppColors.primaryGreen;
    final totalHeight = height + waveHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Wave background
          Positioned.fill(
            child: CustomPaint(
              size: Size(double.infinity, totalHeight),
              painter: WavePainter(
                color: headerColor,
                gradient: gradient,
                waveHeight: waveHeight,
                isTop: true,
              ),
            ),
          ),
          // Content
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: waveHeight,
            child: useSafeArea
                ? SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: contentPadding,
                      child: child,
                    ),
                  )
                : Padding(
                    padding: contentPadding,
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Simple curved header with title and optional actions
class SimpleCurvedHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? color;
  final Gradient? gradient;
  final double height;

  const SimpleCurvedHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.color,
    this.gradient,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      height: height,
      color: color,
      gradient: gradient ?? AppColors.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with leading and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leading != null) leading!,
              if (actions != null) Row(children: actions!),
            ],
          ),
          const Spacer(),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashboard curved header with stats
class DashboardCurvedHeader extends StatelessWidget {
  final String title;
  final String greeting;
  final Widget? avatar;
  final List<Widget>? stats;
  final VoidCallback? onAvatarTap;

  const DashboardCurvedHeader({
    super.key,
    required this.title,
    this.greeting = 'Welcome back',
    this.avatar,
    this.stats,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedHeader(
      height: stats != null ? 220 : 180,
      gradient: AppColors.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (avatar != null)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: avatar!,
                ),
            ],
          ),
          if (stats != null) ...[
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Mini stat widget for header
class HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const HeaderStat({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
