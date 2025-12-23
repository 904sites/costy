import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';

// --- MODEL INTERNAL UNTUK BARIS INPUT ---
class RecipeRow {
  Ingredient? master;
  TextEditingController qty = TextEditingController(text: "0");
  RecipeRow({this.master, String? initialQty}) {
    if (initialQty != null) qty.text = initialQty;
  }
}

class AddRecipeView extends StatefulWidget {
  final Recipe? existingRecipe;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const AddRecipeView({
    super.key,
    this.existingRecipe,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<AddRecipeView> createState() => _AddRecipeViewState();
}

class _AddRecipeViewState extends State<AddRecipeView> {
  final _nameController = TextEditingController();
  final _porsiController = TextEditingController(text: "1");
  final _marginController = TextEditingController(text: "50");

  final List<RecipeRow> _ingRows = [];
  final List<RecipeRow> _packRows = [];
  final List<RecipeRow> _otherRows = [];

  double _total = 0, _modalPorsi = 0, _jualIdeal = 0, _profit = 0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingRecipe != null) {
      _nameController.text = widget.existingRecipe!.name;
      _porsiController.text = widget.existingRecipe!.portion.toString();
      _marginController.text = widget.existingRecipe!.margin.toString();

      _loadSafeRows(widget.existingRecipe!.ingredients, _ingRows);
      _loadSafeRows(widget.existingRecipe!.packaging, _packRows);
      _loadSafeRows(widget.existingRecipe!.otherCosts, _otherRows);
    } else {
      _ingRows.add(RecipeRow());
    }
    _calculate();
  }

  void _loadSafeRows(List<Ingredient> src, List<RecipeRow> dest) {
    final masterList = DataService.masterBahan.value;
    for (var item in src) {
      Ingredient? matchedMaster;
      for (var m in masterList) {
        if (m.name.toLowerCase() == item.name.toLowerCase()) {
          matchedMaster = m;
          break;
        }
      }
      dest.add(
        RecipeRow(master: matchedMaster, initialQty: item.use.toString()),
      );
    }
  }

  void _calculate() {
    double totalAll = 0;
    for (var r in [..._ingRows, ..._packRows, ..._otherRows]) {
      if (r.master != null) {
        double q = double.tryParse(r.qty.text) ?? 0;
        totalAll += r.master!.unitPrice * q;
      }
    }

    double p = double.tryParse(_porsiController.text) ?? 1;
    double m = double.tryParse(_marginController.text) ?? 0;

    setState(() {
      _total = totalAll;
      _modalPorsi = totalAll / (p > 0 ? p : 1);
      _jualIdeal = (m < 100)
          ? (_modalPorsi / (1 - (m / 100)))
          : (_modalPorsi * 2);
      _profit = _jualIdeal - _modalPorsi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.matchaDark,
                  size: 20,
                ),
              ),
              Text(
                widget.existingRecipe != null ? "Edit Resep" : "Resep Baru",
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
                _buildWhiteCard(),
                const SizedBox(height: 25),
                _sectionTitle("Bahan Baku", _ingRows),
                _buildDynamicList(_ingRows),
                const SizedBox(height: 25),
                _sectionTitle("Biaya Kemasan", _packRows),
                _buildDynamicList(_packRows),
                const SizedBox(height: 25),
                _sectionTitle("Biaya Lain-lain", _otherRows),
                _buildDynamicList(_otherRows),
                const SizedBox(height: 30),
                _buildGreenEstimationCard(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET ---

  Widget _buildHeader() => Container(
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
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const Spacer(),
        buildProBadge(context),
      ],
    ),
  );

  Widget _buildWhiteCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Nama Produk / Resep"),
        _textField(_nameController, "Contoh: Brownies Matcha 20cm"),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Hasil Produksi (Porsi)"),
                  _textField(
                    _porsiController,
                    "1",
                    isNum: true,
                    onC: (_) => _calculate(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Target Margin (%)"),
                  _textField(
                    _marginController,
                    "50",
                    isNum: true,
                    onC: (_) => _calculate(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, List<RecipeRow> list) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.matchaDark,
        ),
      ),
      TextButton(
        onPressed: () => setState(() => list.add(RecipeRow())),
        child: const Text(
          "+ Tambah",
          style: TextStyle(
            color: AppColors.strawberryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  Widget _buildDynamicList(List<RecipeRow> rows) {
    return ValueListenableBuilder(
      valueListenable: DataService.masterBahan,
      builder: (context, List<Ingredient> master, _) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        itemBuilder: (ctx, i) => Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Ingredient>(
                  isExpanded: true,
                  value: master.contains(rows[i].master)
                      ? rows[i].master
                      : null,
                  hint: const Text("Pilih item..."),
                  items: master
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      rows[i].master = v;
                    });
                    _calculate();
                  },
                ),
              ),
              const Divider(color: Colors.black12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rows[i].qty,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "0",
                      ),
                    ),
                  ),
                  Text(
                    rows[i].master?.unit ?? "unit",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() => rows.removeAt(i));
                      _calculate();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.strawberryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreenEstimationCard() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.matchaDark,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              "Estimasi Harga",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white24, height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _priceBox("TOTAL MODAL", "Rp${_total.toStringAsFixed(0)}"),
            _priceBox("MODAL / PCS", "Rp${_modalPorsi.toStringAsFixed(0)}"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _priceBox("HARGA JUAL", "Rp${_jualIdeal.toStringAsFixed(0)}"),
            _priceBox("PROFIT / PCS", "Rp${_profit.toStringAsFixed(0)}"),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.matchaDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              "Simpan Resep & Harga",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _saveAction() {
    if (_nameController.text.isEmpty) return;

    List<Ingredient> getFinal(List<RecipeRow> rows) {
      return rows
          .where((r) => r.master != null)
          .map(
            (r) => Ingredient(
              id: r.master!.id,
              name: r.master!.name,
              buyPrice: r.master!.buyPrice,
              buyAmount: r.master!.buyAmount,
              cost: r.master!.unitPrice * (double.tryParse(r.qty.text) ?? 0),
              use: double.tryParse(r.qty.text) ?? 0,
              unit: r.master!.unit,
            ),
          )
          .toList();
    }

    DataService.saveRecipe(
      Recipe(
        id: widget.existingRecipe?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        date:
            widget.existingRecipe?.date ??
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
        totalModal: _total,
        modalPerPorsi: _modalPorsi,
        hargaJual: _jualIdeal,
        portion: int.parse(_porsiController.text),
        margin: int.parse(_marginController.text),
        ingredients: getFinal(_ingRows),
        packaging: getFinal(_packRows),
        otherCosts: getFinal(_otherRows),
      ),
    );
    widget.onSuccess();
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    ),
  );

  Widget _textField(
    TextEditingController c,
    String h, {
    bool isNum = false,
    Function(String)? onC,
  }) => TextField(
    controller: c,
    keyboardType: isNum ? TextInputType.number : TextInputType.text,
    onChanged: onC,
    decoration: InputDecoration(
      hintText: h,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
    ),
  );

  Widget _priceBox(String l, String v) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          v,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
