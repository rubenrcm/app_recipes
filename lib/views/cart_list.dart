import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CartList extends StatefulWidget {

  CartList();

  @override
  State<StatefulWidget> createState() {
    return CartListState();
  }
}

class CartListState extends State<CartList> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<CartIngredient> ingredientList;
  int ingredient_count = 0;

  CartListState();

  @override
  Widget build(BuildContext context) {

    if (ingredientList == null) {
      ingredientList = List<CartIngredient>();
      updateIngredientListView();
    }

    return WillPopScope(
      onWillPop: () {
        // This function executes when the navbar back button is pressed
        moveToLastScreen();
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text('Carrito',
              style: TextStyle(fontFamily: 'Lobster',
                  fontSize: 30),
            ),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.add),
                  onPressed: () {
                    newIngredientDialog(CartIngredient(1,null,null,1,true,false), "Nuevo ingrediente");
                  }
              )
            ],
          ),
          body: getIngredientListView(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Opacity(
            opacity: ingredient_count > 0 ? 1 : 0, //Only visible if there is some element
            child: FloatingActionButton.extended(
              label: Text("Vaciar carrito"),
              icon: FaIcon(FontAwesomeIcons.shoppingCart, size: 20,),
              onPressed: () {
                _deleteCart();
              },
            ),
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
            Image.asset('assets/img/empty_cart_icon.png', scale: 4.0,),
            Text("¡El carrito está vacío!", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),)
          ],
        ),
      );
    }
    else{
      return ListView.builder(
        itemCount: ingredient_count,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
            enabled: ! ingredientList[position].done,
            leading: new IconButton(
              icon: new FaIcon(ingredientList[position].done ? FontAwesomeIcons.checkSquare: FontAwesomeIcons.square, color: Theme.of(context).primaryColor, size: 20.0,),
              onPressed: (){_toggleDone(position);},
            ),
            title: new Row(
              children: <Widget>[
                new Text(this.ingredientList[position].qty.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                new SizedBox(width:4),
                new Text(this.ingredientList[position].qty_type ?? ' ', style: TextStyle(fontWeight: FontWeight.bold)),
                new SizedBox(width:6),
                new Text(this.ingredientList[position].name ?? ' '),
              ],
            ),
            trailing: new IconButton(
                icon: FaIcon(FontAwesomeIcons.trash, size: 16, color: Theme.of(context).accentColor,),
                onPressed: () async {
                  int result = await databaseHelper.deleteCartIngredient(this.ingredientList[position].id);
                  updateIngredientListView();
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
              newIngredientDialog(ingredientList[position], "Editar ingrediente");
            },
          );
        },
      );
    }
  }

  void _toggleDone(int index){
    setState(() {
      this.ingredientList[index].done =! ingredientList[index].done;
    });
  }

  void updateIngredientListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<CartIngredient>> ingredientListFuture = databaseHelper.getCartList();
      ingredientListFuture.then((ingredientList) {
        setState(() {
          this.ingredientList = ingredientList;
          this.ingredient_count = ingredientList.length;
        });
      });
    });
  }

  void newIngredientDialog(CartIngredient ingredient, String title) {

    TextEditingController qtyController = TextEditingController(text: ingredient.qty.toString());
    TextEditingController qtyTypeController = TextEditingController(text: ingredient.qty_type);
    TextEditingController nameController = TextEditingController(text: ingredient.name);

    AlertDialog alertDialog = AlertDialog(
      title: Text(
        title,
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
              ingredient.qty = double.parse(qtyController.text);
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
                result = await databaseHelper.updateCartIngredient(ingredient);
              } else { // Case 2: Insert Operation
                result = await databaseHelper.insertCartIngredient(ingredient);
              }

              if (result == 0) {
                Fluttertoast.showToast(msg: 'Problema al guardar');
              }
              updateIngredientListView();
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
    _saveCart();
    Navigator.pop(context, true);
  }

  void _saveCart() async {
    int result;
    if (ingredient_count > 0) {
      for (int i=0;i<ingredient_count;i++){
        if (ingredientList[i].id == null){
          result = await databaseHelper.insertCartIngredient(ingredientList[i]);
        }
        else {
          result = await databaseHelper.updateCartIngredient(ingredientList[i]);
        }
      }
    }
    if (result == 0) {
      Fluttertoast.showToast(msg: 'Problema al guardar');
    }
  }

  void _deleteCart() async {
    int result;
    for (int i=0;i<ingredient_count;i++){
      result = await databaseHelper.deleteCartIngredient(ingredientList[i].id);
    }
    if (result != 0) {
      setState(() {
        ingredientList = List<CartIngredient>();
        ingredient_count = 0;
      });
    }
  }

}
