import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/router_helper.dart';
import 'package:hackathlone_app/screens/auth/index.dart';
import 'package:hackathlone_app/screens/home/index.dart';
import 'package:hackathlone_app/screens/login/index.dart';
import 'package:hackathlone_app/screens/onboarding/index.dart';
import 'package:hackathlone_app/screens/qr/display.dart';
import 'package:hackathlone_app/screens/qr/scan.dart';
import 'package:hackathlone_app/screens/profile/index.dart';
import 'package:hackathlone_app/screens/signup/index.dart';
import 'package:hackathlone_app/core/transitions.dart';

class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String authAction = '/auth_action';
  static const String events = '/events';
  static const String inbox = '/inbox';
  static const String qrDisplay = '/qr_display';
  static const String qrScan = '/qr_scan';
  static const String profile = '/profile';

  static GoRouter getRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    String? initialLocation,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation ?? login,
      routes: [
        createRoute(path: root, child: const OnboardingPage()),
        createRoute(path: home, child: const HomePage(initialIndex: 0)),
        createRoute(path: events, child: const HomePage(initialIndex: 1)),
        createRoute(path: inbox, child: const HomePage(initialIndex: 2)),
        createRoute(path: login, child: const LoginPage()),
        createRoute(path: signup, child: const SignUpPage()),
        createRoute(path: onboarding, child: const OnboardingPage()),
        createRoute(path: qrDisplay, child: const QrDisplayPage()),
        createRoute(path: qrScan, child: const QrScanPage()),
        createRoute(path: profile, child: const ProfilePage()),

        // Auth action takes params from context or query parameters
        GoRoute(
          path: authAction,
          pageBuilder: (context, state) {
            final params =
                state.extra as Map<String, String>? ??
                state.uri.queryParameters;
            return CustomTransitionPage(
              key: state.pageKey,
              child: AuthActionPage(
                action: params['type'] ?? 'confirm',
                token: params['token'],
              ),
              transitionsBuilder: AppTransitions.fadeTransition,
              transitionDuration: const Duration(milliseconds: 300),
            );
          },
        ),
      ],
    );
  }
}
