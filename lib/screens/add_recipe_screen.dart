import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';

class RecipeRow {
  Ingredient? master;
  TextEditingController qty = TextEditingController(text: "0");
  RecipeRow({this.master, String? initialQty}) {
    if (initialQty != null) qty.text = initialQty;
  }
}

class AddRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe;
  final VoidCallback onBack, onSuccess;
  const AddRecipeScreen({
    super.key,
    this.existingRecipe,
    required this.onBack,
    required this.onSuccess,
  });
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _name = TextEditingController(),
      _porsi = TextEditingController(text: "1"),
      _margin = TextEditingController(text: "50");
  List<RecipeRow> _ingRows = [], _packRows = [], _otherRows = [];
  double _total = 0, _modalPorsi = 0, _jualIdeal = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      _name.text = widget.existingRecipe!.name;
      _porsi.text = widget.existingRecipe!.portion.toString();
      _margin.text = widget.existingRecipe!.margin.toString();
      _loadRows(widget.existingRecipe!.ingredients, _ingRows);
      _loadRows(widget.existingRecipe!.packaging, _packRows);
      _loadRows(widget.existingRecipe!.otherCosts, _otherRows);
    } else {
      _ingRows.add(RecipeRow());
    }
    _calc();
  }

  void _loadRows(List<Ingredient> src, List<RecipeRow> dest) {
    for (var i in src) {
      final m = DataService.masterBahan.value.firstWhere(
        (b) => b.name == i.name,
        orElse: () => i,
      );
      dest.add(RecipeRow(master: m, initialQty: i.use.toString()));
    }
  }

  void _calc() {
    double tI = 0, tP = 0, tO = 0;
    for (var r in _ingRows) {
      if (r.master != null) {
        tI += r.master!.unitPrice * (double.tryParse(r.qty.text) ?? 0);
      }
    }
    for (var r in _packRows) {
      if (r.master != null) {
        tP += r.master!.unitPrice * (double.tryParse(r.qty.text) ?? 0);
      }
    }
    for (var r in _otherRows) {
      if (r.master != null) {
        tO += r.master!.unitPrice * (double.tryParse(r.qty.text) ?? 0);
      }
    }
    double totalAll = tI + tP + tO;
    double p = double.tryParse(_porsi.text) ?? 1;
    double m = double.tryParse(_margin.text) ?? 0;
    setState(() {
      _total = totalAll;
      _modalPorsi = totalAll / (p > 0 ? p : 1);
      _jualIdeal = _modalPorsi / (1 - (m / 100));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.matchaDark,
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
                _inputCard(),
                const SizedBox(height: 25),
                _section(
                  "Bahan Baku",
                  _ingRows,
                  () => setState(() => _ingRows.add(RecipeRow())),
                ),
                const SizedBox(height: 25),
                _section(
                  "Biaya Kemasan",
                  _packRows,
                  () => setState(() => _packRows.add(RecipeRow())),
                ),
                const SizedBox(height: 25),
                _section(
                  "Biaya Lain-lain",
                  _otherRows,
                  () => setState(() => _otherRows.add(RecipeRow())),
                ),
                const SizedBox(height: 30),
                _estimasiCard(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() => Container(
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

  Widget _inputCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nama Produk",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        TextField(controller: _name),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Porsi", style: TextStyle(fontSize: 11)),
                  TextField(
                    controller: _porsi,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calc(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Margin %", style: TextStyle(fontSize: 11)),
                  TextField(
                    controller: _margin,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calc(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _section(String t, List<RecipeRow> list, VoidCallback onA) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.matchaDark,
            ),
          ),
          TextButton(
            onPressed: onA,
            child: const Text(
              "+ Tambah",
              style: TextStyle(
                color: AppColors.strawberryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      ValueListenableBuilder(
        valueListenable: DataService.masterBahan,
        builder: (c, List<Ingredient> m, _) => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (c, i) => Container(
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
                    value: list[i].master,
                    hint: const Text("Pilih item..."),
                    items: m
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        list[i].master = v;
                      });
                      _calc();
                    },
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: list[i].qty,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calc(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                    Text(list[i].master?.unit ?? ""),
                    IconButton(
                      onPressed: () {
                        setState(() => list.removeAt(i));
                        _calc();
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
      ),
    ],
  );

  Widget _estimasiCard() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.matchaDark,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calculate, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              "Estimasi Harga",
              style: TextStyle(
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
            _pBox("TOTAL MODAL", "Rp${_total.toStringAsFixed(0)}"),
            _pBox("MODAL / PORSI", "Rp${_modalPorsi.toStringAsFixed(0)}"),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pBox("HARGA JUAL IDEAL", "Rp${_jualIdeal.toStringAsFixed(0)}"),
            _pBox(
              "PROFIT / PORSI",
              "Rp${(_jualIdeal - _modalPorsi).toStringAsFixed(0)}",
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
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

  void _save() {
    if (_name.text.isEmpty) return;
    List<Ingredient> map(List<RecipeRow> r) => r
        .where((x) => x.master != null)
        .map(
          (x) => Ingredient(
            id: x.master!.id,
            name: x.master!.name,
            buyPrice: x.master!.buyPrice,
            buyAmount: x.master!.buyAmount,
            cost: x.master!.unitPrice * (double.tryParse(x.qty.text) ?? 0),
            use: double.tryParse(x.qty.text) ?? 0,
            unit: x.master!.unit,
          ),
        )
        .toList();
    DataService.saveRecipe(
      Recipe(
        id: widget.existingRecipe?.id ?? DateTime.now().toString(),
        name: _name.text,
        date:
            widget.existingRecipe?.date ??
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
        totalModal: _total,
        modalPerPorsi: _modalPorsi,
        hargaJual: _jualIdeal,
        portion: int.parse(_porsi.text),
        margin: int.parse(_margin.text),
        ingredients: map(_ingRows),
        packaging: map(_packRows),
        otherCosts: map(_otherRows),
      ),
    );
    widget.onSuccess();
  }

  Widget _pBox(String l, String v) => Column(
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
  );
}
