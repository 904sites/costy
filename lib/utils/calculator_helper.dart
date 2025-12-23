double calculateTotalModal(List<Map<String, dynamic>> items) {
  return items.fold(
    0,
    (sum, item) => sum + (item['pricePerUnit'] * item['qtyUsed']),
  );
}

double suggestSellingPrice(double modalPerPorsi, double marginPercentage) {
  // Rumus: Modal / (1 - Margin%)
  return modalPerPorsi / (1 - (marginPercentage / 100));
}
