import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().init();
  runApp(const MedicineLocatorApp());
}

class MedicineLocatorApp extends StatelessWidget {
  const MedicineLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRITEC Medicine Locator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
