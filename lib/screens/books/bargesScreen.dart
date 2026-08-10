
import 'package:ebarge/models/bargModel.dart';
import 'package:ebarge/screens/books/AboutBarg.dart';
import 'package:ebarge/providers/bargProvider.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class bargesScreen extends StatefulWidget {
  String _bookId;
  bargesScreen(this._bookId);

  AnimationController? animationController;
  @override
  _bargesScreenState createState() => _bargesScreenState(this._bookId);
}

class _bargesScreenState extends State<bargesScreen> with TickerProviderStateMixin {

  String _bookId;
  _bargesScreenState(this._bookId);

  List<bargModel> _barges = <bargModel>[];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
  }

  Future<void> setData() async {
    animationController!.forward();
    if(!mounted){
      return;
    }
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    UserProvider userProvider = UserProvider.instance();
    await userProvider.onStartUp();
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _barges.length,
        itemBuilder: (BuildContext context, int index) {
          final barg = _barges[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: HexColor('#654c9b')
                              .withOpacity(0.06),
                          offset: const Offset(1.1, 6.0),
                          blurRadius: 8.0),
                    ],
                    gradient: LinearGradient(
                      colors: <HexColor>[
                        HexColor('#654c9b'),
                        HexColor('#6CF1AB'),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      topLeft: Radius.circular(44.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: opacity3,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: barg.type != null
                                    ? getTimeBoxUI(
                                    '${barg.type}')
                                    : Container(),
                              ),
                              Expanded(
                                flex: 5,
                                child: barg.wdate != null
                                    ? getTimeBoxUI(
                                    '${barg.wdate}')
                                    : Container(),
                              ),
                              Expanded(
                                flex: 5,
                                child: barg.amount != null
                                    ? getTimeBoxUI2(
                                    '${barg.amount}')
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: opacity3,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: barg.detail != null
                                    ? getTimeBoxUI(
                                    '${barg.detail}')
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget getTimeBoxUI(String txt) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 6.0, right: 6.0, top: 6.0, bottom: 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: OurTheme.nearlyWhite,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: OurTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 14.0, right: 14.0, top: 12.0, bottom: 7.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                txt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  letterSpacing: 0.27,
                  fontFamily: "Vazir",
                  color: OurTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimeBoxUI2( String txt) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 8.0, right: 6.0, top: 4.0, bottom: 0.0),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xf64c87).withAlpha(1000),
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: Offset(
                  0.0,
                  2.0,
                ),
              ),
            ],
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
            topLeft: Radius.circular(100.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 14.0, right: 14.0, top: 10.0, bottom: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                txt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  letterSpacing: 0.27,
                  fontFamily: "Vazir",
                  color: Colors.limeAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showLoadingTitle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          SpinKitFadingCube (
            color: Colors.indigo,
            size: 45.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          Expanded(
            flex: 2,
            child: Text('در حال فراهم سازی برگ(ها)!',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 15,
                  fontFamily: "Vazir"
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showBlankTitle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Expanded(flex: 1, child: SizedBox()),
            Icon(Icons.widgets_rounded, color: Colors.indigo, size: 50,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Expanded(
              flex: 2,
              child: Text('شما برای این کتاب هیچ برگی جمع آوری نکرده اید، با طراحی سوال و یا بارگذاری محتوا می توانید وزن برگهایتان را افزایش دهید...',
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 15,
                    fontFamily: "Vazir"
                ),
              ),
            ),
          ],
        ),
      ),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              child: const Icon(Icons.help_center_outlined, color: Colors.black,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutBarg(),
                  ),
                );
              }
            ),
            const SizedBox(width: 16),
            Text("جزئیات برگهای اخیر من",
              softWrap: false,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Vazir",
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              child: Column(
                  children: <Widget>[
                    Icon(Icons.arrow_forward, size: 22, color: Colors.black,),
                  ]
              ),
              onTap: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
  );

  _showCircularIndicator() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
          Expanded(
            flex: 2,
            child: Text('ارتباط اینترنتی برقرار نیست!',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 15,
                  fontFamily: "Vazir"
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<BargProvider>(
        create: (context) =>
            BargProvider.instance(_bookId),
        child: Consumer(
          // ignore: missing_return
            builder: (context, BargProvider bargProvider, _) {
              _barges = bargProvider.getPageBarges;
              return FutureProvider.value(
                //value: _createbargStream(context, bargProvider),
                value: null,
                initialData: null,
                child: Stack(
                    children: <Widget>[
                      _appBar(context),
                      Padding(
                        padding: EdgeInsets.only(top: 98.0),
                        child: Scaffold(
                          body: Center(
                            child:
                            bargProvider.bargStatus ==
                                BargStatus.Initializing ?
                            _showLoadingTitle() :
                            bargProvider.bargStatus ==
                                BargStatus.Uninitialized ?
                            _showCircularIndicator()
                                : bargProvider.bargStatus ==
                                BargStatus.BlankBarges ?
                            _showBlankTitle() : _getListView(),
                          ),
                          extendBody: true,
                        ),
                      ),
                    ]
                ),
              );
            }
        ),
      ),
    );
  }
}