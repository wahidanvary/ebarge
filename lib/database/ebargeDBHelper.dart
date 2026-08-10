import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ebargeDBHelper {
  ebargeDBHelper.internal();
  static final ebargeDBHelper dbInstance  = ebargeDBHelper._internal();
  factory ebargeDBHelper() => dbInstance;
  ebargeDBHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  final databaseName = "ebarge_db.db";
  static const userTable = 'user_tbl';
  static const booksTable = 'books_tbl';
  static const bargsTable = 'bargs_tbl';
  static const azbaziTable = 'azbazi_tbl';
  static const questionsTable = 'questions_tbl';
  int dBVersion = 1;

  Future<String> getDatabasePath(String dbName) async {
    // Get a location using getDatabasesPath
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    //make sure the folder exists
    if (!await Directory(dirname(path)).exists()) {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }



  Future<Database> _initDatabase() async {
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    Database db = await _getDB();

    return db;
  }

  Future<Database> _getDB() async{
    final path = await _getPath(); // Get a location using getDatabasesPath

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: dBVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print("Creating Table");
    }

    const queryUser = '''CREATE TABLE IF NOT EXISTS $userTable
      (
        status TEXT,
        user_id TEXT NOT NULL,
        username TEXT NOT NULL,
        name TEXT,
        family TEXT,
        email TEXT,
        birthday TEXT,
        diploma TEXT,
        proficiency TEXT,
        edu_code TEXT,
        tell_mobile TEXT,
        zafran REAL,
        time_balance INTEGER,
        isactive_timebal INTEGER,
        app_streak INTEGER,
        max_app_streak INTEGER,
        parent_lock_pin TEXT,
        grade_lock INTEGER,
        state INTEGER,
        wallet_id INTEGER,
        gold_amount INTEGER,
        modified_date TEXT,
        detail TEXT,
        password TEXT,
        session_id TEXT,
        error_code TEXT,
        error_description TEXT,
        is_guest INTEGER,
        session_expire INTEGER
      )''';
    await db.execute(queryUser);

    const queryBooks = '''CREATE TABLE IF NOT EXISTS $booksTable
      (
        book_id TEXT NOT NULL,
        tids TEXT,
        admin_id TEXT,
        admin_name TEXT,
        assistant_id TEXT,
        assistant_name TEXT,
        book_name TEXT NOT NULL,
        bchap_id TEXT,
        avatar TEXT,
        small_avatar TEXT,
        ebavatar TEXT,
        small_ebavatar TEXT,
        section_num TEXT,
        ref_link TEXT,
        bchap_pdf TEXT,
        ebarge_pdf TEXT,
        pdfsize TEXT,
        pages_count TEXT,
        gap_pages TEXT,
        rate TEXT,
        edu_year TEXT,
        state TEXT,
        azbazi_count TEXT,
        status TEXT,
        error_code TEXT,
        error_description TEXT
      )''';
    await db.execute(queryBooks);

    const queryBargs = '''CREATE TABLE IF NOT EXISTS $bargsTable
      (
        bargid TEXT NOT NULL,
        userid TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT,
        book_id TEXT,
        item_id TEXT,
        wdate TEXT,
        detail TEXT
      )''';
    await db.execute(queryBargs);

    const queryQuestions = '''CREATE TABLE IF NOT EXISTS $questionsTable
      (
        "question_id" TEXT NOT NULL,
        "azbazi_id" TEXT NOT NULL,
        "book_id" TEXT NOT NULL,
        "page_id" TEXT NOT NULL,
        "user_id" TEXT NOT NULL,
        "editor_id" TEXT,
        "book_chapter" TEXT NOT NULL,
        "page_num" INTEGER NOT NULL,
        "que_content" TEXT NOT NULL,
        "answer_map" TEXT NOT NULL,
        "que_level" TEXT NOT NULL,
        "que_type" TEXT NOT NULL,
        "question_in" TEXT,
        "que_answer" TEXT,
        "testi_answer" TEXT,
        "que_score" TEXT,
        "que_answertime" TEXT,
        "que_rate" TEXT,
        "que_source" TEXT,
        "print_count" TEXT,
        "created_date" TEXT,
        "modified_date" TEXT,
        "qstate" TEXT NOT NULL,
        "guide" TEXT,
        "max_score" REAL,
        "qholes" INTEGER,
        "first_solver" TEXT,
        "myqscore" REAL,
        "qview_count" INTEGER NOT NULL,
        "myqrate" TEXT,
        "visit_date" TEXT,
        "solved_date" TEXT,
        "uvstate" INTEGER,
        "status" TEXT,
        "error_code" TEXT,
        "error_description" TEXT
      )''';
    await db.execute(queryQuestions);

    const queryAzbazies = '''CREATE TABLE IF NOT EXISTS $azbaziTable
      (
        "azbazi_id" TEXT NOT NULL,
        "book_id" TEXT,
        "book_name" TEXT,
        "owner_id" TEXT,
        "editor_id" TEXT,
        "owner_name" TEXT,
        "isteacher" TEXT,
        "thumb_link" TEXT,
        "title" TEXT,
        "note" TEXT,
        "qcount" TEXT,
        "allholes" INTEGER,
        "max_score" INTEGER,
        "first_pageq" TEXT,
        "until_pageq" TEXT,
        "average_scores" TEXT,
        "rate" TEXT,
        "rate_count" TEXT,
        "entrant_count" TEXT,
        "qview_count" INTEGER,
        "created_date" TEXT,
        "modified_date" TEXT,
        "state" TEXT,
        "rejectreasons" TEXT,
        "azbaziaccess" TEXT,
        "mycoins" INTEGER,
        "myscore" REAL,
        "myview_count" INTEGER,
        "mysolved_count" INTEGER,
        "myfsolved_count" INTEGER,
        "myfsolved_holes" INTEGER,
        "qs_try_streak" INTEGER,
        "myRate" TEXT,
        "myvisit_date" TEXT,
        "mystate" TEXT,
        "aiModels" TEXT,
        "status" TEXT,
        "error_code" TEXT,
        "error_description" TEXT
      )''';
    await db.execute(queryAzbazies);
    // todo: Add your code here ...
  }

  Future<String> _getPath() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);
    return path;
  }

  Future close() async {
    final db = await dbInstance.database;
    _database = null;
    return db.close();
  }
}
