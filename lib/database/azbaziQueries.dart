
import 'package:ebarge/providers/questionProvider.dart';
import 'package:intl/intl.dart';

import 'package:ebarge/database/ebargeDBHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ebarge/models/questionModel.dart';
import '../models/azbaziModel.dart';
import '../providers/azbaziProvider.dart';
import '../services/azbazi_service.dart';

class azbazisQueries{

  static const questionsTable = 'questions_tbl';
  static const azbaziTable = 'azbazi_tbl';

  final conn = ebargeDBHelper.dbInstance;

  Future<List<questionModel>> getQuestions(String azbaziId) async {
   // List<question> fetchedQuestions = [];
    //final List<Map<String, dynamic>> dbQuestionsMap = await (await conn.db)!.rawQuery('SELECT * FROM $questionsTable LIMIT 10');
    final List<Map<String, Object?>>? dbQuestionsMap =
        await (await conn.database).query(questionsTable,
          where: "azbazi_id = ?",
          // Pass the Dog's id as a whereArg to prevent SQL injection.
          whereArgs: [azbaziId],
            orderBy: 'page_num ASC'
        );
    return List.generate(dbQuestionsMap!.length, (i) {
      return questionModel.fromJson(dbQuestionsMap[i]);
    });
    /*for (var oneDbQuestion in dbQuestionsMap!) {
      fetchedQuestions.add(question.fromJson(oneDbQuestion));
    }
    return fetchedQuestions;*/
  }

  Future<void> syncUserQsOnLocalDB(
      List<questionModel> onlineAzbaziQs,
      List<questionModel> oldLocalAzbaziQs,
      String azbaziId) async {

    Database? _db = await conn.database;

    // ۱. بهینه‌سازی جستجو: تبدیل لیست محلی به Map برای سرعت فوق‌العاده بالاتر
    Map<String, questionModel> localMap = {
      for (var q in oldLocalAzbaziQs) q.question_id!: q
    };

    // ۲. نگهداری IDهای سرور برای حذف موارد اضافی در پایان
    List<String> onlineIds = onlineAzbaziQs.map((e) => e.question_id!).toList();

    try {
      // استفاده از Transaction برای امنیت و سرعت بسیار بالاتر در دیتابیس
      await _db.transaction((txn) async {
        for (var oneOnlineAzbQ in onlineAzbaziQs) {

          // پیدا کردن رکورد محلی از Map (بسیار سریع)
          questionModel? localTempQ = localMap[oneOnlineAzbQ.question_id];

          if (localTempQ == null) {
            // الف) اگر در محلی نبود -> درج جدید
            await txn.insert(
              questionsTable,
              oneOnlineAzbQ.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            // ب) اگر وجود داشت -> بررسی تاریخ برای بروزرسانی
            DateTime onlineModified = DateTime.tryParse(oneOnlineAzbQ.modified_date ?? "") ?? DateTime.utc(0);
            DateTime localModified = DateTime.tryParse(localTempQ.modified_date ?? "") ?? DateTime.utc(0);

            // شرط بروزرسانی (ساده شده)
            if (azbaziId != "5" || onlineModified.isAfter(localModified)) {
              await txn.update(
                questionsTable,
                oneOnlineAzbQ.toJson(),
                where: 'question_id = ?',
                whereArgs: [oneOnlineAzbQ.question_id],
              );
            }
          }
        }

        // ۳. عملیات حذف رکوردهای یتیم (Orphaned Records)
        // حذف سوالاتی که در سرور نیستند اما در لوکال باقی مانده‌اند
        if (onlineIds.isNotEmpty) {
          // ایجاد رشته‌ای به شکل '1','2','3' برای کوئری
          String placeholders = List.filled(onlineIds.length, '?').join(',');
          await txn.delete(
            questionsTable,
            where: 'question_id NOT IN ($placeholders)',
            whereArgs: onlineIds,
          );
        }
      });

      print("همگام‌سازی با موفقیت انجام شد.");
    } catch (e) {
      if (kDebugMode) print("خطا در همگام‌سازی: $e");
    }
  }

  Future<Map<String, dynamic>?> upUVQOnlineDB(String qId, String myQRate, List<String>? answerMap) async {
    Map<String, dynamic>? updatedUAzQVRate;
    if (qId.isNotEmpty) {
      updatedUAzQVRate = (await QuestionProvider.upUVQOnlineDB(qId, myQRate, answerMap))!;
    }

    return updatedUAzQVRate;
  }

  Future<Map<String, dynamic>?> upUVQPageHint(String qId, bool isPage) async {
    Map<String, dynamic>? updatedUVQPageHint;
    if (qId.isNotEmpty) {
      updatedUVQPageHint = (await QuestionProvider.upUVQPageHint(qId, isPage))!;
    }

    return updatedUVQPageHint;
  }

  Future<questionModel> getOneQuestion(String qId) async {
    final List<Map<String, Object?>>? dbOneQMap =
    await (await conn.database).query(questionsTable,
      where: "question_id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [qId],
    );
    return questionModel.fromJson(dbOneQMap![0]);
  }

  updateQuestion(questionModel question) async{
    await (await conn.database).update(
      questionsTable,
      question.toJson(),
      // Ensure that the Dog has a matching id.
      where: "question_id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [question.question_id],
    );
  }

  // deleteQuestion(String qId) async {
  //   await (await conn.database).delete(
  //       questionsTable,
  //       where: "question_id = ?",
  //       whereArgs: [qId]
  //   );
  // }

  // Future<azbaziModel> addupAzScoreRate(azbaziModel updatedAzbazi) async {
  //   if (updatedAzbazi.azbazi_id!.isNotEmpty) {
  //     updatedAzbazi = (await AzbaziService().addUpAzScoreRate(updatedAzbazi, ""))!;
  //    /* azbaziViews = azbazi.entrantCount;
  //     mycRate = _azbazi.rate;
  //     rateCount = _azbazi.allRateCount;*/
  //   }
  //   return updatedAzbazi;
  // }

  updateAzbazi(azbaziModel azbazi) async{

  await (await conn.database).update(
      azbaziTable,
      azbazi.toJson(),
      // Ensure that the Dog has a matching id.
      where: "azbazi_id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [azbazi.azbazi_id],
    );
  }
}