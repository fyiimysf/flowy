// lib/widgets/common/indicators.dart

import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

/// Animated progress indicator with soft styling
class ProgressIndicator extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final String? label;

  const ProgressIndicator({
    super.key,
    required this.value,
    this.size = 100,
    this.strokeWidth = 10,
    this.color,
    this.backgroundColor,
    this.showPercentage = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer soft shadow for depth (light mode only)
        if (!isDark)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: AppDimensions.durationSlow,
            curve: Curves.easeOut,
            builder: (context, animatedValue, child) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                color: color ?? AppColors.primary,
                backgroundColor: backgroundColor ?? theme.colorScheme.onSurface.withOpacity(0.1),
              );
            },
          ),
        ),
        if (showPercentage)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.25,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Fertility indicator with soft dot and label
class FertilityIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  final IconData? icon;

  const FertilityIndicator({
    super.key,
    required this.label,
    required this.color,
    this.size = 14,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: size * 0.6,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Phase chip with claymorphism styling
class PhaseChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final IconData? icon;

  const PhaseChip({
    super.key,
    required this.label,
    required this.color,
    this.isActive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      // Removed AnimatedContainer to prevent theme switch flash
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.elementSpacing,
        vertical: AppDimensions.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? color.withOpacity(0.15) 
            : isDark
                ? Colors.white.withOpacity(0.05)
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive && !isDark
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDimensions.iconSmall,
              color: isActive ? color : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: AppDimensions.tinySpacing),
          ],
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? color : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status dot with pulse animation
class StatusDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool pulse;

  const StatusDot({
    super.key,
    required this.color,
    this.size = 10,
    this.pulse = true,
  });

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: widget.pulse ? widget.size * (_animation.value - 0.5) : 6,
                      spreadRadius: widget.pulse ? widget.size * (_animation.value - 1.0) * 0.3 : 0,
                    ),
                  ],
          ),
        );
      },
    );
  }
}

/// Cycle progress bar with segments
class CycleProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> phaseColors;
  final double height;

  const CycleProgressBar({
    super.key,
    required this.progress,
    required this.phaseColors,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: theme.colorScheme.onSurface.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            // Background segments
            Row(
              children: phaseColors.map((color) {
                return Expanded(
                  child: Container(
                    color: color.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
            // Progress indicator
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
