import 'package:ebarge/azbazi/components/icons/timeBal.dart';
import 'package:ebarge/azbazi/pages/game-page/game-page.dart';
import 'package:ebarge/azbazi/pages/game-page/views/my-final-result-screen.dart';
import 'package:ebarge/azbazi/pages/landing-page/landing-page.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/providers/azbaziProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/userModel.dart';
import '../providers/userProvider.dart';
import '../screens/books/myBooks.dart';
import '../services/accessCheck.dart';
import '../services/azbazi_service.dart';
import '../utils/utils.dart';
import 'change-notifiers/azStreak-notifier.dart';
import 'change-notifiers/coins-notifier.dart';
import 'change-notifiers/game-mode-notifier.dart';
import 'change-notifiers/scores-notifier.dart';
import 'change-notifiers/skip_q_notifier.dart';
import 'components/icons/wallet.dart';
import 'components/icons/zafran.dart';
import 'oneAzbaziProfileSc.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class OneAzbaziScreen extends StatefulWidget {
  bookModel book;
  azbaziModel azbazi;
  int qsState;
  final UserModel? userData;
  final UserProvider userProvider;
  final isOutsideClick;
  OneAzbaziScreen({Key? key, required this.book, required this.azbazi, required this.qsState, required this.userData, required this.userProvider, required this.isOutsideClick}) : super(key: key);
  AnimationController? animationController;

  @override
  _OneAzbaziScreenState createState() => _OneAzbaziScreenState(this.book, this.azbazi, this.qsState);
}

class _OneAzbaziScreenState extends State<OneAzbaziScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bookModel _book;
  azbaziModel _azbazi;
  int _qsState;

  _OneAzbaziScreenState(this._book, this._azbazi, this._qsState);

  final double infoHeight = 600.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  double rating = 0.0;
  String? mycRate;
  String? rateCount;
  String? azbaziViews;

  String txtReason = "";
  String userBarg = "";

  TextEditingController searchController = new TextEditingController();
  int? firstPageInclude;
  int? lastPageInclude;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();

    rating = double.parse(_azbazi.rate!);
    mycRate = "";
    rateCount = "";
    azbaziViews = "";

    super.initState();
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    addupAzScoreRate("");
  }

  void addupAzScoreRate(String rate) async {
    if (_azbazi.azbazi_id!.isNotEmpty) {
      _azbazi = (await AzbaziService().addUpAzScoreRate(_azbazi, rate, widget.userProvider))!;
      azbaziViews = _azbazi.entrantCount;
      mycRate = _azbazi.rate;
      rateCount = _azbazi.allRateCount;
      if(mounted) {
        setState(() {});
      }
    }
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
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(750, 1334),
    );
      final double tempHeight = MediaQuery.of(context).size.height - (MediaQuery.of(context).size.width / 2.8) + 24.0;;

      return PopScope(
        canPop: false, // یعنی خودت تصمیم می‌گیری که آیا اجازه بازگشت داده شود یا نه
        onPopInvokedWithResult: (bool didPop, Object? result)  async {
          if (didPop) return;
          final backNavigationAllowed = widget.isOutsideClick;
          if (!backNavigationAllowed) {
            if (mounted) Navigator.of(context).pop();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MyBooks(widget.userData),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/space_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                _appBar(context),
                Positioned(
                  top:  60,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery
                        .of(context)
                        .padding
                        .top),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SingleChildScrollView(
                            child: Container(
                              constraints: BoxConstraints(
                                  minHeight: infoHeight,
                                  maxHeight: tempHeight > infoHeight
                                      ? tempHeight
                                      : infoHeight),
                              child:MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(create: (context) => GameModeNotifier()),
                                  ChangeNotifierProvider(create: (context) => CoinsNotifier(_azbazi)),
                                  ChangeNotifierProvider(create: (context) => ScoresNotifier(_azbazi)),
                                  ChangeNotifierProvider(create: (context) => AzQStreakNotifier(_azbazi)),
                                  ChangeNotifierProvider(create: (context) => SkipQuestionNotifier())
                                ],
                                child: BlanksInQuestions(_azbazi, _book, _qsState, animationController, animation),
                              )
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
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
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Card(
      color: Colors.transparent,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            PopupMenuButton(
              iconColor: Colors.white,
              //constraints: const BoxConstraints.tightFor(height: 100),
              color: Colors.white,
              itemBuilder: (context) =>
              [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "پروفایل",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontFamily: "Vazir"
                        ),
                      ),
                      Icon(
                        Icons.arrow_circle_left_outlined, color: Colors.blueAccent,
                        size: 20,)
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "خروج",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontFamily: "Vazir"
                        ),
                      ),
                      Icon(
                        Icons.arrow_circle_left_outlined, color: Colors.blueGrey,
                        size: 20,)
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if(value == 1){
                  _azbazi.azbaziAccess == "normaluser" ?
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OneAzbaziProfileSc(book: _book, azbazi: _azbazi, userData: widget.userData, userProvider: widget.userProvider,);
                      },
                    ),
                  ) : !widget.isOutsideClick ? Navigator.pop(context, true) :
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBooks(widget.userData),
                    ),
                  );
                }else if(value == 2){
                  !widget.isOutsideClick ? Navigator.pop(context, true) :
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBooks(widget.userData),
                    ),
                  );
                }
              },
            ),
            //const SizedBox(width: 20),
            Text(
              'شناسه: ' + '${AccessCheck().replaceFarsiNumber(_azbazi.azbazi_id!)}',
              style: TextStyle(
                  fontSize: 15, color: Colors.white, fontFamily: "Vazir"),
            ),
            ZafranView(),
            TimeBalView(),
            WalletView(walletAmount: 0, shopData: [],)
          ],
        ),
      ),
    ),
  );

  void backToPreviousPage(){
    Navigator.of(context).pop();
    GlobalKeys.navigatorKey.currentState!.pushReplacementNamed("azbazisscreen");
  }

  void azCheckResult(String result, String txtReason, String userBarg) async {
    AzbaziProvider azbaziProvider = AzbaziProvider.instance(
        _book.book_id!, "", "", 1, "", "", "");
    _azbazi = (await azbaziProvider.azCheckResult(
        _azbazi.azbazi_id!, result, txtReason, userBarg))!;
  }


  Widget getTimeBoxUI(String text1, String txt2) {
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
              left: 14.0, right: 14.0, top: 1.0, bottom: 9.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: OurTheme.nearlyBlue,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: OurTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlanksInQuestions extends StatelessWidget {
  const BlanksInQuestions(this.azbazi, this.book, this.qsState, this.animationController, this.animation, {super.key});
  final azbaziModel azbazi;
  final bookModel book;
  final int qsState;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = !true;
    return MaterialApp(
      title: azbazi.title!,
      debugShowCheckedModeBanner: false,
      initialRoute: LandingPage.route,
      routes: {
        LandingPage.route: (context) => LandingPage(azbazi: azbazi, book: book, qsState: qsState),
        GamePage.route: (context) => GamePage(book: book, azbazi: azbazi),
        MyFinalResultScreen.route: (context) => MyFinalResultScreen(azbazi: azbazi, book: book, animationController: animationController,),
      },
    );
  }
}