import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:high_end_restaurants/domain/models.dart';
import 'package:high_end_restaurants/data/repositories.dart';

// Raw stream of all users
final allUsersStreamProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  return ref.watch(databaseRepositoryProvider).getAllUsers();
});

// State class to hold list and filter/pagination metadata
class UserState {
  final List<AppUser> users;
  final List<AppUser> filteredUsers;
  final String searchQuery;
  final String? roleFilter;
  final String? statusFilter;
  final int currentPage;
  final int itemsPerPage;

  UserState({
    this.users = const [],
    this.filteredUsers = const [],
    this.searchQuery = '',
    this.roleFilter,
    this.statusFilter,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  UserState copyWith({
    List<AppUser>? users,
    List<AppUser>? filteredUsers,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return UserState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
  
  List<AppUser> get paginatedUsers {
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= filteredUsers.length) return [];
    final endIndex = startIndex + itemsPerPage;
    return filteredUsers.sublist(
        startIndex, endIndex > filteredUsers.length ? filteredUsers.length : endIndex);
  }

  int get totalPages => (filteredUsers.length / itemsPerPage).ceil();
}

class UserNotifier extends AutoDisposeAsyncNotifier<UserState> {
  
  @override
  FutureOr<UserState> build() async {
     // Watch the stream! This will trigger a rebuild whenever the DB changes.
     final users = await ref.watch(allUsersStreamProvider.future);
     
     // Preserve existing filters if we are rebuilding due to data change
     String query = '';
     String? role;
     String? status;
     
     try {
       if (state.hasValue) {
         final old = state.value!;
         query = old.searchQuery;
         role = old.roleFilter;
         status = old.statusFilter;
       }
     } catch (_) {}

     // Apply filters to the NEW data
     final filtered = _filterUsers(users, query, role, status);
     
     return UserState(
       users: users, 
       filteredUsers: filtered,
       searchQuery: query,
       roleFilter: role,
       statusFilter: status,
     );
  }

  // --- Actions ---

  void search(String query) {
    if (!state.hasValue) return;
    _updateStateWithFilters(searchQuery: query);
  }

  void filterByRole(String? role) {
    if (!state.hasValue) return;
    _updateStateWithFilters(roleFilter: role);
  }

  void filterByStatus(String? status) {
    if (!state.hasValue) return;
    _updateStateWithFilters(statusFilter: status, forceStatusUpdate: true);
  }
  
  void _updateStateWithFilters({
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
    bool forceStatusUpdate = false, 
  }) {
    if (!state.hasValue) return;
    final current = state.value!;
    final query = searchQuery ?? current.searchQuery;
    final newRole = roleFilter ?? current.roleFilter;
    final newStatus = forceStatusUpdate ? statusFilter : (current.statusFilter);
    final isExplicitStatus = forceStatusUpdate;
    // previous logic used ternary on forceStatusUpdate but logic above is cleaner
    final statusToUse = forceStatusUpdate ? statusFilter : current.statusFilter;

    final filtered = _filterUsers(current.users, query, newRole, statusToUse);

    state = AsyncData(current.copyWith(
      filteredUsers: filtered,
      searchQuery: query,
      roleFilter: newRole,
      statusFilter: statusToUse,
      currentPage: 1, 
    ));
  }

  List<AppUser> _filterUsers(List<AppUser> allUsers, String query, String? role, String? status) {
    List<AppUser> filtered = allUsers;

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((u) =>
          (u.name?.toLowerCase().contains(lowerQuery) ?? false) ||
          u.email.toLowerCase().contains(lowerQuery)).toList();
    }

    if (role != null) {
      filtered = filtered.where((u) => u.role == role).toList();
    }

    if (status != null) {
      filtered = filtered.where((u) => u.status == status).toList();
    }
    
    return filtered;
  }

  void setPage(int page) {
    if (!state.hasValue) return;
    state = AsyncData(state.value!.copyWith(currentPage: page));
  }

  Future<void> deleteUser(String userId) async {
    await ref.read(databaseRepositoryProvider).deleteUser(userId);
  }

  Future<void> updateUser(AppUser updatedUser) async {
     await ref.read(databaseRepositoryProvider).updateUser(updatedUser);
  }
  
  Future<void> addUser(AppUser newUser) async {
      await ref.read(databaseRepositoryProvider).updateUser(newUser);
  }
  
  void sortUsers(int Function(AppUser a, AppUser b) compare) {
      if (!state.hasValue) return;
      final currentState = state.value!;
      final sortedList = List<AppUser>.from(currentState.filteredUsers)..sort(compare);
      state = AsyncData(currentState.copyWith(filteredUsers: sortedList));
  }
}

final userProvider = AsyncNotifierProvider.autoDispose<UserNotifier, UserState>(() {
  return UserNotifier();
});
