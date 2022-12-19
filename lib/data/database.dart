import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:drinkwaterpro/models/user.dart';
import 'package:drinkwaterpro/models/param.dart';
import 'package:drinkwaterpro/data/globals.dart' as globals;
import 'package:drinkwaterpro/pages/home/home_page.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {

    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'drinkwater_r.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users(id INTEGER, first_name TEXT NOT NULL, last_name TEXT NOT NULL, birthday DATE, city TEXT, email TEXT, phone TEXT, timezone TEXT, srv INTEGER)",
        );
        await database.execute(
          "CREATE TABLE settings(name TEXT NOT NULL, value TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(User user) async {
    int result = 0;
    final Database db = await initializeDB();

    result = await db.insert('users', user.toMap());
    print('USER: Добавили пользователя в хранилище');
    globals.service = user.srv!;
    return result;
  }

  Future<int> removeLoginUser() async {
    int result = 0;
    final Database db = await initializeDB();

    result =  await db.delete(
      'users',
      where: "id > 0",
    );
    print('USER: Удалили всех пользователей из хранилища');
    globals.isLoggedIn = false;
    return result;
  }

  Future<User> userInfo() async {
    bool result;
    User user = User();
    globals.isLoggedIn = false;
    final Database db = await initializeDB();
    List<Map> query = await db.query(
      'users',
      where: "id > 0",
    );
    query.forEach((row) {
      user = User.fromMap(row);
    });
    print("USER: достали из базы пользователя "+ user.email.toString());
    globals.userId = int.parse(user.id.toString());
    globals.service = user.srv!;
    return user;
  }

  Future<bool> isLoginUser() async {
    print('AUTH: Проверяем пользователя в базе ');
    bool result;
    final Database db = await initializeDB();
    List<Map> query = await db.query(
        'users',
        where: "id > 0",
        );
    result = query.length>0? globals.isLoggedIn =  true : globals.isLoggedIn = false;
    //globals.isLoggedIn = true;
    //result = globals.isLoggedIn;
    print('AUTH: Результат проверки: '+result.toString());
    return result;
  }

  Future<int> setParam(String name, String value) async {
    int result = 0;
    final Database db = await initializeDB();

    result =  await db.delete(
      'settings',
      where: "name = ?",
      whereArgs: [name],
    );

    result = await db.insert(
        'settings',
        {'name': name, 'value': value}
    );

    return result;
  }


  Future<dynamic> getParam(String name) async {

    List result;
    final Database db = await initializeDB();
    List<Map> query = await db.query(
      'settings',
      where: "name = ?",
      whereArgs: [name],
      limit: 1
    );
    //query.forEach((row) => result = jsonDecode(row.toString()));
    return query[0]['value'];
  }

}