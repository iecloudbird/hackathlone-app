import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';

class HomePageController {
  Future<void> signOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut(context);
  }
}
