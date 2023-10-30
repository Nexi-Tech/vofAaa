import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Danie1.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  static const String dbName = 'dbDanie1.db';

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY,
            ingredients TEXT,
            steps TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertRecipe(Recipe recipe) async {
    final db = await database;
    await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> fetchRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> recipes = await db.query('recipes');
    return recipes.map((recipeMap) => Recipe.fromMap(recipeMap)).toList();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}
