import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'package:parkisense_app/presentation/screens/auth/onboarding_screen.dart';
import 'package:parkisense_app/presentation/screens/auth/welcome_screen.dart';
import 'package:parkisense_app/presentation/screens/auth/login_screen.dart';
import 'package:parkisense_app/presentation/screens/auth/doctor_login_screen.dart';
import 'package:parkisense_app/presentation/screens/auth/signup_screen.dart';
import 'package:parkisense_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:parkisense_app/presentation/screens/dashboard/home_dashboard_screen.dart';
import 'package:parkisense_app/presentation/screens/screening/voice_screening_screen.dart';
import 'package:parkisense_app/presentation/screens/screening/processing_screen.dart';
import 'package:parkisense_app/presentation/screens/screening/results_screen.dart';
import 'package:parkisense_app/presentation/screens/profile/profile_settings_screen.dart';
import 'package:parkisense_app/presentation/screens/history/history_analytics_screen.dart';
import 'package:parkisense_app/presentation/screens/appointment/appointment_booking_screen.dart';
import 'package:parkisense_app/presentation/screens/main_navigation_screen.dart';
import 'package:parkisense_app/presentation/screens/doctor/doctor_dashboard_screen.dart';
import 'package:parkisense_app/presentation/screens/doctor/doctor_schedule_screen.dart';
import 'package:parkisense_app/presentation/screens/doctor/doctor_profile_screen.dart';
import 'package:parkisense_app/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCERryNG_2Ezzuv4xr9RUAveakPmjuYgKM",
      authDomain: "parkisense-web.firebaseapp.com",
      projectId: "parkisense-web",
      storageBucket: "parkisense-web.firebasestorage.app",
      messagingSenderId: "261350920704",
      appId: "1:261350920704:web:09c91760fd32c52b0ebee5",
      measurementId: "G-Z76FKEB6CF",
    ),
  );
  
  runApp(
    const ProviderScope(
      child: ParkiSenseApp(),
    ),
  );
}

class ParkiSenseApp extends ConsumerWidget {
  const ParkiSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ParkiSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/doctor-login': (context) => const DoctorLoginScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor-profile': (context) => const DoctorProfileScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/home': (context) => const HomeDashboardScreen(),
        '/voice-screening': (context) => const VoiceScreeningScreen(),
        '/processing': (context) => const ProcessingScreen(audioPath: ''),
        '/history': (context) => const HistoryAnalyticsScreen(),
        '/appointment': (context) => const AppointmentBookingScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
      },
      onGenerateRoute: (settings) {
        // Only handle special routes that require arguments
        if (settings.name == '/doctor-schedule') {
          final args = settings.arguments as Map<String, dynamic>?;
          final patientId = args?['patientId'] ?? '';
          return MaterialPageRoute(
            builder: (context) => DoctorScheduleScreen(patientId: patientId),
          );
        }
        return null; // Let the normal routes handle everything else
      },
    );
  }
}