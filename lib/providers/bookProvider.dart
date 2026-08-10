import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/database/booksQueries.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/bookModel.dart';

enum BookStatus { ExistBooks, BlankBooks, Initializing, Uninitialized }

class BookProvider extends ChangeNotifier{
  bookModel? _book;
  BookStatus _bookStatus = BookStatus.Uninitialized;
  List<bookModel> _books = <bookModel>[];

  BookProvider.instance(String userId, String bookId, bool loggedIn){
    getBooks(userId, bookId, loggedIn);
    _onInstanceStateChanged(_books);
  }

  List<bookModel> get getUserBooks => _books;
  bookModel? get getOneBook => _book;
  BookStatus get bookStatus => _bookStatus;

  void getBooks(String userId, String bookId, bool loggedIn) async{
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    await getBooksData( userId, bookId, loggedIn);
  }

  Future<List<bookModel>> getBooksData(String userId, String bookId, bool loggedIn) async {
    try {
      _bookStatus = BookStatus.Initializing;
      notifyListeners();

      if(loggedIn) {
        _books = await booksQueries().getBooks();
        if (await GlobalKeys.checkInternetConnection()) {
          var url = GlobalKeys.ebargeUrl +
              '/index.php?option=com_jbackend&view=request&action=get&module=books&resource=getbooks';

          var dio = Dio();
          FormData formData = new FormData.fromMap({
            "useridbooks": userId,
            "book_id": bookId,
          });

          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var cookieJar = PersistCookieJar(
              ignoreExpires: true,
              storage: FileStorage(appDocPath + "/.cookies/"));
          dio.interceptors.add(CookieManager(cookieJar));
          var response = await dio.post(url, data: formData);

          if(response.data["status"] == "ok") {
            List<bookModel> _onlineBooks = [];
            var booksJson = response.data["books"];
            for (var oneBookJson in booksJson) {
              _onlineBooks.add(bookModel.fromJson(oneBookJson));
            }
            await booksQueries().saveUserBooksToDB(_onlineBooks);
            _books = _onlineBooks;

            if(bookId != "") _book = _books.first;
          }
        }
        if (_books.length > 0) {
          _bookStatus = BookStatus.ExistBooks;
          notifyListeners();
        } else {
          _bookStatus = BookStatus.BlankBooks;
          notifyListeners();
        }
      }
    } catch (e) {
      _bookStatus = BookStatus.Uninitialized;
      notifyListeners();
      print(e);
    }

    return _books;
  }

  Future<void> _onInstanceStateChanged(List<bookModel> books) async {
    if (books.length != 0) {
      _books = books;
      _bookStatus = BookStatus.ExistBooks;
    }

    notifyListeners();
  }

}