import 'dart:math' as math;
import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/oneContentScreen.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/contentProvider.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class CheckContents extends StatefulWidget {
  bookModel book;
  String contentState;
  String contentAccess;
  int pageNumber;

  CheckContents({Key? key, required this.book, required this.contentState, required this.contentAccess, required this.pageNumber}) : super(key: key);

  @override
  _CheckContentsState createState() => _CheckContentsState(book, contentState, contentAccess, pageNumber);
}

class _CheckContentsState extends State<CheckContents> {
  bookModel _book;
  String contentState;
  String contentAccess;
  int pageNumber;

  _CheckContentsState(this._book, this.contentState, this.contentAccess,
      this.pageNumber);

  pageModel? pageData;
  List<dynamic>? _contentPageNumToId;

  final thumbWidth = 100;
  final thumbHeight = 150;
  List<contentModel> _contents = <contentModel>[];

  int limit = 6;
  int? totalPagesCount;

  int? inputValue;

  @override
  void initState() {
    pageData = pageModel(
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
      "",);

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
            child: Text('محتوایی وجود ندارد!',
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
            return CheckContents(book: _book,
              contentState: contentState,
              contentAccess: contentAccess,
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
              Text("${_contents.length}مورد محتوا صفحه: ${AccessCheck().replaceFarsiNumber(pageNumber.toString())} ",
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
            ],
          ),
        ),
      ),
    );
  }

  _checkContentResult(contentModel content) {
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


  _getListView() {
    List<dynamic>? _pageNumToId;
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _contents.length,
        itemBuilder: (BuildContext context, int index) {
          final content = _contents[index];
          for( var i = 0 ; i < _contentPageNumToId!.length; i++ ) {
            if(content.content_id == _contentPageNumToId![i]["content_id"]){
              _pageNumToId = _contentPageNumToId![i]["pagenumtoid"];
            }
          }
          final pageNumToIdTemp = _pageNumToId;
          final bookTemp = bookModel(
            book_id: content.book_id!,
            tids: "",
            admin_id: "",
            admin_name: "",
            assistant_id: "",
            assistant_name: "",
            book_name: content.book_name!,
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
            gap_pages: content.gap_pages!,
            rate: "",
            edu_year: "",
            state: "",
            azbaziCount: "",
            status: "",
            error_code: "",
            error_description: "",);


          final pageTemp = pageModel(
            content.page_id!,
            content.page_image!,
          "",
          "",
          "",
            content.real_page_num!,
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
          "",);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OneContentScreen(book: bookTemp,
                        pageData: pageTemp,
                        content: content,
                        pageNumToId: pageNumToIdTemp!,);
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
                              Container(
                                width: thumbWidth.toDouble(),
                                height: thumbHeight.toDouble(),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              ),
                              ClipRRect(
                                borderRadius: new BorderRadius.circular(8.0),
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: GlobalKeys.ebargeUrl + '/' +
                                      content.thumb_link!,
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
                                  Text("${content.content_title}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),),
                                  Container(
                                    margin: new EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      content.owner_name != null ? 'اثر: ' +
                                          content.owner_name! : 'اثر: ' +
                                          content.user_name!,
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.blueGrey),
                                    ),
                                  ),
                                  Container(
                                    margin: new EdgeInsets.only(top: 5.0),
                                    child: Text('${content.created_date}',
                                      style: TextStyle(fontSize: 15,),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        '${content.rate}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          letterSpacing: 0.27,
                                          color: OurTheme.grey,
                                        ),
                                      ),
                                      //SizedBox(width: 6.0),
                                      Icon(Icons.star, color: Colors.amber,
                                        size: 18,
                                      ),
                                      SizedBox(width: 20,),
                                      Text(
                                        'کد محتوا: ${content.content_id}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          letterSpacing: 0.27,
                                          color: OurTheme.grey,
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
                      _checkContentResult(content),
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
      body: ChangeNotifierProvider<ContentProvider>(
        create: (context) =>
            ContentProvider.instance(
                "", "", contentState, contentAccess, limit, pageNumber),
        child: Consumer(
          // ignore: missing_return
            builder: (context, ContentProvider contentProvider, _) {
              _contents = contentProvider.getPageContents;
              totalPagesCount = contentProvider.getTotalPages;
              _contentPageNumToId = contentProvider.getContentPageNumToId;
              return FutureProvider.value(
                //value: _createContentStream(context, contentProvider),
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