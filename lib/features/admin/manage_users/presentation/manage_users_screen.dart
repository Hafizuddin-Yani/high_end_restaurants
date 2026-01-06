import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:high_end_restaurants/features/admin/widgets/admin_scaffold.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';
import 'providers/user_provider.dart';
import 'widgets/user_table.dart';
import 'widgets/user_filter.dart';
import 'widgets/user_card_list.dart';
import 'widgets/user_modal.dart';
import 'package:high_end_restaurants/domain/models.dart';

// UI PAGE: Admin user management (View, Edit, Delete, Filter)
class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateAsync = ref.watch(userProvider);

    return AdminScaffold(
      title: "Manage Users",
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () => _showEditDialog(context, ref, null),
        label: const Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      child: userStateAsync.when(
        data: (state) {
          // STATE: List of users is paginated and filtered in the provider
          final paginatedUsers = state.paginatedUsers;

          return Column(
            children: [
              // UI Component: Custom filter bar for Role/Status/Search
              UserFilter(
                searchQuery: state.searchQuery,
                selectedRole: state.roleFilter,
                selectedStatus: state.statusFilter,
                onSearchChanged: (val) =>
                    ref.read(userProvider.notifier).search(val),
                onRoleChanged: (val) =>
                    ref.read(userProvider.notifier).filterByRole(val),
                onStatusChanged: (val) =>
                    ref.read(userProvider.notifier).filterByStatus(val),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: paginatedUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_off,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return UserTable(
                              users: paginatedUsers,
                              onEdit: (user) =>
                                  _showEditDialog(context, ref, user),
                              onDelete: (user) =>
                                  _showDeleteDialog(context, ref, user),
                            );
                          } else {
                            return UserCardList(
                              users: paginatedUsers,
                              onEdit: (user) =>
                                  _showEditDialog(context, ref, user),
                              onDelete: (user) =>
                                  _showDeleteDialog(context, ref, user),
                            );
                          }
                        },
                      ),
              ),

              // Glass Pagination
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    borderRadius: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          onPressed: state.currentPage > 1
                              ? () => ref
                                    .read(userProvider.notifier)
                                    .setPage(state.currentPage - 1)
                              : null,
                        ),
                        Text(
                          'Page ${state.currentPage} of ${state.totalPages}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: state.currentPage < state.totalPages
                              ? () => ref
                                    .read(userProvider.notifier)
                                    .setPage(state.currentPage + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, AppUser? user) {
    showDialog(
      context: context,
      builder: (ctx) => UserModal(
        user: user,
        onSave: (updatedUser) {
          if (user == null) {
            ref.read(userProvider.notifier).addUser(updatedUser);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User ${updatedUser.name} created successfully'),
              ),
            );
          } else {
            ref.read(userProvider.notifier).updateUser(updatedUser);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          width: null,
          padding: const EdgeInsets.all(32),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'DELETE USER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to permanently delete\n${user.name}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    LiquidButton(
                      label: "Delete",
                      color: Colors.redAccent,
                      onPressed: () {
                        ref.read(userProvider.notifier).deleteUser(user.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User deleted')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
