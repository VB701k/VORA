import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vora/backend/services/notification_service.dart';
import 'package:vora/frontend/pages/login_page.dart';

// ✅ Add this import ONLY if you created the QuotesService file I gave you
import 'package:vora/backend/services/quotes_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Seed quotes (safe: only adds if quotes collection is empty)
  // If you don't have quotes_service.dart yet, comment this line.
  await QuotesService.instance.seedQuotesIfEmpty();

  // ✅ Initialize Notification system
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC77DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const LoginPage(),
    );
  }
}
