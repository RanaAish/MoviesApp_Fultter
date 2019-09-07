import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Film.dart';
import 'package:toast/toast.dart';


class MyHelper {
//1- create object from MyHelper
  static MyHelper helper;

  MyHelper._getInstance();

  factory MyHelper() {
    if (helper == null) {
      return MyHelper._getInstance();
    } else {
      return helper;
    }
  }

  static Database _database;

  //2- define constants
  static String db_name = 'Films.db';
  static String table_name = 'film';
  static String col_id = 'id';
  static String col_title = 'title';
  static String col_path='path';

  //3- create object from datbase
  Future<Database> get database async {
    if (_database != null)
      return _database;
    else
      return intializeDb();
  }

  Future<Database> intializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    var path = join(dir.path, db_name);
    return openDatabase(path, version:5, onCreate: createTable);
  }

//create table
  static void createTable(Database db, int version) {
    //create table mytable (id integer primary key autoincrement, text text)
    String sql = '''create table $table_name (
    $col_id integer primary key autoincrement, 
    $col_title integer, $col_path text)''';
    db.execute(sql);
  }
//insert operation
   Future <int>insertIntoTable(Film f) async {
    //values => Map<String,dynamic>
    var db = await this.database;
    db.insert(table_name,f.ConvertToMap());
  }
//select operation
  Future<List<Map<String, dynamic>>> selectFromTable(String order) async {
    var db = await database;
    return db.rawQuery("select * from $table_name order by $col_id $order");
  }
  Future<List<Film>> getNotes(String order) async {
    var listOfMap = await selectFromTable(order);
    List<Film> notes = List();
    for (int i = 0; i < listOfMap.length; i++) {
      notes.add(Film.ConvertFromMap(listOfMap[i]));
    }
    return notes;
  }
  Future <int> deletefromtable (int id)
  async {
    var db = await database;

      return  await db.rawDelete('DELETE FROM $table_name WHERE $col_title=$id');
  }
}
