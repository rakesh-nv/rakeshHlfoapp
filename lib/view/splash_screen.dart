import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/routes/app_routs.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 1)); // for smooth animation

    final user = Supabase.instance.client.auth.currentUser;
    print('🔑 Logged in user: $user');
    if (user == null) {
      Get.offAllNamed(AppRoutes.auth);
      return;
    }

    final role = await AuthService().getUserRole();

    if (role == 'chef') {
      Get.offAllNamed(AppRoutes.chefDashboard);
    } else if (role == 'customer') {
      Get.offAllNamed(AppRoutes.customerDashboard);
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
