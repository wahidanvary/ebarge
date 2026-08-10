
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as dio_cookiemanager;
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/designQuestion.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
// ignore: must_be_immutable
class QuestionsScreen extends StatefulWidget {
  var userpassData = List.filled(2, '', growable: false);
  pageModel pageData;
  bookModel book;
  List<dynamic> pageNumToId;
  //QuestionsScreen(this._userPassData, this._pageData, this._book, this._pageNumToId);
  QuestionsScreen({Key? key, required this.userpassData, required this.pageData, required this.book, required this.pageNumToId}) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState(userpassData, pageData, book, pageNumToId);
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  var _userPassData = List.filled(2, '', growable: false);
  pageModel _pageData;
  bookModel _book;
  List<dynamic> _pageNumToId;
  _QuestionsScreenState(this._userPassData, this._pageData, this._book, this._pageNumToId);
 // final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
      transparentBackground: true,
      safeBrowsingEnabled: true,
      isFraudulentWebsiteWarningEnabled: true);

  PullToRefreshController? pullToRefreshController;
  ContextMenu? contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  int? inputValue;
  bool? isLoading;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          _appBar(context),
          Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Scaffold(
              body: Container(
                child: Stack(
                    children: <Widget>[
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                        URLRequest(
                            url: WebUri.uri(Uri.parse(GlobalKeys.ebargeUrl + '/index.php?option=com_ebarge&view=pageqs&tmpl=component&pageid=' +
                                _pageData.page_id,),),
                            method: "post",
                            body: Uint8List.fromList(
                                utf8.encode("firstname=Foo&lastname=Bar")),
                            headers: {
                              'usn': base64Encode(utf8.encode(_userPassData[0].toString())),
                              'pwd': base64Encode(utf8.encode(_userPassData[1].toString())),
                            }),
                        onWebViewCreated: (InAppWebViewController controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onProgressChanged: (InAppWebViewController controller,
                            int progress) {
                          setState(() {
                            this.progress = progress / 100;
                          });
                        },
                        onPermissionRequest: (controller, origin) async {
                          return PermissionResponse(
                              resources: origin.resources,
                              action: PermissionResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          var uri = navigationAction.request.url;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri!.scheme)) {
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController!.endRefreshing();
                          setState(() {
                            isLoading = false;
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onReceivedError: (controller, url, code) {
                          pullToRefreshController!.endRefreshing();
                        },
                        onUpdateVisitedHistory: (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print(consoleMessage);
                        },
                        onReceivedServerTrustAuthRequest: (controller, challenge) async {
                          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),

                      isLoading! ? Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        strokeWidth: 5,)) : Container(),
                    ]
                ),
              ),
              floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: FloatingActionButton(
                  backgroundColor: Colors.blueAccent, onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return DesignQuestion(_userPassData, _pageData, _book);
                      },
                    ),
                  );
                },
                  child: Icon(Icons.add, color: Colors.white,), foregroundColor: Colors.white,),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation
                  .startDocked,
            ),
          ),
        ]
    );
  }

  Widget _appBar(BuildContext context) =>
      Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                snap: true,
                title: _topActions(context),
                automaticallyImplyLeading: false,
                centerTitle: true,
                titleSpacing: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ]
        ),
      );

  void _onSearchPageTap(BuildContext context) async{
    int pageCount =  _pageNumToId[0].length - int.parse(_book.gap_pages!);
    int realPageNumIndex = inputValue! + int.parse(_book.gap_pages!);
    if(realPageNumIndex <= pageCount &&  realPageNumIndex > 0){
      pageModel _updatedPageData = (await GlobalKeys.getOnePageData(_book, _pageNumToId[0][realPageNumIndex.toString()]))!;
      setState(() {
        _pageData.page_id = _pageNumToId[0][realPageNumIndex.toString()];
        _pageData.real_page_num = inputValue.toString();
        _pageData.page_image = _updatedPageData.page_image;
        _pageData.page_ns_count = _updatedPageData.page_ns_count;
        _pageData.page_qs_count = _updatedPageData.page_qs_count;
        _pageData.page_cs_count = _updatedPageData.page_cs_count;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context){
            return QuestionsScreen(userpassData: _userPassData, pageData: _pageData, book: _book, pageNumToId: _pageNumToId,);
          },
        ),
      );
    }else{
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "صفحه مورد نظر پیدا نشد!",
            style: TextStyle(fontSize: 14.0, color: Colors.pink, fontFamily: "Vazir",),
          ),
        ),
        duration:  Duration(seconds: 2),
      )..show(context);
    }
  }

  Future<void> getOnePageData(String pageId) async {
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';
      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "book_id": _book.book_id,
        "page_id": pageId,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(dio_cookiemanager.CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);
      setState(() {
        _pageData = pageModel(
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
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _topActions(BuildContext context) => Container(
    // width: double.infinity,
    constraints: const BoxConstraints(
      maxWidth: 720,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              child: Column(
                  children: <Widget>[
                    Icon(Icons.import_contacts, size: 16, color: Colors.black,),
                    Text("قبلی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                  ]
              ),
              onTap: (){
                inputValue = int.parse(_pageData.real_page_num!) - 1;
                _onSearchPageTap(context);
              },
            ),
            const SizedBox(width: 16),
            Text("سوالات صفحه: ${AccessCheck().replaceFarsiNumber(_pageData.real_page_num!)}",
              softWrap: false,
              style: TextStyle(
                fontFamily: "Vazir",
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              child: Column(
                  children: <Widget>[
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(Icons.import_contacts, size: 16, color: Colors.black,),
                    ),
                    Text("بعدی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                  ]
              ),
              onTap: (){
                inputValue = int.parse(_pageData.real_page_num!) + 1;
                _onSearchPageTap(context);
              },
            ),

          ],
        ),
      ),
    ),
  );
}
