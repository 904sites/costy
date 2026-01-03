import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  final List<String> _units = [
    "gram",
    "kg",
    "ml",
    "liter",
    "pcs",
    "cm",
    "meter",
    "inch",
    "jam",
    "menit",
    "detik",
  ];

  void _dialog({Ingredient? item}) {
    final bool isPro = DataService.isPro.value;
    final bool isEdit = item != null;
    final n = TextEditingController(text: isEdit ? item.name : "");
    final p = TextEditingController(
      text: isEdit ? item.buyPrice.toStringAsFixed(0) : "0",
    );
    final a = TextEditingController(
      text: isEdit ? item.buyAmount.toStringAsFixed(0) : "0",
    );
    final s = TextEditingController(
      text: isEdit ? (item.currentStock?.toStringAsFixed(0) ?? "0") : "0",
    );
    final m = TextEditingController(
      text: isEdit ? (item.minStock?.toStringAsFixed(0) ?? "0") : "0",
    );
    String u = isEdit ? item.unit : "gram";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDE4),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? "Edit Item" : "Tambah Item Baru",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.matchaDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _dialogLabel("Nama Item"),
                  _dialogField(n, "Nama bahan/jasa/kemasan"),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel("Harga Beli"),
                            _dialogField(p, "0", isNum: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dialogLabel("Isi/Berat"),
                            _dialogField(a, "0", isNum: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isPro) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "INVENTARIS PRO",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("Stok Awal"),
                                    _dialogField(s, "0", isNum: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dialogLabel("Stok Min."),
                                    _dialogField(m, "0", isNum: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  _dialogLabel("Satuan"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: u,
                        isExpanded: true,
                        items: _units
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setS(() => u = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Batal"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (n.text.isNotEmpty) {
                              final newB = Ingredient(
                                id: isEdit
                                    ? item.id
                                    : DateTime.now().toString(),
                                name: n.text,
                                buyPrice: double.parse(p.text),
                                buyAmount: double.parse(a.text),
                                cost: 0,
                                use: 0,
                                unit: u,
                                currentStock: isPro
                                    ? double.tryParse(s.text)
                                    : null,
                                minStock: isPro
                                    ? double.tryParse(m.text)
                                    : null,
                              );
                              if (isEdit) {
                                DataService.updateBahan(newB);
                              } else {
                                DataService.saveBahan(newB);
                              }
                              Navigator.pop(ctx);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.matchaDark,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Simpan"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daftar Bahan",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.matchaDark,
                ),
              ),
              GestureDetector(
                onTap: () => _dialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.matchaDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari bahan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: DataService.masterBahan,
            builder: (context, List<Ingredient> list, _) {
              final filtered = list
                  .where((b) => b.name.toLowerCase().contains(_query))
                  .toList();
              if (filtered.isEmpty) {
                return const Center(child: Text("Tidak ada bahan."));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 100,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final item = filtered[i];
                  final bool isPro = DataService.isPro.value;
                  final bool isLow =
                      isPro &&
                      item.currentStock != null &&
                      item.minStock != null &&
                      item.currentStock! <= item.minStock!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isLow ? Colors.red.shade200 : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.matchaDark,
                                    ),
                                  ),
                                  Text(
                                    "Harga: Rp${item.buyPrice.toStringAsFixed(0)} / ${item.buyAmount.toStringAsFixed(0)} ${item.unit}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "RP${item.unitPrice.toStringAsFixed(2)} / ${item.unit.toUpperCase()}",
                                    style: const TextStyle(
                                      color: AppColors.strawberryDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _dialog(item: item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.strawberryDark,
                              ),
                              onPressed: () => DataService.deleteBahan(item.id),
                            ),
                          ],
                        ),
                        if (isPro && item.currentStock != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "STOK: ${item.currentStock!.toStringAsFixed(0)} ${item.unit}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLow
                                      ? Colors.red
                                      : AppColors.matchaDark,
                                ),
                              ),
                              Row(
                                children: [
                                  _stockBtn(
                                    "-",
                                    () => DataService.updateStock(item.id, -10),
                                  ),
                                  const SizedBox(width: 8),
                                  _stockBtn(
                                    "+",
                                    () => DataService.updateStock(item.id, 10),
                                    isAdd: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              style: GoogleFonts.poppins(
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
  Widget _stockBtn(String t, VoidCallback onT, {bool isAdd = false}) =>
      GestureDetector(
        onTap: onT,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isAdd ? AppColors.matchaDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isAdd
                ? null
                : Border.all(color: AppColors.strawberryMedium),
          ),
          child: Center(
            child: Text(
              t,
              style: TextStyle(
                color: isAdd ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
  Widget _dialogLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 2),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    ),
  );
  Widget _dialogField(
    TextEditingController c,
    String h, {
    bool isNum = false,
  }) => TextField(
    controller: c,
    keyboardType: isNum ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: h,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    ),
  );
}
