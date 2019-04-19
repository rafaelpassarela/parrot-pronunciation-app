import 'package:sqflite/sqflite.dart';

final String _columnId = '_id';
final String _columnDescription = 'description';
final String _columnValue = 'value';

class Config {
  int id;
  String description;
  String value;

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      _columnDescription: description,
      _columnValue: value
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  Config.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    description = map[_columnDescription];
    value = map[_columnDescription];
  }
}