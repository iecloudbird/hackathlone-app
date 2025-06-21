import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathlone_app/screens/login/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageController {
  Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Clear any saved credentials, will move this into separate method later
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.setBool('remember_me', false);

    // Navigate to login page
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }
}
