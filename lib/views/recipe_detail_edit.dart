import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'ingredient_list.dart';
import 'step_list.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RecipeDetailEdit extends StatefulWidget {

	final String appBarTitle;
	final Recipe recipe;

	RecipeDetailEdit(this. recipe, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {
    return RecipeDetailState(this.recipe, this.appBarTitle);
  }
}

class RecipeDetailState extends State<RecipeDetailEdit> {

	DatabaseHelper helper = DatabaseHelper();

	String appBarTitle;
	Recipe recipe;
	List<Ingredient> ingredientList;
	int ingredient_count = 0;
	List<RecipeStep> stepList;
	int step_count = 0;
	File recipePhoto;
	TimeOfDay pickedTime;

	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();
	TextEditingController durationController = TextEditingController();
	TextEditingController servingsController = TextEditingController();
	TextEditingController sourceController = TextEditingController();
	TextEditingController notesController = TextEditingController();

	RecipeDetailState(this.recipe, this.appBarTitle);

	@override
  Widget build(BuildContext context) {

		TextStyle textStyle = Theme.of(context).textTheme.title;

		titleController.text = recipe.name;
		descriptionController.text = recipe.description;
		durationController.text = recipe.duration.toString().split(':')[0] + 'h ' + recipe.duration.toString().split(':')[1] + 'm';
		servingsController.text = recipe.servings.toString();
		sourceController.text = recipe.source;
		notesController.text = recipe.notes;
		recipePhoto = recipe.photo_path == null ? null : File(recipe.photo_path);

		if (ingredientList == null) {
			ingredientList = List<Ingredient>();
			updateIngredientListView(recipe.id);
		}
		if (stepList == null) {
			stepList = List<RecipeStep>();
			updateStepListView(recipe.id);
		}

    return WillPopScope(

	    onWillPop: (){
		    moveToLastScreen();
	    },

	    child: Scaffold(
	    appBar: AppBar(
		    title: Text(appBarTitle),
		    centerTitle: true,
		    leading: IconButton(icon: Icon(Icons.arrow_back),
				    onPressed: () {
		    	    // Write some code to control things,
							// when user press back button in AppBar
		    	    moveToLastScreen();
				    }
		    ),
				actions: <Widget>[
					IconButton(
						icon: FaIcon(FontAwesomeIcons.check, size: 16.0,),
						onPressed: () {
							setState(() {
								_save(true);
							});
						},
					)
				],
	    ),
	    body: Padding(
		    padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
		    child: ListView(
			    children: <Widget>[
			    	Stack(
							alignment: Alignment.center,
							children: <Widget>[
								ClipRRect(
									borderRadius: BorderRadius.circular(16.0),
									child: recipePhoto == null
											? Stack(
										alignment: Alignment.center,
										children: <Widget>[
											Container(height: MediaQuery.of(context).size.width, width: MediaQuery.of(context).size.width, color: Color(recipe.backColor),),
											FaIcon(FontAwesomeIcons.utensils, size: 180, color: Color(0x88FFFFFF))
										],
									)
											: Image.file(recipePhoto, fit: BoxFit.cover,)
									,
								),
								MaterialButton(
									height: 100,
									onPressed: (){
										getImage();
									},
									color: Color(0x99FFFFFF),
									child: FaIcon(FontAwesomeIcons.camera, color: Color(0x99E25A53), size: 40,),
									shape: CircleBorder()
								)
							],
						),
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: titleController,
						    maxLength: 27,
								decoration: InputDecoration(
										labelText: 'Nombre',
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(8.0)
										)//labelStyle: textStyle,
								),
						    onChanged: (value) {
						    	updateTitle();
						    },
					    ),
				    ),
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: descriptionController,
						    //style: textStyle,
						    onChanged: (value) {
							    updateDescription();
						    },
						    decoration: InputDecoration(
								    labelText: 'Descripción',
								    //labelStyle: textStyle,
								    border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(8.0)
								    )
						    ),
					    ),
				    ),
						Container(
							margin: EdgeInsets.only(top: 20),
							child: Text("Detalles",
									style: TextStyle(
										fontFamily: 'BalooPaaji2',
										fontSize: 18,
										fontWeight: FontWeight.w600,
									)),
						),// Duration
						Divider(
							color: Theme.of(context).accentColor,
							thickness: 2,
						),
						Container(height: 20,),
						Row(
							children: <Widget>[
								Expanded(
									child: TextField(
										controller: durationController,
										readOnly: true,
										onTap: () async {
											Duration resultingDuration = await showDurationPicker(
												context: context,
												initialTime: new Duration(minutes: 30),
											);
											// This is null when the user cancel the picking
											if (resultingDuration != null){
												updateDuration(resultingDuration);
												durationController.text = resultingDuration.toString().split(':')[0] + 'h ' + resultingDuration.toString().split(':')[1] + 'm';
											}
										},
										decoration: InputDecoration(
												labelText: 'Tiempo',
												icon: FaIcon(FontAwesomeIcons.clock, size: 20,),
												//labelStyle: textStyle,
												border: OutlineInputBorder(
														borderRadius: BorderRadius.circular(8.0)
												)
										),
									),
								),
								Container(width: 10.0,),
								Expanded(
									child: TextField(
										controller: servingsController,
										keyboardType: TextInputType.numberWithOptions(),
										inputFormatters: <TextInputFormatter>[
											WhitelistingTextInputFormatter.digitsOnly
										],
										onChanged: (value) {
											updateServings();
										},
										decoration: InputDecoration(
												labelText: 'Personas',
												icon: FaIcon(FontAwesomeIcons.user, size: 20,),
												//labelStyle: textStyle,
												border: OutlineInputBorder(
														borderRadius: BorderRadius.circular(8.0)
												)
										),
									),
								),
							],
						),
						Container(height: 20,),
						Row(
							children: <Widget>[
								Expanded(
									child: TextField(
										controller: sourceController,
										onChanged: (value) {
											updateSource();
										},
										decoration: InputDecoration(
												labelText: 'Fuente',
												icon: FaIcon(FontAwesomeIcons.lightbulb, size: 22,),
												border: OutlineInputBorder(
														borderRadius: BorderRadius.circular(8.0)
												)
										),
									),
								),
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
											)),
									Expanded(child: Container(),),
									IconButton(
										icon: FaIcon(FontAwesomeIcons.pen, size: 20, color: Theme.of(context).accentColor),
										onPressed: (){
											navigateToEditIngredients(recipe, 'Ingredientes');
										},
										tooltip: "Editar ingredientes",
									)
								],
							)
						),// Duration
						Divider(
							color: Theme.of(context).accentColor,
							thickness: 2,
						),
						Container(height: 20,),
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
												)),
										Expanded(child: Container(),),
										IconButton(
											icon: FaIcon(FontAwesomeIcons.pen, size: 20, color: Theme.of(context).accentColor),
											onPressed: (){
												navigateToEditSteps(recipe, 'Pasos');
											},
											tooltip: "Editar pasos",
										)
									],
								)
						),// Duration
						Divider(
							color: Theme.of(context).accentColor,
							thickness: 2,
						),
						Container(height: 20,),
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
												)),
									],
								)
						),
						Divider(
							color: Theme.of(context).accentColor,
							thickness: 2,
						),
						Padding(
							padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
							child: TextField(
								controller: notesController,
								//style: textStyle,
								onChanged: (value) {
									updateNotes();
								},
								decoration: InputDecoration(
										border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(8.0)
										)
								),
							),
						),
			    ],
		    ),
	    ),

    ));
  }

  void moveToLastScreen() {
		Navigator.pop(context, true);
  }

	void navigateToEditIngredients(Recipe recipe, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return IngredientList(recipe, title);
		}));
		if (result != null){
			updateIngredientListView(recipe.id);
		}
	}

	void navigateToEditSteps(Recipe recipe, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return StepList(recipe, title);
		}));
		if (result != null){
			updateStepListView(recipe.id);
		}
	}

	Future getImage() async {
		ImagePicker.pickImage(source: ImageSource.camera)
				.then((File recordedImage) {
			if (recordedImage != null && recordedImage.path != null) {
				setState(() {
					recipePhoto = recordedImage;
				});
				GallerySaver.saveImage(recordedImage.path);
				recipe.photo_path = recordedImage.path;
			}
		});
	}

  void updateTitle(){
    recipe.name = titleController.text;
  }

	void updateDescription() {
		recipe.description = descriptionController.text;
	}

	void updateDuration(Duration duration) {
		recipe.duration = duration;
	}

	void updateServings() {
		recipe.servings = int.parse(servingsController.text);
	}

	void updateSource() {
		recipe.source = sourceController.text;
	}

	void updateNotes() {
		recipe.notes = notesController.text;
	}

	void _save(bool showToast) async {

		moveToLastScreen();

		int result;
		if (recipe.id != null) {  // Case 1: Update operation
			result = await helper.updateRecipe(recipe);
		} else { // Case 2: Insert Operation
			result = await helper.insertRecipe(recipe);
			recipe.id = result;
			for (int i=0;i<ingredient_count;i++){
				ingredientList[i].recipe_id = recipe.id;
				await helper.updateIngredient(ingredientList[i]);
			}
			for (int i=0;i<step_count;i++){
				stepList[i].recipe_id = recipe.id;
				await helper.updateStep(stepList[i]);
			}
		}
		if (showToast == true){
			if (result != 0) {  // Success
				Fluttertoast.showToast(msg: 'Receta guardada');
			} else {  // Failure
				Fluttertoast.showToast(msg: 'Problema al guardar');
			}
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

	ListView getIngredientListView() {

		return ListView.builder(
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics() ,
			itemCount: ingredient_count,
			itemBuilder: (BuildContext context, int position) {
				return IngredientRow(ingredientList[position]);
			},
		);
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

	ListView getStepListView() {

		return ListView.builder(
			shrinkWrap: true,
			physics: NeverScrollableScrollPhysics() ,
			itemCount: step_count,
			itemBuilder: (BuildContext context, int position) {
				return StepRow(stepList[position], position);
			},
		);
	}

}

class IngredientRow extends StatelessWidget {

	final Ingredient ingredient;
	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Ingredient> ingredientList;
	int ingrecient_count = 0;

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








