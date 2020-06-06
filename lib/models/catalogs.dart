
class Days {

  int _id;
  String _name_en;
  String _name_es;
  String _name_it;

  Days(this._name_en, this._name_es, this._name_it);

  Days.withId(this._id, this._name_en, this._name_es, this._name_it);

  int get id => _id;
  String get name_en => _name_en;
  String get name_es => _name_es;
  String get name_it => _name_it;

  set id(int newId) {
    this._id = newId;
  }

  set name_en(String newName) {
    this._name_en = newName;
  }

  set name_es(String newName) {
    this._name_es = newName;
  }

  set name_it(String newName) {
    this._name_it = newName;
  }

  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name_en'] = _name_en;
    map['name_es'] = _name_es;
    map['name_it'] = _name_it;

    return map;
  }

  Days.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name_en = map['name_en'];
    this._name_es = map['name_es'];
    this._name_it = map['name_it'];
  }


}

class Meals {

  int _id;
  String _name_en;
  String _name_es;
  String _name_it;

  Meals(this._name_en, this._name_es, this._name_it);

  Meals.withId(this._id, this._name_en, this._name_es, this._name_it);

  int get id => _id;
  String get name_en => _name_en;
  String get name_es => _name_es;
  String get name_it => _name_it;

  set id(int newId) {
    this._id = newId;
  }

  set name_en(String newName) {
    this._name_en = newName;
  }

  set name_es(String newName) {
    this._name_es = newName;
  }

  set name_it(String newName) {
    this._name_it = newName;
  }

  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name_en'] = _name_en;
    map['name_es'] = _name_es;
    map['name_it'] = _name_it;

    return map;
  }

  Meals.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name_en = map['name_en'];
    this._name_es = map['name_es'];
    this._name_it = map['name_it'];
  }


}
