import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'presentation/module_1_auth/forgot_password_screen.dart';
// Auth screens
import 'presentation/module_1_auth/login_screen.dart';
import 'presentation/module_1_auth/register_screen.dart';
import 'presentation/module_1_auth/reset_password_screen.dart';
// Explore screens
import 'presentation/module_2_explore/home_screen.dart';
// Map screens
import 'presentation/module_3_map/explore_map_screen.dart';
import 'presentation/module_4_booking/booking_confirm_screen.dart';
// Booking screens
import 'presentation/module_4_booking/property_detail_screen.dart';
// Interaction screens
import 'presentation/module_5_interaction/chat_screen.dart';
import 'presentation/module_5_interaction/notification_center_screen.dart';
import 'presentation/module_5_interaction/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enforce portrait orientation for mobile-first design
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Status bar style - light icons on dark header
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const VibeLocalsApp());
}

/// VibeLocals - Sang trọng & Bản sắc
/// Root application widget
class VibeLocalsApp extends StatelessWidget {
  const VibeLocalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeLocals - Sang trọng & Bản sắc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Initial route - start from login
      initialRoute: '/login',
      routes: {
        // ===== AUTH FLOW =====
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),

        // ===== MAIN APP FLOW =====
        '/home': (context) => const HomeScreen(),
        '/explore': (context) => const ExploreMapScreen(),

        // ===== BOOKING FLOW =====
        '/property-detail': (context) => const PropertyDetailScreen(),
        '/booking': (context) => const BookingConfirmScreen(),

        // ===== INTERACTION FLOW =====
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationCenterScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      // Page transition builder for smooth navigation
      onGenerateRoute: (settings) {
        // Fallback for any undefined routes
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      },
    );
  }
}
