import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // // -----------------------
  // // ✅ Sign Up Function
  // // -----------------------

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name':name,
          'role':role
        }
      );

      final user = res.user;
      if (user == null) {
        return 'Signup failed';
      }

      // Update the users table with name and role
      await supabase.from('users').update({
        'name': name,
        'role': role,
      }).eq('id', user.id);

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }


  // -----------------------
  // ✅ Login Function
  // -----------------------
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        return null; // success
      } else {
        return 'Login failed. User is null.';
      }
    } catch (e) {
      return e.toString();
    }
  }


  // -----------------------
  // ✅ Get Current User Role
  // -----------------------
  Future<String?> getUserRole() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  // -----------------------
  // ✅ Logout Function
  // -----------------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }


  // get current user
  Future<AppUser?> getCurrentUserData() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return null;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    if (response == null) return null;

    return AppUser.fromMap(response);
  }


}
