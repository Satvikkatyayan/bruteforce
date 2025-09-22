import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sih2025/landing%20page.dart';
import 'package:sih2025/loginpage.dart';
// Import your firebase options file if you have one
// import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    // If you have firebase_options.dart, use this:
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco App',
      theme: ThemeData(

        primaryColor: const Color(0xFF4A7C59),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A7C59)),
        useMaterial3: true,
      ),
      home: const landing_page(),
    );
  }
}
