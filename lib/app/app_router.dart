import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/home/presentation/walk_home_page.dart';
import '../features/results/presentation/results_page.dart';

class RouteNames {
  static const login = 'login';
  static const signup = 'signup';
  static const walkHome = 'walkHome';
  static const results = 'results';
}

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: RouteNames.signup,
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/walkHome/:userId',
      name: RouteNames.walkHome,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return WalkHomePage(userId: userId);
      },
    ),
    GoRoute(
      path: '/results',
      name: RouteNames.results,
      builder: (context, state) => const ResultsPage(),
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page not found')),
  ),
);
