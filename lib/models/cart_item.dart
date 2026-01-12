class CartItem {
  final int productId;
  final String name;
  final double pricePerKg;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.pricePerKg,
    this.quantity = 1,
  });

  int get subTotal => (pricePerKg * quantity).round();
}
