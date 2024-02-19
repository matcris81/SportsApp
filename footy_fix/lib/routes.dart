import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:footy_fix/screens/navigation_screens/home_screen.dart';
import 'package:footy_fix/descriptions/game_description.dart';

final GoRouter appRoutes = GoRouter(
  routes: <RouteBase>[
    // Define the default or "home" route.
    GoRoute(
        path: '/',
        builder: (context, state) {
          return const AuthPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'game/:gameId',
            builder: (BuildContext context, GoRouterState state) {
              final gameId = state.pathParameters['gameId'];
              final id = int.parse(gameId!);
              return GameDescription(
                gameID: id,
              );
            },
          ),
        ]),
  ],
);
