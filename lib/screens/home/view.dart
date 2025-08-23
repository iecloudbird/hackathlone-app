import 'package:flutter/material.dart';
import 'package:hackathlone_app/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/common/widgets/appbar.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/common/widgets/drawer.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/providers/notification_provider.dart';
import 'package:hackathlone_app/providers/timeline_provider.dart';
import 'package:hackathlone_app/screens/events/index.dart';
import 'package:hackathlone_app/screens/inbox/index.dart';
import 'widgets/timeline_section.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

    // Load timeline events for home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimelineProvider>().fetchUpcomingEvents(limit: 2);
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const EventsPage();
      case 2:
        return const InboxPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Timeline section with upcoming events
          const TimelineSection(),

          // Placeholder for NTK and other sections (to be developed)
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.maastrichtBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.spiroDiscoBall.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'More sections coming soon...\n(Announcements, Mentors, etc.)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontFamily: 'Overpass',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
              style: TextStyle(color: AppColors.rocketRed),
            ),
          ),
        ],
      ),
    );
  }
}
