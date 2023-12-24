import 'package:postgres/postgres.dart';

class PostgresService {
  late Connection connection;

  static final PostgresService _instance = PostgresService._internal();

  factory PostgresService() {
    return _instance;
  }

  PostgresService._internal();

  Future<void> initDatabase() async {
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
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    if (connection.isOpen == false) {
      initDatabase();
    }

    final columns = data.keys.join(', ');
    final values =
        data.values.map((e) => e is String ? "'$e'" : e.toString()).join(', ');

    final query = 'INSERT INTO $table ($columns) VALUES ($values)';
    await connection.execute(query);
  }

  Future<void> update(
      String table, Map<String, dynamic> data, String whereClause) async {
    final updates = data.entries
        .map(
            (e) => "${e.key} = ${e.value is String ? "'${e.value}'" : e.value}")
        .join(', ');

    final query = 'UPDATE $table SET $updates WHERE $whereClause';
    await connection.execute(query);
  }

  Future<void> delete(String table, String whereClause) async {
    final query = 'DELETE FROM $table WHERE $whereClause';
    await connection.execute(query);
  }

  Future<Result> retrieveMultiple(
      String table, String coloumn, String whereClause) async {
    final query = 'SELECT $coloumn FROM $table WHERE $whereClause';
    var result = await connection.execute(query);
    return result;
  }

  Future<Result> retrieveRows(String table, String coloumns) async {
    final query = 'SELECT $coloumns FROM $table';
    print(query);
    var result = await connection.execute(query);
    return result;
  }

  Future<Result> retrieveSingle(
      String table, String coloumn, String row, String whereClause) async {
    final query = "SELECT $coloumn FROM $table WHERE $row = '$whereClause'";
    print(query);
    var result = await connection.execute(query);
    return result;
  }

  Future<void> executeQuery(String query) async {
    await connection.execute(query);
  }

  Future<Result> retrieve(String query) {
    if (connection.isOpen == false) {
      initDatabase();
    }

    return connection.execute(query);
  }

  Future<void> increment(
      String table, String column, String whereClause, int incrementBy) async {
    final query =
        'UPDATE $table SET $column = $column + $incrementBy WHERE $whereClause';
    await connection.execute(query);
  }

  void closeConnection() {
    print('Closing connection');
    connection.close();
  }
}
