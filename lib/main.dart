// Packages imports
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hackathlone_app/screens/auth/index.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
// Wrappers
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// Screens
import 'package:hackathlone_app/screens/login/index.dart';
import 'package:hackathlone_app/screens/home/index.dart';
import 'package:hackathlone_app/screens/signup/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  if (uri != null && uri.path == '/login') {
    // Handle password reset link
    final accessToken = uri.queryParameters['access_token'];
    final type = uri.queryParameters['type'];

    if (accessToken != null && type != null) {
      await Supabase.instance.client.auth.verifyOTP(
        type: type == 'recovery'
            ? OtpType.recovery
            : type == 'invite'
            ? OtpType.invite
            : OtpType.signup,
        token: accessToken,
      );
    }
  }
  appLinks.uriLinkStream.listen((uri) {
    if (uri.path == '/login') {
      final accessToken = uri.queryParameters['access_token'];
      if (accessToken != null) {
        Supabase.instance.client.auth.verifyOTP(
          type: OtpType.recovery,
          token: accessToken,
        );
      }
    }
  });

  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
  SemanticsBinding.instance.ensureSemantics(); //Automatically enable semantics
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathlone App',
      theme: ThemeData(
        primaryColor: const Color(0xFF0042A6),
        fontFamily: 'Overpass',
        useMaterial3: true,
      ),
      // If user auth token is available, navigate to home page, otherwise to login page.
      initialRoute: Supabase.instance.client.auth.currentSession != null
          ? '/home'
          : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/auth_action': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, String>?;
          return AuthActionPage(action: args?['action'] ?? 'confirm');
        },
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(title: 'Instruments', home: HomePage());
  // }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _HomePageState();
}

class _HomePageState extends State<MainApp> {
  final _future = Supabase.instance.client.from('instruments').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final instruments = snapshot.data!;
          return ListView.builder(
            itemCount: instruments.length,
            itemBuilder: ((context, index) {
              final instrument = instruments[index];
              return ListTile(title: Text(instrument['name']));
            }),
          );
        },
      ),
    );
  }
}
