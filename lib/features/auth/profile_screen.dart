import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // UI: Typography
import 'package:flutter_animate/flutter_animate.dart'; // UI: Animations
import '../../data/repositories.dart'; // DATABASE: Access user data
import '../../core/glass_widgets.dart';
import '../../core/shimmer.dart';
import '../../core/notifications.dart';
import '../../core/responsive.dart';
import '../../domain/models.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added form key
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // LOGIC: Update user profile in database
  Future<void> _updateProfile(AppUser user) async {
    setState(() => _isLoading = true);
    try {
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await ref.read(databaseRepositoryProvider).updateUser(updatedUser);

      setState(() => _isEditing = false);
      if (mounted) {
        LuxeToast.success(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        LuxeToast.error(context, 'Error updating profile: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // STATE MANAGEMENT: Stream/Watch real-time user data
    final userAsync = ref.watch(currentAppUserStreamProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const LoginScreen();

        // Initialize controllers once
        if (!_isEditing && _nameController.text.isEmpty) {
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber ?? '';
        }

        return Scaffold(
          backgroundColor: Colors.black, // Ensure full black background
          extendBodyBehindAppBar: true,
          appBar: GlassAppBar(
            title: 'My Profile',
            actions: [
              if (!_isEditing)
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
            ],
          ),
          body: Stack(
            children: [
              // 1. Background
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1544148103-0773bf10d330?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Content - Centered with max width on desktop
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      kToolbarHeight + MediaQuery.of(context).padding.top + 20,
                      20,
                      100,
                    ),
                    child: Column(
                      children: [
                        // Avatar Section
                        Center(
                          child: GlassContainer(
                            borderRadius: BorderRadius.circular(60),
                            padding: const EdgeInsets.all(4),
                            opacity: 0.2,
                            blur: 10,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              child: Text(
                                user.email.isNotEmpty
                                    ? user.email.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Details / Edit Form
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          borderRadius: BorderRadius.circular(20),
                          opacity: 0.15,
                          blur: 20,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField(
                                  label: "Full Name",
                                  controller: _nameController,
                                  isEditing: _isEditing,
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Name cannot be empty';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const Divider(
                                  color: Colors.white24,
                                  height: 30,
                                ),
                                _buildField(
                                  label: "Phone Number",
                                  controller: _phoneController,
                                  isEditing: _isEditing,
                                  icon: Icons.phone_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Phone number cannot be empty';
                                    }
                                    // Basic phone validation (digits and maybe +)
                                    final phoneRegExp = RegExp(
                                      r'^\+?[\d\s-]{8,}$',
                                    );
                                    if (!phoneRegExp.hasMatch(value.trim())) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),

                                if (_isEditing) ...[
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isEditing = false;
                                                    _nameController.text =
                                                        user.name ?? '';
                                                    _phoneController.text =
                                                        user.phoneNumber ?? '';
                                                  });
                                                },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    _updateProfile(user);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFFD700,
                                            ),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Text('Save Changes'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Logout Content
                        if (!_isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                                ref.read(authRepositoryProvider).signOut();
                                context.go('/login');
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white60,
                              ),
                              label: const Text(
                                "Sign Out",
                                style: TextStyle(color: Colors.white60),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),
                        Text(
                          'Version 1.0.0 • Luxe Dining',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: const ProfileSkeleton(),
          ),
        ),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    String? Function(String?)? validator, // Added validator param
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: isEditing
                  ? TextFormField(
                      // Changed to TextFormField
                      controller: controller,
                      validator: validator, // Pass validator
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        hintText: "Enter $label",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        errorStyle: const TextStyle(
                          color: Colors.redAccent,
                        ), // Style error
                      ),
                    )
                  : Text(
                      controller.text.isEmpty ? "Not set" : controller.text,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontStyle: controller.text.isEmpty
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
