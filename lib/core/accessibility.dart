import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helpers for WCAG compliance
class A11y {
  /// Minimum touch target size (48x48 per WCAG)
  static const double minTouchTarget = 48.0;

  /// High contrast colors
  static const Color highContrastText = Colors.white;
  static const Color highContrastBackground = Color(0xFF121212);
  
  /// Focus indicator color
  static const Color focusColor = Color(0xFFD4AF37);
}

/// Accessible button wrapper ensuring minimum touch target
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onTap != null,
      excludeSemantics: excludeFromSemantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: A11y.minTouchTarget,
            minHeight: A11y.minTouchTarget,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Focus-aware container with visible focus indicator
class FocusableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const FocusableContainer({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<FocusableContainer> createState() => _FocusableContainerState();
}

class _FocusableContainerState extends State<FocusableContainer> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            border: _isFocused
                ? Border.all(color: A11y.focusColor, width: 2)
                : null,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: A11y.focusColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Semantic heading for screen readers
class SemanticHeading extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int level;

  const SemanticHeading({
    super.key,
    required this.text,
    this.style,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: style,
        semanticsLabel: text,
      ),
    );
  }
}

/// Skip to main content link for keyboard navigation
class SkipToContent extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;

  const SkipToContent({
    super.key,
    required this.onSkip,
    this.label = 'Skip to main content',
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          
          return AnimatedOpacity(
            opacity: hasFocus ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.translationValues(
                0,
                hasFocus ? 0 : -100,
                0,
              ),
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  backgroundColor: A11y.focusColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(label),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Extension to add common semantic properties
extension SemanticWidgetExtension on Widget {
  /// Wrap with semantic label
  Widget withSemantics({
    String? label,
    String? hint,
    bool? button,
    bool? header,
    bool? image,
    bool? link,
    bool? enabled,
    bool? focused,
    bool? selected,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      image: image,
      link: link,
      enabled: enabled,
      focused: focused,
      selected: selected,
      onTap: onTap,
      child: this,
    );
  }

  /// Exclude from semantics tree
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Mark as decorative (ignore by screen readers)
  Widget decorative() {
    return Semantics(
      excludeSemantics: true,
      child: this,
    );
  }
}

/// Accessible loading indicator
class AccessibleLoadingIndicator extends StatelessWidget {
  final String? label;
  final double size;
  final Color? color;

  const AccessibleLoadingIndicator({
    super.key,
    this.label,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label ?? 'Loading',
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color ?? const Color(0xFFD4AF37),
        ),
      ),
    );
  }
}

/// Announce message to screen readers
void announceToScreenReader(BuildContext context, String message) {
  SemanticsService.announce(message, TextDirection.ltr);
}

/// High contrast mode detector
bool isHighContrastMode(BuildContext context) {
  return MediaQuery.of(context).highContrast;
}

/// Reduced motion detector
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

/// Get animation duration based on user preference
Duration getAnimationDuration(BuildContext context, Duration normal) {
  if (prefersReducedMotion(context)) {
    return Duration.zero;
  }
  return normal;
}

