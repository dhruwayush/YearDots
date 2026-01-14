import 'package:flutter/material.dart';
import 'package:year_dots/data/services/background_service.dart';
import 'package:year_dots/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initialize();
  // Register the task immediately for now (or maybe checking if already registered)
  // For a robust app, we might do this in the ViewModel or a specialized init logic
  // but for simplicity doing it here is fine.
  await BackgroundService.registerDailyTask(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YearDots',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7A00)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
