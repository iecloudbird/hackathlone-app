// Packages imports
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathlone_app/utils/routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
// Wrappers
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Global navigator key for accessing GoRouter outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // White icons
      statusBarBrightness: Brightness.dark, // For iOS
      systemNavigationBarColor: Color(0xFF000613), // Match app gradient
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Ensure edge-to-edge rendering
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final appLinks = AppLinks();
  Uri? initialUri = await appLinks.getInitialLink();
  print('Initial link: $initialUri');
  if (initialUri != null) {
    print(
      'Scheme: ${initialUri.scheme}, Host: ${initialUri.host}, Path: ${initialUri.path}',
    );
    print('Query parameters: ${initialUri.queryParameters}');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(initialUri: initialUri),
    ),
  );

  appLinks.uriLinkStream.listen((uri) {
    print('Stream link: $uri');
    print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    print('Query parameters: ${uri.queryParameters}');
    final token = uri.queryParameters['token'];
    final type = uri.queryParameters['type'];
    if (navigatorKey.currentContext != null) {
      if (token != null && type != null) {
        GoRouter.of(
          navigatorKey.currentContext!,
        ).go(AppRoutes.authAction, extra: {'type': type, 'token': token});
      } else if (uri.path == '/' || uri.path.isEmpty) {
        GoRouter.of(navigatorKey.currentContext!).go(AppRoutes.login);
      }
    }
  });

  SemanticsBinding.instance.ensureSemantics(); //Automatically enable semantics
}

class MyApp extends StatelessWidget {
  final Uri? initialUri;
  const MyApp({super.key, this.initialUri});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hackathlone App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0042A6),
        fontFamily: 'Overpass',
        useMaterial3: true,
        scaffoldBackgroundColor:
            Colors.transparent, // Ensure no default white background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0042A6),
          brightness: Brightness.dark, // Align with dark theme
          surface: const Color(0xFF000613), // Match gradient start
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      routerConfig: AppRoutes.getRouter(
        navigatorKey: navigatorKey,
        initialLocation: _getInitialLocation(),
      ),
    );
  }

  String _getInitialLocation() {
    if (Supabase.instance.client.auth.currentSession != null) {
      return AppRoutes.home;
    } else if (initialUri != null) {
      if (initialUri!.path.startsWith('/auth_action')) {
        return AppRoutes.authAction;
      } else if (initialUri!.path == '/' || initialUri!.path.isEmpty) {
        return AppRoutes.login;
      }
    }
    return AppRoutes.login;
  }
}
