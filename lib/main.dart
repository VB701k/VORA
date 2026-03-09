import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vora/backend/services/notification_service.dart';
import 'package:vora/frontend/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Notification system
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // App theme
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC77DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // First screen when app starts
      home: const LoginPage(),
    );
  }
}
