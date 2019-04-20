import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String _tableConfig = 'CONFIG';
final String _columnId = '_id';
final String _columnCode = 'code';
final String _columnDescription = 'description';
final String _columnValue = 'value';

class Config {
  int id;
  String code;
  String description;
  String value;

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      _columnDescription: description,
      _columnValue: value,
      _columnCode: code,
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  Config({this.id, this.code, this.description, this.value});

  Config.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    code = map[_columnCode];
    description = map[_columnDescription];
    value = map[_columnValue];
  }
}

class ConfigProvider {
  Database db;

  Future open() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'parrot.db');

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
CREATE TABLE IF NOT EXISTS $_tableConfig ( 
  $_columnId integer primary key autoincrement, 
  $_columnCode text not null,
  $_columnDescription text not null,
  $_columnValue text not null) ''');
        });
  }

  Future<Config> insert(Config config) async {
    config.id = await db.insert(_tableConfig, config.toMap());
    return config;
  }

  Future<int> update(Config config) async {
    return await db.update(_tableConfig, config.toMap(),
        where: '$_columnId = ?', whereArgs: [config.id]);
  }

  Future<int> insertOrUpdate(Config config) async {
    if (config.id == null || config.id <= 0) {
      Config newConf = await insert(config);
      return newConf.id;
    }
    else
      return update(config);
  }

  Future<Config> getConfig(String code) async {
    List<Map> maps = await db.query(
        _tableConfig,
        columns: [_columnId, _columnCode, _columnDescription, _columnValue],
        where: '$_columnCode = ?',
        whereArgs: [code]);
    if (maps.length > 0) {
      return Config.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(_tableConfig, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future close() async => db.close();
}