import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes/models/photo_colors.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:recipes/views/recipe_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/views/recipe_detail_edit.dart';
import 'package:recipes/views/cart_list.dart';
import 'recipe_row.dart';
import "dart:math";


class RecipeList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {
    return RecipeListState();
  }
}


class RecipeListState extends State<RecipeList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Recipe> recipeList;
	int count = 0;
	String query = '';

	@override
  Widget build(BuildContext context) {

		if (recipeList == null) {
			recipeList = List<Recipe>();
			updateListView();
		}

		SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
				statusBarColor: Theme.of(context).primaryColor
		));

    return Scaffold(
			backgroundColor: Colors.white,

	    appBar: AppBar(
				centerTitle: true,
		    elevation: 1.0,
		    title: Text('Recetas',
										style: TextStyle(fontFamily: 'Lobster',
																			fontSize: 30),
				),
				actions: <Widget>[
					IconButton(
						icon: FaIcon(FontAwesomeIcons.search, size: 16,),
						onPressed: () async {
							final String selected = await showSearch(context: context, delegate: _search_delegate(recipeList));
							if (selected != null && selected != query) {
								setState(() {
									query = selected;
								});
							}
						},
					)
				],
	    ),

	    body: getRecipeListView(),

			bottomNavigationBar: BottomAppBar(
					child: new Row(
						mainAxisSize: MainAxisSize.max,
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							SizedBox(width:6),

							IconButton(
								icon:FaIcon(
									FontAwesomeIcons.shoppingCart,
									size: 20.0,
									color: Colors.black26,
								),
								onPressed: () {
									navigateToCart();
								},
							),

							SizedBox(width:40),

							IconButton(
								icon: FaIcon(
									FontAwesomeIcons.tag,
									size: 20.0,
									color: Colors.black26,
								),
								onPressed: () {
									Fluttertoast.showToast(msg: 'Coming soon');
								},
							),

							SizedBox(width:6),
						],
					),
					//color: Theme.of(context).primaryColor,
					color: Colors.white,
					shape: CircularNotchedRectangle(),
				),

			floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
	    floatingActionButton: FloatingActionButton(
		    onPressed: () {
					navigateToAddNew(Recipe('', '', Duration(minutes:30), 1, null, '', '', null, PhotoColors.colors[new Random().nextInt(PhotoColors.colors.length)]), 'Nueva Receta');
		    },
		    tooltip: 'Añade una receta',
		    child: FaIcon(FontAwesomeIcons.utensils, size: 20,),
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
				itemCount: count,
				itemBuilder: (BuildContext context, int position) {
					return RecipeRow(recipeList[position]);
				},
			);
		}
  }

	void _delete(BuildContext context, Recipe recipe) async {
		int result = await databaseHelper.deleteRecipe(recipe.id);
		if (result != 0) {
			Fluttertoast.showToast(msg: 'Receta Borrada');
			updateListView();
		}
	}

  void navigateToDetail(Recipe recipe, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return RecipeDetail(recipe, title);
	  }));
	  if (result == true) {
	  	updateListView();
	  }
  }

	void navigateToCart() async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return CartList();
		}));
		if (result == true) {
			updateListView();
		}
	}

	void navigateToAddNew(Recipe recipe, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return RecipeDetailEdit(recipe, title);
		}));
		if (result == true) {
			updateListView();
		}
	}

  void updateListView() {
		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {
			Future<List<Recipe>> recipeListFuture = databaseHelper.getRecipeList();
			recipeListFuture.then((recipeList) {
				setState(() {
				  this.recipeList = recipeList;
				  this.count = recipeList.length;
				});
			});
		});
  }
}


class _search_delegate extends SearchDelegate<String> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Recipe> recipeList;

	_search_delegate(this.recipeList);

	@override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
			primaryColor: Color(0xFFFDB35D),
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
					return RecipeRow(recipeList[index]);
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
						leading: FaIcon(FontAwesomeIcons.utensilSpoon, size: 16, color: Theme.of(context).primaryColor,),
						title: Text(recipeList[index].name),
						onTap: () async {
							close(context, recipeList[index].name);
							bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
								return RecipeDetail(recipeList[index], recipeList[index].name);
							}));
						},
					);
				});
  }
}







