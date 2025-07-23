import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/food_model.dart';
import '../../services/chef/food_service.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodModel food;

  const EditFoodScreen({super.key, required this.food});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _imageFile;

  final List<String> _categories = [
    'Starters',
    'Main Course',
    'Drinks',
    'Desserts',
  ];

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late String _selectedCategory;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.food.title);
    _descController = TextEditingController(text: widget.food.description);
    _priceController = TextEditingController(text: widget.food.price.toString());
    _selectedCategory = widget.food.category!;
    _isAvailable = widget.food.isAvailable;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'food/$fileName';

      final bytes = await file.readAsBytes();

      final response = await Supabase.instance.client.storage
          .from('food-images')
          .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl = Supabase.instance.client.storage
          .from('food-images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _updateFood() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String? imageUrl = widget.food.imageUrl;

      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception("Image upload failed");
        }
      }

      final updatedFood = FoodModel(
        id: widget.food.id,
        chefId: widget.food.chefId,
        restaurantId: widget.food.restaurantId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        category: _selectedCategory,
        createdAt: widget.food.createdAt,
      );

      await FoodService().updateFood(updatedFood);

      Get.back(); // Return to previous screen
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Food Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
              value!.isEmpty ? 'Please enter title' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
              validator: (value) =>
              value!.isEmpty ? 'Enter price' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                  value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text("Available"),
              value: _isAvailable,
              onChanged: (val) => setState(() => _isAvailable = val),
            ),
            const SizedBox(height: 10),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : widget.food.imageUrl != null
                ? Image.network(widget.food.imageUrl!, height: 150)
                : const Text('No Image'),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Change Image'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFood,
              child: const Text('Update Food'),
            )
          ]),
        ),
      ),
    );
  }
}
