import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width > 1100;
        // Use condensed sidebar (Rail) for anything smaller than Desktop
        // This satisfies the user request for "side bar with icon only" on mobile

        return Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: floatingActionButton,
          // Remove AppBar/Drawer for navigation, rely on the permanent side rail
          body: AuroraBackground(
            child: Row(
              children: [
                // 1. Navigation Sidebar
                // Expanded on Desktop, Collapsed (Icon Only) on Tablet/Mobile
                _GlassSidebar(isExpanded: isDesktop),

                // 2. Main Content Area
                Expanded(
                  child: Padding(
                    // Adjust padding: Desktop gets more space, Mobile gets minimal
                    // Adjust padding: Desktop gets more space, Mobile gets minimal
                    padding: EdgeInsets.only(
                      top:
                          MediaQuery.of(context).padding.top +
                          24, // Account for status bar/notch
                      left: isDesktop
                          ? 16
                          : 8, // Less padding on mobile to save space
                      right: isDesktop ? 16 : 8,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Header (Visible on all sizes now since we removed AppBar)
                        // But maybe smaller on mobile
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 32 : 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassSidebar extends StatelessWidget {
  final bool isExpanded;

  const _GlassSidebar({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: isExpanded ? 250 : 90, // Slightly wider rail to prevent overflow
      height: double.infinity,
      margin: EdgeInsets.all(isExpanded ? 16 : 8), // Tighter margin on rail
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: isExpanded ? 16 : 8,
      ), // Tighter padding
      child: Column(
        children: [
          // Logo Area
          if (isExpanded)
            const Text(
              "LUXE ADMIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            )
          else
            const Icon(Icons.restaurant, color: Colors.white, size: 32),

          const SizedBox(height: 48),

          // Nav Items
          _NavButton(
            icon: Icons.dashboard,
            label: "Dashboard",
            route: "/admin/home",
            isExpanded: isExpanded,
            isActive: GoRouterState.of(context).uri.toString() == "/admin/home",
          ),
          _NavButton(
            icon: Icons.people,
            label: "Manage Users",
            route: "/admin/manage-users",
            isExpanded: isExpanded,
            isActive:
                GoRouterState.of(context).uri.toString() ==
                "/admin/manage-users",
          ),
          _NavButton(
            icon: Icons.calendar_today,
            label: "Reservations",
            route: "/admin/bookings",
            isExpanded: isExpanded,
            isActive:
                GoRouterState.of(context).uri.toString() == "/admin/bookings",
          ),
          _NavButton(
            icon: Icons.restaurant_menu,
            label: "Manage Menu",
            route: "/admin/packages",
            isExpanded: isExpanded,
            isActive: GoRouterState.of(
              context,
            ).uri.toString().startsWith("/admin/packages"),
          ),

          const Spacer(),

          _NavButton(
            icon: Icons.logout,
            label: "Logout",
            route: "/login",
            isExpanded: isExpanded,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isDestructive;
  final bool isExpanded;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
    this.isDestructive = false,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        opacity: isActive ? 0.2 : 0.05,
        blur: 5,
        border: isActive
            ? Border.all(color: Colors.blue.withOpacity(0.5))
            : Border.all(color: Colors.transparent),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 8,
          vertical: 12,
        ),
        onTap: () {
          // Close drawer if mobile
          if (Scaffold.of(context).hasDrawer &&
              Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
          context.go(route);
        },
        child: Row(
          mainAxisAlignment: isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Flexible(
                // Prevent overflow
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
