import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:recipes/views/recipe_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeekDay extends StatefulWidget {

	final String appBarTitle;
	final List<int> recipe_ids;
	final int day_id;

	WeekDay(this.appBarTitle, this.recipe_ids, this.day_id);

	@override
  State<StatefulWidget> createState() {
    return WeekDayState(this.appBarTitle, this.recipe_ids, this.day_id);
  }
}


class WeekDayState extends State<WeekDay> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Recipe> recipeList;
	int count = 0;
	List<int> recipe_ids = List<int>();
	String appBarTitle;
	String query = '';
	int day_id;

	WeekDayState(this.appBarTitle, this.recipe_ids, this.day_id);

	@override
  Widget build(BuildContext context) {

		if (recipeList == null) {
			recipeList = List<Recipe>();
			updateListView();
		}

		SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
				statusBarColor: Theme.of(context).primaryColor
		));

    return WillPopScope(
			onWillPop: () {
				// This function executes when the navbar back button is pressed
				moveToLastScreen();
			},
			child: Scaffold(
				backgroundColor: Colors.white,
				appBar: AppBar(
					centerTitle: true,
					elevation: 1.0,
					title: Text(appBarTitle,
						style: TextStyle(fontFamily: 'Lobster', fontSize: 26),
					),
					leading: IconButton(icon: Icon(Icons.arrow_back),
							onPressed: () {
								moveToLastScreen();
							}
					),
				),
				body: getRecipeListView(),
				floatingActionButton: FloatingActionButton(
					onPressed: () async {
						final String selected = await showSearch(context: context, delegate: _search_delegate(recipeList, day_id));
						if (selected != null && selected != query) {
							setState(() {
								query = selected;
								recipe_ids.add(int.parse(selected));
							});
						}
						updateListView();
					},
					tooltip: 'Añade una receta',
					child: FaIcon(FontAwesomeIcons.plus, size: 20,),
				),
			),
		);
  }

	Widget getRecipeListView() {
		if (count == 0){
			return Center(
				child: Column(
					children: <Widget>[
						SizedBox(height: 26.0,),
						Image.asset('assets/img/empty_recipes_icon.png', scale: 4.0,),
						Text("No hay recetas todavía", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),)
					],
				),
			);
		}
		else{
			return ListView.builder(
				padding: const EdgeInsets.all(8),
				itemCount: count,
				itemBuilder: (BuildContext context, int position) {
					return Card(
						child: ListTile(
							leading: FaIcon(FontAwesomeIcons.utensilSpoon, size: 16, color: Theme.of(context).primaryColor,),
							title: Text(recipeList[position].name),
							subtitle: Text(recipeList[position].description, overflow: TextOverflow.ellipsis,),
							trailing: IconButton(
								icon: FaIcon(FontAwesomeIcons.trash, size: 16, color: Theme.of(context).accentColor,),
								onPressed: () {
									_deleteRecipe(day_id, recipeList[position].id);
								},
							),
							onTap: () {
								navigateToDetail(recipeList[position], recipeList[position].name);
							},
						),
					);
					//return RecipeRow(recipeList[position]);
				},
			);
		}
	}

	void updateListView() {
		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {
			Future<List<Recipe>> recipeListFuture = databaseHelper.getRecipeListById(this.recipe_ids);
			recipeListFuture.then((recipeList) {
				setState(() {
					this.recipeList = recipeList;
					this.count = recipeList.length;
				});
			});
		});
	}

	void navigateToDetail(Recipe recipe, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return RecipeDetail(recipe, title);
		}));

		if (result == true) {
			updateListView();
		}
	}


	void _deleteRecipe(int day, int recipe) async {

		int result = await databaseHelper.deleteDayRecipe(day, recipe);

		if (result != 0) {
			recipe_ids.remove(recipe);
			Fluttertoast.showToast(msg: 'Receta Borrada');
		} else {
			Fluttertoast.showToast(msg: 'Problema al borrar');
		}
		updateListView();
	}

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}
}

class _search_delegate extends SearchDelegate<String> {

	DatabaseHelper databaseHelper = DatabaseHelper();

	List<Recipe> recipeList;
	int day_id;

	_search_delegate(this.recipeList, this.day_id);

	@override
	ThemeData appBarTheme(BuildContext context) {
		return ThemeData(
			primaryColor: Color(0xFFFFC078),
			accentIconTheme: IconThemeData(color: Colors.white),
			primaryIconTheme: IconThemeData(color: Colors.white),
			textTheme: TextTheme(
				title: TextStyle(
						color: Color(0xFFFBF5E8)
				),
			),
			primaryTextTheme: TextTheme(
				title: TextStyle(
						color: Color(0xFFFBF5E8)
				),
			),
		);
	}

	@override
	String get searchFieldLabel => "Busca una receta";

	@override
	List<Widget> buildActions(BuildContext context) {
		return <Widget>[
			IconButton(
				tooltip: 'Borrar',
				icon: const Icon((Icons.clear)),
				onPressed: () {
					query = '';
					showSuggestions(context);
				},
			)
		];
	}

	@override
	Widget buildLeading(BuildContext context) {
		return IconButton(
			icon: AnimatedIcon(
					icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
			onPressed: () {
				close(context, null);
			},
		);
	}

	@override
	Widget buildResults(BuildContext context) {
		Future<List<Recipe>> recipeListFuture = databaseHelper.getRecipeListFiltered(query);
		recipeListFuture.then((recipeList) {
			this.recipeList = recipeList;
		});
		return ListView.builder(
				itemCount: recipeList.length,
				itemBuilder: (BuildContext context, int index) {
					return new ListTile(
						leading: FaIcon(FontAwesomeIcons.utensilSpoon, size: 16, color: Theme.of(context).accentColor,),
						title: Text(recipeList[index].name),
						onTap: () async {
							databaseHelper.insertRecipeToDay(day_id.toString(),0.toString(),recipeList[index].id.toString());
							close(context, recipeList[index].id.toString());
						},
					);
				});
	}

	@override
	Widget buildSuggestions(BuildContext context) {
		Future<List<Recipe>> recipeListFuture = databaseHelper.getRecipeListFiltered(query);
		recipeListFuture.then((recipeList) {
			this.recipeList = recipeList;
		});
		return ListView.builder(
				itemCount: recipeList.length,
				itemBuilder: (BuildContext context, int index) {
					return new ListTile(
						leading: FaIcon(FontAwesomeIcons.utensilSpoon, size: 16, color: Theme.of(context).accentColor,),
						title: Text(recipeList[index].name),
						onTap: () async {
							databaseHelper.insertRecipeToDay(day_id.toString(),0.toString(),recipeList[index].id.toString());
							close(context, recipeList[index].id.toString());
						},
					);
				});
	}
}
