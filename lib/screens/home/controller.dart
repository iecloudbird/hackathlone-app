import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/utils/routes.dart';

class HomePageController {
  Future<void> signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    // Clear any saved credentials, will move this into separate method later
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.setBool('remember_me', false);

    // Navigate to login page
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }
}
