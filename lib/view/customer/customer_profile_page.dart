import 'dart:ui';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rakeshhlfoapp/view/customer/CustomerOrderHistory_screen.dart';
import 'package:rakeshhlfoapp/view/customer/cart_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _emailController.text = user.email ?? '';

    try {
      final data = await supabase.from('users').select('name').eq('id', user.id).single();
      if (data != null && data['name'] != null) {
        _nameController.text = data['name'];
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('users').update({'name': _nameController.text}).eq('id', user.id);
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔸 User Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepOrange, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.deepOrange[50],
                      child: const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.deepOrange),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 15, color: Colors.black),
                        onPressed: () {}, // Image upload logic
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🔸 Profile Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  _buildModernTextField(controller: _nameController, label: "Full Name", icon: CupertinoIcons.person),
                  const SizedBox(height: 16),
                  _buildModernTextField(controller: _emailController, label: "Email Address", icon: CupertinoIcons.mail, enabled: false),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 🔸 Menu Items Section
            _buildMenuTile(
              icon: CupertinoIcons.cart,
              title: "Cart Items",
              onTap: () => Get.to(() => const FoodCartScreen()),
            ),
            _buildMenuTile(
              icon: Icons.history,
              title: "Order History",
              onTap: () => Get.to(() => const CustomerOrderHistoryScreen()),
            ),

            const SizedBox(height: 40),

            // 🔸 Logout Button
            TextButton.icon(
              onPressed: () async {
                await supabase.auth.signOut();
                Get.offAllNamed('/auth');
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red.withOpacity(0.2))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: enabled ? Colors.deepOrange : Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.transparent : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepOrange, width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[100]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}