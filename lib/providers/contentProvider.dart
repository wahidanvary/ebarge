import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum ContentStatus { ExistContents, BlankContents, Initializing, Uninitialized }

class ContentProvider extends ChangeNotifier{
  contentModel? _content;
  var _contentInstance;
  ContentStatus _contentStatus = ContentStatus.Uninitialized;
  List<contentModel> _contents = <contentModel>[];
  List<dynamic> _contentPageNumToId = [];
  int? _totalPages = 0;

  ContentProvider.instance(String bookId, String pageId, String contentState, String contentAccess, int limit, int pageNumber)
      : _contentInstance = contentModel("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", false, "", [], "", "", "", "", "", "", "", "", "", "", "", "", "",) {

    getContents(bookId, pageId, contentState, contentAccess, limit, pageNumber);
    _onInstanceStateChanged(_contents, _totalPages!);
  }

  List<contentModel> get getPageContents => _contents;
  contentModel get getOneContent => _content!;
  ContentStatus get contentStatus => _contentStatus;
  int get getTotalPages => _totalPages!;
  List<dynamic> get getContentPageNumToId=> _contentPageNumToId;

  void getContents(String bookId, String pageId, String contentState, String contentAccess, int limit, int pageNumber) async{
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    if(pageId != ""){
      await getContentsData( bookId, pageId );
    } else {
      await getCheckContentsData( bookId, contentState, contentAccess, limit, pageNumber );
    }
  }

  Future<List<contentModel>> getContentsData(String bookId, String pageId) async {
    try {
      _contentStatus = ContentStatus.Initializing;
      notifyListeners();
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "book_id": bookId,
        "page_id": pageId,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      var contentsJson = response.data["contents"];
      for (var j in contentsJson) {
        double roundedRate = double.parse(j['rate']);
        String rate = roundedRate.toStringAsFixed(1);
        var contentItem = contentModel(
          j['content_id'],
          j['book_id'],
          j['page_id'],
          j['user_id'],
          j['user_name'],
          j['editor_id'],
          j['owner_id'],
          j['owner_name'],
          j['isteacher'],
          j['content_link'],
          j['thumb_link'],
          j['content_title'],
          j['content_note'],
          j['size'],
          j['language'],
          j['pages_include'],
          rate,
          j['views'],
          j['rate_count'],
          j['created_date'],
          j['modified_date'],
          j['state'],
          j['ismine'],
          j['isDeleteVideo'],
          j['isnewcontent'],
          j['rejectreasons'],
          j['contentaccess'],
          j['book_name'],
          j['gap_pages'],
          j['page_image'],
          j['page_thumb'],
          j['real_page_num'],
          j['cview_id'],
          j['cview_count'],
          j['crate'],
          j['visit_date'],
          j['status'],
          j['error_code'],
          j['error_description'],
        );
        _contents.add(contentItem);
      }

      if (_contents.length > 0) {
        _contentStatus = ContentStatus.ExistContents;
        notifyListeners();
      } else {
        _contentStatus = ContentStatus.BlankContents;
        notifyListeners();
      }
    } catch (e) {
      _contentStatus = ContentStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _contents;
  }

  Future<List<contentModel>> getCheckContentsData(String bookId, String contentState, String contentAccess, int limit, int pageNumber) async {
    try {
      _contentStatus = ContentStatus.Initializing;
      notifyListeners();

      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getcontents';

      int offset = limit * (pageNumber - 1);

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "book_id": bookId,
        "state": contentState,
        "contentaccess": contentAccess,
        "limit" : limit,
        "offset" : offset,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      var pagesTotal = response.data["pages_total"];
      _totalPages = pagesTotal;
      var contentsJson = response.data["contents"];

      for (var j in contentsJson) {
        double roundedRate = double.parse(j['rate']);
        String rate = roundedRate.toStringAsFixed(1);
        var contentItem = contentModel(
          j['content_id'],
          j['book_id'],
          j['page_id'],
          j['user_id'],
          j['user_name'],
          j['editor_id'],
          j['owner_id'],
          j['owner_name'],
          j['isteacher'],
          j['content_link'],
          j['thumb_link'],
          j['content_title'],
          j['content_note'],
          j['size'],
          j['language'],
          j['pages_include'],
          rate,
          j['views'],
          j['rate_count'],
          j['created_date'],
          j['modified_date'],
          j['state'],
          j['ismine'],
          j['isDeleteVideo'],
          j['isnewcontent'],
          j['rejectreasons'],
          j['contentaccess'],
          j['book_name'],
          j['gap_pages'],
          j['page_image'],
          j['page_thumb'],
          j['real_page_num'],
          j['cview_id'],
          j['cview_count'],
          j['crate'],
          j['visit_date'],
          j['status'],
          j['error_code'],
          j['error_description'],
        );
        _contentPageNumToId.add(j['contentpagenumtoid']);
        _contents.add(contentItem);
      }

      if (_contents.length > 0) {
        _contentStatus = ContentStatus.ExistContents;
        notifyListeners();
      } else {
        _contentStatus = ContentStatus.BlankContents;
        notifyListeners();
      }
    } catch (e) {
      _contentStatus = ContentStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _contents;
  }

  Future<contentModel?> addupCViewRate(String contentId, String rate, contentModel oldContent) async{
    try {
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "content_id": contentId,
        "crate": rate,
        "action": "post",
        "module": "pages",
        "resource": "cviewrate",
      });

      _content = oldContent;

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
        _content!.rate = rate;
        _content!.views = response.data['views'];
        _content!.rate_count = response.data['rate_count'];
        _content!.crate = response.data['crate'];
      } else {
        print("درخواست با خطا مواجه شد");
      }
    } catch (e) {
      print(e);
    }

    return _content;
  }

  Future<contentModel?> cCheckResult(String contentId, String result, String txtReason, String userBarg) async{
    try {
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      var dio = Dio(GlobalKeys.options);
      FormData formData = new FormData.fromMap({
        "content_id": contentId,
        "result": result,
        "reason": txtReason,
        "userbarg": userBarg,
        "action": "post",
        "module": "pages",
        "resource": "ccheckresult",
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
        _content = contentModel(
          contentId,
          response.data['book_id'],
          response.data['page_id'],
          response.data['user_id'],
          response.data['user_name'],
          response.data['editor_id'],
          response.data['owner_id'],
          response.data['owner_name'],
          response.data['isteacher'],
          response.data['content_link'],
          response.data['thumb_link'],
          response.data['content_title'],
          response.data['content_note'],
          response.data['size'],
          response.data['language'],
          response.data['pages_include'],
          rate,
          response.data['views'],
          response.data['rate_count'],
          response.data['created_date'],
          response.data['modified_date'],
          response.data['state'],
          response.data['ismine'],
          response.data['isDeleteVideo'],
          response.data['isnewcontent'],
          response.data['rejectreasons'],
          response.data['contentaccess'],
          response.data['book_name'],
          response.data['gap_pages'],
          response.data['page_image'],
          response.data['page_thumb'],
          response.data['real_page_num'],
          response.data['cview_id'],
          response.data['cview_count'],
          response.data['crate'],
          response.data['visit_date'],
          response.data['status'],
          response.data['error_code'],
          response.data['error_description'],
        );
      } else {
        print("درخواست با خطا مواجه شد");
      }
    } catch (e) {
      print(e);
    }

    return _content;
  }

  Future<void> _onInstanceStateChanged(List<contentModel> contents, int totaPages) async {
    if (contents.length != 0) {
      _contents = contents;
      _totalPages = totaPages;
      _contentStatus = ContentStatus.ExistContents;
    }

    notifyListeners();
  }

}