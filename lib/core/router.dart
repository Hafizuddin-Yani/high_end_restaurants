import 'package:go_router/go_router.dart'; // ROUTING: 3rd party package for navigation
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../features/guest/guest_home_screen.dart';
import '../features/guest/package_detail_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
// import '../features/guest/search_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/shared/main_wrapper.dart';
import '../features/booking/booking_screen.dart';
import '../features/booking/multi_step_booking.dart';
import '../features/booking/user_dashboard_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/manage_bookings_screen.dart';
import '../features/admin/manage_packages_screen.dart';
import '../features/admin/edit_package_screen.dart';
import '../features/admin/manage_users/presentation/manage_users_screen.dart';
import '../data/repositories.dart';
import '../domain/models.dart';

// Placeholder screens for routing setup
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

// STATE MANAGEMENT & ROUTING: Provider for the app router
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state (removed for now to avoid reset bugs)
  // ref.watch(authStateProvider);

  // Define the Global Keys for the ShellRoute navigators to maintain state
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // ROUTING: Initialize GoRouter
  return GoRouter(
    navigatorKey: _rootNavigatorKey, // Key to control root navigation logic
    initialLocation: '/', // Start app at home screen
    routes: [
      // Shell Route Wrapper (Bottom Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // 0. My Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const UserDashboardScreen(),
              ),
            ],
          ),
          // 1. Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const GuestHomeScreen(),
              ),
            ],
          ),
          // 2. Search (Placeholder - actual search is toggled on Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) =>
                    const GuestHomeScreen(), // Falls through to Home logic
              ),
            ],
          ),
          // 3. Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ROUTING: Screen NOT in the Bottom Bar (Full Screen Overlay)
      GoRoute(
        path: '/package-details',
        parentNavigatorKey:
            _rootNavigatorKey, // Covers bottom bar by using root navigator
        builder: (context, state) {
          // ROUTING: Extracting arguments passed during navigation
          final package = state.extra as MenuPackage;
          return PackageDetailScreen(package: package);
        },
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/book',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final package = state.extra as MenuPackage;
          return MultiStepBookingScreen(package: package);
        },
      ),
      GoRoute(
        path: '/book/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final package = extras['package'] as MenuPackage;
          final booking = extras['booking'] as Booking;
          return MultiStepBookingScreen(
            package: package,
            existingBooking: booking,
          );
        },
      ),
      // Legacy booking screen route (for fallback)
      GoRoute(
        path: '/book-legacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final package = state.extra as MenuPackage;
          return BookingScreen(package: package);
        },
      ),
      // ROUTING: Admin Routes (Independent of core user flow)
      GoRoute(
        path: '/admin/home',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/packages',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManagePackagesScreen(),
      ),
      GoRoute(
        path: '/admin/bookings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageBookingsScreen(),
      ),
      GoRoute(
        path: '/admin/packages/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditPackageScreen(),
      ),
      GoRoute(
        path: '/admin/packages/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final package = state.extra as MenuPackage;
          return EditPackageScreen(package: package);
        },
      ),
      GoRoute(
        path: '/admin/manage-users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageUsersScreen(),
      ),
    ],
  );
});
