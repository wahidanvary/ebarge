import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/azbazi_service.dart';

enum AzbaziStatus { ExistAzbaziha, BlankAzbaziha, Initializing, Uninitialized }

class AzbaziProvider extends ChangeNotifier{
  azbaziModel? _azbazi;
  var _azbaziInstance;
  AzbaziStatus _azbaziStatus = AzbaziStatus.Initializing;
  List<azbaziModel> _Azbaziha = <azbaziModel>[];
  List<dynamic> _azbaziPageNumToId = [];
  int? _totalPages = 0;

  AzbaziProvider.instance(String bookId, String AzbaziState, String azbaziAccess, int pageNumber, String orderBy, String orderDir, String searchTXT)
      : _azbaziInstance = azbaziModel() {

    getAzbaziha(bookId, AzbaziState, azbaziAccess, pageNumber, orderBy, orderDir, searchTXT);
    _onInstanceStateChanged(_Azbaziha, _totalPages!);
  }

  List<azbaziModel> get getBookAzbaziha => _Azbaziha;
  azbaziModel get getOneAzbazi => _azbazi!;
  AzbaziStatus get azbaziStatus => _azbaziStatus;
  int get getTotalPages => _totalPages!;
  List<dynamic> get getAzbaziPageNumToId=> _azbaziPageNumToId;

  void getAzbaziha(String bookId, String AzbaziState, String azbaziAccess, int pageNumber, String orderBy, String orderDir, String searchTXT) async{
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    await getCheckAzbazihaData( bookId, AzbaziState, azbaziAccess, pageNumber, orderBy, orderDir, searchTXT);
  }

  Future<List<azbaziModel>> getCheckAzbazihaData(String bookId, String AzbazihaState, String azbaziAccess, int pageNumber, String orderBy, String orderDir, String searchTXT) async {
    try {
      _azbaziStatus = AzbaziStatus.Initializing;
      notifyListeners();
      if(await GlobalKeys.checkInternetConnection()) {
        var url = GlobalKeys.ebargeUrl +
            '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getazbazis';
        int limit = 10;
        int offset = limit * (pageNumber - 1);
        var dio = Dio(GlobalKeys.options);
        FormData formData = new FormData.fromMap({
          "book_id": bookId,
          "state": AzbazihaState,
          "azbaziaccess": azbaziAccess,
          "limit": limit,
          "offset": offset,
          "orderby": orderBy,
          "orderdir": orderDir,
          "search": searchTXT,
        });

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocPath + "/.cookies/"));
        dio.interceptors.add(CookieManager(cookieJar));
        var response = await dio.post(url, data: formData);

        var pagesTotal = response.data["pages_total"];
        _totalPages = pagesTotal;
        if(_totalPages == null) _totalPages = 0;
        var AzbazihaJson = response.data["azbazis"];

        for (var oneAzbaziJson in AzbazihaJson) {
          double roundedRate = double.parse(oneAzbaziJson['rate']);
          String rate = roundedRate.toStringAsFixed(1);
          oneAzbaziJson['myscore'] = oneAzbaziJson['myscore'].toDouble();
          var azbaziItem = azbaziModel.fromJson(oneAzbaziJson);
          azbaziItem.rate = rate;
          SharedPreferences sharedPreferences = await SharedPreferences
              .getInstance();
          sharedPreferences.setInt(
              "mycoins" + azbaziItem.azbazi_id!, azbaziItem.myCoins!);
          sharedPreferences.setDouble(
              "myscore" + azbaziItem.azbazi_id!, azbaziItem.myScore!);
          _Azbaziha.add(azbaziItem);
        }
        if (_Azbaziha.length > 0) {
          _azbaziStatus = AzbaziStatus.ExistAzbaziha;
          notifyListeners();
        } else {
          _azbaziStatus = AzbaziStatus.BlankAzbaziha;
          notifyListeners();
        }
      } else {
        _azbaziStatus = AzbaziStatus.Uninitialized;
        notifyListeners();
      }
    } catch (e) {
      _azbaziStatus = AzbaziStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _Azbaziha;
  }

  // Future<azbaziModel?> addUpAzScoreRate(azbaziModel oldAzbazi, String rate) async{
  //   final _azbazi = await AzbaziService().addUpAzScoreRate(oldAzbazi, rate);
  //
  //   return _azbazi;
  // }

  Future<azbaziModel?> azCheckResult(String azbaziId, String newState, String txtReason, String userBarg) async{
    try {
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "azbazi_id": azbaziId,
        "newstate": newState,
        "reason": txtReason,
        "userbarg": userBarg,
        "action": "post",
        "module": "books",
        "resource": "azcheckresult",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        double roundedRate = double.parse(response.data['rate']);
        String rate = roundedRate.toStringAsFixed(1);
        response.data['myscore'] = response.data['myscore'].toDouble();
        _azbazi = azbaziModel.fromJson(response.data);
        _azbazi?.rate = rate;
        _azbazi?.azbazi_id = azbaziId;
      } else {
        print("درخواست با خطا مواجه شد");
      }
    } catch (e) {
      print(e);
    }

    return _azbazi;
  }

  Future<void> _onInstanceStateChanged(List<azbaziModel> Azbaziha, int totalPages) async {
    if (Azbaziha.length != 0){
      _Azbaziha = Azbaziha;
      _totalPages = totalPages;
      _azbaziStatus = AzbaziStatus.ExistAzbaziha;
    }

    notifyListeners();
  }

}