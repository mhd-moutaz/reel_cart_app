
import 'package:flutter/material.dart';
import 'package:reel_cart/screens/login_screen.dart';

void main() {
  runApp(const ReelCartApp());
}

class ReelCartApp extends StatelessWidget {
  const ReelCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelCart - Electronics Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

