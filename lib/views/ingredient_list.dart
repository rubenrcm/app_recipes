import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class IngredientList extends StatefulWidget {

  final String appBarTitle;
  final Recipe recipe;

  IngredientList(this.recipe, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return IngredientListState(this.recipe, this.appBarTitle);
  }
}

class IngredientListState extends State<IngredientList> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Recipe recipe;
  List<Ingredient> ingredientList;
  int ingredient_count = 0;

  IngredientListState(this.recipe, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    if (ingredientList == null) {
      ingredientList = List<Ingredient>();
      updateIngredientListView(recipe.id);
    }

    return WillPopScope(
      onWillPop: () {
        // This function executes when the navbar back button is pressed
        moveToLastScreen();
      },
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
          body: getIngredientListView(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: new FloatingActionButton(
            child: FaIcon(FontAwesomeIcons.plus, size: 20,),
            onPressed: () {
              newIngredientDialog(Ingredient(recipe.id, 1, null, null));
            },
          )
      ),
    );
  }

  Widget getIngredientListView() {
    if (ingredient_count == 0){
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 26.0,),
            Image.asset('assets/img/empty_ingredients_icon.png', scale: 4.0,),
            Text("¡Añade ingredientes!", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),)
          ],
        ),
      );
    }
    else{
      return ListView.builder(
        itemCount: ingredient_count,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              leading: new FaIcon(FontAwesomeIcons.utensilSpoon, color: Theme.of(context).primaryColor, size: 16.0,),
              title: new Row(
                children: <Widget>[
                  new Text(this.ingredientList[position].quantity.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                  new SizedBox(width:4),
                  new Text(this.ingredientList[position].qty_type ?? ' ', style: TextStyle(fontWeight: FontWeight.bold)),
                  new SizedBox(width:6),
                  new Text(this.ingredientList[position].name),
                ],
              ),
              trailing: new IconButton(
                  icon: FaIcon(FontAwesomeIcons.trash, size: 16, color: Theme.of(context).accentColor,),
                  onPressed: () async {
                    int result = await databaseHelper.deleteIngredient(this.ingredientList[position].id);
                    updateIngredientListView(this.ingredientList[position].recipe_id);
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
              onTap: () {
                newIngredientDialog(ingredientList[position]);
              },
          );
        },
      );
    }
  }

  void updateIngredientListView(int recipe_id) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Ingredient>> ingredientListFuture = databaseHelper.getIngredientList(recipe_id);
      ingredientListFuture.then((ingredientList) {
        setState(() {
          this.ingredientList = ingredientList;
          this.ingredient_count = ingredientList.length;
        });
      });
    });
  }

  void newIngredientDialog(Ingredient ingredient) {

    TextEditingController qtyController = TextEditingController(text: ingredient.quantity.toString());
    TextEditingController qtyTypeController = TextEditingController(text: ingredient.qty_type);
    TextEditingController nameController = TextEditingController(text: ingredient.name);

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        "Nuevo ingrediente",
        style: TextStyle(color: Theme.of(context).primaryColor),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(height: 20,),
          TextField(
            controller: qtyController,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              labelText: "Cantidad",
              hintText: "1, 2, 1.5, ...",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)
              )
            ),
            onChanged: (value) {
              ingredient.quantity = double.parse(qtyController.text);
            },
          ),
          Container(height: 10,),
          TextField(
            controller: qtyTypeController,
            decoration: InputDecoration(
              hintText: "Mililitros, ml, kgs, gramos, ...",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)
              )
            ),
            onChanged: (value) {
              ingredient.qty_type = qtyTypeController.text;
            },
          ),
          Container(height: 20,),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Ingrediente",
              hintText: "Azucar, Sal, Harina, ...",
              hasFloatingPlaceholder: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)
              )
            ),
            onChanged: (value) {
              ingredient.name = nameController.text;
            },
          ),
          Container(height: 20,),
          RaisedButton(
            onPressed: () async {
              moveToLastScreen();
              int result;
              if (ingredient.id != null) {  // Case 1: Update operation
                result = await databaseHelper.updateIngredient(ingredient);
              } else { // Case 2: Insert Operation
                result = await databaseHelper.insertIngredient(ingredient);
              }

              if (result == 0) {
                Fluttertoast.showToast(msg: 'Problema al guardar');
              }
              updateIngredientListView(recipe.id);
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

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

}
