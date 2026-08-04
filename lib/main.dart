import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:gitstreak_app/models/habit_model.dart';

import 'package:gitstreak_app/main_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(HabitModelAdapter());
}
  await Hive.openBox<HabitModel>('habits');
  await Hive.openBox('settings');


  runApp(const MyApp());
}



class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Git Streak',

      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark(
        useMaterial3: true,
      ),

      home: const MainScreen(),

    );
  }
}