import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/core/config/navbar_config.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/core/theme.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int _selectedIndex = 2; // Index 2 is for Events in NavBarConfig

  @override
  void initState() {
    super.initState();
    // Any initialization code
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
    context.pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Navigate to home when back button is pressed
          context.pushReplacement(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          backgroundColor: AppColors.deepBlue,
          elevation: 0,
        ),
        body: Center(
          child: const Text(
            'Events Page - Coming Soon',
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar: HomeNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
