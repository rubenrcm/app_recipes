import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:recipes/views/recipe_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/views/cart_list.dart';


class WeekList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {
    return WeekListState();
  }
}


class WeekListState extends State<WeekList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Recipe> recipeList;
	int count = 0;
	String query = '';
	List<String> weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes','Sábado', 'Domingo'];

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
		    title: Text('Semana',
										style: TextStyle(fontFamily: 'Lobster',
																			fontSize: 30),
				),
				leading: IconButton(icon: Icon(Icons.arrow_back),
						onPressed: () {
							moveToLastScreen();
						}
				),
	    ),

	    body: getWeekDaysView(),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
				},
				tooltip: 'Añade la compra de la semana',
				child: FaIcon(FontAwesomeIcons.shoppingCart, size: 20,),
			),

    );
  }

  Widget getWeekDaysView() {
		return ListView(
			scrollDirection: Axis.horizontal,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				dayCard(weekDays[0], 0xFFe94714, 0xFFda8859),
				dayCard(weekDays[1], 0xFF92d56e, 0xFFcde345),
				dayCard(weekDays[2], 0xFFa06bb9, 0xFFde6a9a),
				dayCard(weekDays[3], 0xFF319fdd, 0xFF59d1d9),
				dayCard(weekDays[4], 0xFFe2991d, 0xFFeece5b),
				dayCard(weekDays[5], 0xFF32cd9a, 0xFF5bee9f),
				dayCard(weekDays[6], 0xFFe75a5a, 0xFFbc79c2),
			],
		);
  }

  Widget dayCard(String name, int color1, int color2){
		return new GestureDetector(
			onTap: (){
				Fluttertoast.showToast(msg: name);
			},
			child: Container(
				width: 300,
				margin: new EdgeInsets.only(left: 20, top: 100, right: 20, bottom: 100),
				decoration: new BoxDecoration(
					gradient: LinearGradient(
						colors: [Color(color1), Color(color2)],
						begin: Alignment.topLeft,
						end: Alignment(0.8, 0.0),
					),
					borderRadius: new BorderRadius.circular(10.0),
					boxShadow: <BoxShadow>[
						new BoxShadow(
							color: Color(color1 - 0x66000000),
							blurRadius: 20.0,
							offset: new Offset(0.0, 0.0),
						),
					],
				),
				child: Padding(
					padding: const EdgeInsets.only(top:40, left: 40),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							Text(name, style: TextStyle(color: Colors.white, fontSize: 40),),
							SizedBox(height: 20,),
							Text("Desayuno", style: TextStyle(color: Colors.white, fontSize: 16),),
							Divider(color: Colors.white, endIndent: 40,),
							Row(children: <Widget>[
								FaIcon(FontAwesomeIcons.utensilSpoon, color: Colors.white, size: 12,),
								SizedBox(width: 4,),
								Text("Albóndigas en salsa", style: TextStyle(color: Colors.white)),
							],),
							SizedBox(height: 20,),
							Text("Comida", style: TextStyle(color: Colors.white, fontSize: 16),),
							Divider(color: Colors.white, endIndent: 40,),
							Row(children: <Widget>[
								FaIcon(FontAwesomeIcons.utensilSpoon, color: Colors.white, size: 12,),
								SizedBox(width: 4,),
								Text("Pollo bien asao", style: TextStyle(color: Colors.white)),
							],),
							SizedBox(height: 20,),
							Text("Cena", style: TextStyle(color: Colors.white, fontSize: 16),),
							Divider(color: Colors.white, endIndent: 40,),
							Row(children: <Widget>[
								FaIcon(FontAwesomeIcons.utensilSpoon, color: Colors.white, size: 12,),
								SizedBox(width: 4,),
								Text("Un yogurcito", style: TextStyle(color: Colors.white)),
							],),
						],
					)
				),
			),
		);
	}

  void navigateToDay(Recipe recipe, String title) async {
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

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}
}
