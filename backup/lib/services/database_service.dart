import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/apod_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'astroview.db');
      print('Database path: $path');
      
      // Delete old database if it exists
      await deleteDatabase(path);
      
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          date TEXT NOT NULL UNIQUE,
          explanation TEXT NOT NULL,
          url TEXT NOT NULL,
          hdUrl TEXT,
          copyright TEXT,
          addedDate TEXT NOT NULL
        )
      ''');
      print('✅ Database tables created successfully');
    } catch (e) {
      print('❌ Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> addFavorite(ApodImage image) async {
    try {
      final db = await database;
      await db.insert(
        'favorites',
        {
          'title': image.title,
          'date': image.date,
          'explanation': image.explanation,
          'url': image.url,
          'hdUrl': image.hdUrl,
          'copyright': image.copyright,
          'addedDate': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Favorite added: ${image.title}');
    } catch (e) {
      print('❌ Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String date) async {
    try {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'date = ?',
        whereArgs: [date],
      );
      print('✅ Favorite removed: $date');
    } catch (e) {
      print('❌ Error removing favorite: $e');
      rethrow;
    }
  }

  Future<List<ApodImage>> getFavorites() async {
    try {
      final db = await database;
      final maps = await db.query('favorites', orderBy: 'addedDate DESC');
      print('✅ Retrieved ${maps.length} favorites from database');
      return List.generate(maps.length, (i) => ApodImage.fromJson(maps[i]));
    } catch (e) {
      print('❌ Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String date) async {
    try {
      final db = await database;
      final result = await db.query(
        'favorites',
        where: 'date = ?',
        whereArgs: [date],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Error checking favorite: $e');
      return false;
    }
  }
}