import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/common/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/common/widgets/appbar.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';
import 'package:hackathlone_app/config/constants/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<String> _routes = [
    AppRoutes.home,
    AppRoutes.team,
    AppRoutes.events,
    AppRoutes.inbox,
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfileIfNeeded();
    });
  }

  void _loadUserProfileIfNeeded() async {
    final authProvider = context.read<AuthProvider>();

    // If user is logged in but no profile, try to load it
    if (authProvider.userProfile == null && authProvider.user != null) {
      await authProvider.loadUserProfile();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(title: AppStrings.appTitle),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Placeholder for NTK and Events (to be developed)
            Text(AppStrings.ntkPlaceholder, style: AppTextStyles.bodyMedium),
            AppDimensions.verticalSpaceM,
            Text(AppStrings.eventsPlaceholder, style: AppTextStyles.bodyMedium),
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
