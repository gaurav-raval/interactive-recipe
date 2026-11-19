class Recipe {
  final int? id;
  final String name;
  final String ingredients;
  final String instructions;
  final String cookingTime;
  final String? imagePath;
  final bool isFavorite;

  const Recipe({
    this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.cookingTime = '',
    this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'cooking_time': cookingTime,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      cookingTime: (map['cooking_time'] as String?) ?? '',
      imagePath: map['image_path'] as String?,
      isFavorite: ((map['is_favorite'] as int?) ?? 0) == 1,
    );
  }
}
