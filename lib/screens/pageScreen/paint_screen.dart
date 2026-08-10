
import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/noteModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/noteScreen.dart';
import 'package:ebarge/screens/pageScreen/questionsScreen.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:ebarge/widgets/board_widget.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_painter/history_model.dart';
import 'package:badges/badges.dart' as myBadges;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'contentsScreen.dart';
import 'note_editor.dart';

enum AuthStatus { notLoggedIn, loggedIn }

// ignore: must_be_immutable
class PaintScreen extends StatefulWidget {
  pageModel _pageData;
  bookModel _book;
  List<dynamic> _pageNumToId;
  PaintScreen(this._pageData, this._book, this._pageNumToId);

  @override
  PaintScreenState createState() => PaintScreenState(this._pageData, this._book, this._pageNumToId);
}

class PaintScreenState extends State<PaintScreen> {

  var _userPassData = List.filled(2, '', growable: false);
  int? inputValue;

  int? _currentIndex;
  //final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  pageModel _pageData;
  bookModel _book;
  List<dynamic> _pageNumToId;
  bool _aLoading = false;
  bool _bLoading = false;

  PaintScreenState(this._pageData, this._book, this._pageNumToId);

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
   // _boardWidgetKey = GlobalKey<BoardWidgetState>();

    setUserPassStorage();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    bool isAccess = await AccessCheck().hasAccessTime();
    if (!isAccess) {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    if (_currentIndex == 0) {
      GlobalKeys.addUpUView(_pageData);
    }
  }

  Future<void> setUserPassStorage() async {
    final storage = new FlutterSecureStorage();
    String? _username = await storage.read(key: 'username');
    String? _password = await storage.read(key: 'password');
    _userPassData[0] = _username!;
    _userPassData[1] = _password!;
  }

