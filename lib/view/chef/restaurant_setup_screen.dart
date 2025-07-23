import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chef/restaurant_service.dart'; // ✅ ensure this is correct

class RestaurantSetupScreen extends StatefulWidget {
  const RestaurantSetupScreen({super.key});

  @override
  State<RestaurantSetupScreen> createState() => _RestaurantSetupScreenState();
}

class _RestaurantSetupScreenState extends State<RestaurantSetupScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _existingImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    try {
      final restaurant = await RestaurantService().getMyRestaurant();
      if (restaurant != null) {
        setState(() {
          _nameController.text = restaurant.name;
          _addressController.text = restaurant.address;
          _descriptionController.text = restaurant.description;
          _existingImageUrl = restaurant.imageUrl;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load restaurant data');
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _existingImageUrl = null; // Clear previous image preview
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final fileExt = imageFile.path.split('.').last;
    final filePath =
        'restaurant_images/$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    final bytes = await imageFile.readAsBytes();

    final response = await Supabase.instance.client.storage
        .from('restaurant-images')
        .uploadBinary(filePath, bytes,
            fileOptions: const FileOptions(upsert: true));

    if (response.isEmpty) return null;

    final publicUrl = Supabase.instance.client.storage
        .from('restaurant-images')
        .getPublicUrl(filePath);
    return publicUrl;
  }

  Future<void> _saveRestaurant() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        (_imageFile == null && _existingImageUrl == null)) {
      Get.snackbar('Error', 'Name, address and image are required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';
      if (_imageFile != null) {
        final uploaded = await _uploadImage(_imageFile!);
        if (uploaded == null) throw Exception("Image upload failed");
        imageUrl = uploaded;
      }

      await RestaurantService().upsertRestaurant(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
      );

      Get.snackbar('Success', 'Restaurant saved successfully!');
      // Get.offAllNamed(AppRoutes.chefDashboard);
    } catch (e) {
      print(e);
      Get.snackbar('Error', e.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Setup Your Restaurant"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile != null
                  ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
                  : (_existingImageUrl != null
                      ? Image.network(_existingImageUrl!,
                          height: 150, fit: BoxFit.cover)
                      : Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo, size: 50,color: Colors.deepOrange,),
                        )),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _saveRestaurant,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Restaurant"),
            ),
          ],
        ),
      ),
    );
  }
}
