import 'package:flutter/material.dart';
import '../../../models/food_model.dart';
import '../../../services/chef/food_service.dart';
import 'add_food_screen.dart';
import 'edit_food_screen.dart';

class ChefMenuPage extends StatefulWidget {
  const ChefMenuPage({Key? key}) : super(key: key);

  @override
  State<ChefMenuPage> createState() => _ChefMenuPageState();
}

class _ChefMenuPageState extends State<ChefMenuPage> {
  final FoodService _foodService = FoodService();
  List<FoodModel> _foods = [];
  bool _isLoading = true;

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    _foods = await _foodService.getFoodsByChef();
    setState(() => _isLoading = false);
  }

  Future<void> _deleteFood(String id) async {
    await _foodService.deleteFood(id);
    _loadFoods();
  }

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Menu")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _foods.length,
              itemBuilder: (context, index) {
                final food = _foods[index];
                return ListTile(
                  leading: food.imageUrl != null
                      ? Image.network(food.imageUrl!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.fastfood),
                  title: Text(food.title),
                  subtitle: Text("₹${food.price.toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditFoodScreen(food: food),
                          ),
                        ).then((_) => _loadFoods()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFood(food.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFoodScreen()),
        ).then((_) => _loadFoods()),
      ),
    );
  }
}
