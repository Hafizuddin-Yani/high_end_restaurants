import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:high_end_restaurants/features/admin/widgets/admin_scaffold.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';
import '../../data/repositories.dart';
import 'seeding_util.dart';

// UI PAGE: Main landing page for Admin users.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminScaffold(
      title: "Dashboard",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome / Stats area could go here

            // Admin Actions
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _AdminGlassActionCard(
                  icon: Icons.calendar_today,
                  title: "Reservations",
                  color: Colors.purpleAccent,
                  onTap: () => context.go('/admin/bookings'),
                ),
                _AdminGlassActionCard(
                  icon: Icons.restaurant_menu,
                  title: "Manage Menu",
                  color: Colors.orangeAccent,
                  onTap: () => context.go('/admin/packages'),
                ),
                _AdminGlassActionCard(
                  icon: Icons.people,
                  title: "Manage Users",
                  color: Colors.blueAccent,
                  onTap: () => context.go('/admin/manage-users'),
                ),
                _AdminGlassActionCard(
                  icon: Icons.cloud_upload,
                  title: "Seed Data",
                  color: Colors.greenAccent,
                  onTap: () async {
                    // DATABASE: Development utility to seed initial data
                    await seedSampleData(ref.read(databaseRepositoryProvider));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sample packages added!")),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminGlassActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AdminGlassActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AdminGlassActionCard> createState() => _AdminGlassActionCardState();
}

class _AdminGlassActionCardState extends State<_AdminGlassActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GlassContainer(
            width: 160,
            padding: const EdgeInsets.all(24),
            border: _isHovered
                ? Border.all(color: widget.color.withOpacity(0.5))
                : null,
            child: Column(
              children: [
                Icon(widget.icon, size: 40, color: widget.color),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
