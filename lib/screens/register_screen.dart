import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _shop = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  void _handleRegister() async {
    if (_name.text.isNotEmpty &&
        _email.text.isNotEmpty &&
        _pass.text.isNotEmpty) {
      // MENGGUNAKAN registerUser (Sesuai DataService)
      await DataService.registerUser(
        _name.text,
        _shop.text,
        _email.text,
        _pass.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EDE4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Text(
              "Daftar Akun",
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            const Text("Mulai kelola bisnis kuliner Anda lebih profesional."),
            const SizedBox(height: 40),
            _f(_name, "Nama Lengkap Owner"),
            _f(_shop, "Nama Toko / Usaha"),
            _f(_email, "Alamat Email"),
            _f(_pass, "Kata Sandi", isPass: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.matchaDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Daftar Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                ),
                child: const Text(
                  "Sudah punya akun? Masuk di sini",
                  style: TextStyle(color: AppColors.matchaMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String l, {bool isPass = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TextField(
          controller: c,
          obscureText: isPass,
          decoration: InputDecoration(
            labelText: l,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
}
