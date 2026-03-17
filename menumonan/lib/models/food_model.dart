import 'dart:math';

class Food {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;

  Food({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.category = '',
  });

  Food copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? category,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json, {String category = ''}) {
    // the public API doesn't provide a price, so we fake one
    final randomPrice = (Random().nextDouble() * 50) + 10;
    return Food(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      imageUrl: json['strMealThumb'] as String,
      price: double.parse(randomPrice.toStringAsFixed(2)),
      category: category,
    );
  }
}