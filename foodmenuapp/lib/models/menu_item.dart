// lib/models/menu_item.dart

class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final bool availability;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.availability,
  });

  // Factory constructor to create a MenuItem from a map (for Supabase data)
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      category: map['category'],
      availability: map['availability'],
    );
  }

  // Method to convert a MenuItem to a map (for inserting into Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'availability': availability,
    };
  }
}
