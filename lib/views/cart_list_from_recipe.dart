import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CartListRecipe extends StatefulWidget {

  final List<CartIngredient> cartList;

  CartListRecipe(this.cartList);

  @override
  State<StatefulWidget> createState() {
    return CartListRecipeState(this.cartList);
  }
}

class CartListRecipeState extends State<CartListRecipe> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<CartIngredient> cartList;

  List<CartIngredient> ingredientList;
  int ingredient_count = 0;

  CartListRecipeState(this.cartList);

  @override
  Widget build(BuildContext context) {

    if (ingredientList == null) {
      updateIngredientListView();
    }

    return WillPopScope(
      onWillPop: () {
        // This function executes when the navbar back button is pressed
        moveToLastScreen();
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text("Añadir al carrito"),
            centerTitle: true,
            leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }
            ),
          ),
          body: getIngredientListView(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: new FloatingActionButton.extended(
            label: Text("Añadir"),
            icon: FaIcon(FontAwesomeIcons.shoppingCart, size: 20,),
            onPressed: () {
              _saveIngredients();
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
            Text("¡Añade ingredientes al carrito!", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),)
          ],
        ),
      );
    }
    else{
      return ListView.builder(
        itemCount: ingredient_count,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
              leading: new IconButton(
                icon: new FaIcon(ingredientList[position].add_cart ? FontAwesomeIcons.checkCircle: FontAwesomeIcons.circle, color: Theme.of(context).primaryColor, size: 20.0,),
                onPressed: (){_toggleAddCart(position);},
              ),
              title: new Row(
                children: <Widget>[
                  new Text(this.ingredientList[position].qty.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                  new SizedBox(width:4),
                  new Text(this.ingredientList[position].qty_type ?? ' ', style: TextStyle(fontWeight: FontWeight.bold)),
                  new SizedBox(width:6),
                  new Text(this.ingredientList[position].name),
                ],
              ),
              onTap: () {
                newIngredientDialog(ingredientList[position]);
              },
          );
        },
      );
    }
  }

  void updateIngredientListView() {
    setState(() {
      this.ingredientList = cartList;
      this.ingredient_count = ingredientList.length;
    });
  }

  void _toggleAddCart(int index){
    setState(() {
      this.ingredientList[index].add_cart =! ingredientList[index].add_cart;
    });
  }

  void newIngredientDialog(CartIngredient ingredient) {

    TextEditingController qtyController = TextEditingController(text: ingredient.qty.toString());
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
    Navigator.pop(context, true);
  }


  void _saveIngredients() async {
    moveToLastScreen();
    int result;

    for (int i=0;i<ingredient_count;i++){
      if (ingredientList[i].add_cart == true){
        result = await databaseHelper.insertCartIngredient(ingredientList[i]);
      }
    }

    if (result != 0) {
      Fluttertoast.showToast(msg: 'Ingredientes añadidos al carrito');
    } else {
      Fluttertoast.showToast(msg: 'Problema al añador');
    }
  }

}
