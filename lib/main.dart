import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
<<<<<<< HEAD
import 'data/repositories/mock_booking_repository.dart';
=======
import 'data/datasources/local/app_database.dart';
import 'data/repositories/firebase_user_repository.dart';
>>>>>>> origin/feature/booking/hoang
import 'data/repositories/mock_property_repository.dart';
import 'data/repositories/search_history_repository_impl.dart';
import 'data/repositories/wishlist_repository_impl.dart';
import 'domain/repositories/search_history_repository.dart';
import 'domain/repositories/wishlist_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/module_1_auth/forgot_password_screen.dart';
// Auth screens
import 'presentation/module_1_auth/login_screen.dart';
import 'presentation/module_1_auth/register_screen.dart';
import 'presentation/module_1_auth/reset_password_screen.dart';
// Explore screens
import 'presentation/module_2_explore/cubit/wishlist_cubit.dart';
import 'presentation/module_2_explore/home_screen.dart';
import 'presentation/module_2_explore/wishlist_screen.dart';
import 'presentation/module_3_map/bloc/map_bloc.dart';
// Map screens
import 'presentation/module_3_map/explore_map_intro_screen.dart';
import 'presentation/module_3_map/explore_map_screen.dart';
import 'presentation/module_4_booking/booking_confirm_screen.dart';
// Booking screens
import 'presentation/module_4_booking/property_detail_screen.dart';
// Interaction screens
import 'presentation/module_5_interaction/chat_screen.dart';
import 'presentation/module_5_interaction/host_dashboard_screen.dart';
import 'presentation/module_5_interaction/inbox_screen.dart';
import 'presentation/module_5_interaction/notification_center_screen.dart';
import 'presentation/module_5_interaction/profile_screen.dart';

<<<<<<< HEAD
import 'error_dumper.dart';
=======
late final AppDatabase _appDatabase;
>>>>>>> origin/feature/booking/hoang

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupErrorCatcher();
  await Firebase.initializeApp();
  // Khởi tạo AppDatabase singleton một lần duy nhất
  _appDatabase = AppDatabase();
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
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(userRepository: FirebaseUserRepository()),
      child: const VibeLocalsApp(),
    ),
  );
}

/// VibeLocals - Sang trọng & Bản sắc
/// Root application widget
class VibeLocalsApp extends StatelessWidget {
  const VibeLocalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WishlistRepository>(
          create: (_) => WishlistRepositoryImpl(
            db: _appDatabase,
            propertyRepository: MockPropertyRepository(),
          ),
        ),
        RepositoryProvider<SearchHistoryRepository>(
          create: (_) => SearchHistoryRepositoryImpl(_appDatabase),
        ),
      ],
      child: BlocProvider<WishlistCubit>(
        create: (context) =>
            WishlistCubit(context.read<WishlistRepository>()),
        child: MaterialApp(
          title: 'VibeLocals - Sang trọng & Bản sắc',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: '/login',
          routes: {
            // ===== AUTH FLOW =====
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/reset-password': (context) => const ResetPasswordScreen(),

<<<<<<< HEAD
        // ===== MAIN APP FLOW =====
        '/home': (context) => const HomeScreen(),
        '/explore-intro': (context) => const ExploreMapIntroScreen(),
        '/explore': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => MapBloc(
              propertyRepository: MockPropertyRepository(),
              bookingRepository: MockBookingRepository(),
            ),
            child: ExploreMapScreen(
              city: (args != null && args['city'] != null) ? args['city'] as String : null,
              dates: (args != null && args['dates'] != null) ? args['dates'] as DateTimeRange : null,
              lat: (args != null && args['lat'] != null) ? args['lat'] as double : null,
              lon: (args != null && args['lon'] != null) ? args['lon'] as double : null,
            ),
          );
        },
=======
            // ===== MAIN APP FLOW =====
            '/home': (context) => const HomeScreen(),
            '/wishlist': (context) => const WishlistScreen(),
            '/explore': (context) => BlocProvider(
                  create: (context) => MapBloc(
                    propertyRepository: MockPropertyRepository(),
                  ),
                  child: const ExploreMapScreen(),
                ),
>>>>>>> origin/feature/booking/hoang

            // ===== BOOKING FLOW =====
            '/property-detail': (context) => const PropertyDetailScreen(),
            '/booking': (context) => const BookingConfirmScreen(),

            // ===== INTERACTION FLOW =====
            '/chat': (context) => const ChatScreen(),
            '/notifications': (context) => const NotificationCenterScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
          onGenerateRoute: (settings) {
            // CHẶN ĐỨNG PHANTOM PUSH: Nếu là link quay lại từ PayOS, không cho đẩy Login đè lên
            if (settings.name != null &&
                settings.name!.contains('payment-success')) {
              return PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(context)) Navigator.of(context).pop();
                  });
                  return const SizedBox.shrink();
                },
              );
            }
            // Fallback for any undefined routes
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: settings,
            );
          },
        ),
      ),
    );
  }
}
