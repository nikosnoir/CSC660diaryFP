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
      version: 3, // 🔼 bump version to trigger upgrade
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
            updatedAt TEXT,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE entries ADD COLUMN isFavorite INTEGER DEFAULT 0");
        }
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

  Future<void> toggleFavorite(String id, bool isFav) async {
    final database = await db;
    await database.update(
      'entries',
      {'isFavorite': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
