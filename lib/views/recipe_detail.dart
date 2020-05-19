import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:recipes/views/recipe_detail_edit.dart';
import 'package:recipes/models/menu_list.dart';
import 'dart:io';

import 'cart_list_from_recipe.dart';

class RecipeDetail extends StatefulWidget {

	final String appBarTitle;
	final Recipe recipe;

	RecipeDetail(this.recipe, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {
    return RecipeDetailState(this.recipe, this.appBarTitle);
  }
}

class RecipeDetailState extends State<RecipeDetail> {

	DatabaseHelper helper = DatabaseHelper();

	String appBarTitle;
	Recipe recipe;
	List<Ingredient> ingredientList;
	int ingredient_count = 0;
	List<RecipeStep> stepList;
	int step_count = 0;
	File recipePhoto;

	RecipeDetailState(this.recipe, this.appBarTitle);

	@override
	Widget build(BuildContext context) {

		recipePhoto = recipe.photo_path == null ? null : File(recipe.photo_path);

		if (ingredientList == null) {
			ingredientList = List<Ingredient>();
			updateIngredientListView(recipe.id);
		}

		if (stepList == null) {
			stepList = List<RecipeStep>();
			updateStepListView(recipe.id);
		}

		return new Scaffold(
			body: new CustomScrollView(
					 slivers: <Widget>[
							SliverAppBar(
								actionsIconTheme: IconThemeData(color:Colors.white),
								expandedHeight: 300.0,
								floating: false,
								pinned: true,
								actions: <Widget>[
									PopupMenuButton<String>(
										onSelected:_select,
										itemBuilder: (BuildContext context) {
											return MenuList.choices.map((String choice){
												return PopupMenuItem<String> (
													value: choice,
													child: Text(choice)
												);
											}).toList();
										},
									)
								],
								flexibleSpace: FlexibleSpaceBar(
										centerTitle: true,
										title: Text(recipe.name,
												style: TextStyle(
													fontSize: 20.0,
												)),
										background: Hero(
											tag: "recipe-hero-${recipe.id}",
											child: recipePhoto == null
													? Stack(
												alignment: Alignment.center,
												children: <Widget>[
													Container(height: MediaQuery.of(context).size.width, width: MediaQuery.of(context).size.width, color: Color(recipe.backColor),),
													FaIcon(FontAwesomeIcons.utensils, size: 180, color: Color(0x88FFFFFF))
												],
											)
													: Image.file(recipePhoto, fit: BoxFit.cover,)
										),
								),
							),
						 SliverList(
							 delegate: SliverChildListDelegate(
								 [
								 	Container(
										//color: Color(0xFFFBF5E8),
										padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),
										child: new Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: <Widget>[
												Container(
													margin: EdgeInsets.only(top: 20),
													child: Row(
														children: <Widget>[
															Text("Descripción",
																	style: TextStyle(
																		fontFamily: 'BalooPaaji2',
																		fontSize: 18,
																		fontWeight: FontWeight.w600,
																	))
														],
													),
												), // Description
												Container(color: Theme.of(context).accentColor,width: 40, height: 6,),
												SizedBox(height: 20,),
												Container(
													margin: EdgeInsets.symmetric(vertical: 10),
													child: Text(recipe.description),
												),
												Container(
													margin: EdgeInsets.only(top: 20),
													child: Row(
													children: <Widget>[
														Text("Detalles",
														style: TextStyle(
														fontFamily: 'BalooPaaji2',
														fontSize: 18,
														fontWeight: FontWeight.w600,
														))
														],
													)
												),// Duration
												Container(color: Theme.of(context).accentColor,width: 40, height: 6,),
												SizedBox(height: 20,),
												Container(
														margin: EdgeInsets.only(top:10),
														child: Row(
																children: <Widget>[
																	FaIcon(FontAwesomeIcons.clock, size: 18, color: Colors.grey,),
																	Container(width: 8.0),
																	Text(recipe.duration.toString().split(':')[0] + 'h ' + recipe.duration.toString().split(':')[1] + 'm' ?? ''),
																	Container(width: 16.0),
																	FaIcon(FontAwesomeIcons.user, size: 18, color: Colors.grey,),
																	Container(width: 8.0),
																	Text(recipe.servings.toString()),
																]
														)
												),
												SizedBox(height: 14,),
												Row(
													children: <Widget>[
														Container(width: 2.0),
														FaIcon(FontAwesomeIcons.lightbulb, size: 20, color: Colors.grey),
														Container(width: 8.0),
														Expanded(
															child: Text(recipe.source ?? '', overflow: TextOverflow.clip),
														)
													],
												),
												Container(
													margin: EdgeInsets.only(top: 20),
													child: Row(
														children: <Widget>[
															Text("Ingredientes",
																	style: TextStyle(
																		fontFamily: 'BalooPaaji2',
																		fontSize: 18,
																		fontWeight: FontWeight.w600,
																	))
														],
													)
												),//Ingredients
												Container(color: Theme.of(context).accentColor,width: 40, height: 6,),
												getIngredientListView(),
												Container(
													margin: EdgeInsets.only(top: 20),
													child: Row(
														children: <Widget>[
															Text("Pasos",
																	style: TextStyle(
																		fontFamily: 'BalooPaaji2',
																		fontSize: 18,
																		fontWeight: FontWeight.w600,
																	))
														],
													)
												),//Steps
												Container(color: Theme.of(context).accentColor,width: 40, height: 6,),
												getStepListView(),
												Container(
														margin: EdgeInsets.only(top: 20),
														child: Row(
															children: <Widget>[
																Text("Notas",
																		style: TextStyle(
																			fontFamily: 'BalooPaaji2',
																			fontSize: 18,
																			fontWeight: FontWeight.w600,
																		))
															],
														)
												),//Ingredients
												Container(color: Theme.of(context).accentColor,width: 40, height: 6,),
												Container(
													margin: EdgeInsets.symmetric(vertical: 10),
													child: Text(recipe.notes ?? ''),
												),
											],
										),
									)
								 ]
							 ),
						 )
						]
			),
			floatingActionButton: new FloatingActionButton(
				child: FaIcon(FontAwesomeIcons.pen, size: 20,),
				onPressed: () {
					navigateToEdit(recipe, 'Editar receta');
				},
			)
		);
	}

	ListView getIngredientListView() {
		return ListView.builder(
			padding: EdgeInsets.all(0.0),
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics() ,
			itemCount: ingredient_count,
			itemBuilder: (BuildContext context, int position) {
				return IngredientRow(ingredientList[position]);
			},
		);
	}

	ListView getStepListView() {
		return ListView.builder(
			padding: EdgeInsets.symmetric(vertical: 6.0),
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics() ,
			itemCount: step_count,
			itemBuilder: (BuildContext context, int position) {
				return StepRow(stepList[position], position);
			},
		);
	}

	void _select(String choice) {
		if(choice == 'borrar'){
			_delete();
		}
		if(choice == 'Añadir al carrito'){
			_create_cart();
		}
	}

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}

	void _delete() async {

		moveToLastScreen();

		int result = await helper.deleteRecipe(recipe.id);

		if (result != 0) {
			Fluttertoast.showToast(msg: 'Receta Borrada');
		} else {
			Fluttertoast.showToast(msg: 'Problema al borrar');
		}
	}

	void _create_cart() {
		List<CartIngredient> cartList = new List();

		if (ingredient_count > 0){
			for (int i=0; i<ingredient_count; i++){
				cartList.add(CartIngredient(ingredientList[i].quantity, ingredientList[i].qty_type, ingredientList[i].name, ingredientList[i].quantity, true, false));
			}
		}
		else{
			Fluttertoast.showToast(msg: '¡No hay ingredientes!');
		}

    navigateToEditCart(cartList);
	}

  void navigateToEditCart(List<CartIngredient> cartList) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CartListRecipe(cartList);
    }));
  }

	void navigateToEdit(Recipe recipe, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return RecipeDetailEdit(recipe, title);
		}));
		if (result == true){
			updateIngredientListView(recipe.id);
			updateStepListView(recipe.id);
		}
	}

	void updateIngredientListView(int recipe_id) {

		final Future<Database> dbFuture = helper.initializeDatabase();
		dbFuture.then((database) {
			Future<List<Ingredient>> ingredientListFuture = helper.getIngredientList(recipe_id);
			ingredientListFuture.then((ingredientList) {
				setState(() {
					this.ingredientList = ingredientList;
					this.ingredient_count = ingredientList.length;
				});
			});
		});
	}

	void updateStepListView(int recipe_id) {

		final Future<Database> dbFuture = helper.initializeDatabase();
		dbFuture.then((database) {
			Future<List<RecipeStep>> stepListFuture = helper.getStepList(recipe_id);
			stepListFuture.then((stepList) {
				setState(() {
					this.stepList = stepList;
					this.step_count = stepList.length;
				});
			});
		});
	}

}

