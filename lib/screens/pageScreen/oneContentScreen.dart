import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/books/checkContents.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/services/requestDownload.dart';
import 'package:ebarge/providers/contentProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ebarge/screens/pageScreen/content_editor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as path;
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class OneContentScreen extends StatefulWidget {

  bookModel book;
  pageModel pageData;
  contentModel content;
  List<dynamic> pageNumToId;
  OneContentScreen({Key? key, required this.book, required this.pageData, required this.content, required this.pageNumToId}) : super(key: key);
  AnimationController? animationController;

  @override
  _OneContentScreenState createState() => _OneContentScreenState(this.book, this.pageData, this.content, this.pageNumToId);
}

class _OneContentScreenState extends State<OneContentScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bookModel _book;
  pageModel _pageData;
  contentModel _content;
  List<dynamic> _pageNumToId;
  _OneContentScreenState(this._book, this._pageData, this._content, this._pageNumToId);

  final double infoHeight = 400.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  double rating = 0.0;
  String? mycRate;
  String? rateCount;
  String? contentViews;

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

    rating = double.parse(_content.rate!);
    mycRate = "";
    rateCount = "";
    contentViews = "";

    var includePagesNum = _content.pages_include?.split(',');
    for( var i = 0 ; i < _pageNumToId[0].length; i++ ) {
      int j = i+1;
      if(includePagesNum?.first == _pageNumToId[0]["$j"]){
        firstPageInclude = j - int.parse(_book.gap_pages!);
      }
      if(includePagesNum?.last == _pageNumToId[0]["$j"]){
        lastPageInclude = j - int.parse(_book.gap_pages!);
      }
    }
    super.initState();
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    addupCViewRate("");
  }

  void addupCViewRate(String rate) async {
    if (_content.content_id!.isNotEmpty) {
      ContentProvider contentProvider = ContentProvider.instance(
          _book.book_id!, _pageData.page_id, "", "", 0, 0);
      _content = (await contentProvider.addupCViewRate(_content.content_id!, rate, _content))!;
      contentViews = _content.views;
      mycRate = _content.crate;
      rateCount = _content.rate_count;
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
      final double tempHeight = MediaQuery
          .of(context)
          .size
          .height -
          (MediaQuery
              .of(context)
              .size
              .width / 1.2) +
          24.0;
      return Container(
        color: OurTheme.nearlyWhite,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(AppBar().preferredSize.height),
                      child: Image.network(
                          GlobalKeys.ebargeUrl + '/' + _content.thumb_link!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Player(content: _content,),
                          ),
                        );
                      },
                    ),
                    //child: Image.network(_book.avatar),
                  ),
                ],
              ),
              Positioned(
                top: (MediaQuery
                    .of(context)
                    .size
                    .width / 1.2) - 100.0,
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
                                      top: 10, left: 18, right: 16),
                                  child: Text(
                                    '${_content.content_title}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      letterSpacing: 0.27,
                                      color: OurTheme.darkerText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 16, bottom: 0, top: 0),
                                  child: Text(
                                    firstPageInclude != lastPageInclude ?
                                    "محتوا برای صفحه${AccessCheck().replaceFarsiNumber(firstPageInclude.toString())} تا صفحه${AccessCheck().replaceFarsiNumber(lastPageInclude.toString())} کتاب " +
                                        _book.book_name! :
                                    "محتوا برای صفحه${AccessCheck().replaceFarsiNumber(firstPageInclude.toString())} کتاب " +
                                        _book.book_name!,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      fontFamily: "Vazir",
                                      fontSize: 16,
                                      letterSpacing: 0.27,
                                      color: OurTheme.nearlyBlue,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(14),
                                ),
                                Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5, right: 20),
                                        child: Icon(Icons.streetview,
                                          color: Colors.green, size: 18,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5, right: 5),
                                        child: Text(
                                          contentViews!,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            letterSpacing: 0.27,
                                            color: OurTheme.darkerText,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 5, right: 10),
                                        child: SmoothStarRating(
                                          allowHalfRating: true,
                                          onRatingChanged: (v) {
                                            addupCViewRate(v.toString());
                                            rating = v;
                                            mycRate = v.toString();
                                            setState(() {});
                                          },
                                          starCount: 5,
                                          rating: rating,
                                          size: 22,
                                          color: Colors.amber,
                                          borderColor: Colors.black45,
                                          spacing: 0.0,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5),
                                        child: Text(
                                          mycRate != "0" && mycRate != ""
                                              ? 'رای شما: $mycRate | (آرا: $rateCount)'
                                              : '(آرا: $rateCount)',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(26),
                                            color: Colors.black45,
                                            fontFamily: "Montserrat",
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(14),
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
                                          child: getTimeBoxUI(
                                              'تولید کننده محتوا',
                                              '${_content.owner_name}'),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: getTimeBoxUI(
                                              'تاریخ بارگذاری',
                                              '${_content.created_date}'),
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
                                          child: _content.owner_id !=
                                                  _content.user_id
                                              ? getTimeBoxUI(
                                              'وارد کننده محتوا',
                                              '${_content.user_name}')
                                              : Container(),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: _content.modified_date !=
                                                  _content.created_date
                                              ? getTimeBoxUI(
                                              'تاریخ بازبینی',
                                              '${_content.modified_date}')
                                              : Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _showCheckReasons(),
                                SizedBox(height: 20.0),
                                Divider(thickness: 0.7,),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: ScreenUtil().setWidth(460),
                                  ),
                                  child: Text(
                                    "توضیح تکمیلی:",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32),
                                      color: Colors.indigo,
                                      fontFamily: "Montserrat",
                                    ),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: ScreenUtil().setWidth(460),
                                  ),
                                  child: Text(
                                    _content.content_note!,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      fontFamily: "Montserrat",
                                    ),
                                  ),
                                ),
                                SizedBox(height: 100.0),
                                _content.page_image != null ?
                                Image.network(
                                    GlobalKeys.ebargeUrl + '/' + _content.page_image!) : Container(),
                                SizedBox(height: 100.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _showCheckBTNs(),
              _showEditBTN(),
              Positioned(
                top: (MediaQuery
                    .of(context)
                    .size
                    .width / 1.2) - 240.0,
                right: 40,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: CurvedAnimation(
                      parent: animationController!, curve: Curves.fastOutSlowIn),
                  child: Card(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    elevation: 400.0,
                    child: Container(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          child: const Icon(
                            Icons.play_circle_outline, size: 50,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Player(content: _content,),
                              ),
                            );
                          },
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
                        color: Colors.black45,
                      ),
                      onTap: () {
                        //_navigatorKey.currentState.changePage(2);
                        /*Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OurEbargeApp(),
                          ),
                        );*/

                        Navigator.pop(context, true);
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
                      .top),

                  child: SizedBox(
                    width: AppBar().preferredSize.height,
                    height: AppBar().preferredSize.height,
                    child: PopupMenuButton(
                      itemBuilder: (context) =>
                      [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("دانلود", style: TextStyle(
                                  color: Colors.green, fontSize: 15)),
                              Icon(Icons.file_download, color: Colors.green,
                                size: 20,)
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("گزارش", style: TextStyle(color: Colors.pink,
                                  fontSize: 14)),
                              Icon(
                                Icons.report_problem, color: Colors.pink,
                                size: 20,)
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                         String videoUrl = GlobalKeys.ebargeUrl + _content.content_link!;
                         String ebargePath = '/ebarge/videos';
                         File file = new File(videoUrl);
                         String fileName = path.basename(file.path);

                        if (value == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RequestDownload(downloadUrl: videoUrl, ebargePath: ebargePath, fileName: fileName, allowBack: true, allowExecute: true,)),
                          );
                        }
                        if (value == 2) {
                          final text = await showTextInputDialog(
                            context: context,
                            textFields: [
                              DialogTextField(
                                hintText: '...',
                                validator: (value) =>
                                value!.length < 8
                                    ? '!حداقل در چند کلمه دلیلتان را وارد نمایید'
                                    : null,
                              ),
                            ],
                            okLabel: "گزارش",
                            cancelLabel: "لغو",
                            style: AdaptiveStyle.iOS,
                            isDestructiveAction: true,
                            title: "!گزارش ایراد محتوا",
                            message: '...دلیل گزارش محتوا را در کادر زیر وارد نمایید',
                          );
                          if (text != null) {
                            await showOkAlertDialog(
                              context: context,
                              style: AdaptiveStyle.iOS,
                              okLabel: "!باشه",
                              title: '...ممنون از گزارش تان',
                            );
                          }
                          //logger.info(text);
                          //print("value:$value");
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _showCheckReasons() {
    var allReasons = _content.rejectReasons;
    return ListView.builder(
        itemCount: allReasons!.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Column(
              children: <Widget>[
                index == 0 ? Divider(thickness: 0.7,) : Container(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ScreenUtil().setWidth(460),
                  ),
                  child: Text(
                    "نیازمند بررسی:",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: Colors.pinkAccent,
                      fontFamily: "Montserrat",
                    ),
                  ),
                ),
                ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ScreenUtil().setWidth(700),
                    ),
                    child: RichText(
                      text: new TextSpan(
                        children: <TextSpan>[
                          new TextSpan(text: allReasons[index]["reason"],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Montserrat",
                              color: Colors.deepOrange[700],
                            ),
                          ),
                          new TextSpan(
                            text: ' (${allReasons[index]["reviewer"]})',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Montserrat",
                              color: Colors.black54,
                            ),
                          ),
                          new TextSpan(
                            text: ' (${allReasons[index]["check_date"]})',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Montserrat",
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _showCheckBTNs() {
    return Positioned(
      top: (MediaQuery
          .of(context)
          .size
          .width / 1.2) - 260.0,
      left: 10,
      child: Column(
        children: <Widget>[
          _content.contentAccess == "imadmin" && _content.state == "0"
              ? ScaleTransition(
            alignment: Alignment.center,
            scale: CurvedAnimation(
                parent: animationController!, curve: Curves.fastOutSlowIn),
            child: InkWell(
              child: Card(
                color: OurTheme.nearlyWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                elevation: 10.0,
                child: Container(
                  width: 80,
                  height: 45,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("تائید", style: TextStyle(
                            color: Colors.green, fontSize: 14)),
                        Icon(Icons.check_circle,
                          color: Colors.green,
                          size: 20,)
                      ],
                    ),
                  ),
                ),
              ),
              onTap: _confirmPopup,
            ),
          )
              : Container(),
          (_content.contentAccess == "imadmin" ||
              _content.contentAccess == "bookadmin") && _content.state == "0"
              ? ScaleTransition(
            alignment: Alignment.center,
            scale: CurvedAnimation(
                parent: animationController!, curve: Curves.fastOutSlowIn),
            child: InkWell(
              child: Card(
                color: OurTheme.nearlyWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                elevation: 10.0,
                child: Container(
                  width: 80,
                  height: 45,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("رد", style: TextStyle(
                            color: Colors.deepOrange, fontSize: 14)),
                        Icon(Icons.cancel,
                          color: Colors.deepOrange,
                          size: 20,)
                      ],
                    ),
                  ),
                ),
              ),
              onTap: _rejectPopup,
            ),
          )
              : Container(),
          (_content.contentAccess == "imadmin" ||
              _content.contentAccess == "imadder" ||
              _content.contentAccess == "ismine") && (_content.state != "2")
              ? ScaleTransition(
            alignment: Alignment.center,
            scale: CurvedAnimation(
                parent: animationController!, curve: Curves.fastOutSlowIn),
            child: InkWell(
              child: Card(
                color: OurTheme.nearlyWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
                elevation: 10.0,
                child: Container(
                  width: 80,
                  height: 45,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text("حذف", style: TextStyle(
                            color: Colors.pink, fontSize: 14)),
                        Icon(Icons.delete_forever,
                          color: Colors.pinkAccent,
                          size: 20,)
                      ],
                    ),
                  ),
                ),
              ),
              onTap: _deletePopup,
            ),
          )
              : Container(),
        ],
      ),
    );
  }

  Future<void> _confirmPopup() async{
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: '.در چند کلمه بنویسید',
          validator: (value) => null,
        ),
        DialogTextField(
          hintText: 'برگ حداقل 200- حداکثر 1550',
          validator: (value) =>
          value!.length != 0 && value.length > 4
              ? '!حداقل برگ 200- و حداکثر 1550 وارد نمایید'
              : null,
        ),
      ],
      okLabel: "ارسال",
      cancelLabel: "لغو",
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
      title: "!تائید محتوا",
      message: '...اگر توصیه ای دارید در کادر زیر بنویسید',
    );

    if (text != null) {
      txtReason = text[0];
      userBarg = text[1];
      cCheckResult("2", txtReason, userBarg);
      await showOkAlertDialog(
          context: context,
        style: AdaptiveStyle.iOS,
          okLabel: "!باشه",
          title: '...ممنون از بررسی این محتوا',
      );
      backToPreviousPage();
    }
  }

  Future<void> _rejectPopup() async{
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'دلیل رد محتوا',
          validator: (value) =>
          value!.length < 8
              ? '!حداقل در چند کلمه دلیلتان را وارد نمایید'
              : null,
        ),
      ],
      okLabel: "ارسال",
      cancelLabel: "لغو",
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
      title: "!رد محتوا",
      message: '...دلیل رد محتوا را در کادر زیر وارد نمایید',
    );

    if (text != null) {
      txtReason = text[0];
      cCheckResult("-1", txtReason, "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...ممنون از بررسی این محتوا',
      );
      backToPreviousPage();
    }
  }

  Future<void> _deletePopup() async{
    final deleteResult = await showOkCancelAlertDialog(
      context: context,
      title: '!حذف محتوا',
      message: '!محتوا کامل از پایگاه داده حذف شود',
      okLabel: 'تائید',
      cancelLabel: 'لغو',
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
    );

    String result = deleteResult.index.toString();
    if (result == "0") {//yani tayiid hazf
      cCheckResult("-5", "", "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...محتوا با موفقیت حذف شد',
      );
      backToPreviousPage();
    }
  }

  void backToPreviousPage(){
    if(_pageData.pdf_page_num != ""){
      Navigator.of(context).pop();
      GlobalKeys.navigatorKey.currentState!.pushReplacementNamed("contentsscreen");
    } else {
      bookModel? bookTemp;
      String _contentState;
      String _contentAccess;
      if(_book.pages_count == "") {
        _contentState = "0";
        _contentAccess = "admin";
        bookTemp = _book;
      } else {
        _contentState = "";
        _contentAccess = "imadder";
      }

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CheckContents(book: bookTemp!, contentState: _contentState, contentAccess: _contentAccess, pageNumber: 1,);
          },
        ),
      );
    }
  }

  void cCheckResult(String result, String txtReason, String userBarg) async {
    ContentProvider contentProvider = ContentProvider.instance(
        _book.book_id!, _pageData.page_id, "", "", 0, 0);
    _content = (await contentProvider.cCheckResult(_content.content_id!, result, txtReason, userBarg))!;
    }

  Widget _showEditBTN() {
    return Positioned(
      top: (MediaQuery
          .of(context)
          .size
          .width / 1.2) - 155.0,
      right: 10,
      child: (_content.contentAccess == "imadmin" ||
          _content.contentAccess == "imadder" ||
          _content.contentAccess == "ismine") && (_content.state != "2")
          ? ScaleTransition(
        alignment: Alignment.center,
        scale: CurvedAnimation(
            parent: animationController!, curve: Curves.fastOutSlowIn),
        child: InkWell(
          child: Card(
            color: Colors.amberAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            elevation: 10.0,
            child: Container(
              width: 90,
              height: 45,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text("ویرایش", style: TextStyle(
                        color: Colors.blue, fontSize: 14, fontFamily: "Vazir")),
                    Icon(Icons.edit,
                      color: Colors.blue,
                      size: 20,)
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ContentEditor(content: _content,
                      pageData: _pageData,
                      book: _book,
                      pageNumToId: _pageNumToId);
                },
              ),
            );
          },
        ),
      )
          : Container(),
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