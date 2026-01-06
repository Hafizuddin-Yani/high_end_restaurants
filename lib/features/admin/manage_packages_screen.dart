import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../guest/guest_home_screen.dart'; // Reuse provider
import 'widgets/admin_scaffold.dart';
import '../../core/theme/design_system.dart';
import 'package:high_end_restaurants/domain/models.dart';

class ManagePackagesScreen extends ConsumerWidget {
  const ManagePackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // STATE MANAGEMENT: Watch stream of all menu packages
    final packagesAsync = ref.watch(providerOfPackages);

    return AdminScaffold(
      title: "Manage Menu",
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () => context.push('/admin/packages/add'),
        label: const Text(
          "Add Item",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      child: packagesAsync.when(
        data: (packages) {
          if (packages.isEmpty) {
            return const Center(
              child: Text(
                "No menu items found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // UI: Responsive Grid layout for package cards
          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 4;
              if (constraints.maxWidth <= 1100) crossAxisCount = 3;
              if (constraints.maxWidth <= 850) crossAxisCount = 2;
              if (constraints.maxWidth <= 650) crossAxisCount = 1;

              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return _PackageGlassCard(package: package);
                },
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, st) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _PackageGlassCard extends StatefulWidget {
  final MenuPackage package;

  const _PackageGlassCard({required this.package});

  @override
  State<_PackageGlassCard> createState() => _PackageGlassCardState();
}

class _PackageGlassCardState extends State<_PackageGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: 300.ms,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -10.0 : 0.0), // Floating effect
        child: GlassContainer(
          padding: EdgeInsets.zero,
          blur: 15,
          opacity: _isHovered ? 0.15 : 0.1,
          border: _isHovered
              ? Border.all(color: Colors.white.withOpacity(0.5))
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Header
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.package.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.package.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.black38,
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),

                      // Gradient Overlay for text readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),

                      // Edit Button Overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => context.push(
                              '/admin/packages/edit',
                              extra: widget.package,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.package.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "RM ${widget.package.pricePerGuest}",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Availability Badge
                      NeonBadge(
                        text: widget.package.isAvailable
                            ? "AVAILABLE"
                            : "SOLD OUT",
                        color: widget.package.isAvailable
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
