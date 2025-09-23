import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sih2025/landing%20page.dart'; // Import dotenv
import 'package:sih2025/homescreen.dart'; // Ensure your HomeScreen is imported

Future<void> main() async {
  // Ensures that Flutter's binding (its connection to the native platform)
  // is initialized before any async operations like loading dotenv.
  WidgetsFlutterBinding.ensureInitialized();

  // This is the core line for flutter_dotenv: it loads the variables
  // from your .env file into memory so they can be accessed later.
  await dotenv.load(fileName: ".env");

  // Once dotenv is loaded, you can safely run your app.
  runApp(const MyApp()); // Your main app widget
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eco Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Make sure this points to your actual home screen
      home: const landing_page(),
    );
  }
}