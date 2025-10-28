class MealEntry {
  MealEntry({
    this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int? id;
  final String name;
  final String category;
  final int calories;
  final int quantity;
  final int protein;
  final int carbs;
  final int fat;

  MealEntry copyWith({
    int? id,
    String? name,
    String? category,
    int? calories,
    int? quantity,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      quantity: quantity ?? this.quantity,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      calories: map['calories'] as int,
      quantity: map['quantity'] as int,
      protein: map['protein'] as int,
      carbs: map['carbs'] as int,
      fat: map['fat'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'quantity': quantity,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
