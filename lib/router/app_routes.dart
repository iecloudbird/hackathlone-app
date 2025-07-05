import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/router/router_helper.dart';
import 'package:hackathlone_app/screens/auth/index.dart';
import 'package:hackathlone_app/screens/home/index.dart';
import 'package:hackathlone_app/screens/login/index.dart';
import 'package:hackathlone_app/screens/signup/index.dart';
import 'package:hackathlone_app/core/transitions.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String authAction = '/auth_action';
  static const String team = '/team';
  static const String events = '/events';
  static const String inbox = '/inbox';

  static GoRouter getRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    String? initialLocation,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation ?? login,
      routes: [
        createRoute(path: home, child: const HomePage()),
        createRoute(path: login, child: const LoginPage()),
        createRoute(path: signup, child: const SignUpPage()),
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
        // createRoute(
        //   path: team,
        //   child: const TeamPage(),
        // ),
        // createRoute(
        //   path: events,
        //   child: const EventsPage(),
        // ),
        // createRoute(
        //   path: inbox,
        //   child: const InboxPage(),
        // ),
      ],
    );
  }
}
