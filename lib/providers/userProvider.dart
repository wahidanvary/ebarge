import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/database/userQueries.dart';
import 'package:ebarge/models/shopModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as InAppWW;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/ebargeDBHelper.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserProvider extends ChangeNotifier{
  UserModel? _user;
  var _auth;
  Status? _status;
  String? pendingAzbaziLink;

  UserProvider.instance()
      : _auth = UserModel() {
    //_auth.listen(_onAuthStateChanged);
    checkLogin();
    _onAuthStateChanged(_auth);
  }

  UserModel? get getUserProvider => _user;
  Status? get status => _status;

  void checkLogin() async{
      _user = await onStartUp();
  }

  Future<UserModel?> onStartUp() async {
    _status = Status.Authenticating;
    notifyListeners();
    final storage = new FlutterSecureStorage();
    String? _username = await storage.read(key: 'username');
    String? _password = await storage.read(key: 'password');
    if (_username != null) {
      try {
        _status = Status.Authenticated;
        notifyListeners();

        _user = await userQueries().getUser(_username);
        if (_user == null)
          _user = UserModel();

        if(await GlobalKeys.checkInternetConnection()) {
          var url = GlobalKeys.ebargeUrl +
              '/index.php?option=com_jbackend&view=request&action=get&module=user&resource=status';
          var dio = Dio(GlobalKeys.options);
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var cookieJar = PersistCookieJar(
              ignoreExpires: true,
              storage: FileStorage(appDocPath + "/.cookies/"));
          dio.interceptors.add(CookieManager(cookieJar));
          var response = await dio.get(url);

          UserModel? _userOnline;
          if (response.statusCode == 200) {
            if (response.data["zafran"] != null)
              response.data["zafran"] = response.data["zafran"].toDouble();
            else
              response.data["zafran"] = 0.0;
            if(response.data["user_id"] == 0 )
              response.data["user_id"] = "0";
            _userOnline = UserModel.fromJson(response.data);
            if (_userOnline.status == "ko" || _userOnline.userid == "0") {
              _userOnline = await this.sendLoginRequest(_username, _password!);
            }
            if (_userOnline != null && _userOnline.status != "ko" && _userOnline.userid != "0"){
              if (_user?.userid == null || _user?.userid == "0")
                await userQueries().saveUserToDB(_userOnline);
              else
                await userQueries().updateUser(_userOnline);
              _user = _userOnline;
            }
          }
        } else {
          _status = Status.Uninitialized;
          notifyListeners();
        }
      } catch (e) {
        //_status = Status.Uninitialized;
        //notifyListeners();
        print(e);
      }
    } else {
      _status = Status.Unauthenticated;
      notifyListeners();
    }

    return _user;
  }

  Future<List<shopModel>> goldShopData() async {
    List<shopModel> _shopData = <shopModel>[];
    try {
      var url = GlobalKeys.ebargeUrl +
          '/index.php?option=com_jbackend&view=request&action=get&module=user&resource=goldshopdata';
      var dio = Dio(GlobalKeys.options);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath + "/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        List productIds = response.data["productIds"];
        int baseGoldPrice = response.data["baseGoldPrice"];
        List sellStatuses = response.data["sellStatuses"];
        List priceAmounts = response.data["priceAmounts"];
        List bonusPercents = response.data["bonusPercents"];
        List bonusZafrans = response.data["bonusZafrans"];
        for (int i = 0; i < priceAmounts.length; i++) {
          shopModel _oneShopData = shopModel();
          _oneShopData.productId = productIds[i];
          _oneShopData.sellStatus = sellStatuses[i];
          _oneShopData.priceAmount = priceAmounts[i];
          _oneShopData.bonusPercent = bonusPercents[i];
          _oneShopData.bonusZafran = bonusZafrans[i].toDouble();
          _oneShopData.goldAmount = (priceAmounts[i] / ((baseGoldPrice * (100 - bonusPercents[i])) / 100)).toInt();
          _shopData.add(_oneShopData);
        }
      }
    } catch (e) {
      print(e);
    }

    return _shopData;
  }



  Future<String> signOut() async {
    String snackBarTxt = "error";
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=user&resource=logout';

      var dio = Dio(GlobalKeys.options);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.get(url);

      if(response.statusCode==200) {
        //Successful
        _user = UserModel.fromJson(response.data);

        final storage = new FlutterSecureStorage();
        await storage.deleteAll();
        InAppWW.CookieManager().deleteCookies(url: InAppWW.WebUri.uri(Uri.parse(GlobalKeys.ebargeUrl),),);
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.clear();
        final databaseName = "ebarge_db.db";
        final path = await getDatabasePath(databaseName);
        final conn = ebargeDBHelper.dbInstance;
        await conn.close();
        Database? _db = await conn.database;
        await _db.delete('user_tbl');
        await _db.delete('books_tbl');
        await _db.delete('bargs_tbl');
        await _db.delete('azbazi_tbl');
        await _db.delete('questions_tbl');
        ebargeDBHelper().close();
        await deleteDatabase(path);
        if (_user!.status == "ko") {
          snackBarTxt = "ko";
        } else if (_user!.status == "ok") {
          _status = Status.Unauthenticated;
          notifyListeners();
          _user = null;
          snackBarTxt = "success";
        }
      }else {
        snackBarTxt = "درخواست با خطا مواجه شد";
      }
    } catch (e) {
      print(e);
    }

    return snackBarTxt;
  }

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


  Future<dynamic> signUpUser(UserModel user) async {
    try {
      _status = Status.Unauthenticated;
      //notifyListeners();
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      String userMobileNum = "0"+user.tell_mobile!;

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "username": user.username,
        "firstname": user.name,
        "lastname": user.family,
        "mobile": userMobileNum,
        "email": user.email,
        "password": user.password,
        "action": "post",
        "module": "user",
        "resource": "mobileregister",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        _status = Status.Uninitialized;
        print("درخواست با خطا مواجه شد");
        return null;
      }
    } catch (e) {
      _status = Status.Uninitialized;
      print(e);
      return null;
    }
  }

  Future<UserModel?> signUpConfirm(String code, UserModel uncheckedUser) async {
    try {
      _status = Status.Unauthenticated;
      //notifyListeners();
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "code": code,
        "action": "post",
        "module": "user",
        "resource": "mobileconfirm",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        //Successful
        String _username = uncheckedUser.username!;
        String _password = uncheckedUser.password!;
        if (response.data["status"] == "ok") {
          _user = await this.sendLoginRequest(_username, _password);
                } else {
          response.data["status"] = 'ko';
          _user = UserModel.fromJson(response.data);
        }
      } else {
        _status = Status.Uninitialized;
        notifyListeners();
        print("درخواست با خطا مواجه شد");
        return null;
      }
    } catch (e) {
      _status = Status.Uninitialized;
      notifyListeners();
      print(e);
      return null;
    }

    return _user;
  }

  Future<UserModel?> sendLoginRequest(String username, String password) async{
    try {
      if(_status != Status.Authenticating){
        _status = Status.Authenticating;
        //notifyListeners();
      }

      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "username": username,
        "password": password,
        "action": "post",
        "module": "user",
        "resource": "login",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        //Successful
        if (response.data["zafran"] != null)
          response.data["zafran"] = response.data["zafran"].toDouble();
        else
          response.data["zafran"] = 0.0;
        _user = UserModel.fromJson(response.data);

        if(_user!.status == "ok") {
          final storage = new FlutterSecureStorage();
          await storage.write(key: "username", value: _user!.username);
          await storage.write(key: "password", value: password);

          _status = Status.Authenticated;
          notifyListeners();
        } else if(_user!.error_code != "USR_ALI") {
          final storage = new FlutterSecureStorage();
          await storage.deleteAll();

          print("نام کاربری یا رمز عبور اشتباه است!");
          _status = Status.Unauthenticated;
          notifyListeners();
        } else {
          _status = Status.Authenticated;
          notifyListeners();
        }
      } else {
        _status = Status.Uninitialized;
        notifyListeners();
        print("اتصال به سرور با مشکل روبرو شد!");
        return null;
      }
    } catch (e) {
      _status = Status.Uninitialized;
      notifyListeners();
      print(e);

      return null;
    }

    return _user;
  }

  Future<void> _onAuthStateChanged(UserModel userData) async {
    if ((userData.status == "ko" && userData.error_code != "USR_ALI") || userData.userid == "0" || _status != Status.Unauthenticated) {
      _status = Status.Authenticating;
    } else if ((userData.status == "ok" && userData.userid != "0") || userData.error_code == "USR_ALI") {
      _user = userData;
      _status = Status.Authenticated;
    }

    notifyListeners();
  }
}