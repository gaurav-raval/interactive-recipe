import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'add_edit_recipe_screen.dart';
import 'recipe_details_screen.dart';

/// READ: shows all recipes (or only favourites) with a search box.
class RecipeListPage extends StatefulWidget {
  final bool favoritesOnly;

  const RecipeListPage({super.key, required this.favoritesOnly});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Recipe> _recipes = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await DbHelper.instance.getRecipes(
      query: _query,
      favoritesOnly: widget.favoritesOnly,
    );
    if (!mounted) return;
    setState(() {
      _recipes = result;
      _loading = false;
    });
  }

  Future<void> _openDetails(Recipe recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipeId: recipe.id!)),
    );
    _load();
  }

  Future<void> _openForm([Recipe? recipe]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditRecipeScreen(recipe: recipe)),
    );
    _load();
  }

  Future<void> _confirmDelete(Recipe recipe) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('"${recipe.name}" will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await DbHelper.instance.deleteRecipe(recipe.id!);
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Recipe deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.favoritesOnly ? 'Favorites' : 'Recipe Book')),
      floatingActionButton: widget.favoritesOnly
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.orange,
              foregroundColor: Colors.white,
              onPressed: () => _openForm(),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                _query = value;
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? Center(
                        child: Text(
                          widget.favoritesOnly
                              ? 'No favorite recipes yet'
                              : 'No recipes found.\nTap + to add one.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _recipes.length,
                        itemBuilder: (_, i) {
                          final r = _recipes[i];
                          return RecipeCard(
                            recipe: r,
                            onTap: () => _openDetails(r),
                            onEdit: () => _openForm(r),
                            onDelete: () => _confirmDelete(r),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
