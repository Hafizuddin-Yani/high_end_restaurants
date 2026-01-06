import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories.dart'; // REPOSITORY: Access to AuthRepository
import '../../data/admin_setup.dart';
import '../../core/glass_widgets.dart'; // UI: Custom reusable glassmorphism widgets
import '../../core/logger.dart';

// UI PAGE: Handles user login functionality
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // STATE: Variable to track loading state for UI feedback
  bool _isLoading = false;

  // LOGIC: Handle login submission
  Future<void> _login() async {
    final emailInput = _emailController.text.trim();
    final passwordInput = _passwordController.text.trim();

    // Admin Backdoor Logic
    if (emailInput == 'admin' && passwordInput == 'admin') {
      await _handleAdminLogin();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    AppLogger.auth('Login attempt', email: emailInput);

    try {
      // NETWORK: Call repository to sign in with Firebase
      await ref.read(authRepositoryProvider).signIn(emailInput, passwordInput);

      if (mounted) {
        final user = await ref
            .read(authRepositoryProvider)
            .getCurrentUserData();
        AppLogger.auth('Login successful', email: emailInput, userId: user?.id);
        if (mounted) {
          if (user?.role == 'admin') {
            // ROUTING: Navigate based on role
            context.go('/admin/home');
          } else {
            context.go('/bookings');
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAdminLogin() async {
    setState(() => _isLoading = true);
    const adminEmail = 'admin@app.com';
    const adminPassword = 'admin123';

    try {
      // Try to sign in first
      try {
        await ref
            .read(authRepositoryProvider)
            .signIn(adminEmail, adminPassword);
      } catch (e) {
        // If sign in fails, try to create the admin account
        await ref
            .read(authRepositoryProvider)
            .signUp(adminEmail, adminPassword);
      }

      // Ensure admin role exists in Firestore
      final adminSetup = ref.read(adminSetupProvider);
      await adminSetup.ensureAdminRole();

      AppLogger.auth('Admin login successful', email: adminEmail);

      if (mounted) {
        context.go('/admin/home');
      }
    } catch (e) {
      AppLogger.error('Admin login failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Login'),
      body: Stack(
        children: [
          // 1. Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1559339352-11d035aa65de?ixlib=rb-1.2.1&auto=format&fit=crop&w=1920&q=80',
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
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  borderRadius: BorderRadius.circular(24),
                  blur: 20,
                  opacity: 0.15,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700), // Gold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFFFFD700),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFFD700)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(0xFFFFD700),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFFD700)),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'Password too short'
                              : null,
                        ),

                        const SizedBox(height: 48),

                        // Login Button
                        AnimatedScale(
                          scale: _isLoading ? 0.98 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text('LOGIN'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register Link
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              children: const [
                                TextSpan(
                                  text: "Create one",
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
