import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Dashboard',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}