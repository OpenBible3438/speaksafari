import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:speak_safari/src/view/login/auth_service.dart';
import 'firebase_options.dart';

import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/util/route_path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        // Provider(
        //   create: (context) => ProductRepository(),
        // ),
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
        ),
        ChangeNotifierProvider(create: (context) => AuthService()),
        // ChangeNotifierProvider(
        //   create: (context) => LangService(),
        // ),
        // ChangeNotifierProvider(
        //   create: (context) => CartService(),
        // ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => child!),
          ],
        );
      },
      debugShowCheckedModeBanner: false,
      theme: context.themeService.themeData,
      // initialRoute: RoutePath.main,
      initialRoute: isLoggedIn() ? RoutePath.login : RoutePath.main,
      onGenerateRoute: RoutePath.onGenerateRoute,
    );
  }
}
