import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes/models/catalogs.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:recipes/views/week_day.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
	List<List<String>> daysRecipes;

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
					AlertDialog alertDialog = AlertDialog(
						title: Text(
							'Se borrarán las recetas de la semana',
							textAlign: TextAlign.center,
							style: TextStyle(color: Colors.black45),
						),
						content:
								FlatButton(
									onPressed: () async {
										_deleteWeek();
									},
									shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(40)
									),
									child: Text("Ok", style: TextStyle(color: Colors.white),),
									color: Theme.of(context).primaryColor,
								)

					);
					showDialog(
							context: context,
							builder: (_) => alertDialog
					);
				},
				tooltip: 'Vaciar semana',
				child: FaIcon(FontAwesomeIcons.redoAlt, size: 20,),
			),

    );
  }

  Widget getWeekDaysView() {
		return ListView(
			scrollDirection: Axis.horizontal,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				dayCard(daysList.length != 0 ? daysList[0].name_es : ' ',0, 0xFFFFC581, 0xFFFFD5A4),
				dayCard(daysList.length != 0 ? daysList[1].name_es : ' ',1, 0xFFFDB35D, 0xFFFFC581),
				dayCard(daysList.length != 0 ? daysList[2].name_es : ' ',2, 0xFFE59437, 0xFFFDB35D),
				dayCard(daysList.length != 0 ? daysList[3].name_es : ' ',3, 0xFFE68649, 0xFFFDB35D),
				dayCard(daysList.length != 0 ? daysList[4].name_es : ' ',4, 0xFFE68649, 0xFFE59437),
				dayCard(daysList.length != 0 ? daysList[5].name_es : ' ',5, 0xFFE68649, 0xFFFF906B),
				dayCard(daysList.length != 0 ? daysList[6].name_es : ' ',6, 0xFFFF906B, 0xFFFFC078),
			],
		);
  }

  Widget dayCard(String name, int day_id, int color1, int color2){
		return new GestureDetector(
			onTap: (){
				Future<List<int>> recipe_ids_future = databaseHelper.getMenuRecipesByDayList(day_id.toString());
				recipe_ids_future.then((recipe_ids) {
					navigateToDay(name, recipe_ids, day_id);
				});
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
							getDayRecipesList(day_id),
						],
					)
				),
			),
		);
	}

  void navigateToDay(String day, List<int> recipe_ids, int day_id) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return WeekDay(day, recipe_ids, day_id);
	  }));
	  if (result == true) {
	  	updateListView();
	  }
  }

	ListView getDayRecipesList(int day) {
		return ListView.builder(
			padding: EdgeInsets.all(8.0),
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics() ,
			itemCount: (daysRecipes != null) ? this.daysRecipes[day].length : 0,
			itemBuilder: (BuildContext context, int position) {
				return Container(
					height: 30,
					child:Row(children: <Widget>[
						FaIcon(FontAwesomeIcons.utensilSpoon, size: 16, color: Colors.white),
						SizedBox(width: 10,),
						Text(this.daysRecipes[day][position], style: TextStyle(color: Colors.white, fontSize: 16)),
					],) ,
				);
			},
		);
	}

  void updateListView() {
		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {
			Future<List<Days>> daysListFuture = databaseHelper.getDaysList();
			Future<List<Meals>> daysMealsFuture = databaseHelper.getMealsList();
			Future<List<List<String>>> daysRecipesFuture = databaseHelper.getRecipesDaysList();

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
			daysRecipesFuture.then((daysRecipes) {
				setState(() {
					this.daysRecipes = daysRecipes;
				});
			});
		});
  }

	void _deleteWeek() async {

		int result = await databaseHelper.deleteWeekRecipes();

		if (result != 0) {
			Fluttertoast.showToast(msg: 'Se ha vaciado la semana');
		} else {
			Fluttertoast.showToast(msg: 'No había recetas que borrar');
		}
		updateListView();
	}

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}
}
