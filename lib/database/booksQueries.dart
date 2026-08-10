import 'package:ebarge/database/ebargeDBHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bookModel.dart';

class booksQueries{

  static const booksTable = 'books_tbl';

  final conn = ebargeDBHelper.dbInstance;

  Future<List<bookModel>> getBooks() async {
    List<bookModel> fetchedBooks = [];
    final dbBooksMap = await (await conn.database).query(booksTable);
    for (var oneDbBook in dbBooksMap) {
      fetchedBooks.add(bookModel.fromJson(oneDbBook));
    }
    return fetchedBooks;
  }

  Future<void> saveUserBooksToDB(List<bookModel> userBooks) async {
    Database? _db = await conn.database;
    await _db.delete(booksTable);
    try {
      for (var oneUserBook in userBooks) {
        int? res = await _db.insert(
          booksTable,
          oneUserBook.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print(res);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // Query the table for The User.
  }
}