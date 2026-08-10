import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'myBooks.dart';

// ignore: must_be_immutable
class allBooks extends StatefulWidget {
  var _userPassData = List.filled(2, '', growable: false);
  allBooks(this._userPassData);
  @override
  _allBooksState createState() => new _allBooksState(_userPassData);
}

// ignore: camel_case_types
class _allBooksState extends State<allBooks> {
  var _userPassData = List.filled(2, '', growable: false);

  _allBooksState(this._userPassData);
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
    clearCache: true,
      clearSessionCache: true,
      transparentBackground: true,
      safeBrowsingEnabled: true,
      isFraudulentWebsiteWarningEnabled: true);

  PullToRefreshController? pullToRefreshController;
  ContextMenu? contextMenu;
  String? url = "";
  num? progress = 0;
  final urlController = TextEditingController();

  UserModel? _userData;
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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    UserProvider userProvider = UserProvider.instance();
    _userData = await userProvider.onStartUp();
  }


  @override
  Widget build(BuildContext context) {
    return new PopScope(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('جستجو و انتخاب کتاب تحصیلی', style: TextStyle(fontSize: 16, fontFamily: "Vazir"),),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,),
            onPressed: () async {
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) => MyBooks(_userData!)), (
                  route) => false,
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                if (webViewController != null) {
                  webViewController!.reload();
                }
              },
            ),
          ],
        ),
        body: Container(
          child: Stack(
              children: <Widget>[
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                  URLRequest(
                      url: WebUri.uri(Uri.parse(GlobalKeys.ebargeUrl + '/index.php?option=com_ebarge&view=books&Itemid=994&tmpl=component',),),
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
                      urlController.text = this.url!;
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
                      urlController.text = this.url!;
                    });
                  },
                  onReceivedError: (controller, url, code) {
                    pullToRefreshController!.endRefreshing();
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url!;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  },
                ),
                progress! < 1.0
                    ? LinearProgressIndicator(value: progress!.toDouble())
                    : Container(),

                isLoading! ? Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  strokeWidth: 5,)) : Container(),
              ]
          ),
        ),
      ),
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) => MyBooks(_userData)), (route) => false,
        );
      },
    );
  }
}