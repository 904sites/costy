import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _avatar(),
                const SizedBox(height: 30),
                _stats(),
                const SizedBox(height: 30),
                _sectionTitle("Sistem"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () async {
                            await DataService.logout();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const LoadingScreen(),
                                ),
                              );
                            }
                          },
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.orange,
                          ),
                          title: const Text(
                            "Keluar Akun",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          onTap: () {
                            DataService.allRecipes.value = [];
                            DataService.masterBahan.value = [];
                          },
                          leading: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          title: const Text(
                            "Reset Seluruh Data",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext ctx) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Color(0xFFFCEBF1),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Costy",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            const Text(
              "SMART RECIPE PRICING",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Spacer(),
        buildProBadge(ctx),
      ],
    ),
  );
  Widget _avatar() => ValueListenableBuilder(
    valueListenable: DataService.userName,
    builder: (c, String n, _) => Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.matchaDark,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Text(
          n.isEmpty ? "Owner Costy" : n,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.matchaDark,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: DataService.shopName,
          builder: (c, String s, _) => Text(
            s.isEmpty ? "Pengusaha Kuliner" : s,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
  Widget _stats() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.strawberryLight),
      ),
      child: Row(
        children: [
          _sItem(
            "Resep",
            DataService.allRecipes.value.length.toString(),
            Icons.pie_chart,
            AppColors.matchaDark,
            true,
          ),
          _sItem(
            "Bahan",
            DataService.masterBahan.value.length.toString(),
            Icons.shopping_bag,
            AppColors.strawberryDark,
            false,
          ),
        ],
      ),
    ),
  );
  Widget _sItem(String l, String v, IconData i, Color c, bool b) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: b
            ? const Border(right: BorderSide(color: Color(0xFFF1EDE4)))
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(i, size: 14, color: c),
              const SizedBox(width: 5),
              Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            v,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(left: 30, bottom: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
}
