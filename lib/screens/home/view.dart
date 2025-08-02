import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/common/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:hackathlone_app/common/widgets/appbar.dart';
import 'package:hackathlone_app/common/widgets/navbar.dart';
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:hackathlone_app/router/app_routes.dart';

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
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userProfile == null && authProvider.user != null) {
      authProvider.signIn(
        email: '', // Placeholder, update with saved email if needed
        password: '', // Placeholder, update with saved credentials if needed
        rememberMe: false, // Placeholder
      ); // Retry fetch if profile is null
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
    // final authProvider = context.watch<AuthProvider>();

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
