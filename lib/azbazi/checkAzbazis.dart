import 'dart:math' as math;
import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/azbazi/oneAzbaziProfileSc.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/azbaziProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class CheckAzbazis extends StatefulWidget {
  bookModel book;
  String azbaziState;
  String azbaziAccess;
  int pageNumber;

  CheckAzbazis({Key? key, required this.book, required this.azbaziState, required this.azbaziAccess, required this.pageNumber}) : super(key: key);

  @override
  _CheckAzbazisState createState() => _CheckAzbazisState(book, azbaziState, azbaziAccess, pageNumber);
}

class _CheckAzbazisState extends State<CheckAzbazis> {
  bookModel _book;
  String azbaziState;
  String azbaziAccess;
  int pageNumber;

  _CheckAzbazisState(this._book, this.azbaziState, this.azbaziAccess,
      this.pageNumber);

  pageModel? pageData;

  final thumbWidth = 100;
  final thumbHeight = 150;
  List<azbaziModel> _azbazis = <azbaziModel>[];

  int? totalPagesCount;

  int? inputValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
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
            child: Text('در حال فراهم سازی آزبازی(ها)!',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          Icon(Icons.video_collection_outlined, color: Colors.indigo, size: 50,),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          Expanded(
            flex: 2,
            child: Text('هیچ آزبازی یافت نشد!',
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

  void onChangePageTap(BuildContext context) async {
    if (pageNumber <= totalPagesCount! && pageNumber > 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CheckAzbazis(book: _book,
              azbaziState: azbaziState,
              azbaziAccess: azbaziAccess,
              pageNumber: pageNumber,);
          },
        ),
      );
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
            style: TextStyle(fontSize: 14.0,
              color: Colors.pink,
              fontFamily: "Vazir", ),
          ),
        ),
        duration: Duration(seconds: 2),
      )
        ..show(context);
    }
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

  Widget _topActions(BuildContext context) {
    return Container(
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
              pageNumber > 1 ? InkWell(
                child: Column(
                    children: <Widget>[
                      Icon(Icons.import_contacts, size: 16,
                        color: Colors.black,),
                      Text("قبلی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                    ]
                ),
                onTap: () {
                  if(mounted) {
                    setState(() {
                      pageNumber = pageNumber - 1;
                      onChangePageTap(context);
                    });
                  }
                },
              ) : Container(),
              const SizedBox(width: 16),
              Text("${_azbazis.length}مورد آزبازی صفحه: ${AccessCheck().replaceFarsiNumber(pageNumber.toString())} ",
                softWrap: false,
                style: TextStyle(
                  fontFamily: "Vazir",
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 20),
              totalPagesCount != null && pageNumber < totalPagesCount! ? InkWell(
                child: Column(
                    children: <Widget>[
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(Icons.import_contacts, size: 16,
                          color: Colors.black,),
                      ),
                      Text("بعدی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                    ]
                ),
                onTap: () {
                  if(mounted) {
                    setState(() {
                      pageNumber = pageNumber + 1;
                      onChangePageTap(context);
                    });
                  }
                },
              ) : Container(),
              const SizedBox(width: 15),
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
  }

  _checkAzbaziResult(azbaziModel azbazi) {
    String checkTxt;
    Color checkColor;
    switch (azbazi.state) {
      case '5':
        checkTxt = "منتشر شده";
        checkColor = Colors.green;
        break;
      case '2':
        checkTxt = "در صف تایید!";
        checkColor = Colors.blue;
        break;
      case '1':
        checkTxt = "مرحله طراحی!";
        checkColor = Colors.deepPurple;
        break;
      case '-1':
        checkTxt = "رد شده!";
        checkColor = Colors.red;
        break;
      case '-2':
        checkTxt = "رد درخواست شده!";
        checkColor = Colors.red;
        break;
      default:
        checkTxt = "پیش بررسی!";
        checkColor = Colors.orange;
        break;
    }
    return Container(
      child: azbazi.azbaziAccess != "normaluser" ? Positioned(
        bottom: 0.0,
        left: 5.0,
        child: Text(
          checkTxt,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.27,
            color: checkColor,
          ),
        ),
      ) : null,
    );
  }


  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _azbazis.length,
        itemBuilder: (BuildContext context, int index) {
          final azbazi = _azbazis[index];
          final bookTemp = bookModel(
            book_id: azbazi.book_id!,
            tids: "",
            admin_id: "",
            admin_name: "",
            assistant_id: "",
            assistant_name: "",
            book_name: azbazi.book_name,
            bchap_id: "",
            avatar: "",
            small_avatar: "",
            ebavatar: "",
            small_ebavatar: "",
            section_num: "",
            ref_link: "",
            bchap_pdf: "",
            ebarge_pdf: "",
            pdfsize: "",
            pages_count: "",
            gap_pages: "",
            rate: "",
            edu_year: "",
            state: "",
            azbaziCount: "",
            status: "",
            error_code: "",
            error_description: "",);

          UserProvider userProvider = UserProvider.instance();

          return Directionality(
            textDirection: TextDirection.rtl,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OneAzbaziProfileSc(book: bookTemp, azbazi: azbazi, userData: UserModel(), userProvider: userProvider,);
                    },
                  ),
                );
              },
              child: Card(
                child: new Container(
                  padding: new EdgeInsets.all(10.0),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: new BorderRadius.circular(8.0),
                                child: FloatingActionButton.large(
                                  heroTag: "btn"+azbazi.azbazi_id!,
                                  backgroundColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OneAzbaziProfileSc(book: bookTemp, azbazi: azbazi, userData: UserModel(), userProvider: userProvider,);
                                        },
                                      ),
                                    );
                                  },
                                  child: azbazi.thumb_link != "" && azbazi.thumb_link != null ? FadeInImage
                                      .memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: GlobalKeys.ebargeUrl +
                                        azbazi.thumb_link!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.fitWidth,
                                  ) :
                                  Image.asset('assets/images/blankazbazthumb.png', height: 130,),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              margin: new EdgeInsets.only(right: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text("${azbazi.title}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black, fontFamily: "Vazir"),),
                                  Container(
                                    margin: new EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      azbazi.owner_name != null ? 'اثر: ' +
                                          azbazi.owner_name! : 'اثر: ' +
                                          azbazi.owner_name!,
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.blueGrey, fontFamily: "Vazir"),
                                    ),
                                  ),
                                  Row(
                                      children: <Widget>[
                                        Container(
                                          margin: new EdgeInsets.only(top: 5.0),
                                          child: Text('${azbazi.created_date}',
                                            style: TextStyle(fontSize: 15,fontFamily: "Vazir"),
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        Text(
                                          'تعداد سوال: ${AccessCheck().replaceFarsiNumber(azbazi.qCount!)}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14,
                                              letterSpacing: 0.27,
                                              color: Colors.indigoAccent,
                                              fontFamily: "Vazir"
                                          ),
                                        ),
                                      ]
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        AccessCheck().replaceFarsiNumber(azbazi.rate!),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          letterSpacing: 0.27,
                                          color: OurTheme.grey,
                                            fontFamily: "Vazir"
                                        ),
                                      ),
                                      //SizedBox(width: 6.0),
                                      Icon(Icons.star, color: Colors.amber,
                                        size: 18,
                                      ),
                                      SizedBox(width: 20,),
                                      Text(
                                        'کد آزبازی: ${azbazi.azbazi_id}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          letterSpacing: 0.27,
                                          color: OurTheme.grey,
                                            fontFamily: "Vazir"
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _checkAzbaziResult(azbazi),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<AzbaziProvider>(
        create: (context) =>
            AzbaziProvider.instance(
                "", azbaziState, azbaziAccess, pageNumber, "", "", ""),
        child: Consumer(
          // ignore: missing_return
            builder: (context, AzbaziProvider azbaziProvider, _) {
              _azbazis = azbaziProvider.getBookAzbaziha;
              totalPagesCount = azbaziProvider.getTotalPages;
              return FutureProvider.value(
                //value: _createAzbaziStream(context, azbaziProvider),
                value: null,
                initialData: null,
                child: Stack(
                    children: <Widget>[
                      _appBar(context),
                      SizedBox(height: 60.0),
                      Padding(
                        padding: EdgeInsets.only(top: 102.0),
                        child: Scaffold(
                          body: Center(
                            child:
                            azbaziProvider.azbaziStatus ==
                                AzbaziStatus.Initializing ?
                            _showLoadingTitle() :
                            azbaziProvider.azbaziStatus ==
                                AzbaziStatus.Uninitialized ?
                            _showCircularIndicator()
                                : azbaziProvider.azbaziStatus ==
                                AzbaziStatus.BlankAzbaziha ?
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