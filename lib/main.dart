import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';

// APP ENTRY POINT
void main() async {
  // FLUTTER BINDING: Ensures binding for native calls (required for Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // NETWORK & DATABASE INITIALIZATION: Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // STATE MANAGEMENT INITIALIZATION: ProviderScope enables Riverpod for the entire app
  runApp(const ProviderScope(child: RestaurantApp()));
}

class RestaurantApp extends ConsumerWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ROUTING: Retrieve the GoRouter configuration from provider
    final router = ref.watch(routerProvider);

    // CORE: Main App Widget using MaterialApp.router for defined navigation schema
    return MaterialApp.router(
      title: 'Luxe Dining',
      theme: AppTheme.darkTheme, // UI: Custom Theme
      routerConfig: router, // ROUTING: Connect GoRouter
      debugShowCheckedModeBanner: false,
    );
  }
}
