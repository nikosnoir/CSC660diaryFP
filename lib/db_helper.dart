import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'diary_entry.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE entries(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            date TEXT,
            emotion TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertEntry(DiaryEntry entry) async {
    final db = await database;
    await db.insert('entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateEntry(DiaryEntry entry) async {
    final db = await database;
    await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<DiaryEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entries');
    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }
}
