import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../style/app_theme.dart';
import '../services/data_service.dart';
import 'home_screen.dart';
import 'recipe_detail_view.dart';

class RecipesPage extends StatelessWidget {
  final VoidCallback onAddPressed;
  final Function(Recipe) onEditPressed;

  const RecipesPage({
    super.key,
    required this.onAddPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // --- 1. HEADER PINK COSTY ---
        _buildHeader(context),

        // --- 2. TITLE & TOMBOL TAMBAH (+) ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Koleksi Resep",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.matchaDark,
                ),
              ),
              GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.strawberryDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),

        // --- 3. LIST DATA RESEP ---
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: DataService.allRecipes,
            builder: (context, List<Recipe> recipes, _) {
              if (recipes.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final r = recipes[index];
                  return GestureDetector(
                    // --- KLIK KARTU UNTUK MELIHAT DETAIL ---
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => RecipeDetailView(
                          recipe: r,
                          onEdit: (recipeToEdit) => onEditPressed(recipeToEdit),
                          onDelete: () => DataService.deleteRecipe(r.id),
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.matchaDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${r.portion} PORSI • ${r.ingredients.length + r.packaging.length + r.otherCosts.length} ITEM TOTAL",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.black12, thickness: 0.5),
                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _priceDisplay(
                                "MODAL / PORSI",
                                currency.format(r.modalPerPorsi),
                                AppColors.matchaDark,
                              ),
                              _priceDisplay(
                                "HARGA JUAL",
                                currency.format(r.hargaJual),
                                AppColors.strawberryDark,
                                alignEnd: true,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // --- WIDGET HELPER ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFFCEBF1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Costy",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.matchaDark,
                    ),
                  ),
                  const SizedBox(width: 5),
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
  }

  Widget _priceDisplay(
    String label,
    String value,
    Color color, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAddPressed,
            child: Container(
              padding: const EdgeInsets.all(35),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 60, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Belum ada resep yang disimpan.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.blueGrey[200],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: onAddPressed,
            child: Text(
              "Mulai buat resep pertama!",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.strawberryDark.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
