import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'ingredients_page.dart';
import 'recipes_page.dart';
import 'add_recipe_view.dart';
import 'profile_screen.dart';
import 'subscription_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Recipe? _recipeToEdit;

  void setIndexFromOtherPage(int index) {
    setState(() {
      _currentIndex = index;
      _recipeToEdit = null;
    });
  }

  void _handleAddNew() {
    if (!DataService.isPro.value &&
        DataService.allRecipes.value.length >= DataService.freeLimit) {
      _showLimitDialog();
    } else {
      setState(() {
        _recipeToEdit = null;
        _currentIndex = 2;
      });
    }
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Kuota Penuh!"),
        content: const Text("Upgrade PRO untuk simpan tanpa batas!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Nanti"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setIndexFromOtherPage(4);
            },
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return HomeBody(onSeeAll: () => setState(() => _currentIndex = 3));
      case 1:
        return const IngredientsPage();
      case 2:
        return AddRecipeView(
          existingRecipe: _recipeToEdit,
          onBack: () => setState(() {
            _currentIndex = 0;
            _recipeToEdit = null;
          }),
          onSuccess: () => setState(() {
            _currentIndex = 3;
            _recipeToEdit = null;
          }),
        );
      case 3:
        return RecipesPage(
          onAddPressed: _handleAddNew,
          onEditPressed: (r) => setState(() {
            _recipeToEdit = r;
            _currentIndex = 2;
          }),
        );
      case 4:
        return const SubscriptionView();
      case 5:
        return const ProfileScreen();
      default:
        return HomeBody(onSeeAll: () => setState(() => _currentIndex = 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EDE4),
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, Icons.home, "Beranda", 0),
            _navItem(
              Icons.shopping_bag_outlined,
              Icons.shopping_bag,
              "Bahan",
              1,
            ),
            _centerAddItem(),
            _navItem(Icons.book_outlined, Icons.book, "Resep", 3),
            _navItem(Icons.person_outline, Icons.person, "Profil", 5),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData i1, IconData i2, String l, int idx) {
    bool act = _currentIndex == idx;
    Color c = act ? AppColors.matchaDark : Colors.grey[400]!;
    return Expanded(
      child: InkWell(
        onTap: () => setIndexFromOtherPage(idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(act ? i2 : i1, color: c, size: 26),
            Text(
              l,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: act ? FontWeight.bold : FontWeight.normal,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerAddItem() => Expanded(
    child: InkWell(
      onTap: _handleAddNew,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.matchaDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          Text(
            "Tambah",
            style: TextStyle(
              fontSize: 10,
              color: AppColors.matchaDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildProBadge(BuildContext ctx) => ValueListenableBuilder(
  valueListenable: DataService.isPro,
  builder: (c, bool pro, _) => GestureDetector(
    onTap: () {
      final state = ctx.findAncestorStateOfType<HomeScreenState>();
      state?.setIndexFromOtherPage(4);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pro ? AppColors.strawberryDark : AppColors.matchaDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pro ? Icons.workspace_premium : Icons.stars,
            color: pro ? Colors.yellow : Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            pro ? "ACTIVE" : "PRO",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
);

class HomeBody extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeBody({super.key, required this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _banner(),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: DataService.allRecipes,
                        builder: (c, v, _) => _stat(
                          "Total Resep",
                          "${v.length}",
                          DataService.isPro.value
                              ? ""
                              : "/${DataService.freeLimit}",
                          Icons.history_toggle_off_rounded,
                          AppColors.matchaDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: DataService.masterBahan,
                        builder: (c, v, _) => _stat(
                          "Total Bahan",
                          "${v.length}",
                          "",
                          Icons.trending_up_rounded,
                          AppColors.strawberryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _tips(),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Resep Terakhir",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.matchaDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: onSeeAll,
                      child: const Text(
                        "Lihat Semua",
                        style: TextStyle(
                          color: AppColors.strawberryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ValueListenableBuilder(
                  valueListenable: DataService.allRecipes,
                  builder: (c, list, _) =>
                      list.isEmpty ? _empty() : _recent(list.reversed.first),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext ctx) => Container(
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
                    fontSize: 28,
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
  Widget _banner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.matchaMedium,
      borderRadius: BorderRadius.circular(30),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Halo Foodpreneur! 👋",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Siap hitung harga jual produkmu?",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
  Widget _stat(String t, String v, String l, IconData i, Color c) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(i, size: 16, color: c),
            const SizedBox(width: 6),
            Text(
              t,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              v,
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(l, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ],
    ),
  );
  Widget _tips() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF1EDE4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.strawberryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            color: AppColors.strawberryDark,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        const Expanded(
          child: Text(
            "Pastikan margin kamu di atas 30% ya!",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    ),
  );
  Widget _empty() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.black12, style: BorderStyle.solid),
    ),
    child: const Center(
      child: Text(
        "Belum ada resep tersimpan.",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    ),
  );
  Widget _recent(Recipe r) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            Text(
              "${r.portion} Porsi • Margin ${r.margin}%",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "Dibuat",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.matchaDark,
              ),
            ),
            Text(
              r.date,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );
}
