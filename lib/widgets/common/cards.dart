// lib/widgets/common/cards.dart

import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

/// Claymorphism card with soft shadows and rounded corners
/// Creates that soft, toy-like 3D effect perfect for feminine UI
/// Now theme-aware - adapts to light/dark mode
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? radius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Theme-aware shadows: NO shadows in dark mode, minimal in light for performance
    final clayShadows = shadows ??
        (isDark
            ? [] // No shadows in dark mode - clean flat design
            : [
                // Light mode: single subtle shadow for performance
                BoxShadow(
                  color: AppColors.clayShadow.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]);

    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(radius ?? AppDimensions.radiusLarge),
        boxShadow: clayShadows,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.clayShadow.withOpacity(0.2),
          width: AppDimensions.borderThin,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Metric card with claymorphism styling
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClayCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.primary).withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(height: AppDimensions.elementSpacing),
              ],
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
        ],
      ),
    );
  }
}

/// Stat card with subtle claymorphism
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? backgroundColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClayCard(
      color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      shadows: isDark
          ? [] // No shadows in dark mode
          : [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppDimensions.iconSmall,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.smallSpacing),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info card with prominent claymorphism
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClayCard(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      color: backgroundColor ?? theme.colorScheme.surface,
      // Use default ClayCard shadows for consistency and performance
      child: child,
    );
  }
}

/// Pressable clay button with animated feedback
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final double? radius;

  const ClayButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.radius,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // NO animated container - use regular Container to prevent flash
    // during theme transitions
    // Minimal shadows for performance in light mode
    final shadows = _isPressed
        ? (isDark
            ? [] // No pressed shadows in dark
            : [
                BoxShadow(
                    color: AppColors.clayShadow.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                    spreadRadius: -1),
              ])
        : (isDark
            ? [] // No shadows in dark mode at all
            : [
                BoxShadow(
                  color: AppColors.clayShadow.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Container(
        // Removed AnimatedContainer to prevent color flash during theme switch
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.elementSpacing,
            ),
        decoration: BoxDecoration(
          color: widget.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
              widget.radius ?? AppDimensions.radiusMedium),
        ),
        child: widget.child,
      ),
    );
  }
}
