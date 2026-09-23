import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../database/azbaziQueries.dart';
import '../models/questionModel.dart';

enum QuestionStatus { ExistQuestions, BlankQuestions, Initializing, Uninitialized }

class QuestionProvider extends ChangeNotifier{
  questionModel? _question;
  QuestionStatus _questionStatus = QuestionStatus.Uninitialized;
  List<questionModel> _questions = <questionModel>[];

  QuestionProvider.instance(String azbaziId, int qsState) {

    getQuestions(azbaziId, qsState);
    _onInstanceStateChanged(_questions);
  }

  List<questionModel> get getAzbaziQuestions => _questions;
  questionModel? get getOneQuestion => _question;
  QuestionStatus get questionStatus => _questionStatus;

  void getQuestions(String azbaziId, int qsState) async{
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    await getQuestionsData( azbaziId, false, qsState);
  }

  Future<List<questionModel>> getQuestionsData(String azbaziId, bool fillPages, int qsState) async {
    try {
      _questionStatus = QuestionStatus.Initializing;
      notifyListeners();
      _questions = await azbazisQueries().getQuestions(azbaziId);
      if(await GlobalKeys.checkInternetConnection()) {
        int nextPageNum = 1;
        int totalPages = 0;
        int limit = 20;
        int offset = 0;
        List<questionModel> _onlineQuestions = [];
        while (!fillPages) {//ta zamanike soalat tamam safahat load nashode bashad edame dahad
          offset = limit * (nextPageNum - 1);
          var url = GlobalKeys.ebargeUrl +
              '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getazbaziqs&orderby=page_num';

          var dio = Dio(GlobalKeys.options);
          FormData formData = new FormData.fromMap({
            "azbazi_id": azbaziId,
            "limit": limit,
            "offset": offset,
            "qstate": qsState,
          });

          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var cookieJar = PersistCookieJar(
              ignoreExpires: true,
              storage: FileStorage(appDocPath + "/.cookies/"));
          dio.interceptors.add(CookieManager(cookieJar));
          var response = await dio.post(url, data: formData);

          nextPageNum = response.data["pages_current"] + 1;
          totalPages = response.data["pages_total"];
          if(nextPageNum > totalPages) fillPages = true;

          var questionsJson = response.data["azbaziqs"];
          for (var oneQuestionJson in questionsJson) {
           // oneQuestionJson["answer_map"] = json.decode(oneQuestionJson["answer_map"].toString());
            oneQuestionJson["answer_map"] = jsonEncode(jsonDecode(oneQuestionJson["answer_map"]));
            oneQuestionJson['myqscore'] = oneQuestionJson['myqscore'].toDouble();
            oneQuestionJson['max_score'] = oneQuestionJson['max_score'].toDouble();
            _onlineQuestions.add(questionModel.fromJson(oneQuestionJson));
          }
        }

        // هشدار (BUG-04): همگام‌سازی تنها پس از دریافت موفقیت‌آمیز «تمام» صفحات سرور
        // انجام می‌شود. اگر داخل حلقه صفحه‌بندی فراخوانی شود، چون مجموعه کامل
        // شناسه‌های سرور هنوز مشخص نیست، سوالات صفحات بعدی به اشتباه «یتیم» تشخیص
        // داده شده و از دیتابیس محلی حذف می‌شوند (حذف مخرب در حالت صفحه‌بندی جزئی).
        // از همین رو `_onlineQuestions` ابتدا در تمام صفحات انباشته می‌شود و سپس
        // یک‌بار، به صورت کامل، همگان می‌گردد.
        await azbazisQueries().syncUserQsOnLocalDB(
            _onlineQuestions, _questions, azbaziId);

        _questions = _onlineQuestions;
      }
      if (_questions.length > 0) {
        _questionStatus = QuestionStatus.ExistQuestions;
        notifyListeners();
      } else {
        _questionStatus = QuestionStatus.BlankQuestions;
        notifyListeners();
      }
    } catch (e) {
      _questionStatus = QuestionStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _questions;
  }

  static Future<Map<String, dynamic>?> upUVQOnlineDB(String qId, String myQRate, List<String>? answerMap) async {
    Map<String, dynamic>? updatedUAzQVRate;
    if (qId != '') {
      try {
        var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=post&module=books&resource=uponlineuqv';
        var dio = Dio();

        var formData = {
          "question_id": qId,
          "myqrate": myQRate,
          "answermap": answerMap,
        };
        String jsonFormattedData = jsonEncode(formData);

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocPath+"/.cookies/"));
        dio.interceptors.add(CookieManager(cookieJar));
        var response =
        await dio.post(
            url,
            options: Options(
                headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                }),
            data: jsonFormattedData
        );

        if (response.statusCode == 200) {
          if (response.data['status'] == "ok") {
            updatedUAzQVRate = response.data['upeduazq'];
          }
          else {
            print('Synced Failed');
          }
        } else {
          print("درخواست با خطا مواجه شد");
        }
      } catch (e) {
        print(e);
      }
    }
    return updatedUAzQVRate;
  }

  static Future<Map<String, dynamic>?> upUVQPageHint(String qId, bool isPageView) async {
    Map<String, dynamic>? upedPageHintRes;
    if (qId != '') {
      try {
        var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=post&module=books&resource=upUVQPageHint';
        var dio = Dio();

        var formData = {
          "question_id": qId,
          "isPageView": isPageView,
        };
        String jsonFormattedData = jsonEncode(formData);

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocPath+"/.cookies/"));
        dio.interceptors.add(CookieManager(cookieJar));
        var response =
        await dio.post(
            url,
            options: Options(
                headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                }),
            data: jsonFormattedData
        );

        if (response.statusCode == 200) {
          if (response.data['status'] == "ok") {
            upedPageHintRes = response.data['upedpagehint'];
          }
          else {
            print('Synced Failed');
          }
        } else {
          print("درخواست با خطا مواجه شد");
        }
      } catch (e) {
        print(e);
      }
    }
    return upedPageHintRes;
  }

  Future<void> _onInstanceStateChanged(List<questionModel> questions) async {
    if (questions.length != 0) {
      _questions = questions;
      _questionStatus = QuestionStatus.ExistQuestions;
    }
    notifyListeners();
  }

}