import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ebarge/azbazi/pages/addQsAiEditor.dart';
import 'package:ebarge/azbazi/pages/azbazi_editor.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/providers/azbaziProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/userModel.dart';
import '../providers/userProvider.dart';
import '../screens/azBaziScreen/azBaziha.dart';
import '../services/accessCheck.dart';
import '../services/azbazi_service.dart';
import '../utils/hexColor.dart';
import 'change-notifiers/azStreak-notifier.dart';
import 'change-notifiers/timeBal-notifier.dart';
import 'change-notifiers/wallet-notifier.dart';
import 'change-notifiers/zafrans-notifier.dart';
import 'checkAzbazis.dart';
import 'oneAzBaziScreen.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class OneAzbaziProfileSc extends StatefulWidget {
  bookModel book;
  azbaziModel azbazi;
  final UserModel? userData;
  final UserProvider userProvider;
  OneAzbaziProfileSc({Key? key, required this.book, required this.azbazi, required this.userData, required this.userProvider}) : super(key: key);
  AnimationController? animationController;

  @override
  _OneAzbaziProfileScState createState() => _OneAzbaziProfileScState(this.book, this.azbazi);
}

class _OneAzbaziProfileScState extends State<OneAzbaziProfileSc>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bookModel _book;
  azbaziModel _azbazi = azbaziModel();

  _OneAzbaziProfileScState(this._book, this._azbazi);

  final double infoHeight = 400.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  double rating = 0.0;
  String? myAzRate;
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
        duration: const Duration(milliseconds: 600), vsync: this);

    setData();

    rating = double.parse(_azbazi.rate!);
    myAzRate = "";
    rateCount = "";
    azbaziViews = "";

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }

    addUpAzScoreRate("");

    super.didChangeDependencies();
  }

  void addUpAzScoreRate(String rate) async {
    if (_azbazi.azbazi_id!.isNotEmpty) {
      _azbazi = (await AzbaziService().addUpAzScoreRate(_azbazi, rate, widget.userProvider))!;
      azbaziViews = _azbazi.entrantCount != null ? _azbazi.entrantCount : "";
      myAzRate = _azbazi.rate;
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
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1334));
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.3) + 24.0;

    // اطمینان از اینکه tempHeight مثبت است
    if (tempHeight < 0) {
      return Container(color: Colors.white);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/gamespace_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // اطمینان از اینکه ارتفاع منفی نیست
            double calculatedHeight = constraints.maxHeight - (constraints.maxWidth / 1.2);
            if (calculatedHeight < 0) {
              calculatedHeight = 0; // جلوگیری از ارتفاع منفی
            }
            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: _azbazi.thumb_link != null && _azbazi.thumb_link != ""
                            ? FadeInImage
                          .memoryNetwork(
                        placeholder: kTransparentImage,
                        image: GlobalKeys.ebargeUrl +
                            _azbazi.thumb_link!,
                        width: 130,
                        height: 130,
                        fit: BoxFit.fitWidth,
                      )
                            : Image.asset('assets/images/blankazbazthumb.png', height: 150),
                    ),
                  ],
                ),
                Positioned(
                  top: constraints.maxWidth / 1.2 - 100.0,
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
                          topRight: Radius.circular(32.0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: OurTheme.grey.withOpacity(0.2),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 0,
                            maxHeight: calculatedHeight,
                          ),
                          child: ListView(
                            primary: false,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 18, right: 16),
                                child: Text(
                                  '${_azbazi.title}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    letterSpacing: 0.27,
                                    color: OurTheme.darkerText,
                                    fontFamily: "Vazir",
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
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
                              SizedBox(height: ScreenUtil().setHeight(14)),
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5, right: 20),
                                    child: Icon(Icons.streetview, color: Colors.green, size: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5, right: 5),
                                    child: Text(
                                      AccessCheck().replaceFarsiNumber(azbaziViews!),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: 0.27,
                                        color: OurTheme.darkerText,
                                        fontFamily: "Vazir",
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5, right: 10),
                                    child: SmoothStarRating(
                                      allowHalfRating: true,
                                      onRatingChanged: (v) {
                                        addUpAzScoreRate(v.toString());
                                        rating = v;
                                        myAzRate = v.toString();
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
                                      myAzRate != "0" && myAzRate != ""
                                          ? 'میانگین: ' + AccessCheck().replaceFarsiNumber(myAzRate!) + ' | (آرا: ' + AccessCheck().replaceFarsiNumber(rateCount!) + ')'
                                          : '(آرا: $rateCount)',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(22),
                                        color: Colors.black45,
                                        fontFamily: "Vazir",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ScreenUtil().setHeight(14)),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 500),
                                opacity: opacity3,
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 5,
                                        child: getTimeBoxUI('طراح آزبازی', '${_azbazi.owner_name}'),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: _azbazi.modified_date != _azbazi.created_date
                                            ? getTimeBoxUI('آخرین بازبینی', '${_azbazi.modified_date}')
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
                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            // ویجت اصلی
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32), // جا برای آیکون خالی می‌کنیم
                                              child: getTimeBoxUI(
                                                'تعداد سوالات',
                                                '${AccessCheck().replaceFarsiNumber(_azbazi.qCount!)}',
                                              ),
                                            ),
                                            _azbazi.state == "1" && widget.userData!.state == 2 && _azbazi.aiModels != null ? Positioned(
                                              top: 18,
                                              right: 18,
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(20),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => addQsAiEditor(azbazi: _azbazi,book: _book,),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.add_circle_outline_outlined,
                                                      size: 22,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ) : Container(),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        flex: 5,
                                        child: _azbazi.modified_date != _azbazi.created_date
                                            ? getTimeBoxUI('تاریخ ایجاد', '${_azbazi.created_date}')
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_azbazi.state != "5") _showCheckReasons(),
                              const SizedBox(height: 24),
                              _buildDescriptionSection(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _showCheckBTNs(),
                if (_azbazi.azbaziAccess != "normaluser")
                  Positioned(
                    top: constraints.maxWidth / 1.2 - 220,
                    right: 2,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: CurvedAnimation(parent: animationController!, curve: Curves.fastOutSlowIn),
                      child: Card(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                        elevation: 400.0,
                        child: Container(
                          width: 140,
                          height: 70,
                          child: ScaleTransition(
                            alignment: Alignment.center,
                            scale: CurvedAnimation(parent: animationController!, curve: Curves.fastOutSlowIn),
                            child: int.parse(_azbazi.state!) >= 1 || int.parse(_azbazi.state!) == -1 ? InkWell(
                              child: Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                elevation: 15.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: HexColor('#1E1466')
                                              .withOpacity(0.6),
                                          offset: const Offset(1.1, 4.0),
                                          blurRadius: 8.0),
                                    ],
                                    gradient: LinearGradient(
                                      colors: <HexColor>[
                                        HexColor('#11faa4'),
                                        HexColor('#03a56a'),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(32.0),
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(32.0),
                                    ),
                                  ),
                                  width: 80,
                                  height: 45,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("ورود به بازی ", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Vazir")),
                                        Icon(Icons.fact_check_outlined, color: Colors.white, size: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(create: (context) => WalletNotifier()),
                                            ChangeNotifierProvider(create: (context) => ZafransNotifier()),
                                            ChangeNotifierProvider(create: (context) => TimeBalNotifier()),
                                          ],
                                          child: OneAzbaziScreen(book: _book, azbazi: _azbazi, qsState: 1, userData: widget.userData, userProvider: widget.userProvider, isOutsideClick: false,));
                                    },
                                  ),
                                ).then((value) {
                                  setState(() {});
                                });
                              },
                            ) :
                            Card(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              elevation: 15.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: HexColor('#1E1466')
                                            .withOpacity(0.6),
                                        offset: const Offset(1.1, 4.0),
                                        blurRadius: 8.0),
                                  ],
                                  gradient: LinearGradient(
                                    colors: <HexColor>[
                                      HexColor('#FFD580'),
                                      HexColor('#E49B0F'),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(32.0),
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(32.0),
                                  ),
                                ),
                                width: 80,
                                height: 45,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("منتظر بررسی ", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Vazir")),
                                      Icon(Icons.watch_later_outlined, color: Colors.white, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 6, left: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () => Navigator.pop(context, true),
                        splashColor: Colors.amber.withOpacity(0.3),
                        highlightColor: Colors.transparent,
                        child: Ink(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4, right: 8),
                    child: SizedBox(
                      width: AppBar().preferredSize.height,
                      height: AppBar().preferredSize.height,
                      child: MenuAnchor(
                        builder: (BuildContext context, MenuController controller, Widget? child) {
                          return IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              shadowColor: Colors.black26,
                              elevation: 2,
                            ),
                            tooltip: 'بیشتر',
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                          );
                        },
                        menuChildren: [
                          if (_azbazi.state == "5") MenuItemButton(
                            leadingIcon: const Icon(Icons.share, color: Colors.green),
                            child: const Text(
                              "اشتراک",
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: "Vazir",
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              Share.share(
                                "https://ebarge.ir/azbazi/${_azbazi.azbazi_id!}\n"
                                    "${_azbazi.title!} را بازی کن، یاد بگیر، ارز زفران کسب کن 🌿\n"
                                    "کتاب: ${_book.book_name!}",
                              );
                            },
                          ),
                          const Divider(height: 1, thickness: 0.8),
                          _azbazi.state != "5" ? MenuItemButton(
                            leadingIcon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                            child: const Text(
                              "ویرایش",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontFamily: "Vazir",
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AzbaziEditor(azbazi: _azbazi,book: _book,),
                                ),
                              );
                            },
                          ) : MenuItemButton(
                            leadingIcon: const Icon(Icons.report_problem, color: Colors.pink),
                            child: const Text(
                              "گزارش اشکال",
                              style: TextStyle(
                                color: Colors.pink,
                                fontFamily: "Vazir",
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () async {
                              final text = await showTextInputDialog(
                                context: context,
                                textFields: [
                                  DialogTextField(
                                    hintText: 'دلیل گزارش...',
                                    validator: (value) => value!.length < 8
                                        ? '!حداقل در چند کلمه دلیلتان را وارد نمایید'
                                        : null,
                                  ),
                                ],
                                okLabel: "ارسال گزارش",
                                cancelLabel: "لغو",
                                style: AdaptiveStyle.iOS,
                                isDestructiveAction: true,
                                title: "گزارش ایراد محتوا",
                                message: 'لطفاً دلیل گزارش خود را بنویسید:',
                              );

                              if (text != null) {
                                await showOkAlertDialog(
                                  context: context,
                                  style: AdaptiveStyle.iOS,
                                  okLabel: "!باشه",
                                  title: 'ممنون از گزارش شما 🙏',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget _showCheckReasons() {
    List? allReasons = _azbazi.rejectReasons;
    return ListView.builder(
        itemCount: allReasons?.length,
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
                          new TextSpan(text: allReasons?[index]["reason"],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Vazir",
                              color: Colors.deepOrange[700],
                            ),
                          ),
                          new TextSpan(
                            text: ' (${allReasons?[index]["reviewer"]})',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Vazir",
                              color: Colors.black54,
                            ),
                          ),
                          new TextSpan(
                            text: ' (${allReasons?[index]["check_date"]})',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(26),
                              fontFamily: "Vazir",
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

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "توضیحات تکمیلی:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OurTheme.nearlyBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _azbazi.note!,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
              fontFamily: "Vazir",
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCheckBTNs() {
    return Positioned(
      top: (MediaQuery.of(context).size.width / 1) - 240.0,
      left: 10,
      child: Column(
        children: [
          if ((_azbazi.azbaziAccess == "imadmin" ||
              _azbazi.azbaziAccess == "bookadmin") &&
              _azbazi.state == "0")
            _buildActionButton(
                "تائید",
                Icons.check_circle,
                Colors.green,
                _confirmReqPopup
            ),
          const SizedBox(height: 12),
          if ((_azbazi.azbaziAccess == "imadmin" ||
              _azbazi.azbaziAccess == "imeditor" ||
              _azbazi.azbaziAccess == "bookadmin") &&
              _azbazi.state == "2")
            _buildActionButton(
                "تائید",
                Icons.check_circle,
                Colors.green,
                _confirmPopup
            ),
          const SizedBox(height: 12),
          if ((_azbazi.azbaziAccess == "imadmin" ||
              _azbazi.azbaziAccess == "bookadmin") &&
              _azbazi.state == "0")
            _buildActionButton(
                "رد",
                Icons.cancel,
                Colors.red,
                _rejectReqPopup
            ),
          const SizedBox(height: 12),
          if ((_azbazi.azbaziAccess == "imadmin" ||
              _azbazi.azbaziAccess == "imeditor" ||
              _azbazi.azbaziAccess == "bookadmin") &&
              _azbazi.state == "2")
            _buildActionButton(
                "رد",
                Icons.cancel,
                Colors.red,
                _rejectPopup
            ),
          const SizedBox(height: 12),
          if ((_azbazi.azbaziAccess == "imadmin" ||
              _azbazi.azbaziAccess == "imadder" ||
              _azbazi.azbaziAccess == "ismine") &&
              (_azbazi.state == "1" || _azbazi.state == "-1") &&
              int.parse(_azbazi.qCount!) >= 10)
            _buildActionButton(
                "انتشار",
                Icons.publish,
                Colors.lightBlueAccent[100]!,
                _publishRequestPopup
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, Function onTap) {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: animationController!,
          curve: Curves.fastOutSlowIn
      ),
      child: FloatingActionButton.extended(
        icon: Icon(icon, size: 24, color:  Colors.white,),
        label: Text(text, style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: "Vazir"
        ),),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        onPressed: () => onTap(),
      ),
    );
  }


  Future<void> _confirmReqPopup() async{
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'تائید درخواست',
        ),
      ],
      okLabel: "ارسال",
      cancelLabel: "لغو",
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
      title: "!تائید درخواست آزبازی",
      message: '...اگر سخنی با طراح دارید در کادر زیر بنویسید',
    );

    if (text != null) {
      txtReason = text[0];
      azCheckResult("1", txtReason, "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...ممنون از بررسی این آزبازی',
      );
      setState(() {});
      backToPreviousPage("0");
    }
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
      title: "!تائید آزبازی",
      message: '...اگر توصیه ای دارید در کادر زیر بنویسید',
    );

    if (text != null) {
      txtReason = text[0];
      userBarg = text[1];
      azCheckResult("5", txtReason, userBarg);
      await showOkAlertDialog(
          context: context,
        style: AdaptiveStyle.iOS,
          okLabel: "!باشه",
          title: '...ممنون از بررسی این آزبازی',
      );
      setState(() {});
      backToPreviousPage("2");
    }
  }
  Future<void> _rejectReqPopup() async {
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'دلیل رد درخواست آزبازی',
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
      title: "!رد درخواست آزبازی",
      message: '...دلیل رد درخواست آزبازی را در کادر زیر وارد نمایید',
    );

    if (text != null && text[0] != "") {
      txtReason = text[0];
      azCheckResult("-2", txtReason, "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...ممنون از بررسی این آزبازی',
      );
      setState(() {});
      backToPreviousPage("0");
    }
  }

  Future<void> _rejectPopup() async {
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'دلیل رد آزبازی',
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
      title: "!رد آزبازی",
      message: '...دلیل رد آزبازی را در کادر زیر وارد نمایید',
    );

    if (text != null && text[0] != "") {
      txtReason = text[0];
      azCheckResult("-1", txtReason, "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...ممنون از بررسی این آزبازی',
      );
      setState(() {});
      backToPreviousPage("2");
    }
  }

  Future<void> _publishRequestPopup() async{
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'پیام درخواست...',
        ),
      ],
      okLabel: "ارسال",
      cancelLabel: "لغو",
      style: AdaptiveStyle.iOS,
      isDestructiveAction: true,
      title: "!درخواست انتشار آزبازی",
      message: 'اگر پیامی دارید در کادر زیر وارد نمایید...',
    );

    if (text != null) {//yani tayiid enteshar
      txtReason = text[0];
      azCheckResult("2", txtReason, "0");
      await showOkAlertDialog(
        context: context,
        style: AdaptiveStyle.iOS,
        okLabel: "!باشه",
        title: '...درخواست با موفقیت ثبت شد',
      );
      backToPreviousPage("");
    }
  }

  void backToPreviousPage(String backPageState) {
    if(_book.pages_count != ""){
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return azBazihaScreen(book: _book, userData: widget.userData, pageNumber: 1, orderBy: "", orderDir: "", searchText: "",);
          },
        ),
      );
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CheckAzbazis(book: _book, azbaziState: backPageState, azbaziAccess: "admin", pageNumber: 1,);
          },
        ),
      );
    }
  }

  void azCheckResult(String newState, String txtReason, String userBarg) async {
    AzbaziProvider azbaziProvider = AzbaziProvider.instance(
        _book.book_id!, "", "", 1, "", "", "");
    _azbazi = (await azbaziProvider.azCheckResult(
        _azbazi.azbazi_id!, newState, txtReason, userBarg))!;
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
                  fontSize: 13,
                  letterSpacing: 0.27,
                  color: OurTheme.nearlyBlue,
                  fontFamily: "Vazir",
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
                  fontFamily: "Vazir",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}