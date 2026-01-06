import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:high_end_restaurants/domain/models.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';
import '../providers/user_provider.dart';

class UserTable extends ConsumerWidget {
  final List<AppUser> users;
  final Function(AppUser) onEdit;
  final Function(AppUser) onDelete;

  const UserTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Header Row
    return Column(
      children: [
        // Glass Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Expanded(flex: 3, child: Text("USER", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
              const Expanded(flex: 1, child: Text("ROLE", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
              const Expanded(flex: 1, child: Text("STATUS", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
              Expanded(
                flex: 2, 
                child: InkWell(
                  onTap: () {
                     ref.read(userProvider.notifier).sortUsers((a, b) => (a.lastLogin ?? DateTime(0)).compareTo(b.lastLogin ?? DateTime(0)));
                  },
                  child: const Row(
                    children: [
                      Text("LAST LOGIN", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                       Icon(Icons.sort, color: Colors.white54, size: 16),
                    ],
                  ),
                )
              ),
              const SizedBox(width: 80), // Actions space
            ],
          ),
        ),
        
        // List of Glass Rows
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return _GlassUserRow(
                user: user,
                onEdit: () => onEdit(user),
                onDelete: () => onDelete(user),
              ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}

class _GlassUserRow extends StatefulWidget {
  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GlassUserRow({required this.user, required this.onEdit, required this.onDelete});

  @override
  State<_GlassUserRow> createState() => _GlassUserRowState();
}

class _GlassUserRowState extends State<_GlassUserRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.01 : 1.0,
        duration: 200.ms,
        child: GlassContainer(
          height: 80,
          opacity: _isHovered ? 0.15 : 0.08, // Highlight on hover
          blur: 10,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // User Info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        boxShadow: [
                          if (_isHovered) BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10)
                        ]
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.user.avatarUrl ?? ''),
                        child: widget.user.avatarUrl == null ? Text(widget.user.name?[0] ?? widget.user.email[0]) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.name ?? 'No Name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(widget.user.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Role
              Expanded(
                flex: 1,
                child: NeonBadge(
                  text: widget.user.role, 
                  color: widget.user.role == 'admin' ? Colors.purpleAccent : (widget.user.role == 'editor' ? Colors.blueAccent : Colors.grey),
                ),
              ),
              
              // Status
              Expanded(
                flex: 1,
                child: NeonBadge(
                  text: widget.user.status, 
                  color: widget.user.status == 'active' ? Colors.greenAccent : (widget.user.status == 'banned' ? Colors.redAccent : Colors.grey),
                ),
              ),

              // Last Login
              Expanded(
                flex: 2,
                child: Text(
                  widget.user.lastLogin != null ? DateFormat('MMM d, h:mm a').format(widget.user.lastLogin!) : 'Never',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
