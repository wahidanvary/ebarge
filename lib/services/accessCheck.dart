import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'GlobalKeys.dart';

class AccessCheck {
  AccessCheck();

  // ignore: missing_return
  Future<bool> hasAccessTime() async {
    final storage = new FlutterSecureStorage();
    String? accessTime = await storage.read(key: 'accestime');
    int nowAccess = DateTime
        .now()
        .millisecondsSinceEpoch;

    if(accessTime == null) accessTime = "0";
    double loadDuration = (nowAccess - int.parse(accessTime)) /
        60000; // milliseconds convert to minutes ..

    bool isAccess = loadDuration < 15 ? true : false; // allow under 15minute Har 15dagige barrasi mikone aya karbar login karde ya na?
    if(!isAccess)
      await storage.write(key: "accestime", value: nowAccess.toString());

    return isAccess;
  }

  Future<List?> checkNewVersion() async {
    List checkVersion;
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "action": "post",
        "module": "books",
        "resource": "versioning",
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
        checkVersion = response.data;
      } else {
        print("درخواست با خطا مواجه شد");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }

    return checkVersion;
  }

  String preprocessLatex(String html) {
    if (html.isEmpty) return html;

    final blockRegex = RegExp(r'\$\$([\s\S]*?)\$\$');
    html = html.replaceAllMapped(blockRegex, (match) {
      final formula = match.group(1) ?? '';
      return '<latex-block data="${Uri.encodeComponent(formula)}"></latex-block>';
    });

    final inlineRegex = RegExp(r'(?<!\\)\$(.*?)(?<!\\)\$');
    html = html.replaceAllMapped(inlineRegex, (match) {
      final formula = match.group(1) ?? '';
      return '<latex-inline data="${Uri.encodeComponent(formula)}"></latex-inline>';
    });

    return html;
  }

  String replaceFarsiNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    return input;
  }
}