import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/SplashScreen/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/subscription_plans_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const NurseMingleApp());
}

class NurseMingleApp extends StatelessWidget {
  const NurseMingleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Nurse Mingle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.urbanistTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/profile-setup': (context) => const ProfileSetupScreen(),
          '/main': (context) => const MainNavigationScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/subscription-plans': (context) => const SubscriptionPlansScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
              ),
              body: const Center(
                child: Text('The requested page was not found.'),
              ),
            ),
          );
        },
      ),
    );
  }
}
