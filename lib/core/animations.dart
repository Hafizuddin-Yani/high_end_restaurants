import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// High-end animation utilities for buttery-smooth micro-interactions
class LuxeAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration dramaticDuration = Duration(milliseconds: 800);

  // Curves
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve dramaticCurve = Curves.easeInOutCubic;
}

/// Extension methods for easy animation application
extension LuxeAnimateExtensions on Widget {
  /// Elegant fade-in with subtle slide up
  Widget fadeInUp({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// Luxury scale-in effect
  Widget scaleIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }

  /// Staggered list item animation
  Widget staggeredItem(int index, {Duration staggerDelay = const Duration(milliseconds: 50)}) {
    return animate(delay: staggerDelay * index)
        .fadeIn(duration: 400.ms)
        .slideX(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Premium shimmer effect
  Widget shimmer({Duration duration = const Duration(milliseconds: 1500)}) {
    return animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: const Color(0xFFD4AF37).withOpacity(0.3),
        );
  }

  /// Subtle pulse for attention
  Widget pulse({Duration duration = const Duration(milliseconds: 1000)}) {
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Button press feedback
  Widget pressable({
    VoidCallback? onTap,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    ).animate()
      .scale(
        begin: const Offset(1, 1),
        end: const Offset(0.98, 0.98),
        duration: duration,
        curve: Curves.easeInOut,
      );
  }
}

/// Animated page transition wrapper
class LuxePageTransition extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const LuxePageTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.02, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

/// Animated counter for price displays
class AnimatedPrice extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final String prefix;

  const AnimatedPrice({
    super.key,
    required this.price,
    this.style,
    this.prefix = 'RM ',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: price),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.toStringAsFixed(2)}',
          style: style,
        );
      },
    );
  }
}

/// Progress indicator with animation
class AnimatedProgress extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;

  const AnimatedProgress({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress.clamp(0, 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      foregroundColor ?? theme.primaryColor,
                      (foregroundColor ?? theme.primaryColor).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: (foregroundColor ?? theme.primaryColor).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Animated checkmark for success states
class AnimatedCheckmark extends StatelessWidget {
  final bool isChecked;
  final double size;
  final Color? color;

  const AnimatedCheckmark({
    super.key,
    required this.isChecked,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isChecked 
            ? (color ?? const Color(0xFFD4AF37))
            : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked 
              ? (color ?? const Color(0xFFD4AF37))
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              size: size * 0.6,
              color: Colors.black,
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 200.ms,
              curve: Curves.easeOutBack,
            )
          : null,
    );
  }
}

