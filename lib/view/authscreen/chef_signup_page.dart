import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChefSignupPage extends StatefulWidget {
  @override
  _ChefSignupPageState createState() => _ChefSignupPageState();
}

class _ChefSignupPageState extends State<ChefSignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final restaurantName = _restaurantNameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || restaurantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')), 
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Store chef details in the database
        await Supabase.instance.client.from('restaurants').insert({
          'user_id': response.user!.id,
          'name': restaurantName,
          'description': '', // Default description
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful!')), 
        );
        // Navigate to the Chef dashboard or another page
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')), 
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _restaurantNameController,
              decoration: InputDecoration(labelText: 'Restaurant Name'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _handleSignup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
} 