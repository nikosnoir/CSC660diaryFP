import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'diary_entry.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'diary.db');
    return await openDatabase(
      path,
      version: 2, // version bumped for schema updates
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            date TEXT,
            emotion TEXT,
            user TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertEntry(DiaryEntry entry) async {
    final database = await db;
    await database.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getEntries(String user) async {
    final database = await db;
    final maps = await database.query(
      'entries',
      where: 'user = ?',
      whereArgs: [user],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<void> deleteEntry(String id) async {
    final database = await db;
    await database.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final database = await db;
    await database.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }
}
