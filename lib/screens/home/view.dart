import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/common/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/common/widgets/appbar.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/core/config/navbar_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    // Load user profile if not available
    if (authProvider.userProfile == null && authProvider.user != null) {
      authProvider.signIn(
        email: '', // Placeholder, update with saved email if needed
        password: '', // Placeholder, update with saved credentials if needed
        rememberMe: false, // Placeholder
      ); // Retry fetch if profile is null
    }

    // Load notifications
    if (authProvider.user != null) {
      context.read<NotificationProvider>().loadNotifications(
        authProvider.user!.id,
      );
    }
  }

  void _onItemTapped(int index) {
    final authProvider = context.read<AuthProvider>();
    final isAdmin = authProvider.userProfile?.role == 'admin';
    final unreadCount = context.read<NotificationProvider>().unreadCount;

    final route = NavBarConfig.getRouteByIndex(
      index,
      isAdmin: isAdmin,
      unreadNotifications: unreadCount,
    );

    setState(() {
      _selectedIndex = index;
    });
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(title: 'Hackathlone App'),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Placeholder for NTK and Events (to be developed)
            const Text('NTK Component Placeholder'),
            const Text('Events Section Placeholder'),
          ],
        ),
      ),
      bottomNavigationBar: HomeNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
