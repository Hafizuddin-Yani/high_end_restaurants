import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultraWide = 1800;
}

/// Screen size categories
enum ScreenSize { mobile, tablet, desktop, ultraWide }

/// Responsive layout helper
class Responsive {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) return ScreenSize.mobile;
    if (width < Breakpoints.tablet) return ScreenSize.tablet;
    if (width < Breakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.ultraWide;
  }

  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < Breakpoints.mobile;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.tablet;
  
  static bool isUltraWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.ultraWide;

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultraWide,
  }) {
    final size = getScreenSize(context);
    
    switch (size) {
      case ScreenSize.ultraWide:
        return ultraWide ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return value(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 32),
      desktop: const EdgeInsets.symmetric(horizontal: 64),
      ultraWide: const EdgeInsets.symmetric(horizontal: 120),
    );
  }

  /// Get maximum content width
  static double maxContentWidth(BuildContext context) {
    return value<double>(
      context,
      mobile: double.infinity,
      tablet: 700,
      desktop: 1000,
      ultraWide: 1400,
    );
  }

  /// Get number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    return value<int>(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      ultraWide: 4,
    );
  }
}

/// Responsive layout builder widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultraWide;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.ultraWide) {
          return ultraWide ?? desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Constrained content wrapper for maximum width
class ContentConstraint extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentConstraint({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? Responsive.padding(context),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid view
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? columns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final cols = columns ?? Responsive.gridColumns(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// Adaptive two-column layout (side by side on desktop, stacked on mobile)
class AdaptiveColumns extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final double primaryFlex;
  final double secondaryFlex;
  final double spacing;

  const AdaptiveColumns({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
    this.spacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: primaryFlex.toInt(),
            child: primary,
          ),
          SizedBox(width: spacing),
          Expanded(
            flex: secondaryFlex.toInt(),
            child: secondary,
          ),
        ],
      );
    }
    
    return Column(
      children: [
        primary,
        SizedBox(height: spacing),
        secondary,
      ],
    );
  }
}

