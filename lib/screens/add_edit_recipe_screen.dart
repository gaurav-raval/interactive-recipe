import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/db_helper.dart';
import '../models/recipe.dart';
import '../widgets/recipe_image.dart';

/// CREATE and UPDATE: one form used for both Add Recipe and Edit Recipe.
class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // null = add mode, not null = edit mode

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _instructionsCtrl;
  late final TextEditingController _timeCtrl;
  String? _imagePath;

  bool get _isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _ingredientsCtrl = TextEditingController(text: r?.ingredients ?? '');
    _instructionsCtrl = TextEditingController(text: r?.instructions ?? '');
    _timeCtrl = TextEditingController(text: r?.cookingTime ?? '');
    _imagePath = r?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _instructionsCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200);
    if (picked == null) return;

    // Copy into the app folder so the image is still there later.
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final saved = await File(picked.path).copy(p.join(dir.path, fileName));
    if (!mounted) return;
    setState(() => _imagePath = saved.path);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final recipe = Recipe(
      id: widget.recipe?.id,
      name: _nameCtrl.text.trim(),
      ingredients: _ingredientsCtrl.text.trim(),
      instructions: _instructionsCtrl.text.trim(),
      cookingTime: _timeCtrl.text.trim(),
      imagePath: _imagePath,
      isFavorite: widget.recipe?.isFavorite ?? false,
    );

    if (_isEdit) {
      await DbHelper.instance.updateRecipe(recipe);
    } else {
      await DbHelper.instance.insertRecipe(recipe);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Recipe updated' : 'Recipe saved')),
    );
    Navigator.pop(context, true);
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Recipe' : 'Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showImageOptions,
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: (_imagePath != null)
                      ? RecipeImage(path: _imagePath, height: 150, width: double.infinity)
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              SizedBox(height: 6),
                              Text('Add Image'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Recipe Name *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Enter recipe name'),
                validator: (v) => _required(v, 'Recipe name'),
              ),
              const SizedBox(height: 16),
              const Text('Ingredients *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ingredientsCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'One ingredient per line\n(e.g. 1 cup rice)',
                ),
                validator: (v) => _required(v, 'Ingredients'),
              ),
              const SizedBox(height: 16),
              const Text('Instructions *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _instructionsCtrl,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'One cooking step per line'),
                validator: (v) => _required(v, 'Instructions'),
              ),
              const SizedBox(height: 16),
              const Text('Cooking Time', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _timeCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. 30 mins',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(_isEdit ? 'Update Recipe' : 'Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
