import 'package:flutter/material.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/screens/checkout_screen.dart';
import 'package:footy_fix/screens/feature_manager_screens/event_adder.dart';
import 'package:footy_fix/screens/feature_manager_screens/venue_adder.dart';
import 'package:footy_fix/screens/navigation_screens/search_screen.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/screens/profile_screen.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/screens/feature_manager_screens/game_venue_manager.dart';

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
            path: 'home/:gameId',
            builder: (BuildContext context, GoRouterState state) {
              final gameId = state.pathParameters['gameId'];
              final id = int.parse(gameId!);
              return NavBar(
                gameId: id,
              );
            },
          ),
          GoRoute(
            path: 'game/:gameId',
            builder: (BuildContext context, GoRouterState state) {
              final gameId = state.pathParameters['gameId'];
              final id = int.parse(gameId!);
              return GameDescription(
                gameID: id,
              );
            },
            routes: <RouteBase>[
              // GoRoute(
              //   path: 'gamePlayers',
              //   builder: (BuildContext context, GoRouterState state) {
              //     return GameDescription(
              //       gameID: id,
              //     );
              //   },
              // ),
              GoRoute(
                path: 'checkout',
                builder: (BuildContext context, GoRouterState state) {
                  final gameId = state.pathParameters['gameId'];
                  final id = int.parse(gameId!);
                  return CheckoutScreen(
                    gameID: id,
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'payment/:price/:topUp',
                    builder: (BuildContext context, GoRouterState state) {
                      final gameId = state.pathParameters['gameId'];
                      final id = int.parse(gameId!);
                      final priceString = state.pathParameters['price'];
                      final price = double.parse(priceString!);
                      final topUpString = state.pathParameters['topUp'];
                      final topUp = topUpString?.toLowerCase() == 'true';
                      return PaymentScreen(
                        gameID: id,
                        price: price,
                        topUp: topUp,
                        label: "Game Participation Fee",
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
              path: 'venue/:venueId/:justCreated',
              builder: (BuildContext context, GoRouterState state) {
                final venueId = state.pathParameters['venueId'];
                final id = int.parse(venueId!);
                final justCreatedString =
                    state.pathParameters['justCreated']?.toLowerCase();
                final justCreated = justCreatedString == 'true';
                return LocationDescription(
                  locationID: id,
                  justCreated: justCreated,
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'upcomingGames',
                  builder: (BuildContext context, GoRouterState state) {
                    final venueId = state.pathParameters['venueId'];
                    final id = int.parse(venueId!);
                    return UpcomingGamesList(
                      venueID: id,
                    );
                  },
                ),
              ]),
          GoRoute(
              path: 'addEvent/:privateEvent',
              builder: (BuildContext context, GoRouterState state) {
                final privateEventString = state.pathParameters['privateEvent'];
                final justCreated = privateEventString?.toLowerCase() == 'true';
                return AddEvent(
                  privateEvent: justCreated,
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: ':venueId',
                  builder: (BuildContext context, GoRouterState state) {
                    final venueId = state.pathParameters['venueId'];
                    final id = int.parse(venueId!);
                    final privateEventString =
                        state.pathParameters['privateEvent'];
                    final justCreated =
                        privateEventString?.toLowerCase() == 'true';
                    return AddEvent(
                      venueId: id,
                      privateEvent: justCreated,
                    );
                  },
                ),
              ]),
          GoRoute(
            path: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginPage();
            },
          ),
          GoRoute(
              path: 'gameVenueManager',
              builder: (BuildContext context, GoRouterState state) {
                return const GameVenueManager();
              },
              routes: <RouteBase>[
                GoRoute(
                    path: 'addEvent/:privateEvent',
                    builder: (BuildContext context, GoRouterState state) {
                      final privateEventString =
                          state.pathParameters['privateEvent'];
                      final justCreated =
                          privateEventString?.toLowerCase() == 'true';
                      return AddEvent(
                        privateEvent: justCreated,
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':venueId',
                        builder: (BuildContext context, GoRouterState state) {
                          final venueId = state.pathParameters['venueId'];
                          final id = int.parse(venueId!);
                          final privateEventString =
                              state.pathParameters['privateEvent'];
                          final justCreated =
                              privateEventString?.toLowerCase() == 'true';
                          return AddEvent(
                            venueId: id,
                            privateEvent: justCreated,
                          );
                        },
                      ),
                    ]),
                GoRoute(
                  path: 'addVenue',
                  builder: (BuildContext context, GoRouterState state) {
                    return const AddVenue();
                  },
                ),
              ]),
          GoRoute(
            path: 'search',
            builder: (context, state) {
              return const SearchScreen();
            },
          ),
        ]),
  ],
  initialLocation: '/',
);
