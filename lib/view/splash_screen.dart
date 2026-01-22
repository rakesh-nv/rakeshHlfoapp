import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/routes/app_routs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// NOTE: add SingleTickerProviderStateMixin so `vsync: this` works
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // initialize controller with the mixin-provided vsync
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // start animation
    _controller.forward();

    // delay navigation so the splash animation plays — we call _navigate()
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _navigate();
    });
  }

  Future<void> _navigate() async {
    // small delay if you still want it (optional)
    // await Future.delayed(const Duration(milliseconds: 300));
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('🔑 Logged in user: $user');

    if (user == null) {
      if (mounted) Get.offAllNamed(AppRoutes.auth);
      return;
    }

    final role = await AuthService().getUserRole();
    if (!mounted) return;
    if (role == 'chef') {
      Get.offAllNamed(AppRoutes.chefDashboard);
    } else if (role == 'customer') {
      Get.offAllNamed(AppRoutes.Navbar);
    } else {
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // gradient background (orange -> deep orange)
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDCB82), // light orange
              Color(0xFFF7931E), // deep orange
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color:
                              Colors.white, // circle behind icon for contrast
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/burger_icon.png',
                          // errorBuilder: (context, error, stackTrace) {
                          //   return const Icon(
                          //     Icons.restaurant_menu,
                          //     size: 80,
                          //     color: Colors.deepOrange,
                          //   );
                          // },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Food Delivery',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
