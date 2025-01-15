import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'tournaments.db');
  return await openDatabase(
    path,
    version: 1, // Keep version as 1
    onCreate: (db, version) async {
      await db.execute(
        '''
        CREATE TABLE tournaments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tournamentId TEXT UNIQUE,
          name TEXT,
          prizePool REAL,
          entryFee REAL,
          startTime TEXT,
          numPlayers INTEGER,
          maxPlayers INTEGER
        )
        ''',
      );
      await db.execute(
        '''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL,
          type TEXT,
          date TEXT
        )
        ''',
      );
      // Create profile table 
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS profile (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imagePath TEXT
        )
        ''',
      );
    },
  );
}
  // Insert a transaction
  Future<void> insertTransaction(double amount, String type) async {
    final db = await database;
    await db.insert(
      'transactions',
      {'amount': amount, 'type': type, 'date': DateTime.now().toIso8601String()},
    );
  }

  // Fetch all transactions
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  // Insert tournament data
  Future<void> insertTournament(Map<String, dynamic> tournament) async {
    final db = await database;
    await db.insert(
      'tournaments',
      {
        'tournamentId': tournament['tournamentId'],
        'name': tournament['tournamentName'] ?? 'Unknown Tournament',
        'prizePool': tournament['prizePool'] ?? 0,
        'entryFee': tournament['entryAmount'] ?? 0,
        'startTime': tournament['startTime']?.toDate().toIso8601String() ?? '',
        'numPlayers': tournament['numPlayers'] ?? 0,
        'maxPlayers': tournament['maxPlayers'] ?? 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all tournaments
  Future<List<Map<String, dynamic>>> fetchTournaments() async {
    final db = await database;
    return await db.query('tournaments', orderBy: 'startTime ASC');
  }

  // Delete a tournament by ID
  Future<void> deleteTournament(String tournamentId) async {
    final db = await database;
    await db.delete(
      'tournaments',
      where: 'tournamentId = ?',
      whereArgs: [tournamentId],
    );
  }

  // Clear all tournaments
  Future<void> clearTournaments() async {
    final db = await database;
    await db.delete('tournaments');
  }

 // Insert the profile image path into the database
Future<void> insertProfileImage(String imagePath) async {
  final db = await database;
  await db.insert(
    'profile',
    {'imagePath': imagePath},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Fetch the latest profile image path from the database
Future<String?> fetchProfileImage() async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'profile',
    limit: 1,
    orderBy: 'id DESC', // Get the most recent image path
  );
  return result.isNotEmpty ? result.first['imagePath'] as String : null;
}

}