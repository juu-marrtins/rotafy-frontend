import 'package:go_router/go_router.dart';
import 'package:rotafy_frontend/features/auth/email_verification/presentation/pages/email_verification_page.dart';
import 'package:rotafy_frontend/features/auth/register/presentation/pages/register_page.dart';
import 'package:rotafy_frontend/features/auth/login/presentation/pages/login_page.dart';
import 'package:rotafy_frontend/features/splash/splash_page.dart';
import 'package:rotafy_frontend/features/passenger_home/presentation/pages/passenger_home.dart';
import 'package:rotafy_frontend/features/search_rides/pages/search_rides.dart';
import 'package:flutter/material.dart';
import 'package:rotafy_frontend/core/services/auth_storage.dart';

final _authNotifier = ValueNotifier<bool>(false);

Future<void> refreshAuth() async {
  _authNotifier.value = await AuthStorage.hasToken();
}

GoRouter createRouter(bool isLoggedIn) => GoRouter(
  initialLocation: isLoggedIn ? '/passenger/home' : '/login',
  refreshListenable: _authNotifier,
  redirect: (context, state) async {
    final hasToken = await AuthStorage.hasToken();
    final isLoginPage = state.matchedLocation == '/login';

    if (!hasToken && !isLoginPage) return '/login';
    if (hasToken && isLoginPage) return '/passenger/home';
    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.extra as String;
        return VerifyEmailPage(email: email);
      },
    ),
    GoRoute(
      path: '/passenger/home',
      builder: (context, state) => const PassengerHome(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchRidesPage(),
    ),
  ],
);