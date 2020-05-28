import 'package:recipes/models/catalogs.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:recipes/models/recipe.dart';

class DatabaseHelper {

	static DatabaseHelper _databaseHelper;
	static Database _database;

	String recipeTable = 'recipe_table';
	String ingredientTable = 'ingredient_table';
	String stepTable = 'step_table';
	String categoryTable = 'category_table';
	String cartTable = 'cart_table';

	String colId = 'id';
	String colTitle = 'title';
	String colDescription = 'description';
	String colDuration = 'duration';
	String colServings = 'servings';
	String colCategory = 'category_id';
	String colSource = 'source';
	String colNotes = 'notes';
	String colDate = 'date';
	String colPhoto = 'photo_path';

	String recipePhotosDir = 'recipes_photos';

	DatabaseHelper._createInstance();

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance();
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path where database will be created
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'recipes.db';

		// Open/create the database at a given path
		var recipesDatabase = await openDatabase(path,
				version: 3,
				onCreate: _createDb,
				onUpgrade: _upgradeDb // Here we can compare the version installed with the new version and
												// create the necessary things to match the new database
		);
		return recipesDatabase;
	}

	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $recipeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
				'$colDescription TEXT, $colDuration INTEGER, $colDate TEXT, $colServings INTEGER, $colCategory INTEGER, '
				'$colSource TEXT, $colNotes TEXT, $colPhoto TEXT, background_color INTEGER, calories INTEGER, '
				'FOREIGN KEY($colCategory) REFERENCES $categoryTable(id)'
				'ON DELETE CASCADE)');

		await db.execute('CREATE TABLE $ingredientTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, recipe_id INTEGER, '
				'quantity REAL, qty_type TEXT, name TEXT, '
				'FOREIGN KEY(recipe_id) REFERENCES $recipeTable(id)'
				'ON DELETE CASCADE)');

		await db.execute('CREATE TABLE $stepTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, recipe_id INTEGER, '
				'description TEXT, '
				'FOREIGN KEY(recipe_id) REFERENCES $recipeTable(id)'
				'ON DELETE CASCADE)');

		await db.execute('CREATE TABLE $categoryTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
				'name TEXT, '
				'color TEXT, icon TEXT)');

		await db.execute('CREATE TABLE $cartTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
				'qty REAL, qty_type TEXT, name TEXT, add_cart INTEGER, original_qty REAL, done INTEGER)');

		await db.execute('CREATE TABLE days_catalog($colId INTEGER PRIMARY KEY, '
				'name_en TEXT, name_es TEXT, name_it TEXT)');

		// I'm sure that there is a better way to do this
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (1,"Lunes", "Monday", "Lunedì")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (2,"Martes", "Tuesday", "Martedí")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (3,"Miércoles", "Wednesday", "Mercoledì")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (4,"Jueves", "Thursday", "Giovedì")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (5,"Viernes", "Friday", "Venerdì")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (6,"Sábado", "Saturday", "Sabato")');
		await db.execute('INSERT INTO days_catalog (id, name_en, name_es, name_it) VALUES (7,"Domingo", "Sunday", "Domenica")');

		await db.execute('CREATE TABLE menus_catalog($colId INTEGER PRIMARY KEY, '
				'name_en TEXT, name_es TEXT, name_it TEXT)');

		await db.execute('INSERT INTO menus_catalog (id, name_es, name_en, name_it) VALUES (1,"Desayunp", "Breakfast", "Colazione")');
		await db.execute('INSERT INTO menus_catalog (id, name_es, name_en, name_it) VALUES (2,"Almuerzo", " ", " ")');
		await db.execute('INSERT INTO menus_catalog (id, name_es, name_en, name_it) VALUES (3,"Comida", "Launch", "Pranzo")');
		await db.execute('INSERT INTO menus_catalog (id, name_es, name_en, name_it) VALUES (4,"Merienda", " ", " ")');
		await db.execute('INSERT INTO menus_catalog (id, name_es, name_en, name_it) VALUES (5,"Cena", "Dinner", "Cena")');

		// We also create here the directory where the images will be stored //Not used for now
		Directory appDocDir = await getApplicationDocumentsDirectory();
		new Directory(appDocDir.path+'/'+recipePhotosDir).create()
				.then((Directory directory) {});
	}

	void _upgradeDb(Database db, int oldVersion, int newVersion) async {
		if (newVersion == 3){
			await db.execute('ALTER TABLE $recipeTable ADD COLUMN calories INTEGER');

			// I'm sure that there is a better way to do this
			await db.execute('CREATE TABLE days_catalog($colId INTEGER PRIMARY KEY, '
					'name_en TEXT, name_es TEXT, name_it TEXT)');

			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (1,"Lunes", "Monday", "Lunedì")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (2,"Martes", "Tuesday", "Martedí")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (3,"Miércoles", "Wednesday", "Mercoledì")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (4,"Jueves", "Thursday", "Giovedì")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (5,"Viernes", "Friday", "Venerdì")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (6,"Sábado", "Saturday", "Sabato")');
			await db.execute('INSERT INTO days_catalog (id, name_es, name_en, name_it) VALUES (7,"Domingo", "Sunday", "Domenica")');

			await db.execute('CREATE TABLE meals_catalog($colId INTEGER PRIMARY KEY, '
					'name_en TEXT, name_es TEXT, name_it TEXT)');

			await db.execute('INSERT INTO meals_catalog (id, name_es, name_en, name_it) VALUES (1,"Desayunp", "Breakfast", "Colazione")');
			await db.execute('INSERT INTO meals_catalog (id, name_es, name_en, name_it) VALUES (2,"Almuerzo", " ", " ")');
			await db.execute('INSERT INTO meals_catalog (id, name_es, name_en, name_it) VALUES (3,"Comida", "Launch", "Pranzo")');
			await db.execute('INSERT INTO meals_catalog (id, name_es, name_en, name_it) VALUES (4,"Merienda", " ", " ")');
			await db.execute('INSERT INTO meals_catalog (id, name_es, name_en, name_it) VALUES (5,"Cena", "Dinner", "Cena")');
		}
	}

	// -- Recipes Operations --

	Future<List<Map<String, dynamic>>> getRecipeMapList() async {
		Database db = await this.database;
		var result = await db.query(recipeTable, orderBy: 'id ASC');
		return result;
	}

	Future<List<Map<String, dynamic>>> getRecipeMapListFiltered(String filter) async {
		Database db = await this.database;
		var result = await db.query(recipeTable, where: 'title like "%$filter%"', orderBy: 'id ASC');
		return result;
	}

	Future<int> insertRecipe(Recipe recipe) async {
		Database db = await this.database;
		var result = await db.insert(recipeTable, recipe.toMap());
		return result;
	}

	Future<int> updateRecipe(Recipe recipe) async {
		var db = await this.database;
		var result = await db.update(recipeTable, recipe.toMap(), where: '$colId = ?', whereArgs: [recipe.id]);
		return result;
	}

	Future<int> deleteRecipe(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $recipeTable WHERE $colId = $id');
		return result;
	}

	Future<int> getRecipesCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (id) from $recipeTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	Future<List<Recipe>> getRecipeList() async {
		var recipeMapList = await getRecipeMapList();
		int count = recipeMapList.length;
		List<Recipe> recipeList = List<Recipe>();
		for (int i = 0; i < count; i++) {
			recipeList.add(Recipe.fromMapObject(recipeMapList[i]));
		}
		return recipeList;
	}

	Future<List<Recipe>> getRecipeListFiltered(String filter) async {
		var recipeMapList = await getRecipeMapListFiltered(filter);
		int count = recipeMapList.length;
		List<Recipe> recipeList = List<Recipe>();
		for (int i = 0; i < count; i++) {
			recipeList.add(Recipe.fromMapObject(recipeMapList[i]));
		}
		return recipeList;
	}

	// -- Ingredients Operations --

	Future<List<Map<String, dynamic>>> getIngredientMapList(int recipe) async {
		Database db = await this.database;
		var where = recipe == null ? "recipe_id is null" : "recipe_id = " + recipe.toString();
		var result = await db.query(ingredientTable, where: where, orderBy: 'id ASC');
		return result;
	}

	Future<List<Ingredient>> getIngredientList(int recipe) async {
		var ingredientMapList = await getIngredientMapList(recipe);
		int count = ingredientMapList.length;
		List<Ingredient> ingredientList = List<Ingredient>();
		for (int i = 0; i < count; i++) {
			ingredientList.add(Ingredient.fromMapObject(ingredientMapList[i]));
		}
		return ingredientList;
	}

	Future<int> insertIngredient(Ingredient ingredient) async {
		Database db = await this.database;
		var result = await db.insert(ingredientTable, ingredient.toMap());
		return result;
	}

	Future<int> updateIngredient(Ingredient ingredient) async {
		var db = await this.database;
		var result = await db.update(ingredientTable, ingredient.toMap(), where: '$colId = ?', whereArgs: [ingredient.id]);
		return result;
	}

	Future<int> deleteIngredient(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $ingredientTable WHERE $colId = $id');
		return result;
	}

	// -- Steps Operations --

	Future<List<Map<String, dynamic>>> getStepMapList(int recipe) async {
		Database db = await this.database;
		var where = recipe == null ? "recipe_id is null" : "recipe_id = " + recipe.toString();
		var result = await db.query(stepTable, where: where, orderBy: 'id ASC');
		return result;
	}

	Future<List<RecipeStep>> getStepList(int recipe) async {
		var stepMapList = await getStepMapList(recipe);
		int count = stepMapList.length;
		List<RecipeStep> stepList = List<RecipeStep>();
		for (int i = 0; i < count; i++) {
			stepList.add(RecipeStep.fromMapObject(stepMapList[i]));
		}
		return stepList;
	}

	Future<int> insertStep(RecipeStep step) async {
		Database db = await this.database;
		var result = await db.insert(stepTable, step.toMap());
		return result;
	}

	Future<int> updateStep(RecipeStep step) async {
		var db = await this.database;
		var result = await db.update(stepTable, step.toMap(), where: '$colId = ?', whereArgs: [step.id]);
		return result;
	}

	Future<int> deleteStep(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $stepTable WHERE $colId = $id');
		return result;
	}

	// -- Category Operations --

	Future<List<Map<String, dynamic>>> getCategoryMapList() async {
		Database db = await this.database;
		var result = await db.query(categoryTable, orderBy: 'id ASC');
		return result;
	}

	Future<List<Category>> getCategoryList() async {
		var categoryMapList = await getCategoryMapList();
		int count = categoryMapList.length;
		List<Category> categoryList = List<Category>();
		for (int i = 0; i < count; i++) {
			categoryList.add(Category.fromMapObject(categoryMapList[i]));
		}
		return categoryList;
	}

	Future<int> insertCategory(Category category) async {
		Database db = await this.database;
		var result = await db.insert(categoryTable, category.toMap());
		return result;
	}

	Future<int> updateCategory(Category category) async {
		var db = await this.database;
		var result = await db.update(categoryTable, category.toMap(), where: '$colId = ?', whereArgs: [category.id]);
		return result;
	}

	Future<int> deleteCategory(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $categoryTable WHERE $colId = $id');
		return result;
	}

	// -- Cart Ingredients Operations --

	Future<List<Map<String, dynamic>>> getCartMapList() async {
		Database db = await this.database;
		var result = await db.query(cartTable, orderBy: 'id ASC');
		return result;
	}

	Future<List<CartIngredient>> getCartList() async {
		var ingredientMapList = await getCartMapList();
		int count = ingredientMapList.length;
		List<CartIngredient> ingredientList = List<CartIngredient>();
		for (int i = 0; i < count; i++) {
			ingredientList.add(CartIngredient.fromMapObject(ingredientMapList[i]));
		}
		return ingredientList;
	}

	Future<int> insertCartIngredient(CartIngredient ingredient) async {
		Database db = await this.database;
		var result = await db.insert(cartTable, ingredient.toMap());
		return result;
	}

	Future<int> updateCartIngredient(CartIngredient ingredient) async {
		var db = await this.database;
		var result = await db.update(cartTable, ingredient.toMap(), where: '$colId = ?', whereArgs: [ingredient.id]);
		return result;
	}

	Future<int> deleteCartIngredient(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $cartTable WHERE $colId = $id');
		return result;
	}

	// -- Days operations --

	Future<List<Map<String, dynamic>>> getDaysMapList() async {
		Database db = await this.database;
		var result = await db.query('days_catalog', orderBy: 'id ASC');
		return result;
	}

	Future<List<Days>> getDaysList() async {
		var daysMapList = await getDaysMapList();
		int count = daysMapList.length;
		List<Days> daysList = List<Days>();
		for (int i = 0; i < count; i++) {
			daysList.add(Days.fromMapObject(daysMapList[i]));
		}
		return daysList;
	}

	// -- Meals operations

	Future<List<Map<String, dynamic>>> getMealsMapList() async {
		Database db = await this.database;
		var result = await db.query('meals_catalog', orderBy: 'id ASC');
		return result;
	}

	Future<List<Meals>> getMealsList() async {
		var mealsMapList = await getMealsMapList();
		int count = mealsMapList.length;
		List<Meals> mealsList = List<Meals>();
		for (int i = 0; i < count; i++) {
			mealsList.add(Meals.fromMapObject(mealsMapList[i]));
		}
		return mealsList;
	}


}







