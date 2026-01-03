import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import '../services/pdf_service.dart';
import 'home_screen.dart';

class RecipeDetailView extends StatelessWidget {
  final Recipe recipe;
  final Function(Recipe) onEdit;
  final VoidCallback onDelete;

  const RecipeDetailView({
    super.key,
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1EDE4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.matchaDark,
                      size: 20,
                    ),
                  ),
                  Text(
                    "Detail Resep",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.matchaDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CARD RINGKASAN PRODUK ---
                    _buildMainInfoCard(currency),
                    const SizedBox(height: 25),

                    // --- DETAIL BAHAN ---
                    _buildSectionTitle("I. Bahan Baku"),
                    _buildItemTable(recipe.ingredients, currency),
                    const SizedBox(height: 20),

                    // --- DETAIL KEMASAN ---
                    if (recipe.packaging.isNotEmpty) ...[
                      _buildSectionTitle("II. Biaya Kemasan"),
                      _buildItemTable(recipe.packaging, currency),
                      const SizedBox(height: 20),
                    ],

                    // --- DETAIL LAIN-LAIN ---
                    if (recipe.otherCosts.isNotEmpty) ...[
                      _buildSectionTitle("III. Biaya Operasional"),
                      _buildItemTable(recipe.otherCosts, currency),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 30),

                    // --- TOMBOL AKSI UTAMA ---
                    _buildActionButtons(context),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
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
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.strawberryDark,
              ),
            ),
          ],
        ),
        const Spacer(),
        buildProBadge(context),
      ],
    ),
  );

  Widget _buildMainInfoCard(NumberFormat currency) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.matchaDark,
          ),
        ),
        Text(
          "Dibuat pada: ${recipe.date}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pCol("PORSI", "${recipe.portion}"),
            _pCol("MARGIN", "${recipe.margin}%"),
            _pCol("MODAL/PCS", currency.format(recipe.modalPerPorsi)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.matchaDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "HARGA JUAL",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                currency.format(recipe.hargaJual),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 10),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.1,
      ),
    ),
  );

  Widget _buildItemTable(List<Ingredient> items, NumberFormat currency) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: items
              .map(
                (item) => ListTile(
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text("${item.use} ${item.unit}"),
                  trailing: Text(
                    currency.format(item.cost),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.matchaDark,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );

  Widget _buildActionButtons(BuildContext context) => Column(
    children: [
      // TOMBOL CETAK PDF
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (DataService.isPro.value) {
              PdfService.generateRecipePdf(recipe);
            } else {
              _showProLocked(context);
            }
          },
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text("Cetak Laporan PDF"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.matchaDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onEdit(recipe);
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text("Edit Data"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: AppColors.matchaDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                foregroundColor: AppColors.matchaDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text("Hapus"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strawberryMedium,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Resep?"),
        content: const Text("Data ini akan hilang permanen dari koleksi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              onDelete();
            },
            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProLocked(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Fitur PRO Terkunci 🔒"),
        content: const Text(
          "Tingkatkan ke PRO untuk cetak laporan PDF profesional.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Nanti"),
          ),
        ],
      ),
    );
  }

  Widget _pCol(String l, String v) => Column(
    children: [
      Text(
        l,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        v,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
