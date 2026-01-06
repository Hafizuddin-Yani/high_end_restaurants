import 'package:flutter/material.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';

class UserFilter extends StatelessWidget {
  final String searchQuery;
  final String? selectedRole;
  final String? selectedStatus;
  final Function(String) onSearchChanged;
  final Function(String?) onRoleChanged;
  final Function(String?) onStatusChanged;

  const UserFilter({
    super.key,
    required this.searchQuery,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 16,
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Bar
          SizedBox(
            width: 300,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                hintText: 'Search by name or email...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          
          // Role Dropdown (Styled)
          _GlassDropdown(
            value: selectedRole,
            hint: "All Roles",
            items: const ['admin', 'editor', 'user'],
            onChanged: onRoleChanged,
          ),

          // Status Dropdown
           _GlassDropdown(
            value: selectedStatus,
            hint: "All Statuses",
            items: const ['active', 'inactive', 'banned'],
            onChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;

  const _GlassDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          dropdownColor: const Color(0xFF1E1B4B), // Match background for popup
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          hint: Text(hint, style: const TextStyle(color: Colors.white70)),
          items: [
             DropdownMenuItem(value: null, child: Text(hint, style: const TextStyle(color: Colors.white))),
            ...items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item.toUpperCase(), style: const TextStyle(color: Colors.white)),
            )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
