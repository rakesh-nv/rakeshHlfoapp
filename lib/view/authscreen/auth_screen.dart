import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/routes/app_routs.dart';
import '../customer/customer_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String selectedRole = 'customer';

  void handleAuth() async {
    if (isLogin) {
      // Login
      final result = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result == null) {
        print("////// Login successful //////");
        final role = await AuthService().getUserRole();
        if (role == 'chef') {
          Get.offAllNamed(AppRoutes.chefDashboard);
        } else {
          Get.offAllNamed(AppRoutes.customerDashboard);
        }
      } else {
        Get.snackbar('Login Failed', result, backgroundColor: Colors.redAccent);
      }
    } else {

      // Sign Up
      final result = await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: selectedRole,
      );

      if (result == null) {
        final role = await AuthService().getUserRole();
        if (role == 'chef') {
          // Redirect to Restaurant Setup if chef signs up
          Get.offAllNamed(AppRoutes.chefDashboard);
        } else {
          Get.offAllNamed(AppRoutes.customerDashboard);
        }
      } else {
        Get.snackbar('Signup Failed', result, backgroundColor: Colors.redAccent);
      }
    }
  }



  void _showChefSetupDialog() {
    Get.defaultDialog(
      title: 'Restaurant Setup Required',
      middleText: 'To complete sign-up as a Chef, you must provide restaurant details.',
      textCancel: 'Cancel',
      textConfirm: 'Continue',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
        Get.toNamed(AppRoutes.RestaurantSetupScreen); // push to setup screen
      },
      onCancel: () {
        Get.snackbar('Signup Incomplete', 'Restaurant setup is required to continue as a chef.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            if (!isLogin)
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'Role'),
                items: ['customer', 'chef'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role.toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(
                  () => selectedRole = value!,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
