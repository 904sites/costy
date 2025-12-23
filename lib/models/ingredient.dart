class Ingredient {
  String name;
  double buyPrice;
  double totalAmount; // misal: 1000 gram
  String unit; // gram, ml, pcs

  Ingredient({
    required this.name,
    required this.buyPrice,
    required this.totalAmount,
    required this.unit,
  });

  // Hitung harga per unit terkecil
  double get pricePerUnit => buyPrice / totalAmount;
}
