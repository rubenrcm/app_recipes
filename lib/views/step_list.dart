import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class StepList extends StatefulWidget {

  final String appBarTitle;
  final Recipe recipe;

  StepList(this.recipe, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return StepListState(this.recipe, this.appBarTitle);
  }
}

class StepListState extends State<StepList> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Recipe recipe;
  List<RecipeStep> stepList;
  int step_count = 0;

  StepListState(this.recipe, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    if (stepList == null) {
      stepList = List<RecipeStep>();
      updateStepListView(recipe.id);
    }

    return WillPopScope(
      onWillPop: () {
        // This function executes when the navbar back button is pressed
        moveToLastScreen();
      }, // This doesn't seem to work
      child: new Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }
            ),
          ),
          body: getStepListView(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: new FloatingActionButton(
            child: FaIcon(FontAwesomeIcons.plus, size: 20,),
            onPressed: () {
              newStepDialog(RecipeStep(recipe.id, null));
            },
          )
      ),
    );
  }

  Widget getStepListView() {

    if (step_count == 0){
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 26.0,),
            Image.asset('assets/img/empty_steps_icon.png', scale: 4.0,),
            Text("¡Añade pasos!", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),)
          ],
        ),
      );
    }
    else{
      return ListView.builder(
        itemCount: step_count,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
            leading: new Text(
              (position + 1).toString(),
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
              ),
            ),
            title: new Text(this.stepList[position].description),
            trailing: new IconButton(
                icon: FaIcon(FontAwesomeIcons.trash, size: 16, color: Theme.of(context).accentColor,),
                onPressed: () async {
                  int result = await databaseHelper.deleteStep(this.stepList[position].id);
                  updateStepListView(this.stepList[position].recipe_id);
                  if (result != 0) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Ingrediente borrado"),
                    ));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Problema al borrar"),
                    ));
                  }
                }),
            onTap:(){
              newStepDialog(stepList[position]);
            },
          );
        },
      );
    }
  }

  void updateStepListView(int recipe_id) {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<RecipeStep>> stepListFuture = databaseHelper.getStepList(recipe_id);
      stepListFuture.then((stepList) {
        setState(() {
          this.stepList = stepList;
          this.step_count = stepList.length;
        });
      });
    });
  }

  void newStepDialog(RecipeStep step) {

    TextEditingController descriptionController = TextEditingController(text: step.description);

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        "Nuevo paso",
        style: TextStyle(color: Theme.of(context).primaryColor),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(height: 20,),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: "Descripción",
              hintText: "Añadir y remover ...",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)
              )
            ),
            onChanged: (value) {
              step.description = descriptionController.text;
            },
          ),
          Container(height: 10,),
          RaisedButton(
            onPressed: () async {
              moveToLastScreen();
              int result;
              if (step.id != null) {  // Case 1: Update operation
                result = await databaseHelper.updateStep(step);
              } else { // Case 2: Insert Operation
                result = await databaseHelper.insertStep(step);
              }
              if (result == 0) {  // Success
                Fluttertoast.showToast(msg: 'Problema al guardar');
              }
              updateStepListView(recipe.id);
            },
            child: Text("Guardar", style: TextStyle(color: Colors.white),),
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  Future<bool> moveToLastScreen() {
    Navigator.pop(context, true);
    return new Future.value(true);
  }

}
