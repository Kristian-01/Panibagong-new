class Product {
  final String id;
  final String name;
  final double price;
  final int qty;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.qty = 1,
  });
}
