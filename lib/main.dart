import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_safari/src/service/theme_service.dart';
import 'package:speak_safari/util/route_path.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provider(
        //   create: (context) => ProductRepository(),
        // ),
        ChangeNotifierProvider(
          create: (context) => ThemeService(),
        ),
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
      initialRoute: RoutePath.main,
      onGenerateRoute: RoutePath.onGenerateRoute,
    );
  }
}
