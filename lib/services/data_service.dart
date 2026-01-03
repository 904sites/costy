import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- MODEL BAHAN ---
class Ingredient {
  final String id, name, unit;
  final double buyPrice, buyAmount, cost, use;
  double? currentStock, minStock;
  Ingredient({
    required this.id,
    required this.name,
    required this.buyPrice,
    required this.buyAmount,
    required this.cost,
    required this.use,
    required this.unit,
    this.currentStock,
    this.minStock,
  });
  double get unitPrice => buyPrice / (buyAmount > 0 ? buyAmount : 1);
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'buyPrice': buyPrice,
    'buyAmount': buyAmount,
    'cost': cost,
    'use': use,
    'unit': unit,
    'currentStock': currentStock,
    'minStock': minStock,
  };
  factory Ingredient.fromMap(Map<String, dynamic> m) => Ingredient(
    id: m['id'],
    name: m['name'],
    buyPrice: m['buyPrice'].toDouble(),
    buyAmount: m['buyAmount'].toDouble(),
    cost: m['cost']?.toDouble() ?? 0,
    use: m['use']?.toDouble() ?? 0,
    unit: m['unit'],
    currentStock: m['currentStock']?.toDouble(),
    minStock: m['minStock']?.toDouble(),
  );
}

// --- MODEL RESEP ---
class Recipe {
  final String id, name, date;
  final double totalModal, modalPerPorsi, hargaJual;
  final int portion, margin;
  final List<Ingredient> ingredients, packaging, otherCosts;
  Recipe({
    required this.id,
    required this.name,
    required this.date,
    required this.totalModal,
    required this.modalPerPorsi,
    required this.hargaJual,
    required this.portion,
    required this.margin,
    required this.ingredients,
    required this.packaging,
    required this.otherCosts,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'date': date,
    'totalModal': totalModal,
    'modalPerPorsi': modalPerPorsi,
    'hargaJual': hargaJual,
    'portion': portion,
    'margin': margin,
    'ingredients': ingredients.map((x) => x.toMap()).toList(),
    'packaging': packaging.map((x) => x.toMap()).toList(),
    'otherCosts': otherCosts.map((x) => x.toMap()).toList(),
  };
  factory Recipe.fromMap(Map<String, dynamic> m) => Recipe(
    id: m['id'],
    name: m['name'],
    date: m['date'],
    totalModal: m['totalModal'].toDouble(),
    modalPerPorsi: m['modalPerPorsi'].toDouble(),
    hargaJual: m['hargaJual'].toDouble(),
    portion: m['portion'],
    margin: m['margin'],
    ingredients: List<Ingredient>.from(
      m['ingredients']?.map((x) => Ingredient.fromMap(x)) ?? [],
    ),
    packaging: List<Ingredient>.from(
      m['packaging']?.map((x) => Ingredient.fromMap(x)) ?? [],
    ),
    otherCosts: List<Ingredient>.from(
      m['otherCosts']?.map((x) => Ingredient.fromMap(x)) ?? [],
    ),
  );
}

// --- SERVICE DATA (MULTI-USER SUPPORT) ---
class DataService {
  static const int freeLimit = 3;

  static ValueNotifier<List<Recipe>> allRecipes = ValueNotifier([]);
  static ValueNotifier<List<Ingredient>> masterBahan = ValueNotifier([]);
  static ValueNotifier<bool> isPro = ValueNotifier(false);
  static ValueNotifier<String> userName = ValueNotifier("");
  static ValueNotifier<String> shopName = ValueNotifier("");
  static ValueNotifier<String> userEmail = ValueNotifier("");
  static ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  // --- 1. INISIALISASI SESSION ---
  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    isLoggedIn.value = p.getBool('is_logged_in') ?? false;
    if (isLoggedIn.value) {
      String email = p.getString('current_session_email') ?? "";
      if (email.isNotEmpty) await loadUserData(email);
    }

    // // Inisialisasi IAP
    // final bool available = await InAppPurchase.instance.isAvailable();
    // if (available) {
    //   InAppPurchase.instance.purchaseStream.listen(_listenToPurchaseUpdated);
    // }
  }

  // --- 2. LOAD DATA USER ---
  static Future<void> loadUserData(String email) async {
    final p = await SharedPreferences.getInstance();
    userEmail.value = email;
    userName.value = p.getString('${email}_name') ?? "";
    shopName.value = p.getString('${email}_shop') ?? "";
    isPro.value = p.getBool('${email}_is_pro') ?? false;

    final b = p.getString('${email}_master_bahan');
    final r = p.getString('${email}_all_recipes');
    masterBahan.value = b != null
        ? List<Ingredient>.from(
            json.decode(b).map((x) => Ingredient.fromMap(x)),
          )
        : [];
    allRecipes.value = r != null
        ? List<Recipe>.from(json.decode(r).map((x) => Recipe.fromMap(x)))
        : [];
  }

