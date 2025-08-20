import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/routes/app_routs.dart';

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
          Get.offAllNamed(AppRoutes.chefDashboard);
        } else {
          Get.offAllNamed(AppRoutes.customerDashboard);
        }
      } else {
        Get.snackbar('Signup Failed', result,
            backgroundColor: Colors.redAccent);
      }
    }
  }

  void _showChefSetupDialog() {
    Get.defaultDialog(
      title: 'Restaurant Setup Required',
      middleText:
          'To complete sign-up as a Chef, you must provide restaurant details.',
      textCancel: 'Cancel',
      textConfirm: 'Continue',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // close dialog
        Get.toNamed(AppRoutes.RestaurantSetupScreen); // push to setup screen
      },
      onCancel: () {
        Get.snackbar('Signup Incomplete',
            'Restaurant setup is required to continue as a chef.');
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 650,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.deepOrangeAccent),
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLogin)
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        suffixIcon: Icon(Icons.person_pin),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.email_outlined),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: false,
                    decoration: InputDecoration(
                      suffixIcon: Icon(CupertinoIcons.eye),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (!isLogin)
                    DropdownButtonFormField<String>(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: ['customer', 'chef'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedRole = value!),
                    ),
                  SizedBox(height: isLogin ? 130 : 10),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: isLogin
                                ? "Don't have an account? "
                                : "Already have an account? ",
                          ),
                          TextSpan(
                            text: isLogin ? "Sign Up" : "Login",
                            style: const TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: handleAuth,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
