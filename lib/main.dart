import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/change_password.dart';
import 'screens/forget_password.dart';
import 'screens/home_page.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/recent_scan.dart';
import 'screens/register.dart';
import 'screens/resultpage.dart';
import 'screens/scan.dart';
import 'screens/send_otp.dart';
import 'state/user_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', useMaterial3: true),
      home: const _StartupScreen(),
      routes: {
        'Login': (_) => const Login(),
        'Change_Password': (_) => const ChangePassword(),
        'OnBoardingScreen': (_) => const OnBoardingScreen(),
        'Register': (_) => const Register(),
        'Forget_Password': (_) => const ForgotPassword(),
        'Send_OTP': (_) => const SendOTP(),
        'ScanPage': (_) => const Scan(),
        'RecentScan': (_) => const RecentScan(),

        // ✅ HomePage بعد التعديل (بياخد parameters)
        'HomePage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;

          return HomePage(
            firstName: args?['firstName'] ?? '',
            fullName: args?['fullName'] ?? '',
            gender: args?['gender'] ?? userState.gender,
          );
        },

        // ✅ ResultPage بعد التعديل (بياخد accuracy الحقيقي)
        'ResultPage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
          as Map<String, dynamic>?;

          return ResultPage(
            imagePath: args?['imagePath'] ?? '',
            plantName: args?['plantName'] ?? '',
            status: args?['status'] ?? '',
            confidence: args?['confidence'] ?? '',
          );
        },
      },
    );
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await loadScans();
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen') ?? false;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacementNamed(context, 'OnBoardingScreen');
      return;
    }

    if (isLoggedIn) {
      await userState.loadPersistedData();
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        'HomePage',
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'gender': userState.gender,
        },
      );
      return;
    }

    Navigator.pushReplacementNamed(context, 'Login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}
