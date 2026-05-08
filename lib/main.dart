import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotafy_frontend/core/services/auth_storage.dart';
import 'package:rotafy_frontend/core/theme/roy_colors.dart';
import 'package:rotafy_frontend/router/app_router.dart';
import 'core/theme/roy_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLoggedIn = await AuthStorage.hasToken();

  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: createRouter(isLoggedIn),
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
    );
  }
}