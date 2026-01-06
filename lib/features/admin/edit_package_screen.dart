import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:high_end_restaurants/domain/models.dart';
import '../guest/guest_home_screen.dart'; // Reuse provider
import 'widgets/admin_scaffold.dart';
import '../../core/theme/design_system.dart';
import '../../data/repositories.dart';

class EditPackageScreen extends ConsumerStatefulWidget {
  // Using StatefulWidget for form
  final MenuPackage? package; // Null for add, logic for edit (CRUD)

  // UI PAGE: Form to create or update menu packages
  const EditPackageScreen({super.key, this.package});

  @override
  ConsumerState<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends ConsumerState<EditPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _dietaryController;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package?.name ?? '');
    _descController = TextEditingController(
      text: widget.package?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.package?.pricePerGuest.toString() ?? '',
    );
    _imageController = TextEditingController(
      text: widget.package?.imageUrl ?? '',
    );
    _dietaryController = TextEditingController(
      text: widget.package?.dietaryInfo.join(', ') ?? '',
    );
    _isAvailable = widget.package?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  // LOGIC: Save or Update package in Firestore
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final dietary = _dietaryController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newPackage = MenuPackage(
        id:
            widget.package?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID gen
        name: _nameController.text,
        description: _descController.text,
        pricePerGuest: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageController.text.isNotEmpty
            ? _imageController.text
            : 'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        dietaryInfo: dietary,
        isAvailable: _isAvailable,
      );

      // DATABASE: Use repository directly to add/update data
      final repository = ref.read(databaseRepositoryProvider);
      await repository.addPackage(newPackage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.package == null ? 'Package Added' : 'Package Updated',
            ),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: widget.package == null ? "Add Package" : "Edit Package",
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GlassHeader(
                      title: widget.package == null
                          ? "CREATE NEW PACKAGE"
                          : "EDIT PACKAGE DETAILS",
                    ),
                    const SizedBox(height: 32),

                    _GlassTextField(
                      controller: _nameController,
                      label: "Package Name",
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    _GlassTextField(
                      controller: _descController,
                      label: "Description",
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    _GlassTextField(
                      controller: _priceController,
                      label: "Price Per Guest",
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    _GlassSwitch(
                      label: "Availability",
                      value: _isAvailable,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                    const SizedBox(height: 16),

                    _GlassTextField(
                      controller: _imageController,
                      label: "Image URL",
                    ),
                    const SizedBox(height: 16),

                    _GlassTextField(
                      controller: _dietaryController,
                      label: "Dietary Info (comma separated)",
                    ),
                    const SizedBox(height: 48),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Flexible(
                          // Allow button to shrink if needed, though usually it fits now
                          child: LiquidButton(
                            label: "SAVE PACKAGE",
                            onPressed: _save,
                            color: Colors.amber, // Gold theme for menu
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  final String title;
  const _GlassHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 60, height: 2, color: Colors.amber),
      ],
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _GlassTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _GlassSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56, // Match input height
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value ? "Active" : "Hidden",
                style: TextStyle(
                  color: value ? Colors.greenAccent : Colors.white54,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
