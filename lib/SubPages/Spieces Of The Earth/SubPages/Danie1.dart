import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../FillPages/AppBar.dart';

class Recipe {
  int id;
  List<String> ingredients;
  String steps;

  Recipe({required this.id, required this.ingredients, required this.steps});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ingredients': ingredients.join("\n"),
      'steps': steps,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int,
      ingredients: (map['ingredients'] as String).split("\n"),
      steps: map['steps'] as String,
    );
  }
}

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

  Future<Recipe?> fetchRecipeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> recipes =
    await db.query('recipes', where: 'id = ?', whereArgs: [id]);

    if (recipes.isEmpty) {
      return null;
    }

    return Recipe.fromMap(recipes[0]);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.update('recipes', recipe.toMap(),
        where: 'id = ?', whereArgs: [recipe.id]);
  }
}

class Danie1 extends StatefulWidget {
  final String title;

  Danie1({required this.title});

  @override
  _Danie1State createState() => _Danie1State();
}

class _Danie1State extends State<Danie1> {
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController stepsController = TextEditingController();
  List<String> ingredients = [];
  String steps = '';

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    try {
      final recipe = await DatabaseHelper.instance.fetchRecipeById(1);

      if (recipe != null) {
        setState(() {
          ingredients = recipe.ingredients;
          ingredientsController.text = recipe.ingredients.join("\n");
          steps = recipe.steps;
          stepsController.text = recipe.steps;
        });
      }
    } catch (e) {
      print("Error loading recipe data: $e");
    }
  }

  Future<void> _saveRecipeData() async {
    try {
      final recipe = Recipe(id: 1, ingredients: ingredients, steps: steps);

      final existingRecipe = await DatabaseHelper.instance.fetchRecipeById(1);

      if (existingRecipe != null) {
        await DatabaseHelper.instance.updateRecipe(recipe);
      } else {
        await DatabaseHelper.instance.insertRecipe(recipe);
      }

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Recipe saved successfully!'),
        ),
      );
    } catch (e) {
      print("Error saving recipe data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX.buildAppBar(widget.title),
      body: Container(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Image.asset(
                      'assets/Splash_logo.png',
                      height: 150,
                      width: 400,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(147, 20, 130, 10),
                    child: Text(
                      "Ingredients",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: TextField(
                      controller: ingredientsController,
                      maxLines: null,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Enter ingredients here",
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          ingredients = text.split("\n");
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(135, 10, 135, 10),
                    child: Text(
                      "Step by Step",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(35, 20, 35, 20),
                    child: TextField(
                      controller: stepsController,
                      maxLines: null,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Enter step-by-step instructions here",
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.7)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          steps = text;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveRecipeData,
                    child: Text("Save Recipe"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Danie1(title: 'Your Title Here'),
    ),
  );
}
