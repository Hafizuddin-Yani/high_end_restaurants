import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable container that implements the "Liquid Glass" aesthetic.
/// Features:
/// - Adjustable blur (Frost)
/// - Translucent background with customizable tint (defaulting to light-blueish white)
/// - Subtle white border
/// - Optional gradient
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.color = const Color(0xFFE0F7FA), // Light Cyan/Blue tint
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: effectiveBorderRadius,
              border:
                  border ??
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(opacity + 0.05),
                  color.withOpacity(opacity),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A highly transparent, frosted glass AppBar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor:
              Colors.transparent, // Fully transparent to let blur show
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300, // Light typography
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          actions: actions,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