  changePage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        GlobalKeys.navigatorKey.currentState!.pushReplacementNamed(
            "paintscreen", arguments: _pageData);
        break;
      case 1:
        GlobalKeys.navigatorKey.currentState!.pushNamed("notescreen");
        break;
      case 2:
        GlobalKeys.navigatorKey.currentState!.pushNamed("questionscreen");
        break;
      case 3:
        GlobalKeys.navigatorKey.currentState!.pushNamed("contentsscreen");
        break;
    }
    setState(() {
      _currentIndex = tabIndex;
    });
  }

  Widget _bottomNavigationBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BubbleBottomBar(
        hasNotch: true,
        // fabLocation: BubbleBottomBarFabLocation.end,
        opacity: .2,
        currentIndex: _currentIndex,
        onTap: (index) => changePage(index!),

        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(
                Icons.brush,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.brush,
                color: Colors.green,
              ),
              title: Text("طراحی", style: TextStyle(fontFamily: "Vazir"),)),
          BubbleBottomBarItem(
              backgroundColor: Colors.pinkAccent,
              icon: myBadges.Badge(
                badgeColor: Colors.pinkAccent,
                shape: myBadges.BadgeShape.square,

                borderRadius: BorderRadius.circular(5),
                child: Icon(Icons.content_paste, color: Colors.black,),
                badgeContent: Text(
                  AccessCheck().replaceFarsiNumber(_pageData.page_ns_count),
                  style: TextStyle(color: Colors.white, fontFamily: "Vazir", fontSize: 14),
                ),
              ),
              activeIcon: Icon(
                Icons.content_paste,
                color: Colors.pinkAccent,
              ),
              title: Text("یادداشت من", style: TextStyle(fontFamily: "Vazir"),)),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: myBadges.Badge(
                badgeColor: Colors.indigo,
                shape: myBadges.BadgeShape.square,
                borderRadius: BorderRadius.circular(5),
                child: Icon(Icons.question_answer, color: Colors.black,),
                badgeContent: Text(
                  AccessCheck().replaceFarsiNumber(_pageData.page_qs_count),
                  style: TextStyle(color: Colors.white, fontFamily: "Vazir", fontSize: 14),
                ),
              ),
              activeIcon: Icon(
                Icons.question_answer,
                color: Colors.indigo,
              ),
              title: Text("سوالات امتحانی", style: TextStyle(fontFamily: "Vazir"),)),
          BubbleBottomBarItem(
              backgroundColor: Colors.orange,
              icon: myBadges.Badge(
                badgeColor: Colors.orange,
                shape: myBadges.BadgeShape.square,
                borderRadius: BorderRadius.circular(5),
                child: Icon(Icons.video_library, color: Colors.black,),
                badgeContent: Text(
                  AccessCheck().replaceFarsiNumber(_pageData.page_cs_count),
                  style: TextStyle(color: Colors.white, fontFamily: "Vazir", fontSize: 14),
                ),
              ),
              activeIcon: Icon(
                Icons.video_library,
                color: Colors.orange,
              ),
              title: Text("محتوای آموزشی", style: TextStyle(fontFamily: "Vazir"),)),
        ],
      ),
    );
  }

  Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) return null;

    final uri = Uri.parse(settings.name!);
    final path = uri.path;
    switch (path) {
      case "notescreen":
        return MaterialPageRoute(builder: (context) => NoteScreen(_pageData));
      case '/note':
        {
          Map? map = (settings.arguments as Map);
          NoteModel? myNote;
          // ignore: unnecessary_null_comparison
          if(map != null){
            myNote = map['note'];
          } else {
            myNote = NoteModel(
              note_id: '', created_date: Jalali.now().toDateTime(),
              page_id: '', state: NoteState.unspecified,
              title: '', color: null,
              error_description: '', status: '',
              thenote: '', saved_content_id: '',
              error_code: '', modified_date: null,
              user_id: '',
            );
          }

          return MaterialPageRoute(
            builder: (_) => NoteEditor(note: myNote!, pageData: _pageData),
          );
        }
      case "questionscreen":
        return MaterialPageRoute(builder: (context) =>
            QuestionsScreen(userpassData: _userPassData,
              pageData: _pageData,
              book: _book,
              pageNumToId: _pageNumToId,));
      case "contentsscreen":
        return MaterialPageRoute(builder: (context) =>
            ContentsScreen(
                book: _book, pageData: _pageData, pageNumToId: _pageNumToId));
      default:
        return MaterialPageRoute(builder: (context) =>
            Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    _appBar(context),
                    MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => HistoryModel()),
                      ],
                      child: new BoardWidget(
                        pageData: _pageData, showActions: 1,),
                    ),
                  ],
                ),
              ),
            ),
        );
    }
  }

  Widget _appBar(BuildContext context) =>
      CustomScrollView(
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
      );

  Widget _topActions(BuildContext context) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              alignment: Alignment.topRight,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const SizedBox(width: 5),
                      !_bLoading ? InkWell(
                        child: Column(
                            children: <Widget>[
                              Icon(Icons.import_contacts, size: 16,
                                color: Colors.black,),
                              Text("قبلی", style: TextStyle(
                                  fontSize: 12, fontFamily: "Vazir"),),
                            ]
                        ),
                        onTap: () {
                          inputValue = int.parse(_pageData.real_page_num!) - 1;
                          _onSearchPageTap(context, "before");
                        },
                      ) :
                      SpinKitRotatingPlain(
                        color: Colors.indigo[900],
                        size: 18.0,
                      ),
                      const SizedBox(width: 16),
                      Text("صفحه: ${AccessCheck().replaceFarsiNumber(_pageData.real_page_num!)}",
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: "Vazir",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 20),
                      !_aLoading ? InkWell(
                        child: Column(
                            children: <Widget>[
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: Icon(Icons.import_contacts, size: 16,
                                  color: Colors.black,),
                              ),
                              Text("بعدی", style: TextStyle(
                                  fontSize: 12, fontFamily: "Vazir"),),
                            ]
                        ),
                        onTap: () {
                          inputValue = int.parse(_pageData.real_page_num!) + 1;
                          _onSearchPageTap(context, "after");
                        },
                      ) :
                      SpinKitRotatingPlain(
                        color: Colors.indigo[900],
                        size: 18.0,
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      );

  void _onSearchPageTap(BuildContext context, String direction) async {
    setState(() {
      direction == "after" ? _aLoading = true : _bLoading = true;
    });

    bool isAccess = await AccessCheck().hasAccessTime();
    if (!isAccess) {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    int pageCount = _pageNumToId[0].length - int.parse(_book.gap_pages!);
    int realPageNumIndex = inputValue! + int.parse(_book.gap_pages!);
    if (realPageNumIndex <= pageCount && realPageNumIndex > 0) {
      _pageData = (await GlobalKeys.getOnePageData(_book, _pageNumToId[0][realPageNumIndex.toString()]))!;
      if (_currentIndex == 0) {
        GlobalKeys.addUpUView(_pageData);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    _appBar(context),
                    MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => HistoryModel()),
                      ],
                      child: new BoardWidget(
                        pageData: _pageData, showActions: 1,),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      setState(() {
        direction == "after" ? _aLoading = false : _bLoading = false;
      });
    } else {
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient: LinearGradient(
            colors: [Colors.white70, Colors.black12]),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "صفحه مورد نظر پیدا نشد!",
            style: TextStyle(
              fontSize: 14.0, color: Colors.pink, fontFamily: "Vazir",),
          ),
        ),
        duration: Duration(seconds: 2),
      )
        ..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PopScope(
            canPop: true,
            onPopInvoked : (didPop) async {
              if (GlobalKeys.navigatorKey.currentState!.canPop() &&
                  _currentIndex != 0) {
                var route = ModalRoute.of(context);
                print(route!.settings.name);
                GlobalKeys.navigatorKey.currentState!.pop();
              }
            },
            child: Navigator(
                key: GlobalKeys.navigatorKey, onGenerateRoute: generateRoute)),
        bottomNavigationBar: _bottomNavigationBar(),
      );
  }
}
