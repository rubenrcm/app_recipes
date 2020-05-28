import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes/models/catalogs.dart';
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
	List<Days> daysList;
	List<Meals> mealsList;
	int dayscount = 7;
	String query = '';
	List<String> weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes','Sábado', 'Domingo'];

	@override
  Widget build(BuildContext context) {

		if (daysList == null) {
			daysList = List<Days>();
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
		    title: Text('Plan Semanal',
										style: TextStyle(fontFamily: 'Lobster',
																			fontSize: 26),
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
				//TODO: fix the error when the first time dayList is empty
				dayCard(daysList[0].name_es ?? ' ', 0xFFFFC581, 0xFFFFD5A4), //This doesn't seem to fix it
				dayCard(daysList != null ? daysList[1].name_es : ' ', 0xFFFDB35D, 0xFFFFC581), //This neither
				dayCard(daysList != null ? daysList[2].name_es : ' ', 0xFFE59437, 0xFFFDB35D),
				dayCard(daysList != null ? daysList[3].name_es : ' ', 0xFFE68649, 0xFFFDB35D),
				dayCard(daysList != null ? daysList[4].name_es : ' ', 0xFFE68649, 0xFFE59437),
				dayCard(daysList != null ? daysList[5].name_es : ' ', 0xFFE68649, 0xFFFF906B),
				dayCard(daysList != null ? daysList[6].name_es : ' ', 0xFFFF906B, 0xFFFFC078),
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
			//TODO: optimize this in order to redraw only one time
			Future<List<Days>> daysListFuture = databaseHelper.getDaysList();
			Future<List<Meals>> daysMealsFuture = databaseHelper.getMealsList();
			daysListFuture.then((daysList) {
				setState(() {
				  this.daysList = daysList;
				});
			});
			daysMealsFuture.then((mealsList) {
				setState(() {
					this.mealsList = mealsList;
				});
			});
		});
  }

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}
}
