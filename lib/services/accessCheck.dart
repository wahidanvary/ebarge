import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'GlobalKeys.dart';
import 'network/http_client.dart';
import 'network/api_exception.dart';

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

      // Use the centralized HTTP client instead of creating a new Dio instance
      final httpClient = HttpClient();
      await httpClient.initialize();
      
      FormData formData = FormData.fromMap({
        "action": "post",
        "module": "books",
        "resource": "versioning",
      });

      var response = await httpClient.post(url, data: formData);

      if (response.statusCode == 200) {
        //Successful
        checkVersion = response.data;
      } else {
        print("درخواست با خطا مواجه شد");
        return null;
      }
    } on ApiException catch (e) {
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