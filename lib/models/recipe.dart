
class Recipe {

	int _id;
	String _name;
	String _description;
	Duration _duration;
	int _servings;
	int _category_id;
	String _source;
	String _notes;
	String _photo_path;

	Recipe(this._name, this._description, this._duration, this._servings, this._category_id, this._source, this._notes, this._photo_path);

	Recipe.withId(this._id, this._name, this._description, this._duration, this._servings, this._category_id, this._source, this._notes, this._photo_path);

	int get id => _id;

	String get name => _name;

	String get description => _description;

	Duration get duration => _duration;

	int get servings => _servings;

	int get category_id => _category_id;

	String get source => _source;

	String get notes => _notes;

	String get photo_path => _photo_path;

	set id(int newId) {
		this._id = newId;
	}

	set name(String newName) {
		if (newName.length <= 255) {
			this._name = newName;
		}
	}

	set description(String newDescription) {
		if (newDescription.length <= 255) {
			this._description = newDescription;
		}
	}

	set duration(Duration newDuration) {
		this._duration = newDuration;
	}

	set servings(int newServings) {
		this._servings = newServings;
	}

	set category_id(int newCategory_id) {
		this._category_id = newCategory_id;
	}

	set source(String newSource) {
		this._source = newSource;
	}

	set notes(String newNotes) {
		this._notes = newNotes;
	}

	set photo_path(String newPath) {
		this._photo_path = newPath;
	}

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['title'] = _name;
		map['description'] = _description;
		map['duration'] = _duration.inMinutes;
		map['servings'] = _servings;
		map['category_id'] = _category_id;
		map['source'] = _source;
		map['notes'] = _notes;
		map['photo_path'] = _photo_path;

		return map;
	}

	Recipe.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._name = map['title'];
		this._description = map['description'];
		this._duration = Duration(minutes: map['duration']);
		this._servings = map['servings'];
		this._category_id = map['category_id'];
		this._source = map['source'];
		this. _notes = map['notes'];
		this. _photo_path = map['photo_path'];
	}
}

class Ingredient {
	//One2one relation with recipe

	int _id;
	int _recipe_id;
	double _quantity;
	String _qty_type;
	String _name;

	Ingredient(this._recipe_id, this._quantity, this._qty_type, this._name);

	Ingredient.withId(this._id, this._recipe_id, this._quantity, this._qty_type, this._name);

	int get id => _id;

	int get recipe_id => _recipe_id;

	double get quantity => _quantity;

	String get qty_type => _qty_type;

	String get name => _name;

	set recipe_id(int newRecipe_id) {
		this._recipe_id = newRecipe_id;
	}

	set quantity(double newQuantity) {
		this._quantity = newQuantity;
	}

	set qty_type(String newQty_type) {
		this._qty_type = newQty_type;
	}

	set name(String newName) {
		this._name = newName;
	}

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['recipe_id'] = _recipe_id;
		map['quantity'] = _quantity;
		map['qty_type'] = _qty_type;
		map['name'] = _name;

		return map;
	}

	Ingredient.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._recipe_id = map['recipe_id'];
		this._quantity = map['quantity'];
		this._qty_type = map['qty_type'];
		this._name = map['name'];
	}

}

class RecipeStep {
	//One2one relation with recipe

	int _id;
	int _recipe_id;
	String _description;

	RecipeStep(this._recipe_id, this._description);

	RecipeStep.withId(this._id, this._recipe_id, this._description);

	int get id => _id;

	int get recipe_id => _recipe_id;

	String get description => _description;


	set recipe_id(int newRecipe_id) {
		this._recipe_id = newRecipe_id;
	}

	set description(String newDescription) {
		this._description = newDescription;
	}

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['recipe_id'] = _recipe_id;
		map['description'] = _description;

		return map;
	}

	RecipeStep.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._recipe_id = map['recipe_id'];
		this._description = map['description'];
	}

}

class Category {
	//One2one relation with recipe

	int _id;
	int _recipe_id;
	String _name;
	String _color;
	String _icon;

	Category(this._recipe_id, this._name, this._color, this._icon);

	Category.withId(this._id, this._recipe_id, this._name, this._color, this._icon);

	int get id => _id;

	int get recipe_id => _recipe_id;

	String get name => _name;

	String get color => _color;

	String get icon => _icon;

	set recipe_id(int newRecipe_id) {
		this._recipe_id = newRecipe_id;
	}

	set description(String newName) {
		this._name = newName;
	}

	set color(String newColor) {
		this._name = newColor;
	}

	set icon(String newIcon) {
		this._name = newIcon;
	}

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['recipe_id'] = _recipe_id;
		map['name'] = _name;
		map['color'] = _color;

		return map;
	}

	Category.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._recipe_id = map['recipe_id'];
		this._name = map['name'];
		this._color = map['color'];
	}

}

class CartIngredient {

	int _id;
	double _qty;
	String _qty_type;
	String _name;
	double _original_qty;
	bool _add_cart; //bool
	bool _done; //bool

	CartIngredient(this._qty, this._qty_type, this._name, this._original_qty, this._add_cart, this._done);

	CartIngredient.withId(this._id, this._qty, this._qty_type, this._name, this._original_qty, this._add_cart, this._done);

	int get id => _id;

	double get qty => _qty;

	String get qty_type => _qty_type;

	String get name => _name;

	double get original_qty => _original_qty;

	bool get add_cart => _add_cart;

	bool get done => _done;

	set qty(double newQuantity) {
		this._qty = newQuantity;
	}

	set qty_type(String newQty_type) {
		this._qty_type = newQty_type;
	}

	set name(String newName) {
		this._name = newName;
	}

	set original_qty(double newQuantity) {
		this._original_qty = newQuantity;
	}

	set add_cart(bool newAddCart) {
		this._add_cart = newAddCart;
	}

	set done(bool newDone) {
		this._done = newDone;
	}

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['qty'] = _qty;
		map['qty_type'] = _qty_type;
		map['name'] = _name;
		map['original_qty'] = _original_qty;
		map['add_cart'] = _add_cart ? 1 : 0;
		map['done'] = _done ? 1 : 0;

		return map;
	}

	CartIngredient.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._qty = map['qty'];
		this._qty_type = map['qty_type'];
		this._name = map['name'];
		this._original_qty = map['original_qty'];
		this._add_cart = map['add_cart'] == 1;
		this._done = map['done'] == 1;
	}

}








