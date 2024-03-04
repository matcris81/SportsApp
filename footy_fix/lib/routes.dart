import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:go_router/go_router.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:footy_fix/descriptions/game_description.dart';

final GoRouter appRoutes = GoRouter(
  debugLogDiagnostics: true,
  routes: <RouteBase>[
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
          GoRoute(
            path: 'venue/:venueId',
            builder: (BuildContext context, GoRouterState state) {
              final venueId = state.pathParameters['venueId'];
              final id = int.parse(venueId!);
              return LocationDescription(
                locationID: id,
              );
            },
          ),
        ]),
  ],
);
