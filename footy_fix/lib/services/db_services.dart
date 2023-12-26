import 'package:postgres/postgres.dart';
import 'dart:io';

class PostgresService {
  Connection? connection;

  static final PostgresService _instance = PostgresService._internal();

  factory PostgresService() {
    return _instance;
  }

  PostgresService._internal();

  Future<void> initDatabase() async {
    try {
      connection = await Connection.open(
        Endpoint(
          host: 'postgres-1.clymy8qkkowx.ap-southeast-2.rds.amazonaws.com',
          database: 'postgres',
          username: 'postgres',
          password: 'Lewandowski9',
        ),
        // The postgres server hosted locally doesn't have SSL by default. If you're
        // accessing a postgres server over the Internet, the server should support
        // SSL and you should swap out the mode with `SslMode.verifyFull`.
        settings: const ConnectionSettings(sslMode: SslMode.require),
      );

      print('Connected to the db');

      connection!.execute(
          "CREATE TABLE games (game_id SERIAL PRIMARY KEY, venue_id INTEGER, sport_id INTEGER, "
          "game_date DATE NOT NULL, start_time TIME WITHOUT TIME ZONE NOT NULL, description VARCHAR(255), "
          "max_players INTEGER NOT NULL, current_players INTEGER DEFAULT 0, price DOUBLE PRECISION)");

      connection!.execute(
          "CREATE TABLE sports (sport_id SERIAL PRIMARY KEY, name VARCHAR(255))");

      connection!.execute(
          "CREATE TABLE users (user_id VARCHAR PRIMARY KEY, username VARCHAR(255), email VARCHAR(255), sport_id INTEGER, venue_id INTEGER)");

      connection!.execute(
          "CREATE TABLE user_game_participation (participation_id SERIAL PRIMARY KEY, user_id VARCHAR, game_id INTEGER, status VARCHAR(255))");

      connection!.execute(
          "CREATE TABLE user_likes (user_id VARCHAR NOT NULL, likeable_id INTEGER NOT NULL, likeable_type VARCHAR NOT NULL)");

      connection!.execute(
          "CREATE TABLE venues (venue_id SERIAL PRIMARY KEY, name VARCHAR(255), address VARCHAR(255), description TEXT)");
    } on SocketException catch (e) {
      // Handle network-related issues here
      print('Network error: $e');
      // Possibly alert the user or handle the situation appropriately
    } catch (e) {
      print('Error connecting to the db: $e');
    }
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    checkConnection();

    final columns = data.keys.join(', ');
    final values =
        data.values.map((e) => e is String ? "'$e'" : e.toString()).join(', ');

    final query = 'INSERT INTO $table ($columns) VALUES ($values)';
    await connection!.execute(query);
  }

  Future<void> executeQuery(String query) async {
    checkConnection();
    await connection!.execute(query);
  }

  Future<Result> retrieve(String query) async {
    checkConnection();

    return await connection!.execute(query);
  }

  Future<void> increment(
      String table, String column, String whereClause, int incrementBy) async {
    checkConnection();

    final query =
        'UPDATE $table SET $column = $column + $incrementBy WHERE $whereClause';
    await connection!.execute(query);
  }

  void closeConnection() {
    print('Closing connection');
    connection!.close();
  }

  void checkConnection() async {
    if (connection == null || !connection!.isOpen) {
      await initDatabase();
      if (connection == null) {
        // Handle the error: connection couldn't be established
        throw Exception('Database connection could not be established');
      }
    }

    if (connection?.isOpen == false) {
      await initDatabase();
    }
  }
}
