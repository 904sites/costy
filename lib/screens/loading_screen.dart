import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _routing();
  }

  void _routing() async {
    await Future.delayed(const Duration(seconds: 3));
    if (DataService.userName.value.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const RegisterScreen()),
        );
      }
    } else if (!DataService.isLoggedIn.value) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const LoginScreen()),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.strawberryLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Costy",
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: AppColors.matchaDark),
          ],
        ),
      ),
    );
  }
}
