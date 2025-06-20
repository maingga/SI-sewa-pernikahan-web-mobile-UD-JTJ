class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String status;
  int quantity;
  final bool selected;
  final String collection; 
  String note; // Add the note field

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.status,
    this.quantity = 1,
    this.selected = false,
    required this.collection,
    this.note = '', // Initialize the note field
  });
}
