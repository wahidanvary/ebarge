import 'dart:io';
import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/models/rankModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/screens/books/bookDrawer.dart';
import 'package:ebarge/screens/books/ranksScreen.dart';
import 'package:ebarge/screens/pageScreen/paint_screen.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/bargProvider.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';

import 'myBooks.dart';

class bookDescription extends StatefulWidget {
  bookModel? _book;
  UserModel? _user;
  bookDescription(this._book, this._user);
  AnimationController? animationController;

  @override
  _bookDescriptionState createState() => _bookDescriptionState(this._book, this._user);
}

// ignore: camel_case_types
class _bookDescriptionState extends State<bookDescription>
  with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bookModel? _book;
  UserModel? _user;
  _bookDescriptionState(this._book, this._user);

  List<pageModel> _lastPagesData = [];
  List<dynamic>? _pageNumToId;
  pageModel? onePageData;

  final double infoHeight = 400.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;

  TextEditingController searchController = new TextEditingController();
  bool? isFollowed;
  bool followClick = false;
  bool paintClick = false;

  bool searchLoading = false;
  bool lastPageLoading = false;

  String? bWalletAmount = '';
  List<RankModel> _ranks = <RankModel>[];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    getWallet();
    getTopRanks();
    isFollowed = true;
    super.initState();
  }

  void getWallet() async{
    BargProvider bargProvider = BargProvider.instance(_book!.book_id!);
    bWalletAmount = (await bargProvider.getUserWallet(_book!.book_id!, "0"))!;
    //setState(() {});
  }

  void getTopRanks() async{
    BargProvider bargProvider = BargProvider.instance(_book!.book_id!);
    _ranks = await bargProvider.getTopRanks(_book!.book_id!);
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    paintClick = false;
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    fetchPagesData(widget._book!.book_id!);
  }

  Future<void> setData() async {
    animationController!.forward();
    if (!mounted) {
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
    int bookPagesCount = int.parse(_book!.pages_count!) -
        int.parse(_book!.gap_pages!);
    final double tempHeight = MediaQuery
        .of(context)
        .size
        .height -
        (MediaQuery
            .of(context)
            .size
            .width / 1.2) +
        24.0;
    String? bookAdmin = _book!.admin_name != null ? _book!.admin_name : "";
    String? bookAssistant = _book!.assistant_name != null ? _book!.assistant_name : "";
    return PopScope(
      child: Container(
        color: OurTheme.nearlyWhite,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
                color: Colors.white,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.70,
                child: BookDrawer(_book!, bWalletAmount!)
            ),
          ),
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.network(
                        GlobalKeys.ebargeUrl + '/' + _book!.ebavatar!),
                  ),
                ],
              ),
              Positioned(
                top: (MediaQuery
                    .of(context)
                    .size
                    .width / 1.2) - 64.0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: OurTheme.nearlyWhite,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: OurTheme.grey.withOpacity(0.2),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                              minHeight: infoHeight,
                              maxHeight: tempHeight > infoHeight
                                  ? tempHeight
                                  : infoHeight),
                          child: PrimaryScrollController(
                            controller: ScrollController(),
                            child: ListView(
                              primary: false,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0, left: 18, right: 16),
                                  child: Text(
                                    '${_book!.book_name}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Vazir",
                                      fontSize: 20,
                                      letterSpacing: 0.27,
                                      color: OurTheme.darkerText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 0, top: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'کد کتاب چاپ: ${_book!.bchap_id}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontFamily: "Vazir",
                                          fontSize: 18,
                                          letterSpacing: 0.27,
                                          color: OurTheme.nearlyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: opacity3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Row(
                                      children: <Widget>[
                                        getTimeBoxUI(
                                            'تعداد صفحه',
                                            '${AccessCheck().replaceFarsiNumber(
                                                bookPagesCount.toString())}'),
                                        getTimeBoxUI(
                                            'سال تحصیلی', '${_book!.edu_year}'),
                                        getTimeBoxUI(
                                            'کد کتاب سامانه',
                                            '${AccessCheck().replaceFarsiNumber(
                                                _book!.book_id!)}'),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 0, bottom: 0, top: 0),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: opacity3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, bottom: 16, right: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              child: TextFormField(
                                                controller: searchController,
                                                keyboardType: TextInputType
                                                    .number,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                style: TextStyle(
                                                  fontFamily: "Vazir",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: OurTheme.nearlyBlue,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'شماره صفحه را وارد کن!',
                                                  border: InputBorder.none,
                                                  helperStyle: TextStyle(
                                                    fontFamily: "Vazir",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: HexColor('#B9BABC'),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    fontFamily: "Vazir",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    letterSpacing: 0.2,
                                                    color: HexColor('#B9BABC'),
                                                  ),
                                                ),
                                                onEditingComplete: () {},
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            height: 40,
                                            child: Builder(
                                              builder: (context) =>
                                              !searchLoading ? InkWell(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    AppBar().preferredSize
                                                        .height),
                                                child: Icon(
                                                  Icons.youtube_searched_for,
                                                  color: OurTheme.nearlyBlack,
                                                ),
                                                onTap: () {
                                                  _onSearchPageTap(
                                                      context, "search");
                                                },
                                              ) :
                                              SpinKitRotatingPlain(
                                                color: Colors.indigo[900],
                                                size: 18.0,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: HexColor('#FFFF80')
                                              .withOpacity(0.6),
                                          offset: const Offset(1.1, 4.0),
                                          blurRadius: 8.0),
                                    ],
                                    gradient: LinearGradient(
                                      colors: <HexColor>[
                                        HexColor('#FFFFFF'),
                                        HexColor('#FFFF80'),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(8.0),
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  height: 190.0,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: !lastPageLoading ? Text(
                                          'صفحات مشاهده شده اخیر...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: "Vazir",
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14,
                                          ),
                                        ) :
                                        SpinKitRotatingPlain(
                                          color: Colors.indigo[900],
                                          size: 18.0,
                                        ),
                                      ),
                                      Expanded(
                                        child: PagesListView(),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30.0),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: opacity3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Row(
                                      children: <Widget>[
                                        getTimeBoxUI(
                                            'مدیر کتاب', '$bookAdmin'),
                                        getTimeBoxUI(
                                            'معاون کتاب', '$bookAssistant'),
                                        _ranks.length != 0 ? InkWell(
                                            child: getTimeBoxUI(
                                                'فعالترین',
                                                '${_ranks[0].user_name}'),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RanksScreen(
                                                          _ranks, bWalletAmount!),
                                                ),
                                              );
                                            }
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40.0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery
                    .of(context)
                    .size
                    .width / 1.2) - 100.0,
                left: 20,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: CurvedAnimation(
                      parent: animationController!,
                      curve: Curves.fastOutSlowIn),
                  child: Card(
                    color: OurTheme.nearlyBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    elevation: 10.0,
                    child: Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: LikeButton(
                          size: 30,
                          circleColor:
                          CircleColor(start: Color(0xff00ddff), end: Color(
                              0xff0099cc)),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Color(0xff33b5e5),
                            dotSecondaryColor: Color(0xff0099cc),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              Icons.business_center,
                              color: isFollowed! ? Colors.pinkAccent : Colors
                                  .white,
                              size: 30,
                            );
                          },
                          onTap: onFollowButtonTapped,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .padding
                    .top),
                child: SizedBox(
                  width: AppBar().preferredSize.height,
                  height: AppBar().preferredSize.height,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(AppBar().preferredSize.height),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onTap: () async {
                        !followClick ? Navigator.pop(context) :
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                            builder: (context) => MyBooks(_user!)), (
                            route) => false,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery
                      .of(context)
                      .padding
                      .top, right: 10),

                  child: SizedBox(
                    width: AppBar().preferredSize.height,
                    height: AppBar().preferredSize.height,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(AppBar().preferredSize.height),
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 28,
                        ),
                        onTap: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        if (didPop) return;
        final backNavigationAllowed = followClick;
        if (!backNavigationAllowed) {
          if (mounted) Navigator.of(context).pop();
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) => MyBooks(_user!)), (route) => false,
          );
        }
      },
    );
  }

  Future<bool> onFollowButtonTapped(bool isLiked) async{
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=post&module=books&resource=followbook';

      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "book_id": _book!.book_id,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      setState(() {
        if(response.data["status"] == "ok")
          if(response.data["result"] == -1){
            isFollowed = false;
            Flushbar(
              margin: EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
              backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
              messageText: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "کتاب از کیف تحصیلی خارج شد!",
                  style: TextStyle(fontSize: 14.0, color: Colors.pink, fontFamily: "Vazir",),
                ),
              ),
              duration:  Duration(seconds: 2),
            )..show(context);
          } else {
            isFollowed = true;
            Flushbar(
              margin: EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
              backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
              messageText: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "کتاب وارد کیف تحصیلی شد!",
                  style: TextStyle(fontSize: 14.0, color: Colors.purple, fontFamily: "Vazir",),
                ),
              ),
              duration:  Duration(seconds: 2),
            )..show(context);
          }
        else
          print(response.data["error_description"]);
        followClick = true;
      });
    } catch (e) {
      print(e);
    }
    return true;
  }

  void _onSearchPageTap(BuildContext context, String direction) async {
    int inputValue = int.parse(searchController.text);
    int pageCount =  _pageNumToId![0].length - int.parse(_book!.gap_pages!);

    int realPageNumIndex = inputValue + int.parse(_book!.gap_pages!);
    if(realPageNumIndex <= pageCount &&  realPageNumIndex > 0 && !paintClick){
      paintClick = true;
      await getOnePageData(_pageNumToId![0][realPageNumIndex.toString()], direction);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context){
            //int i=0;
            return PaintScreen(onePageData!, _book!, _pageNumToId!);
          },
        ),
      );
    } else {
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "صفحه مورد نظر پیدا نشد!",
            style: TextStyle(fontSize: 14.0, fontFamily: "Vazir", color: Colors.pink),
          ),
        ),
        duration:  Duration(seconds: 2),
      )..show(context);
    }
  }

  void fetchPagesData(String bookId) async {
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';
      if (!mounted) {
        return;
      }
      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "book_id": bookId,
        "orderdir": 'desc',
        "orderby": 'visit_date',
        "limit": '10',
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      setState(() {
        _pageNumToId = response.data["pagenumtoid"];
        var pagesJson = response.data["pages"];
        for (var j in pagesJson) {
          var pageItem = pageModel(
              j['page_id'],
              j['page_image'],
              j['page_thumb'],
              j['view_count'],
              j['pdf_page_num'],
              j['real_page_num'],
              j['hotrates'],
              j['uview_id'],
              j['user_id'],
              j['uview_count'],
              j['saved_image'],
              j['hotrate'],
              j['saved_date'],
              j['visit_date'],
              j['page_ns_count'],
              j['page_qs_count'],
              j['page_cs_count'],
              j['status'],
              j['error_code'],
              j['error_description']);
          _lastPagesData.add(pageItem);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getOnePageData(String pageId, String direction) async {
    bool isAccess = await AccessCheck().hasAccessTime();
    if (!isAccess) {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    setState(() {
      direction == "lastPage" ? lastPageLoading = true : searchLoading = true;
    });
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';
      if (!mounted) {
        paintClick = false;
        return;
      }
      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "book_id": _book!.book_id,
        "page_id": pageId,
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);
      setState(() {
        onePageData = pageModel(
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
      setState(() {
        direction == "lastPage" ? lastPageLoading = false : searchLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  // ignore: non_constant_identifier_names
  Widget PagesListView() {
    String startColor = (math.Random().nextDouble() * 0xFFFFFF)
        .toInt()
        .toString();
    String endColor = (math.Random().nextDouble() * 0xFFFFFF)
        .toInt()
        .toString();
    return Container(
      height: 200,
      width: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            top: 0, bottom: 0, right: 16, left: 16),
        itemCount: _lastPagesData.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: InkWell(
              child: SizedBox(
                width: 120,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5, left: 18, right: 2, bottom: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: HexColor(endColor)
                                    .withOpacity(0.7),
                                offset: const Offset(1.1, 2.0),
                                blurRadius: 2.0),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(startColor),
                              HexColor(endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(40.0),
                          ),
                        ),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 40, left: 12, right: 6, bottom: 5),
                            child: Image.network(GlobalKeys.ebargeUrl + '/' +
                                _lastPagesData[index].page_thumb,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null ?
                                    loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -15,
                      left: 0,
                      child: Container(
                        width: 100,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 18,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        // child: Image.asset(_lastPagesData.imagePath),
                        child: Text(
                          'صفحه ${AccessCheck().replaceFarsiNumber(_lastPagesData[index].real_page_num)}',
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
                    )
                  ],
                ),
              ),
              onTap: () async {
                if(!paintClick) {
                  paintClick = true;
                  await getOnePageData(
                      _lastPagesData[index].page_id, "lastPage");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return PaintScreen(onePageData!, _book!, _pageNumToId!);
                      },
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
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
                  fontFamily: "Vazir",
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
                  fontFamily: "Vazir",
                  fontSize: 15,
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
