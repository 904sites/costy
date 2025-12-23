import 'package:flutter/material.dart';
import 'style/app_theme.dart';
import 'screens/loading_screen.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.init();
  runApp(const CostyApp());
}

class CostyApp extends StatelessWidget {
  const CostyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const LoadingScreen(),
    );
  }
}
