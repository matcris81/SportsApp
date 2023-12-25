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
          host: '192.168.3.11',
          database: 'football_fix',
          username: 'mat',
          password: 'pass',
        ),
        // The postgres server hosted locally doesn't have SSL by default. If you're
        // accessing a postgres server over the Internet, the server should support
        // SSL and you should swap out the mode with `SslMode.verifyFull`.
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );

      print('Connected to the db');
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
    print(query);
    await connection!.execute(query);
  }

  Future<void> executeQuery(String query) async {
    checkConnection();
    print(query);
    await connection!.execute(query);
  }

  Future<Result> retrieve(String query) async {
    checkConnection();
    print(query);

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
