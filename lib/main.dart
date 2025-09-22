import 'package:flutter/material.dart';
import 'package:sih2025/landing%20page.dart';

void main() {
  runApp(const GenEchoApp());
}

class GenEchoApp extends StatelessWidget {
  const GenEchoApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gen Echo',
      home: const landing_page(),
    );
  }
}
