import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_model.dart';

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
    final String path = join(await getDatabasesPath(), 'password_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Créer la table utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Créer la table mots de passe
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        website TEXT,
        notes TEXT,
        category TEXT,
        created_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Méthodes pour les utilisateurs
  Future<int> insertUser(String email, String password) async {
    Database db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
    });
  }

  Future<bool> authenticateUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // Méthodes pour les mots de passe
  Future<int> insertPassword(PasswordModel password) async {
    Database db = await database;
    return await db.insert('passwords', password.toMap());
  }

  Future<int> updatePassword(PasswordModel password) async {
    Database db = await database;
    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<int> deletePassword(int id) async {
    Database db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PasswordModel>> getAllPasswords() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('passwords');
    return result.map((item) => PasswordModel.fromMap(item)).toList();
  }

  Future<PasswordModel?> getPasswordById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return PasswordModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<PasswordModel>> searchPasswords(String query) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'passwords',
      where: 'title LIKE ? OR username LIKE ? OR website LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((item) => PasswordModel.fromMap(item)).toList();
  }

  Future<List<String>> getCategories() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT category FROM passwords WHERE category IS NOT NULL AND category != ""'
    );
    return result.map((item) => item['category'] as String).toList();
  }
}