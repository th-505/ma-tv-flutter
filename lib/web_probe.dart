import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebIsolationApp());
}

class WebIsolationApp extends StatelessWidget {
  const WebIsolationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF0A0A0B),
        body: Center(
          child: Text(
            'MA-TV WEB ENGINE OK',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
