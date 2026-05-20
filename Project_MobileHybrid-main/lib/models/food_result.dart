class FoodResult {
  final String id;
  final String description;
  final double caloriesPer100g;
  final double protein;
  final double carbs;
  final double fat;

  FoodResult({
    required this.id,
    required this.description,
    required this.caloriesPer100g,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodResult.fromJson(Map<String, dynamic> json) {
    return FoodResult(
      id: json['fdsId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fdsId': id,
      'description': description,
      'caloriesPer100g': caloriesPer100g,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
