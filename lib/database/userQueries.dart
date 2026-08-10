import 'package:ebarge/database/ebargeDBHelper.dart';
import 'package:ebarge/models/shopModel.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/userModel.dart';

class userQueries{

  static const userTable = 'user_tbl';

  final conn = ebargeDBHelper.dbInstance;

  Future<void> saveUserToDB(UserModel _user) async {
    Database? _db = await conn.database;
    try {
      await _db.delete(userTable);
      // In this case, Do not replace any previous data.
      await _db.insert(
        userTable,
        _user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      //print(res);
    } catch (e) {
      if (kDebugMode) {
        print(_user.userid);
      }
      if (kDebugMode) {
        print(e);
      }
    }
    // Query the table for The User.
  }

  Future<UserModel> getUser(String _userName) async {
    Database? _db = await conn.database;
    final List<Map<String, dynamic>>? dbUser = await _db.rawQuery(
        'SELECT * FROM $userTable where username=?', [_userName]);
    UserModel _user = UserModel();
    if(dbUser!.isNotEmpty)
      _user =  UserModel.fromJson(dbUser[0]);
    return _user;
  }

  updateUser(UserModel _user) async {
    Database? _db = await conn.database;
    await _db.update(
      userTable,
      _user.toJson(),
      // Ensure that the Dog has a matching id.
      where: "username = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [_user.username],
    );
  }
}