  // --- 3. SIMPAN KE STORAGE HP ---
  static Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    String email = userEmail.value;
    if (email.isEmpty) return;

    await p.setBool('is_logged_in', isLoggedIn.value);
    await p.setString('current_session_email', email);
    await p.setString('${email}_name', userName.value);
    await p.setString('${email}_shop', shopName.value);
    await p.setBool('${email}_is_pro', isPro.value);
    await p.setString(
      '${email}_master_bahan',
      json.encode(masterBahan.value.map((e) => e.toMap()).toList()),
    );
    await p.setString(
      '${email}_all_recipes',
      json.encode(allRecipes.value.map((e) => e.toMap()).toList()),
    );
  }

  // --- 4. AUTH LOGIC ---
  static Future<void> registerUser(
    String n,
    String s,
    String e,
    String pass,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('${e}_pass', pass);
    userEmail.value = e;
    userName.value = n;
    shopName.value = s;
    isLoggedIn.value = true;
    allRecipes.value = [];
    masterBahan.value = [];
    isPro.value = false;
    await _persist();
  }

  static Future<bool> login(String e, String pass) async {
    final p = await SharedPreferences.getInstance();
    if (p.getString('${e}_pass') == pass) {
      isLoggedIn.value = true;
      await loadUserData(e);
      await p.setBool('is_logged_in', true);
      await p.setString('current_session_email', e);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('is_logged_in', false);
    isLoggedIn.value = false;
    userEmail.value = "";
    userName.value = "";
    shopName.value = "";
    isPro.value = false;
    allRecipes.value = [];
    masterBahan.value = [];
  }

  // --- 5. CRUD LOGIC ---
  static void saveRecipe(Recipe r) {
    List<Recipe> curr = List.from(allRecipes.value);
    int i = curr.indexWhere((x) => x.id == r.id);
    if (i != -1) {
      curr[i] = r;
    } else {
      curr.add(r);
    }
    allRecipes.value = curr;
    _syncMaster([...r.ingredients, ...r.packaging, ...r.otherCosts]);
    _persist();
  }

  static void deleteRecipe(String id) {
    allRecipes.value = List.from(allRecipes.value)
      ..removeWhere((x) => x.id == id);
    _persist();
  }

  static void saveBahan(Ingredient b) {
    List<Ingredient> curr = List.from(masterBahan.value);
    int i = curr.indexWhere((x) => x.id == b.id);
    if (i != -1) {
      curr[i] = b;
    } else {
      curr.add(b);
    }
    masterBahan.value = curr;
    _persist();
  }

  static void updateBahan(Ingredient b) => saveBahan(b);
  static void deleteBahan(String id) {
    masterBahan.value = List.from(masterBahan.value)
      ..removeWhere((x) => x.id == id);
    _persist();
  }

  static void activatePro(int d) {
    isPro.value = true;
    _persist();
  }

  static Future<void> buyPro() async {
    // Simulate purchase process
    await Future.delayed(const Duration(seconds: 1));
    isPro.value = true;
    await _persist();
  }

  static void updateStock(String id, double change) {
    List<Ingredient> curr = List.from(masterBahan.value);
    int i = curr.indexWhere((x) => x.id == id);
    if (i != -1) {
      double oldVal = curr[i].currentStock ?? 0;
      curr[i] = Ingredient(
        id: curr[i].id,
        name: curr[i].name,
        buyPrice: curr[i].buyPrice,
        buyAmount: curr[i].buyAmount,
        cost: curr[i].cost,
        use: curr[i].use,
        unit: curr[i].unit,
        minStock: curr[i].minStock,
        currentStock: oldVal + change,
      );
      masterBahan.value = curr;
      _persist();
    }
  }

  static void _syncMaster(List<Ingredient> ings) {
    List<Ingredient> curr = List.from(masterBahan.value);
    for (var i in ings) {
      if (!curr.any((x) => x.name.toLowerCase() == i.name.toLowerCase())) {
        curr.add(
          Ingredient(
            id: DateTime.now().toString() + i.name,
            name: i.name,
            buyPrice: i.buyPrice,
            buyAmount: i.buyAmount,
            cost: 0,
            use: 0,
            unit: i.unit,
            currentStock: isPro.value ? 0 : null,
            minStock: isPro.value ? 0 : null,
          ),
        );
      }
    }
    masterBahan.value = curr;
  }
}
