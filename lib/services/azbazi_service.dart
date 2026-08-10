import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzbaziService {
  /// واکشی اطلاعات کامل یک آزبازی + جزئیات کتاب و وضعیت کاربر
  // Future<Map<String, dynamic>> fetchAzbaziBookData(String azbaziId) async {
  //   try {
  //     bool isAccess = await AccessCheck().hasAccessTime();
  //     if (!isAccess) {
  //       UserProvider userProvider = UserProvider.instance();
  //       await userProvider.onStartUp();
  //     }
  //
  //
  //
  //     var url = GlobalKeys.ebargeUrl +
  //         '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getAzbaziBook';
  //     // 🔹 آماده‌سازی درخواست
  //     var dio = Dio(GlobalKeys.options);
  //     // 🔹 تنظیم کوکی‌ها
  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     String appDocPath = appDocDir.path;
  //     var cookieJar = PersistCookieJar(
  //         ignoreExpires: true,
  //         storage: FileStorage(appDocPath + "/.cookies/"));
  //     dio.interceptors.add(CookieManager(cookieJar));
  //
  //     FormData formData = FormData.fromMap({
  //       "azbazi_id": azbaziId,
  //     });
  //
  //     var response = await dio.post(url, data: formData);
  //
  //     if (response.statusCode == 200 && response.data != null) {
  //       var data = response.data;
  //       // انتظار داریم ساختار بازگشتی چیزی شبیه به:
  //       // {
  //       //   "azbazi": {...},
  //       //   "book": {...},
  //       //   "user": {...}
  //       // }
  //       return {
  //         "azbazi": data["azbazi"],
  //         "book": data["book"],
  //         "user": data["user"]
  //       };
  //     } else {
  //       throw Exception("❌ دریافت داده از سرور ناموفق بود (${response.statusCode})");
  //     }
  //   } catch (e) {
  //     print("⚠️ خطا در fetchAzbaziBookDetails: $e");
  //     rethrow;
  //   }
  // }

  Future<azbaziModel?> addUpAzScoreRate(azbaziModel oldAzbazi, String rate, UserProvider userProvider) async{
    azbaziModel _azbazi = oldAzbazi;
    try {
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "azbazi_id": oldAzbazi.azbazi_id,
        "myrate": rate,
        "action": "post",
        "module": "books",
        "resource": "azscorerate",});

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
        _azbazi.rate = rate;
        _azbazi.aiModels = response.data['aiModels'];
        SharedPreferences sharedPreferences = await SharedPreferences
            .getInstance();
        sharedPreferences.setInt(
            "mycoins" + _azbazi.azbazi_id!, _azbazi.myCoins!);
        sharedPreferences.setDouble(
            "myscore" + _azbazi.azbazi_id!, _azbazi.myScore!);
      } else {
        print("درخواست با خطا مواجه شد");
      }
    } catch (e) {
      print(e);
    }

    return _azbazi;
  }
}
