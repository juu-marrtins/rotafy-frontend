import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import 'package:rotafy_frontend/router/app_router.dart';
import 'core/theme/roy_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter, // <- estava fora do lugar
      debugShowCheckedModeBanner: false,
      title: 'Roy App',
      theme: ThemeData(
        scaffoldBackgroundColor: RoyColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: RoyColors.blueNavy,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: RoyTheme.primaryButton(),
        ),
      ),
      // removido o home: pois o router já cuida disso
    );
  }
}