class IngredientRow extends StatelessWidget {

	final Ingredient ingredient;
	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Ingredient> ingredientList;
	int ingredient_count = 0;

	IngredientRow(this.ingredient);

	@override
	Widget build(BuildContext context) {
		return new ListTile(
			title: new Row(
				children: <Widget>[
		      new FaIcon(FontAwesomeIcons.solidCircle, color: Theme.of(context).accentColor, size: 10.0,),
					new Container(width: 8.0,),
					new Text(ingredient.quantity.toString(), style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 16.0),),
					new Container(width: 2.0,),
					new Text(ingredient.qty_type ?? ' ', style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 16.0)),
					new Container(width: 10.0,),
					new Text(ingredient.name)
				],
			)
		);
	}
}

class StepRow extends StatelessWidget {

	final RecipeStep step;
	DatabaseHelper databaseHelper = DatabaseHelper();
	List<RecipeStep> stepList;
	int step_count = 0;
	int step_order = 0;

	StepRow(this.step, this.step_order);

	@override
	Widget build(BuildContext context) {
		return new ListTile(
						leading: new Text(
							(step_order + 1).toString(),
							style: TextStyle(
									color: Theme.of(context).accentColor,
									fontWeight: FontWeight.bold,
									fontSize: 20.0
							),
						),
						title:new Text(step.description)
		);
	}
}









