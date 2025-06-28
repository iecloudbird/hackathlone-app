import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/screens/auth/index.dart';
import 'package:hackathlone_app/screens/home/index.dart';
import 'package:hackathlone_app/screens/login/index.dart';
import 'package:hackathlone_app/screens/signup/index.dart';
import 'package:hackathlone_app/utils/transitions.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String authAction = '/auth_action';

  static GoRouter getRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    String? initialLocation,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation ?? login,
      routes: [
        GoRoute(
          path: login,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: AppTransitions.fadeTransition,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: home,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomePage(),
            transitionsBuilder: AppTransitions.fadeTransition,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: signup,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SignUpPage(),
            transitionsBuilder: AppTransitions.fadeTransition,
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
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
