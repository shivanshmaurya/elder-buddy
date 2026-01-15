import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/contacts/screens/home_screen.dart';

class EasyCallApp extends StatelessWidget {
  const EasyCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elder Buddy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
