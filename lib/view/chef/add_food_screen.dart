import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/food_model.dart';
import '../../services/chef/food_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  String? _category;
  bool _isAvailable = true;

  final List<String> _categories = [
    'Starters',
    'Main Course',
    'Drinks',
    'Desserts',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    try {
      final imageName = 'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = 'foods/$imageName';

      final supabase = Supabase.instance.client;

      // Upload to Supabase Storage
      await supabase.storage.from('food-images').upload(
            imagePath,
            _selectedImage!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final imageUrl =
          supabase.storage.from('food-images').getPublicUrl(imagePath);

      final newFood = FoodModel(
        id: '',
        // Will be auto-generated by Supabase
        chefId: supabase.auth.currentUser!.id,
        restaurantId: '',
        // Fill if needed
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        category: _category!,
        createdAt: DateTime.now(),
      );

      await FoodService().addFood(newFood);

      Navigator.pop(context); // go back to menu list
    } catch (e) {
      print("error$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add food: $e")),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Food")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 50,color: Colors.deepOrange,),
                      )
                    : Image.file(_selectedImage!,
                        height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) => value!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                hint: const Text("Select Category"),
                items: _categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val),
                validator: (val) =>
                    val == null ? 'Please select category' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                activeColor: Colors.deepOrange,
                title: const Text("Is Available"),
                value: _isAvailable,
                onChanged: (val) {
                  setState(() {
                    _isAvailable = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50)
                ),
                onPressed: _submit,
                child: const Text("Add Food"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
