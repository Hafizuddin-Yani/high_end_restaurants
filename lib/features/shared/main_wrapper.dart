import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to control search bar visibility on Home Screen
final searchVisibilityProvider = StateProvider<bool>((ref) => false);

class MainWrapper extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainWrapper({super.key, required this.navigationShell});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  // Removed AnimationController/Auto-hide logic to prevent "broken button" feel

  void _onTap(int index) {
    final isSearchActive = ref.read(searchVisibilityProvider);

    // Special handling for Search (index 2): Toggle visibility instead of navigating
    if (index == 2) {
      // Toggle search bar visibility
      ref.read(searchVisibilityProvider.notifier).state = !isSearchActive;
      // Navigate to Home if not already there, so user sees the search bar
      if (widget.navigationShell.currentIndex != 1) {
        widget.navigationShell.goBranch(1, initialLocation: false);
      }
      return;
    }

    // Close search when navigating to other tabs
    if (isSearchActive) {
      ref.read(searchVisibilityProvider.notifier).state = false;
    }

    // For other tabs, navigate normally
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  // Calculate the visual index for the bottom bar
  int _getVisualIndex() {
    final isSearchActive = ref.watch(searchVisibilityProvider);
    // If search is active and we're on Home, show Search as selected
    if (isSearchActive && widget.navigationShell.currentIndex == 1) {
      return 2; // Search icon
    }
    return widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Watch search state to trigger rebuilds
    ref.watch(searchVisibilityProvider);

    // Show sidebar on desktop (width >= 900px)
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left sidebar navigation
            _buildDesktopSidebar(),
            // Main content
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Allow body to go behind the bottom bar
      body: widget.navigationShell,
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _getVisualIndex(),
        onTap: _onTap,
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    final currentIndex = _getVisualIndex();

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo / Brand
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Color(0xFFD4AF37),
              size: 28,
            ),
          ),
          const SizedBox(height: 40),
          // Nav items - Home first
          _buildSidebarItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            index: 1,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 8),
          _buildSidebarItem(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number,
            label: 'Bookings',
            index: 0,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 8),
          _buildSidebarItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: 'Search',
            index: 2,
            currentIndex: currentIndex,
          ),
          const Spacer(),
          // Profile at bottom
          _buildSidebarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            index: 3,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;

    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: () => _onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4AF37).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))
                : null,
          ),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Floating Island / Pill Design (iOS App Store "Search" Tab style variant)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        bottomPadding > 0 ? bottomPadding + 10 : 25,
      ), // Dynamic bottom padding for safe area
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40), // Fully rounded pill shape
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Container(
            height: 75, // Compact floating height
            decoration: BoxDecoration(
              color: const Color(0xFF191919).withOpacity(0.85),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true, // Fix for overflow
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                elevation: 0,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFFFFD700),
                unselectedItemColor: const Color(0xFF8E8E93),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                iconSize: 28,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.confirmation_num_outlined),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.confirmation_num, size: 24),
                    ),
                    label: 'Bookings',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home_filled, size: 24),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.search),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 24,
                        weight: 800,
                      ),
                    ),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 24),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
