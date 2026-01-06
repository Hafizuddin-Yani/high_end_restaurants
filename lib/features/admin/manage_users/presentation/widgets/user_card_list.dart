import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';
import 'package:high_end_restaurants/domain/models.dart';

class UserCardList extends StatelessWidget {
  final List<AppUser> users;
  final Function(AppUser) onEdit;
  final Function(AppUser) onDelete;

  const UserCardList({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            onTap: () => onEdit(user),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (user.name ?? '').isNotEmpty ? user.name![0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name & Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Action Menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      color: const Color(0xFF1E1B4B), // Match dark theme
                      onSelected: (value) {
                         if (value == 'edit') onEdit(user);
                         if (value == 'delete') onDelete(user);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.redAccent),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                // Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Role Badge
                    NeonBadge(
                      text: user.role,
                      color: _getRoleColor(user.role),
                    ),
                    // Status Badge
                    NeonBadge(
                      text: user.status,
                      color: _getStatusColor(user.status),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.purpleAccent;
      case 'manager': return Colors.amberAccent;
      default: return Colors.blueAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.greenAccent;
      case 'banned': return Colors.redAccent;
      default: return Colors.grey;
    }
  }
}
