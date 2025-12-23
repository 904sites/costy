import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});
  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  int _flowIndex = 0;
  String _selectedMethod = "", _currentPaymentCode = "";
  int _activeSubTab = 0;

  final List<Map<String, dynamic>> _proFeatures = [
    {'icon': Icons.check_circle_outline, 'text': 'Simpan Resep Tanpa Batas'},
    {'icon': Icons.picture_as_pdf_outlined, 'text': 'Cetak Laporan PDF'},
  ];

  void _generateCode(String m) {
    String p = m.contains("GoPay")
        ? "700"
        : m.contains("DANA")
        ? "805"
        : "88";
    _currentPaymentCode =
        p + DateTime.now().millisecondsSinceEpoch.toString().substring(5);
  }

  void _nextFlow(int i, {String m = ""}) {
    setState(() {
      _flowIndex = i;
      if (m != "") {
        _selectedMethod = m;
        _generateCode(m);
      }
      _activeSubTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DataService.isPro,
      builder: (c, bool isPro, _) => Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: isPro ? _buildActiveState() : _offerFlow(),
            ),
          ),
        ],
      ),
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
            Row(
              children: [
                Text(
                  "Costy",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matchaDark,
                  ),
                ),
              ],
            ),
            Text(
              "SMART RECIPE PRICING",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.strawberryDark,
              ),
            ),
          ],
        ),
        const Spacer(),
        buildProBadge(ctx),
      ],
    ),
  );

  Widget _offerFlow() {
    if (_flowIndex == 1) return _viewStepMethods();
    if (_flowIndex == 2) return _viewStepPayment();
    return _viewStepOffer();
  }

  Widget _viewStepOffer() => Column(
    children: [
      Text(
        "Dapatkan Akses PRO",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.matchaDark,
        ),
      ),
      const SizedBox(height: 35),
      Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PAKET PREMIUM",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                Text(
                  "Rp19.900",
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.matchaDark,
                  ),
                ),
                const Text(" / bulan"),
              ],
            ),
            const SizedBox(height: 25),
            ..._proFeatures.map((f) => _featItem(f['icon'], f['text'], false)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _nextFlow(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.matchaDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Upgrade Sekarang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _viewStepMethods() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextButton.icon(
        onPressed: () => _nextFlow(0),
        icon: const Icon(Icons.arrow_back),
        label: const Text("KEMBALI"),
      ),
      Text(
        "Pilih Metode Pembayaran",
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.matchaDark,
        ),
      ),
      const SizedBox(height: 25),
      _mCard("QRIS (All E-Wallets)", Icons.qr_code_scanner, Colors.purple),
      _mCard("GoPay", Icons.account_balance_wallet, Colors.blue),
      _mCard("DANA", Icons.account_balance_wallet, Colors.lightBlue),
    ],
  );

  Widget _viewStepPayment() => Column(
    children: [
      TextButton.icon(
        onPressed: () => _nextFlow(1),
        icon: const Icon(Icons.arrow_back),
        label: const Text("GANTI METODE"),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Selesaikan Pembayaran",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            Text(
              _selectedMethod,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _tabBtn("Tampilkan QR", 0),
                  _tabBtn("Kode Bayar", 1),
                ],
              ),
            ),
            const SizedBox(height: 35),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _activeSubTab == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.network(
                  "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$_currentPaymentCode",
                  width: 180,
                ),
              ),
              secondChild: Column(
                children: [
                  Text(
                    _currentPaymentCode,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.matchaDark,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: _currentPaymentCode),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kode disalin!")),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text("Salin Kode"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                DataService.activatePro(30);
                setState(() => _flowIndex = 0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.matchaLight.withOpacity(0.3),
              ),
              child: const Text(
                "Simulasi Berhasil",
                style: TextStyle(color: AppColors.matchaDark),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildActiveState() => Column(
    children: [
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.amber, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KEANGGOTAAN AKTIF",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              "Rp19.900 / bulan",
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.matchaDark,
              ),
            ),
            const SizedBox(height: 30),
            ..._proFeatures.map((f) => _featItem(f['icon'], f['text'], true)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => DataService.isPro.value = false,
                child: const Text(
                  "Batal Berlangganan",
                  style: TextStyle(
                    color: AppColors.strawberryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _featItem(IconData i, String t, bool act) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(
          act ? Icons.check_circle : i,
          size: 18,
          color: act ? Colors.amber : Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(
          t,
          style: TextStyle(
            fontSize: 13,
            color: act ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    ),
  );
  Widget _mCard(String n, IconData i, Color c) => GestureDetector(
    onTap: () => _nextFlow(2, m: n),
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(i, color: c),
          const SizedBox(width: 15),
          Text(n, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
  Widget _tabBtn(String t, int idx) {
    bool act = _activeSubTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSubTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: act ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              t,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: act ? AppColors.matchaDark : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
