import 'package:ebarge/database/ebargeDBHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bargModel.dart';

class bargesQueries{

  static const bargsTable = 'bargs_tbl';

  final conn = ebargeDBHelper.dbInstance;

  Future<void> saveUserBargsToDB(List<bargModel> _userBarges) async {
    Database? _db = await conn.database;
    await _db.delete(bargsTable);
    try {
      // In this case, Do not replace any previous data.
      for (var oneUserBarg in _userBarges) {
        int? res = await _db.insert(
          bargsTable,
          {
            'bargid': oneUserBarg.barg_id,
            'userid': oneUserBarg.user_id,
            'amount': oneUserBarg.amount,
            'type': oneUserBarg.type,
            'book_id': oneUserBarg.book_id,
            'item_id': oneUserBarg.item_id,
            'wdate': oneUserBarg.wdate,
            'detail': oneUserBarg.detail
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      //  print(res);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // Query the table for The User.
  }


  Future<List<bargModel>> getBarges() async {
    List<bargModel> fetchedBarges = [];
    final List<Map<String, dynamic>>? dbBarges = await (await conn.database).rawQuery(
        'SELECT * FROM $bargsTable');
    for (var oneDbBarg in dbBarges!) {
      var bargItem = bargModel(
          oneDbBarg['bargid'],
          oneDbBarg['userid'],
          oneDbBarg['amount'],
          oneDbBarg['type'],
          oneDbBarg['book_id'],
          oneDbBarg['item_id'],
          oneDbBarg['wdate'],
          oneDbBarg['detail']
      );
      fetchedBarges.add(bargItem);
    }
    return fetchedBarges;
  }
}