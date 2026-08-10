import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/database/bargesQueries.dart';
import 'package:ebarge/models/bargModel.dart';
import 'package:ebarge/models/rankModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum BargStatus { ExistBarges, BlankBarges, Initializing, Uninitialized }

class BargProvider extends ChangeNotifier{
  bargModel? _barg;
  BargStatus _bargStatus = BargStatus.Uninitialized;
  List<bargModel> _barges = <bargModel>[];

  BargProvider.instance(String bookId) {

    getBarges(bookId);
    _onInstanceStateChanged(_barges);
  }

  List<bargModel> get getPageBarges => _barges;
  bargModel? get getOneBarg => _barg;
  BargStatus get bargStatus => _bargStatus;

  void getBarges(String bookId) async{
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    await getBargesData( bookId );
  }

  Future<List<bargModel>> getBargesData(String bookId) async {

    try {
      _bargStatus = BargStatus.Initializing;
      notifyListeners();
      /*bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }*/
      _barges = await bargesQueries().getBarges();
      if(await GlobalKeys.checkInternetConnection()) {
        var url = GlobalKeys.ebargeUrl +
            '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getbarges';

        var dio = Dio(GlobalKeys.options);
        FormData formData = new FormData.fromMap({
          "orderdir": "desc",
          "book_id": bookId,
        });

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocPath + "/.cookies/"));
        dio.interceptors.add(CookieManager(cookieJar));
        var response = await dio.post(url, data: formData);

        List<bargModel> _onlineBarges = [];
        var bargesJson = response.data["barges"];
        for (var j in bargesJson) {
          var bargItem = bargModel(
              j['barg_id'],
              j['user_id'],
              j['amount'],
              j['type'],
              j['book_id'],
              j['item_id'],
              j['wdate'],
              j['detail']
          );
          _onlineBarges.add(bargItem);
        }
        await bargesQueries().saveUserBargsToDB(_onlineBarges);
        _barges = _onlineBarges;
      }
      if (_barges.length > 0) {
        _bargStatus = BargStatus.ExistBarges;
        notifyListeners();
      } else {
        _bargStatus = BargStatus.BlankBarges;
        notifyListeners();
      }
    } catch (e) {
      _bargStatus = BargStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _barges;
  }

  Future<List<RankModel>> getTopRanks(String bookId) async {
    List<RankModel> _ranks = <RankModel>[];
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getranks';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "book_id": bookId,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      var ranksJson = response.data["ranks"];
      for (var j in ranksJson) {
        var rankItem = RankModel(
            j['user_id'],
            j['user_name'],
            j['totalamount'],
            j['rank'],
        );
        _ranks.add(rankItem);
      }

    } catch (e) {
      print(e);
    }

    return _ranks;
  }

  Future<String?> getUserWallet(String bookId, String itemId) async {
    if(await GlobalKeys.checkInternetConnection()) {
      try {
        var url = GlobalKeys.ebargeUrl +
            '/index.php?option=com_jbackend&view=request';
        var dio = Dio();
        FormData formData = new FormData.fromMap({
          "action": "get",
          "module": "books",
          "resource": "getwallet",
          "book_id": bookId,
          "item_id": itemId,
        });

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocPath + "/.cookies/"));
        dio.interceptors.add(CookieManager(cookieJar));
        var response = await dio.post(url, data: formData);

        if (response.statusCode == 200) {
          //Successful
          if (response.data['status'] == "ok") {
            return response.data['walletamount'];
          }
        } else {
          print("درخواست با خطا مواجه شد");
        }
      } catch (e) {
        print(e);
      }
    }

    return "0";//Agar dar sharayet bala chizi estekhraj nashod 0 bargardanad.
  }

  Future<void> _onInstanceStateChanged(List<bargModel> barges) async {
    if (barges.length == 0) {
      _bargStatus = BargStatus.BlankBarges;
    } else {
      _barges = barges;
      _bargStatus = BargStatus.ExistBarges;
    }

    notifyListeners();
  }

}