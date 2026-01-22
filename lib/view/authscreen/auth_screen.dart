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

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String selectedRole = 'customer';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  void handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        final result = await AuthService().login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (result == null) {
          final role = await AuthService().getUserRole();
          _navigateBasedOnRole(role);
        } else {
          _showError('Login Failed', result);
        }
      } else {
        final result = await AuthService().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          role: selectedRole,
        );

        if (result == null) {
          if (selectedRole == 'chef') {
            _showChefSetupDialog();
          } else {
            final role = await AuthService().getUserRole();
            _navigateBasedOnRole(role);
          }
        } else {
          _showError('Signup Failed', result);
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _navigateBasedOnRole(String? role) {
    if (role == 'chef') {
      Get.offAllNamed(AppRoutes.chefDashboard);
    } else {
      Get.offAllNamed(AppRoutes.Navbar);
    }
  }

  void _showChefSetupDialog() {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Complete Your Profile',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'As a Chef, you need to set up your restaurant first.',
      textCancel: 'Cancel',
      textConfirm: 'Set Up Restaurant',
      cancelTextColor: Colors.grey.shade700,
      confirmTextColor: Colors.white,
      buttonColor: Colors.deepOrangeAccent,
      radius: 16,
      onConfirm: () {
        Get.back(); // Close dialog
        Get.toNamed(AppRoutes.RestaurantSetupScreen);
      },
      onCancel: () {
        Get.back(); // Close dialog
        Get.snackbar(
          'Action Required',
          'Restaurant setup is mandatory for chefs.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
      },
    );
  }

  void toggleMode() {
    setState(() => isLogin = !isLogin);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF3E0), Colors.white],
                stops: [0.0, 0.4],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Logo & Title
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/burger_icon.png',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                isLogin ? 'Welcome Back' : 'Join Us',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                isLogin
                                    ? 'Login to continue'
                                    : 'Sign up to get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                          // Glassmorphic Auth Card
                          Column(
                            children: [
                              // Name Field
                              if (!isLogin) ...[
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                  validator: (val) =>
                                  val!.trim().isEmpty ? 'Enter name' : null,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email Field
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) => val!.trim().isEmpty ||
                                    !GetUtils.isEmail(val.trim())
                                    ? 'Enter valid email'
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              // Password Field with Toggle
                              _buildPasswordField(),

                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                _buildRoleDropdown(),
                              ],

                              const SizedBox(height: 28),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrangeAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    shadowColor: Colors.deepOrangeAccent.withOpacity(0.4),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                      : Text(
                                    isLogin ? 'Login' : 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Toggle Mode
                              GestureDetector(
                                onTap: toggleMode,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
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
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrangeAccent),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(CupertinoIcons.lock, color: Colors.deepOrangeAccent),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: Colors.grey.shade600,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: (val) =>
      val!.length < 6 ? 'Password must be 6+ characters' : null,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      decoration: InputDecoration(
        labelText: 'I am a',
        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.deepOrangeAccent),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2),
        ),
      ),
      items: ['customer', 'chef'].map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(
            role[0].toUpperCase() + role.substring(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedRole = value!),
    );
  }
}