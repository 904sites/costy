import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'data_service.dart';

class PdfService {
  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static Future<void> generateRecipePdf(Recipe recipe) async {
    final pdf = pw.Document();

    // Warna Tema Costy
    final matchaDark = PdfColor.fromHex("#4A6644");
    final strawberryDark = PdfColor.fromHex("#C66F80");
    final beigeLight = PdfColor.fromHex("#F1EDE4");

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // --- HEADER ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Costy",
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: matchaDark,
                    ),
                  ),
                  pw.Text(
                    "Smart Recipe Pricing Report",
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: strawberryDark,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Tanggal Laporan",
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.Text(
                    recipe.date,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 2, color: matchaDark),
          pw.SizedBox(height: 20),

          // --- INFORMASI RESEP ---
          pw.Text(
            "NAMA PRODUK",
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
          pw.Text(
            recipe.name.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: matchaDark,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _infoChip("Target Produksi: ${recipe.portion} Porsi", matchaDark),
              pw.SizedBox(width: 10),
              _infoChip("Target Margin: ${recipe.margin}%", strawberryDark),
            ],
          ),
          pw.SizedBox(height: 30),

          // --- TABEL 1: BAHAN BAKU ---
          _sectionTitle("I. RINCIAN BAHAN BAKU"),
          _buildIngredientTable(recipe.ingredients, matchaDark),
          pw.SizedBox(height: 25),

          // --- TABEL 2: BIAYA KEMASAN ---
          if (recipe.packaging.isNotEmpty) ...[
            _sectionTitle("II. RINCIAN BIAYA KEMASAN"),
            _buildIngredientTable(recipe.packaging, matchaDark),
            pw.SizedBox(height: 25),
          ],

          // --- TABEL 3: BIAYA OPERASIONAL (LAIN-LAIN) ---
          if (recipe.otherCosts.isNotEmpty) ...[
            _sectionTitle("III. RINCIAN BIAYA OPERASIONAL"),
            _buildIngredientTable(recipe.otherCosts, matchaDark),
            pw.SizedBox(height: 30),
          ],

          // --- SUMMARY BOX (KESIMPULAN) ---
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: beigeLight,
              borderRadius: pw.BorderRadius.circular(15),
              border: pw.Border.all(color: matchaDark, width: 1),
            ),
            child: pw.Column(
              children: [
                _summaryRow(
                  "TOTAL MODAL KESELURUHAN",
                  currency.format(recipe.totalModal),
                  isBold: true,
                ),
                _summaryRow(
                  "MODAL PER PORSI",
                  currency.format(recipe.modalPerPorsi),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 5),
                _summaryRow(
                  "REKOMENDASI HARGA JUAL",
                  currency.format(recipe.hargaJual),
                  isBold: true,
                  fontSize: 16,
                  color: strawberryDark,
                ),
                _summaryRow(
                  "ESTIMASI PROFIT PER PORSI",
                  currency.format(recipe.hargaJual - recipe.modalPerPorsi),
                  color: matchaDark,
                ),
              ],
            ),
          ),

          // --- FOOTER ---
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey200),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Catatan: Gunakan takaran presisi untuk hasil maksimal.",
                style: const pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                "Dibuat otomatis oleh Costy App",
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: matchaDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Membuka Jendela Preview Cetak
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Laporan_Costy_${recipe.name}",
    );
  }

  // --- HELPER: CHIP INFORMASI ---
  static pw.Widget _infoChip(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // --- HELPER: JUDUL BAGIAN ---
  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  // --- HELPER: GENERATE TABEL ---
  static pw.Widget _buildIngredientTable(
    List<Ingredient> items,
    PdfColor headerColor,
  ) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      headers: ['Item', 'Qty', 'Satuan', 'Biaya (Rp)'],
      data: items
          .map(
            (i) => [
              i.name,
              i.use.toString(),
              i.unit,
              currency.format(i.cost).replaceAll("Rp", ""),
            ],
          )
          .toList(),
    );
  }

  // --- HELPER: BARIS RINGKASAN ---
  static pw.Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize - 2,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
