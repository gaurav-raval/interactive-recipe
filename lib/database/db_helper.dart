import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/recipe.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'recipe_book.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            ingredients TEXT NOT NULL,
            instructions TEXT NOT NULL,
            cooking_time TEXT,
            image_path TEXT,
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Two sample recipes so the app is not empty on first launch.
        const samples = [
          Recipe(
            name: 'Pasta',
            ingredients:
                '1 cup pasta\n2 tomatoes\n1 tsp oregano\nSalt to taste',
            instructions:
                'Boil pasta until soft.\nPrepare sauce with tomatoes.\nMix and serve hot.',
            cookingTime: '20 mins',
          ),
          Recipe(
            name: 'Veg Fried Rice',
            ingredients:
                '1 cup cooked rice\n1 cup chopped vegetables\n1 tbsp soy sauce\n1 tbsp oil',
            instructions:
                'Heat oil in a pan.\nAdd vegetables and stir fry.\nAdd rice and soy sauce, mix well.',
            cookingTime: '15 mins',
          ),
        ];
        for (final r in samples) {
          final map = r.toMap()..remove('id');
          await db.insert('recipes', map);
        }
      },
    );
  }

  // CREATE
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    final map = recipe.toMap()..remove('id');
    return db.insert('recipes', map);
  }

  // READ (all recipes, search by name, favourites only)
  Future<List<Recipe>> getRecipes({
    String query = '',
    bool favoritesOnly = false,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <Object>[];

    if (query.trim().isNotEmpty) {
      conditions.add('name LIKE ?');
      args.add('%${query.trim()}%');
    }
    if (favoritesOnly) {
      conditions.add('is_favorite = 1');
    }

    final rows = await db.query(
      'recipes',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return rows.map(Recipe.fromMap).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    final db = await database;
    final rows = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Recipe.fromMap(rows.first);
  }

  // UPDATE
  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    final map = recipe.toMap()..remove('id');
    return db.update(
      'recipes',
      map,
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<void> setFavorite(int id, bool value) async {
    final db = await database;
    await db.update(
      'recipes',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('recipes');
  }
}
