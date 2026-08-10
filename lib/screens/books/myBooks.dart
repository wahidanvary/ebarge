import 'dart:io';
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/main.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/shopModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/providers/bookProvider.dart';
import 'package:ebarge/screens/books/allBooks.dart';
import 'package:ebarge/screens/books/bookDescription.dart';
import 'package:ebarge/screens/books/checkContents.dart';
import 'package:ebarge/screens/books/manageNewQuestions.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import '../azBaziScreen/azBaziha.dart';
import 'booksDrawer.dart';
import 'goldShop.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class MyBooks extends StatefulWidget {
  UserModel? _userData;
  MyBooks(this._userData);

  UserModel get getUserProvider => _userData!;

  @override
  _MyBooksState createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  List<bookModel> _books = [];
  var _userPassData = List.filled(2, '', growable: false);
  AuthStatus? _authStatus;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool? isEditAllow = false;
  UserModel? userData;
  List<shopModel> shopData = <shopModel>[];

  bookModel emptyBook = bookModel();

  @override
  void initState() {
    super.initState();
    setUserPassStorage();
    _authStatus = AuthStatus.notLoggedIn;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// فقط یک بار لود کن
    if (_authStatus != AuthStatus.loggedIn) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      UserProvider userProvider = UserProvider.instance();
      userData = widget._userData;

      /// مرحله اول: کاربر و داده‌هایش را از حافظه یا سرور بگیر
      var tempUser = await userProvider.onStartUp();
      if (tempUser != null) userData = tempUser;

      /// مرحله دوم: داده‌های فروشگاه طلا را بارگذاری کن
      shopData = await userProvider.goldShopData();

      /// مرحله سوم: بررسی و بروزرسانی نسخه
      await _checkUpdateIfNeeded();

      /// مرحله چهارم: بررسی مجوز ویرایش
      await checkUserState();

      /// در پایان، وضعیت را loggedIn کن و UI را ریفرش کن
      if (mounted) {
        setState(() {
          _authStatus = AuthStatus.loggedIn;
        });
      }
    } catch (e) {
      print('❌ خطا در بارگذاری داده‌های کاربر: $e');
    }
  }

  Future<void> _checkUpdateIfNeeded() async {
    final storage = const FlutterSecureStorage();
    String? updateRemind = await storage.read(key: 'updateRemind') ?? "0";
    int now = DateTime.now().millisecondsSinceEpoch;
    double diffMinutes = (now - int.parse(updateRemind)) / 60000;
    if (diffMinutes < 2800) return;

    if (!await GlobalKeys.checkInternetConnection()) return;

    final newVersionData = await AccessCheck().checkNewVersion();
    if (newVersionData?[0]['status'] != "ok") return;

    Version currentVersion = Version(4, 3, 2);
    Version latestVersion = Version.parse(newVersionData![0]['versionlatest']);
    String level = newVersionData[0]['level'];
    String downloadURL = newVersionData[0]['downloadlink'];

    if (currentVersion < latestVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _newVersionAlert(level, "نسخه جدید برنامه در دسترس است!", downloadURL);
      });
    }
  }

  void _newVersionAlert(String level, String alertText,
      String downloadURL) async {
    if (level == "1") {
      await showOkAlertDialog(
        context: context,
        title: '!نسخه جدید',
        message: alertText,
        okLabel: 'بروزرسانی',
        style: AdaptiveStyle.iOS,
      );

      // String ebargePath = '/ebarge';
      // File file = new File(downloadURL);
      // String fileName = path.basename(file.path);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) =>
      //       RequestDownload(
      //         downloadUrl: downloadURL,
      //         ebargePath: ebargePath,
      //         fileName: fileName,
      //         allowBack: false,
      //         allowExecute: true,)),
      // );
      if (Platform.isAndroid || Platform.isIOS) {
        final appId = Platform.isAndroid ? 'ir.ebarge.ebarge' : 'irebarge';

        final Uri url = Uri.parse(
          Platform.isAndroid
              ? "https://cafebazaar.ir/app/$appId"
              : "https://apps.apple.com/app/id$appId",
        );
        try {
          if (!await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          )) {
            print('لانچ اپلیکیشن از URL صورت نگرفت!');
          }
        } catch (e) {
          print('خطای خیر منتظره هنگام لانچ از URL: $e');
        }
      }
    } else {
      final updateResult = await showOkCancelAlertDialog(
        context: context,
        title: '!نسخه جدید',
        message: alertText,
        okLabel: 'بروز رسانی',
        cancelLabel: 'بعداْ',
        style: AdaptiveStyle.iOS,
        isDestructiveAction: true,
      );

      String result = updateResult.index.toString();
      if (result == "0") {
        // String ebargePath = '/ebarge';
        // File file = new File(downloadURL);
        // String fileName = path.basename(file.path);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) =>
        //       RequestDownload(
        //         downloadUrl: downloadURL,
        //         ebargePath: ebargePath,
        //         fileName: fileName,
        //         allowBack: true,
        //         allowExecute: true,)),
        // );
        if (Platform.isAndroid || Platform.isIOS) {
          final appId = Platform.isAndroid ? 'YOUR_ANDROID_PACKAGE_ID' : 'YOUR_IOS_APP_ID';
          final url = Uri.parse(
            Platform.isAndroid
                ? "https://cafebazaar.ir/app/$appId"
                : "https://apps.apple.com/app/id$appId",
          );
          launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        final storage = new FlutterSecureStorage();
        int updateRemind = DateTime
            .now()
            .millisecondsSinceEpoch;
        await storage.write(
            key: "updateRemind", value: updateRemind.toString());
      }
    }
  }

  Future<void> setUserPassStorage() async {
    final storage = new FlutterSecureStorage();
    String? _username = await storage.read(key: 'username');
    String? _password = await storage.read(key: 'password');
    _userPassData[0] = _username != null ? _username : "";
    _userPassData[1] = _password != null ? _password : "";
  }

  _showBlankTitle(String title, bool otherAlert) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Expanded(flex: 1, child: SizedBox()),
            SpinKitFadingCube(
              color: Colors.indigo,
              size: 40.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Expanded(
              flex: 2,
              child: userData != null && userData?.walletId != 0 ? RichText(
                textAlign: TextAlign.center,
                text: new TextSpan(
                  children: <TextSpan>[
                    new TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Vazir",
                            color: Colors.black54,
                          ),
                        ),
                        otherAlert ? WidgetSpan(
                          child: Transform.rotate(
                            angle: math.pi / 90,
                            child: Icon(Icons.arrow_downward_rounded, size: 18,
                              color: Colors.black,),
                          ),
                        ): TextSpan(
                          text: "",
                        ),
                        otherAlert ? TextSpan(
                          text: " در زیر",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Vazir",
                            color: Colors.black54,
                          ),
                        ): TextSpan(
                          text: "",
                        ),
                        WidgetSpan(
                          child: Icon(Icons.business_center, size: 18,
                            color: Colors.black,),
                        ),
                        otherAlert ? TextSpan(
                          text: "تپ کنید...",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Vazir",
                            color: Colors.black54,
                          ),
                        ): TextSpan(
                          text: "",
                        ),
                      ],
                    ),
                  ],
                ),
              ) : Container(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authStatus == AuthStatus.loggedIn && userData != null) {
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
              color: Colors.white,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.70,
              child: BooksDrawer(isEditAllow!)
          ),
        ),
        appBar: AppBar(
          title: Text(
              "کتابهای من",
              style: TextStyle(color: Colors.indigo, fontFamily: "Vazir", fontSize: 20)
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: <Widget>[
            userData != null && userData?.walletId != 0 ? InkWell(
              child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      child: Image.asset(
                        'assets/images/zafran.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                    Directionality(textDirection: TextDirection.rtl,
                        child: Text("${AccessCheck().replaceFarsiNumber(
                            userData!.zafran.toString())}", style: TextStyle(fontSize: 16,
                            fontFamily: "Vazir",
                            color: Colors.pinkAccent),)),
                  ]
              ),
              onTap: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => bargesScreen("0"),
                  ),
                );*/
              },
            ) : SpinKitPulse(
              color: Colors.indigo[900],
              size: 18.0,
            ),
            Padding(
            padding: EdgeInsets.only(left: 10),
            ),
            userData != null && userData?.walletId != 0 ? InkWell(
              child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 3,
                      ),
                      child: Image.asset(
                        'assets/images/mined_gold.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                    Directionality(textDirection: TextDirection.rtl,
                        child: Text("${AccessCheck().replaceFarsiNumber(
                            userData!.walletAmount.toString())}", style: TextStyle(fontSize: 16,
                            fontFamily: "Vazir",
                            color: Colors.pinkAccent),)),
                  ]
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoldShopScreen(walGold: userData!.walletAmount, userData: userData!, shopData: shopData,),
                  ),
                );
              },
            ) : SpinKitPulse(
              color: Colors.indigo[900],
              size: 18.0,
            ),
           // WalletView(walletAmount: userData!.walletAmount, shopData: shopData,),
            isEditAllow! ? IconButton(
              icon: Icon(Icons.check_box, color: Colors.blueAccent,),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ManageNewQuestions(_userPassData);
                    },
                  ),
                );
              },
            ) : Container(),
            isEditAllow! ? IconButton(
              icon: Icon(Icons.check_box, color: Colors.purpleAccent,),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return CheckContents(book: emptyBook,
                        contentState: "0",
                        contentAccess: "admin",
                        pageNumber: 1,);
                    },
                  ),
                );
              },
            ) : Container(),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.black,),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        body: ChangeNotifierProvider<BookProvider>(
          create: (context) => userData != null && userData!.userid != null
              ? BookProvider.instance(userData!.userid!, "", true)
              : BookProvider.instance("", "", true),
          child: Consumer<BookProvider>(
            builder: (context, bookProvider, _) {
              final books = bookProvider.getUserBooks;

              return Padding(
                padding: const EdgeInsets.all(15),
                child: bookProvider.bookStatus == BookStatus.Initializing || bookProvider.bookStatus == BookStatus.Uninitialized
                    ? Center(child: _showBlankTitle("در حال بارگذاری کتاب‌ها...", false))
                    : books.isEmpty
                    ? Center(child: _showBlankTitle("کتاب دنبال شده ای در کیف تان ندارید به منظور دنبال کردن کتابها بر روی دکمه افزودن ", true))
                    : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return generateItem(books[index], context);
                  },
                ),
              );
            },
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.indigo[800], onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return allBooks(_userPassData);
                },
              ),
            );
          },
            icon: Icon(Icons.business_center, color: Colors.white,),
            label: Text("افزودن", style: TextStyle(fontFamily: "Vazir", color: Colors.white),),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      );
    } else {
      return Splash("Authenticating");
    }
  }

  Future<void> checkUserState() async {
    if (await GlobalKeys.checkInternetConnection()) {
      try {
        var url = GlobalKeys.ebargeUrl +
            '/index.php?option=com_jbackend&view=request';
        var dio = Dio();
        FormData formData = new FormData.fromMap({
          "action": "get",
          "module": "books",
          "resource": "userstate",
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
              isEditAllow = true;
          }
        } else {
          print("درخواست با خطا مواجه شد");
        }
      } catch (e) {
        print(e);
      }
    }

  }

  Padding generateItem(bookModel book, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: HexColor('#1E1466')
                      .withOpacity(0.06),
                  offset: const Offset(1.1, 6.0),
                  blurRadius: 8.0),
            ],
            gradient: LinearGradient(
              colors: <HexColor>[
                HexColor('#FFFFFF'),
                HexColor('#FFFFFF'),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              topLeft: Radius.circular(54.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return bookDescription(book, widget._userData);
                      },
                    ),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 0.0, right: 0.0),
                      child: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width / 3.5,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 3.5,
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Image.network(
                                    GlobalKeys.ebargeUrl + '/' +
                                        book.small_ebavatar!
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "${book.book_name}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            "کد کتاب: ${book.bchap_id}",
                            style: TextStyle(
                              fontFamily: "Vazir",
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              color: Theme
                                  .of(context)
                                  .focusColor,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            children: <Widget>[
                              Text(
                                "${AccessCheck().replaceFarsiNumber(
                                    (int.parse(book.pages_count!) -
                                        int.parse(book
                                            .gap_pages!)).toString())} صفحه | ",
                                style: TextStyle(
                                  fontFamily: "Vazir",
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(width: 2.0),
                              Text(
                                "سال تحصیلی ${book.edu_year}",
                                style: TextStyle(
                                  fontFamily: "Vazir",
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (book.azbaziCount != null && book.azbaziCount! != "0") || (book.azbaziCount != null && (userData?.state == 1 || userData?.state == 2))?
              Positioned(
                top:-10,
                left: 0,
                child: InkWell(
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return azBazihaScreen(book: book, userData: userData, pageNumber: 1, orderBy: "", orderDir: "", searchText: "",);
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 90,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                        HexColor('#F56E98'),
                        HexColor('#F56E98').withOpacity(0.5),
                      ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,),
                      borderRadius: BorderRadius.all(
                          Radius.circular(7.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 32.0),
                      child: Center(
                        child: SizedBox(
                          width: 60,
                          height: 80,
                          // child: Image.asset(_lastPagesData.imagePath),
                          child: Text(
                            '${AccessCheck().replaceFarsiNumber(book
                                .azbaziCount!)} آزبازی',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Vazir",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ): Container(),
            ],
          ),
        ),
      ),
    );
  }
}