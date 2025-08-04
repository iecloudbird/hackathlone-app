import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/common/widgets/appbar.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/common/widgets/drawer.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/screens/home/home_content.dart';
import 'package:hackathlone_app/screens/events/events_content.dart';
import 'package:hackathlone_app/screens/inbox/inbox_content.dart';

class MainTabView extends StatefulWidget {
  final int initialIndex;

  const MainTabView({super.key, this.initialIndex = 0});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    final authProvider = context.read<AuthProvider>();

    // Load user profile if not available
    if (authProvider.userProfile == null && authProvider.user != null) {
      // Load profile from cache or fetch fresh if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.loadUserProfile();
      });
    }

    // Load notifications
    if (authProvider.user != null) {
      context.read<NotificationProvider>().loadNotifications(
        authProvider.user!.id,
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentContent() {
    switch (_selectedIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return const EventsContent();
      case 2:
        return const InboxContent();
      default:
        return const HomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Check if there are any modal routes (like drawer) that can be popped
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // We're at the root level, show exit confirmation
            _showExitConfirmationDialog();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: HomeAppBar(title: 'Hackathlone App'),
        drawer: const HomeDrawer(),
        body: _getCurrentContent(),
        bottomNavigationBar: HomeNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabChanged,
        ),
      ),
    );
  }

  // Show a confirmation dialog when the user tries to exit the app
  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF000613),
        title: const Text('Exit App?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Exit the app properly
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Color(0xFF00C6AE)),
            ),
          ),
        ],
      ),
    );
  }
}
