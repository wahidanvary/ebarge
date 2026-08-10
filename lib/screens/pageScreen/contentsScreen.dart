import 'dart:math' as math;
import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/oneContentScreen.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/contentProvider.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class ContentsScreen extends StatefulWidget {
  pageModel pageData;
  bookModel book;
  List<dynamic> pageNumToId;

  ContentsScreen({Key? key, required this.book, required this.pageData, required this.pageNumToId}) : super(key: key);

  @override
  _ContentsScreenState createState() => _ContentsScreenState(pageData, book, pageNumToId);
}

class _ContentsScreenState extends State<ContentsScreen> {
  pageModel _pageData;
  bookModel _book;
  List<dynamic> _pageNumToId;
  _ContentsScreenState(this._pageData, this._book, this._pageNumToId);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final thumbWidth = 100;
  final thumbHeight = 150;
  List<contentModel> _contents = <contentModel>[];

  int? inputValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _contents.length,
        itemBuilder: (BuildContext context, int index) {
          final content = _contents[index];
          return Directionality(
            textDirection: TextDirection.rtl,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OneContentScreen( book: _book, pageData: _pageData, content: content, pageNumToId: _pageNumToId,);
                    },
                  ),
                ).then((value) {
                  setState(() {
                  });
                });
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
                              Container(
                                width: thumbWidth.toDouble(),
                                height: thumbHeight.toDouble(),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              ClipRRect(
                                borderRadius: new BorderRadius.circular(8.0),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: GlobalKeys.ebargeUrl + content.thumb_link!,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.fill,
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
                                  Text("${content.content_title}", style: TextStyle( fontSize: 14, color: Colors.black),),
                                  Container(
                                    margin: new EdgeInsets.only(top: 4.0),
                                    child: Text( content.owner_name != null ? 'اثر: ' + content.owner_name! : 'اثر: ' + content.user_name!,
                                      style: TextStyle( fontSize: 13, color: Colors.blueGrey),
                                    ),
                                  ),
                                  Container(
                                    margin: new EdgeInsets.only(top: 5.0),
                                    child: Text( '${content.created_date}',
                                      style: TextStyle( fontSize: 15,),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${content.rate}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle( fontWeight: FontWeight.w300,
                                          fontSize: 14, letterSpacing: 0.27, color:  OurTheme.grey,
                                        ),
                                      ),
                                      //SizedBox(width: 6.0),
                                      Icon(Icons.star, color: Colors.amber, size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _checkContentResult(content),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _checkContentResult(contentModel content){
    String checkTxt;
    Color checkColor;
    switch (content.state) {
      case '2':
        checkTxt = "تائید شده";
        checkColor = Colors.green;
        break;
      case '-1':
        checkTxt = "رد شده!";
        checkColor = Colors.red;
        break;
      default:
        checkTxt = " در انتظار بررسی!";
        checkColor = Colors.orange;
        break;
    }
    return Container(
        child: content.contentAccess != "normaluser" ? Positioned(
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
            child: Text('در حال فراهم سازی محتوا(ها)!',
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
            Icon(Icons.video_collection_outlined, color: Colors.indigo, size: 50,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Expanded(
              flex: 2,
              child: Text('محتوایی وجود ندارد! اگر برای این صفحه محتوای تولید شده ای دارید با تپ کردن دکمه نارنجی! عالی میشه با دیگران به اشتراک بگذارید...',
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
            return ContentsScreen(book: _book, pageData: _pageData, pageNumToId: _pageNumToId,);
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
            style: TextStyle(fontSize: 14.0, fontFamily: "Vazir", color: Colors.pink),
          ),
        ),
        duration:  Duration(seconds: 2),
      )..show(context);
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

  Widget _topActions(BuildContext context) => Container(
    // width: double.infinity,
    constraints: const BoxConstraints(
      maxWidth: 720,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 0 : 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              child: const Icon(Icons.menu, color: Colors.black,),
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 30),
            InkWell(
              child: Column(
                  children: <Widget>[
                    Icon(Icons.import_contacts, size: 16, color: Colors.black,),
                    Text("قبلی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                  ]
              ),
              onTap: (){
                inputValue = int.parse(_pageData.real_page_num) - 1;
                _onSearchPageTap(context);
              },
            ),
            const SizedBox(width: 16),
            Text("محتواهای صفحه: ${AccessCheck().replaceFarsiNumber(_pageData.real_page_num)}",
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
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(Icons.import_contacts, size: 16, color: Colors.black,),
                    ),
                    Text("بعدی", style: TextStyle(fontSize: 12, fontFamily: "Vazir"),),
                  ]
              ),
              onTap: (){
                inputValue = int.parse(_pageData.real_page_num) + 1;
                _onSearchPageTap(context);
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ),
  );


  @override
  Widget build(BuildContext context) {
    contentModel? _newContent = contentModel(
        "",
        _book.book_id,
        _pageData.page_id,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        false,
        "",
        [],
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "");
    return ChangeNotifierProvider<ContentProvider>(
      create: (context) =>
          ContentProvider.instance(
              _book.book_id!, _pageData.page_id, "", "", 0, 0),
      child: Consumer(
        // ignore: missing_return
          builder: (context, ContentProvider contentProvider, _) {
            _contents = contentProvider.getPageContents;
            return FutureProvider.value(
              //value: _createContentStream(context, contentProvider),
              value: null,
              initialData: null,
              child: Stack(
                  children: <Widget>[
                    _appBar(context),
                    Padding(
                      padding: EdgeInsets.only(top: 80.0),
                      child: Scaffold(
                        body: Center(
                          child:
                          contentProvider.contentStatus ==
                              ContentStatus.Initializing ?
                          _showLoadingTitle() :
                             contentProvider.contentStatus ==
                                 ContentStatus.Uninitialized ?
                             _showCircularIndicator()
                              : contentProvider.contentStatus ==
                                 ContentStatus.BlankContents ?
                              _showBlankTitle() : _getListView(),
                        ),
                        // floatingActionButton: Padding(
                        //   padding: EdgeInsets.only(bottom: 15),
                        //   child: FloatingActionButton(
                        //     backgroundColor: Colors.deepOrange,
                        //     child: Icon(Icons.add, color: Colors.white,),
                        //     onPressed: () {
                        //       Navigator.of(context).push(
                        //         MaterialPageRoute(
                        //           builder: (BuildContext context) {
                        //             return ContentEditor(content: _newContent,
                        //                 pageData: _pageData,
                        //                 book: _book,
                        //                 pageNumToId: _pageNumToId);
                        //           },
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        // floatingActionButtonLocation: FloatingActionButtonLocation
                        //     .startDocked,
                        extendBody: true,
                      ),
                    ),
                  ]
              ),
            );
          }
      ),
    );
  }
}
