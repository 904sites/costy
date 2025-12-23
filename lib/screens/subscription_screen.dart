import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.check_circle_outline, 'text': 'Simpan Resep Tanpa Batas'},
    {'icon': Icons.description_outlined, 'text': 'Export PDF'},
  ];

  void _handleUpgrade() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      DataService.activatePro(30);
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Berhasil! 🎉"),
        content: const Text(
          "Selamat! Anda sekarang adalah pengguna Costy PRO ✨",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.matchaDark,
            ),
            child: const Text("Mulai", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beigeBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: DataService.isPro,
        builder: (context, bool isPro, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isPro
                        ? Colors.amber[400]
                        : AppColors.strawberryMedium,
                    borderRadius: BorderRadius.circular(32),
                  ),

                  child: const Icon(
                    Icons.workspace_premium,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isPro ? "Status: Costy PRO" : "Dapatkan Costy PRO",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matchaDark,
                  ),
                ),
                const SizedBox(height: 35),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isPro
                              ? Colors.amber[400]!
                              : AppColors.strawberryLight,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? "LANGGANAN AKTIF" : "PAKET PEBISNIS SEJATI",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isPro
                                  ? Colors.amber[700]
                                  : AppColors.strawberryDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Rp19.900",
                                style: GoogleFonts.inter(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                " / bulan",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          ..._features.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Icon(
                                    f['icon'],
                                    size: 18,
                                    color: isPro
                                        ? Colors.amber
                                        : AppColors.matchaMedium,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(f['text']),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (!isPro)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleUpgrade,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.matchaDark,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    // FIXED: Pakai workspace_premium
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.workspace_premium,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Langganan Sekarang",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
