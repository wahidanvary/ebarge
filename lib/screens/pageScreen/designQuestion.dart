import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/services/requestDownload.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;

// ignore: must_be_immutable
class DesignQuestion extends StatefulWidget {
  var _userPassData = List.filled(2, '', growable: false);
  pageModel _pageData;
  bookModel _book;
  DesignQuestion(this._userPassData, this._pageData, this._book);

  @override
  _DesignQuestionState createState() => _DesignQuestionState(_userPassData, _pageData, _book);
}

class _DesignQuestionState extends State<DesignQuestion> {
  var _userPassData = List.filled(2, '', growable: false);
  pageModel _pageData;
  bookModel _book;
  _DesignQuestionState(this._userPassData, this._pageData, this._book);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

  bool? isLoading;
  final storage = new FlutterSecureStorage();

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
  void didChangeDependencies() async {
    super.didChangeDependencies();

    String? designManualView = await storage.read(key: 'designManualView');

    if(designManualView != "1"){
      int nowAlert = DateTime
          .now()
          .millisecondsSinceEpoch;
      if(designManualView == null) designManualView = "0";
      double loadDuration = (nowAlert - int.parse(designManualView)) /
          60000;
      bool doAlertView = loadDuration > 2160 ? true : false; // alert if above 36hours

      if(doAlertView){
        _designManualAlert();
      }
    }
  }

  Future<void> _designManualAlert() async{
    final alertResult = await showOkCancelAlertDialog(
      context: context,
      title: '!اصول طراحی سوال',
      message: "قبل از اقدام به طراحی سوال خواهشمند است به طور کامل اصول و قالبهای طراحی سوال را مطالعه بفرمایید",
      okLabel: 'دانلود و مطالعه',
      cancelLabel: 'بعداْ',
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
    );

    String result = alertResult.index.toString();
    if (result == "0") {//yani tayiid hazf
      String downloadURL = GlobalKeys.ebargeUrl + '/media/com_blogfactory/users/782/TarrahiSoalEbarge.pdf';
      String ebargePath = '/ebarge/pdfs';
      File file = new File(downloadURL);
      String fileName = path.basename(file.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RequestDownload(downloadUrl: downloadURL, ebargePath: ebargePath, fileName: fileName, allowBack: false, allowExecute: true,)),
      );

      await storage.write(key: "designManualView", value: "1");
    } else {
      int alertRemind = DateTime
          .now()
          .millisecondsSinceEpoch;
      await storage.write(key: "designManualView", value: alertRemind.toString());
    }
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
            padding: EdgeInsets.only(top: 50.0),
            child: Scaffold(
              body: Container(
                child: Stack(
                    children: <Widget>[
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                        URLRequest(
                            url: WebUri.uri(Uri.parse(GlobalKeys.ebargeUrl + '/index.php?option=com_ebarge&view=question&layout=edit&tmpl=component&realpagenum='+_pageData.real_page_num!+'&bookid=' + _book.book_id!,),),
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
          children: <Widget>[
            const SizedBox(width: 30),
            InkWell(
              child: const Icon(Icons.menu),
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 10),
            InkWell(
              child: const Icon(Icons.import_contacts, size: 20,),
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 16),
            Text("طراحی سوال برای صفحه: ${AccessCheck().replaceFarsiNumber(_pageData.real_page_num!)}",
              softWrap: false,
              style: TextStyle(
                fontFamily: "Vazir",
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(Icons.import_contacts, size: 20,),
                ),
                onTap: (){}
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ),
  );
}
