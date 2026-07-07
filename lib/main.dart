import 'package:flutter/material.dart';
import 'package:gitstreak_app/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Streak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3:true),
      home: const LoginPage(),
    );
  }
}
