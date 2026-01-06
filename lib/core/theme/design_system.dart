import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 1. AURORA BACKGROUND
/// A deep, animated background with slowly moving "lava lamp" blobs.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Deep Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Slate 900
                Color(0xFF1E1B4B), // Indigo 950
                Color(0xFF111827), // Gray 900
              ],
            ),
          ),
        ),
        
        // Blobs
        Positioned(
          top: -100,
          left: -100,
          child: _AuroraBlob(color: Colors.purple.withOpacity(0.3), size: 400)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 10.seconds, begin: const Offset(0, 0), end: const Offset(50, 50))
              .scale(duration: 15.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: _AuroraBlob(color: Colors.teal.withOpacity(0.2), size: 350)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 12.seconds, begin: const Offset(0, 0), end: const Offset(-40, -40))
              .scale(duration: 20.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1)),
        ),
        Positioned(
          top: 200,
          right: 200,
          child: _AuroraBlob(color: Colors.blue.withOpacity(0.25), size: 250)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(duration: 8.seconds, begin: const Offset(0, 0), end: const Offset(-60, 20)),
        ),

        // Blur Mesh
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),

        // Content
        child,
      ],
    );
  }
}

class _AuroraBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AuroraBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 40, spreadRadius: 20),
        ],
      ),
    );
  }
}

/// 2. GLASS CONTAINER
/// Reusable frosted glass effect for cards/panels.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Border? border;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 16,
    this.opacity = 0.1,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity + 0.05),
                Colors.white.withOpacity(opacity),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: container,
        ),
      );
    }
    
    return Padding(padding: margin ?? EdgeInsets.zero, child: container);
  }
}

/// 3. NEON BADGE
/// Glowing status pills.
class NeonBadge extends StatelessWidget {
  final String text;
  final Color color;

  const NeonBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 0),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color.withOpacity(1.0),
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.2,
          shadows: [
             Shadow(color: color, blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// 4. LIQUID BUTTON
/// Button with fluid scaling/pressed effects.
class LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isOutline;

  const LiquidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = Colors.blue,
    this.isOutline = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isOutline ? Colors.transparent : widget.color;
    final textColor = widget.isOutline ? widget.color : Colors.white;
    final borderColor = widget.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? (widget.isOutline ? widget.color.withOpacity(0.1) : widget.color.withOpacity(0.8)) : baseColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: textColor, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
