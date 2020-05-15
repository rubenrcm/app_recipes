import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/utils/database_helper.dart';
import 'package:recipes/views/recipe_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';


class RecipeRow extends StatelessWidget {

  final Recipe recipe;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Recipe> recipeList;
  int count = 0;

  RecipeRow(this.recipe);

  @override
  Widget build(BuildContext context) {
    final recipeThumbnail = new Container(
      margin: new EdgeInsets.symmetric(
          vertical: 16.0
      ),
      alignment: FractionalOffset.centerLeft,
      height: 92.0,
      width: 92.0,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 0.0),
          ),
        ],
      ),
      child: new Hero(
        tag: "recipe-hero-${recipe.id}",
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: recipe.photo_path == null
              ? Image(image: AssetImage('assets/img/empty_photo.png'), fit: BoxFit.cover, height: 92.0, width: 92.0,)
              : Image.file(File(recipe.photo_path), fit: BoxFit.cover, height: 92.0, width: 92.0,)
        ),
      )
    );

    final recipeCategory = new Container(
        margin: new EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 0.0,
        ),
        alignment: FractionalOffset.center,
        height: 36.0,
        width: 36.0,
        decoration: new BoxDecoration(
          color: Color(0xFFCCEECC), //TODO: this will be the category color
          shape: BoxShape.circle,
        ),
        child: new FaIcon(FontAwesomeIcons.leaf, color: Colors.white, size: 16,), //TODO: this will be the category icon
    );

    final recipeCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(96.0, 16.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(height: 4.0),
          new Text(recipe.name, style: TextStyle(fontSize: 18.0),),
          new Container(height: 10.0),
          new Text(recipe.description, style: TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis,),
          new Container(height: 16.0),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: Row(
                      children: <Widget>[
                        new FaIcon(FontAwesomeIcons.clock, size: 16, color: Colors.grey,),
                        new Container(width: 8.0),
                        new Text(recipe.duration.toString().split(':')[0] + 'h ' + recipe.duration.toString().split(':')[1] + 'm' ?? '', style: TextStyle(color: Colors.grey),),
                        new Container(width: 16.0),
                        new FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.grey,),
                        new Container(width: 8.0),
                        new Text(recipe.servings.toString(), style: TextStyle(color: Colors.grey),),
                      ]
                  )
              ),
            ],
          ),
        ],
      ),
    );

    final recipeCard = new Container(
      child: recipeCardContent,
      margin: new EdgeInsets.only(left: 20.0,),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Color(0xFFEEEEEE),
            blurRadius: 10.0,
            offset: new Offset(0.0, 4.0),
          ),
        ],
      ),
    );

    void updateListView() {

      final Future<Database> dbFuture = databaseHelper.initializeDatabase();
      dbFuture.then((database) {

        Future<List<Recipe>> recipeListFuture = databaseHelper.getRecipeList();
        recipeListFuture.then((recipeList) {
          //setState(() {
          // this.recipeList = recipeList;
          //  this.count = recipeList.length;
          //});  ----------------- This function only respond to stateful widgets not stateless ------------
        });
      });
    }

    void navigateToDetail(Recipe recipe, String title) async {
      bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RecipeDetail(recipe, title);
      }));

      if (result == true) {
        updateListView();
      }
    }


    return new GestureDetector(
      onTap: () {
        navigateToDetail(this.recipe, recipe.name);
        },
      child: new Container(
          height: 140.0,
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: new Stack(
            children: <Widget>[
              recipeCard,
              recipeThumbnail,
              // Align( TODO: category tag
              //   alignment: Alignment.centerRight,
              //   child: recipeCategory,
              // )
            ],
          )
      ),
    );

  }
}