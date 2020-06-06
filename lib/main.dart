import 'package:flutter/material.dart';
import 'package:recipes/views/recipe_list.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {

	@override
  Widget build(BuildContext context) {

    return MaterialApp(
	    title: 'Recipes',
	    debugShowCheckedModeBanner: false,
	    theme: ThemeData(
				brightness: Brightness.light,
		    primaryColor: Color(0xFFFFC078),
				accentColor: Color(0xFFFF816E),
				textSelectionHandleColor: Color(0xFFFF816E),
				accentIconTheme: IconThemeData(color: Colors.white),
				primaryIconTheme: IconThemeData(color: Colors.white),
				primaryTextTheme: TextTheme(
					title: TextStyle(
					color: Color(0xFFFFFFFF)
					),
					body1: TextStyle(
							fontSize: 16.0
					),
					body2: TextStyle(
							fontSize: 16.0
					),
				),
	    ),
	    home: RecipeList(),
    );
  }
}