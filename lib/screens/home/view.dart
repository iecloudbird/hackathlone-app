import 'package:flutter/material.dart';
import './controller.dart';
import 'package:hackathlone_app/utils/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomePageController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000613), Color(0xFF030B21), Color(0xFF040D22)],
            stops: [-2.66, 71.57, 101.72],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Hackathlone!',
                style: TextStyle(
                  fontFamily: 'FiraSans',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: AppColors.neonBlue,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
