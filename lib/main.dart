// Packages imports
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
// Wrappers
import 'package:hackathlone_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
// Screens
import 'package:hackathlone_app/screens/login/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
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
      home: const LoginPage(),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(title: 'Instruments', home: HomePage());
  // }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
