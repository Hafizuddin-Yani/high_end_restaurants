import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

/// Types of toast notifications
enum ToastType { success, error, warning, info }

/// High-end toast notification system
class LuxeToast {
  static OverlayEntry? _currentToast;

  /// Show a luxury toast notification
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _LuxeToastWidget(
        message: message,
        title: title,
        type: type,
        duration: duration,
        onTap: onTap,
        onDismiss: () => _currentToast?.remove(),
      ),
    );

    _currentToast = entry;
    overlay.insert(entry);

    Future.delayed(duration + 500.ms, () {
      if (_currentToast == entry) {
        entry.remove();
        _currentToast = null;
      }
    });
  }

  /// Quick success toast
  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title ?? 'Success', type: ToastType.success);
  }

  /// Quick error toast
  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title ?? 'Error', type: ToastType.error);
  }

  /// Quick warning toast
  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title ?? 'Warning', type: ToastType.warning);
  }

  /// Quick info toast
  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.info);
  }
}

class _LuxeToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _LuxeToastWidget({
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_LuxeToastWidget> createState() => _LuxeToastWidgetState();
}

class _LuxeToastWidgetState extends State<_LuxeToastWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  Color get _accentColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFE53935);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFFD4AF37);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: 300.ms,
        child: GestureDetector(
          onTap: widget.onTap ?? widget.onDismiss,
          onHorizontalDragEnd: (_) => widget.onDismiss(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icon,
                        color: _accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}

/// Inline notification banner
class LuxeBanner extends StatelessWidget {
  final String message;
  final String? title;
  final ToastType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const LuxeBanner({
    super.key,
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  Color get _accentColor {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFE53935);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFFD4AF37);
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _accentColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel ?? 'Action',
                style: TextStyle(color: _accentColor),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.5),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

