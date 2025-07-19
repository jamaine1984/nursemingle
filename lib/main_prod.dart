import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/app_state_provider.dart';
import 'utils/app_colors.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/gender_selection_screen.dart';
import 'screens/edit_profile_screen.dart';

import 'services/notification_service.dart';
import 'services/ad_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  double _fontScale = 1.0;
  
  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void setFontScale(double scale) {
    _fontScale = scale.clamp(0.8, 1.5);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize AdMob
  await AdService.initialize();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final isAuthenticated = prefs.getString('auth_token') != null;
    
    runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: NurseMingleApp(
        onboardingComplete: onboardingComplete,
        isAuthenticated: isAuthenticated,
      ),
    ));
  } catch (e) {
    runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NurseMingleApp(
        onboardingComplete: false,
        isAuthenticated: false,
      ),
    ));
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NurseMingleApp extends StatefulWidget {
  final bool onboardingComplete;
  final bool isAuthenticated;
  
  const NurseMingleApp({
    super.key,
    required this.onboardingComplete,
    required this.isAuthenticated,
  });
  
  @override
  State<NurseMingleApp> createState() => _NurseMingleAppState();
}

class _NurseMingleAppState extends State<NurseMingleApp>
    with WidgetsBindingObserver {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authProvider = AuthProvider();
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Check authentication status with timeout
      await _authProvider.checkAuthStatus().timeout(
        const Duration(seconds: 10),
                onTimeout: () {
            debugPrint('Auth initialization timed out');
            return false;
          },
      );
      
      // Initialize notifications with timeout
      try {
        final token = await NotificationService().getDeviceToken().timeout(
          const Duration(seconds: 5),
        );
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final notificationProvider = Provider.of<NotificationProvider>(
                  context,
                  listen: false,
                );
                if (token != null) {
                  notificationProvider.registerDeviceToken(token);
                }
              } catch (e) {
                debugPrint('Failed to register notification token: $e');
              }
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to get notification token: $e');
      }
    } catch (e) {
      debugPrint('Failed to initialize app: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _authProvider.resetDailyLimits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (context) {
            final notificationProvider = NotificationProvider();
            // Initialize notifications silently
            notificationProvider.initialize().catchError((e) {
              print('Notification initialization failed: $e');
            });
            return notificationProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Nurse Mingle',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildProductionTheme(),
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(
                child: Text('Sorry, that page does not exist.'),
              ),
            ),
          ),
          builder: (context, child) {
            _setupProductionErrorWidget();
            
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeProvider.fontScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: _determineInitialScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/main': (context) => const MainNavigationScreen(),
            '/verify_email': (context) => const VerifyEmailScreen(),
            '/profile-setup': (context) => const ProfileSetupScreen(),
            '/gender-selection': (context) => const GenderSelectionScreen(),
            '/edit_profile': (context) => const EditProfileScreen(),
          },
        ),
      ),
    );
  }

  Widget _determineInitialScreen() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return _buildSplashScreen();
        }
        
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return const MainNavigationScreen();
        }
        
        if (!widget.onboardingComplete) {
          return const LoginScreen(); // Or OnboardingScreen if you have one
        }
        
        return const LoginScreen();
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/nurse_mingle_logo_192x192.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Nurse Mingle',
              style: GoogleFonts.urbanist(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Connecting Healthcare Heroes',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _buildProductionTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: GoogleFonts.urbanist().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.urbanist(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.stethoscopeGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.urbanist(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _setupProductionErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Something went wrong'),
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Oops! Something went wrong',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We\'re working to fix this issue. Please try again later.',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app or go to main screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
} 
