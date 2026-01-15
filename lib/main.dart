import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add provider
import 'package:year_dots/data/services/background_service.dart';
import 'package:year_dots/presentation/screens/dashboard_screen.dart'; // New screen
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart'; // Needed for provider

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
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: MaterialApp(
        title: 'YearDots',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF13C8EC), // Cyan
            brightness: Brightness.dark, 
          ),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
