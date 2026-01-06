import 'package:flutter/material.dart';
import 'package:high_end_restaurants/domain/models.dart';
import 'package:high_end_restaurants/core/theme/design_system.dart';
import 'package:uuid/uuid.dart';

class UserModal extends StatefulWidget {
  final AppUser? user; // Null for create, non-null for edit
  final Function(AppUser) onSave;

  const UserModal({super.key, this.user, required this.onSave});

  @override
  State<UserModal> createState() => _UserModalState();
}

class _UserModalState extends State<UserModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _role;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _role = widget.user?.role ?? 'user';
    _status = widget.user?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newUser = AppUser(
        id: widget.user?.id ?? const Uuid().v4(),
        name: _nameController.text,
        email: _emailController.text,
        role: _role,
        status: _status,
        lastLogin: widget.user?.lastLogin ?? DateTime.now(),
        avatarUrl: widget.user?.avatarUrl ?? 'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}', 
      );
      
      widget.onSave(newUser);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    
    return Dialog(
      backgroundColor: Colors.transparent, // Important for Glass effect
      child: GlassContainer(
        width: 500,
        padding: const EdgeInsets.all(32.0),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'EDIT USER' : 'NEW USER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              
              _GlassInput(
                controller: _nameController,
                label: 'Full Name',
                validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              
              _GlassInput(
                controller: _emailController,
                label: 'Email Address',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _GlassDropdown(
                      value: _role,
                      label: "Role",
                      items: ['admin', 'editor', 'user'],
                      onChanged: (val) => setState(() => _role = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                   Expanded(
                    child: _GlassDropdown(
                      value: _status,
                      label: "Status",
                      items: ['active', 'inactive', 'banned'],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  ),
                  const SizedBox(width: 16),
                  LiquidButton(
                    label: isEditing ? 'Save Changes' : 'Create User',
                    onPressed: _submit,
                    color: Colors.pinkAccent,
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

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _GlassInput({required this.controller, required this.label, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final Function(String?) onChanged;

  const _GlassDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1E1B4B), // Match deep background
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.toUpperCase(), style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
