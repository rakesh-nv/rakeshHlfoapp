import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    _emailController.text = user.email ?? '';

    try {
      final data = await supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();

      if (data != null && data['name'] != null) {
        _nameController.text = data['name'];
      }
    } catch (e) {
      print('Error loading profile: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('users')
          .update({'name': _nameController.text}).eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    child: SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            radius: 60,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: 200,
                            // color: Colors.blue,
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  controller: _nameController,
                                  decoration:
                                      InputDecoration(labelText: 'Name'),
                                ),
                                TextField(
                                  controller: _emailController,
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                  enabled: false,
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _updateProfile,
                                  child: Text('Update Profile'),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Get.offAllNamed('/auth');
                      // TODO: Add sign out logic
                    },
                    child: Text('LogOut'),
                  )
                ],
              ),
            ),
    );
  }
}
