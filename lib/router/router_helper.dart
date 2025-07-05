import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/core/transitions.dart';

GoRoute createRoute({required String path, required Widget child}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: AppTransitions.fadeTransition,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
