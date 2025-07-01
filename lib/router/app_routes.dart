import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        //   GoRoute(
        //   path: team,
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: const TeamPage(),
        //     transitionsBuilder: AppTransitions.fadeTransition,
        //     transitionDuration: const Duration(milliseconds: 300),
        //   ),
        // ),
        // GoRoute(
        //   path: events,
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: const EventsPage(),
        //     transitionsBuilder: AppTransitions.fadeTransition,
        //     transitionDuration: const Duration(milliseconds: 300),
        //   ),
        // ),
        // GoRoute(
        //   path: inbox,
        //   pageBuilder: (context, state) => CustomTransitionPage(
        //     key: state.pageKey,
        //     child: const InboxPage(),
        //     transitionsBuilder: AppTransitions.fadeTransition,
        //     transitionDuration: const Duration(milliseconds: 300),
        //   ),
        // ),
      ],
    );
  }
}
