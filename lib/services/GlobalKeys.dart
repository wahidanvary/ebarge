import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:flutter/widgets.dart';
import 'network/http_client.dart';
import 'network/api_exception.dart';

class GlobalKeys {
  static final navigatorKey = GlobalKey<NavigatorState>();
  //static final ebargeUrl = 'http://10.159.135.91:8080/newjersey';
  //static final ebargeUrl = 'http://127.0.0.1:8080/newjersey';
  //static final ebargeUrl = 'http://192.168.1.103:8080/newjersey';
  //static final ebargeUrl = 'http://192.168.56.1:8080/newjersey';
  //static final ebargeUrl = 'http://192.168.200.115:8080/newjersey';
  //static final ebargeUrl = 'http://192.168.143.2:8080/newjersey';
  //static final ebargeUrl = 'http://192.168.43.135:8080/newjersey';
  static final ebargeUrl = 'https://ebarge.ir';
  static final BaseOptions options = new BaseOptions(
    baseUrl: ebargeUrl,
    receiveDataWhenStatusError: true,
    connectTimeout: Duration(milliseconds: 18000),
    receiveTimeout: Duration(milliseconds: 15000),
  );

  static Future<bool> checkInternetConnection() async{
    bool hasInternet = false;
    try{
      //final result = await InternetAddress.lookup("192.168.1.113");
      final result = await InternetAddress.lookup("ebarge.ir");
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        hasInternet = true;
    }on SocketException catch(_){
      hasInternet = false;
    }

    return hasInternet;
  }

  static Future<pageModel?> getOnePageData(bookModel _book, String pageId) async {
    try {
      var url = ebargeUrl +
          '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';
      
      // Use the centralized HTTP client instead of creating a new Dio instance
      final httpClient = HttpClient();
      await httpClient.initialize();
      
      FormData formData = FormData.fromMap({
        "book_id": _book.book_id,
        "page_id": pageId,
      });

      var response = await httpClient.post(url, data: formData);
      pageModel _pageData = pageModel(
          response.data['page_id'],
          response.data['page_image'],
          response.data['page_thumb'],
          response.data['view_count'],
          response.data['pdf_page_num'],
          response.data['real_page_num'],
          response.data['hotrates'],
          response.data['uview_id'],
          response.data['user_id'],
          response.data['uview_count'],
          response.data['saved_image'],
          response.data['hotrate'],
          response.data['saved_date'],
          response.data['visit_date'],
          response.data['page_ns_count'],
          response.data['page_qs_count'],
          response.data['page_cs_count'],
          response.data['status'],
          response.data['error_code'],
          response.data['error_description']);
      return _pageData;
    } on ApiException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<pageModel?> addUpUView(pageModel _pageData) async {
    if (_pageData.page_id != '') {
      try {
        var url = ebargeUrl + '/index.php?option=com_jbackend&view=request';
        
        // Use the centralized HTTP client instead of creating a new Dio instance
        final httpClient = HttpClient();
        await httpClient.initialize();
        
        FormData formData = FormData.fromMap({
          "page_id": _pageData.page_id,
          "isvisit": "1",
          "action": "post",
          "module": "pages",
          "resource": "uviewaddup",
        });

        var response = await httpClient.post(url, data: formData);

        if (response.statusCode == 200) {
          //Successful
          _pageData = pageModel(
              _pageData.page_id,
              _pageData.page_image,
              _pageData.page_thumb,
              response.data['view_count'],
              _pageData.pdf_page_num,
              _pageData.real_page_num,
              _pageData.hotrates,
              response.data['uview_id'],
              response.data['user_id'],
              response.data['uview_count'],
              response.data['saved_image'],
              response.data['hotrate'],
              response.data['saved_date'],
              response.data['visit_date'],
              response.data['page_ns_count'],
              response.data['page_qs_count'],
              response.data['page_cs_count'],
              response.data['status'],
              response.data['error_code'],
              response.data['error_description']);

          return _pageData;
        } else {
          print("درخواست با خطا مواجه شد");
        }
      } on ApiException catch (e) {
        print(e);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }
}
