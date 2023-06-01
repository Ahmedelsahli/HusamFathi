import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:hostepil1200/firebase_options.dart';
import 'package:hostepil1200/sign_in_page.dart';

import 'app_theme.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return FlutterWebFrame(
      maximumSize: const Size(475.0, 812.0), // Maximum size
      enabled: kIsWeb, // defau
      builder: (context) => MaterialApp(
        title: 'مركز بنغازي الطبي',
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: const LandingPage(title: 'مركز بنغازي الطبي'),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});

  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // check if the user is signed in
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            User? user = snapshot.data;
            if (user != null) {
              return const HomePage();
            } else {
              return const SignInPage();
            }
          }),
    );
  }
}
