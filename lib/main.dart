import 'package:flutter/material.dart';
import 'package:finance_frontend/apptheme.dart';
import 'package:finance_frontend/screens/login_screen.dart';
import 'package:finance_frontend/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: Builder(
        builder: (context) => AnimatedSplashScreen(
          appName: 'Finance AI',
          tagline: 'EXPENSE INTELLIGENCE',
          onFinished: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
    );
  }
}
