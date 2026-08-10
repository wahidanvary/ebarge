import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/azbazi/change-notifiers/timeBal-notifier.dart';
import 'package:ebarge/azbazi/oneAzbaziProfileSc.dart';
import 'package:ebarge/azbazi/pages/azbazi_editor.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/utils/ourTheme.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../azbazi/change-notifiers/wallet-notifier.dart';
import '../../azbazi/change-notifiers/zafrans-notifier.dart';
import '../../azbazi/oneAzBaziScreen.dart';
import '../../providers/azbaziProvider.dart';
import '../../providers/userProvider.dart';
import '../../services/accessCheck.dart';
import '../books/myBooks.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class azBazihaScreen extends StatefulWidget {
  bookModel book;
  final UserModel? userData;
  int pageNumber;
  String orderBy;
  String orderDir;
  String searchText;
  azBazihaScreen({Key? key, required this.book, required this.userData, required this.pageNumber, required this.orderBy, required this.orderDir, required this.searchText}) : super(key: key);

  @override
  _azBazihaScreenState createState() => _azBazihaScreenState(book, pageNumber, orderBy, orderDir, searchText);
}

class _azBazihaScreenState extends State<azBazihaScreen> with SingleTickerProviderStateMixin {
  bookModel _book;
  _azBazihaScreenState(this._book, this.pageNumber, this.orderBy, this.orderDir, this.searchText);
  int pageNumber;
  String orderBy;
  String orderDir;
  String searchText;

  final thumbWidth = 100;
  final thumbHeight = 150;
  List<azbaziModel> _azbazis = <azbaziModel>[];
  int myEditableAzbazies = 0;
  bool canCreateAzbazi = false;

  String _sortOption = 'جدیدتر';

  int? totalPagesCount;

  int? inputValue;

  bool _showLoginForm = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  @override
  initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);

    switch (orderBy) {
      case 'created_date':
        orderDir == 'desc' ? _sortOption = 'جدیدتر' : _sortOption = 'قدیمی‌تر';
        break;
      case 'rate':
        _sortOption = 'امتیاز';
        break;
      case 'title':
        _sortOption = 'عنوان';
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    setState(() {});
    super.didChangeDependencies();
  }

  void _filterAndSortAzbazis() {
    if (!mounted) return;
    setState(() {
      switch (_sortOption) {
        case 'جدیدتر':
          if(mounted) {
            setState(() {
              orderBy = "created_date";
              orderDir = "desc";
              onChangePageTap(context);
            });
          }
          break;
        case 'قدیمی‌تر':
          if(mounted) {
            setState(() {
              orderBy = "created_date";
              orderDir = "asc";
              onChangePageTap(context);
            });
          }
          break;
        case 'امتیاز':
          if(mounted) {
            setState(() {
              orderBy = "rate";
              orderDir = "desc";
              onChangePageTap(context);
            });
          }
          break;
        case 'عنوان':
          if(mounted) {
            setState(() {
              orderBy = "title";
              orderDir = "desc";
              onChangePageTap(context);
            });
          }
          break;
      }
    });
  }

  _getListView() {
    UserProvider userProvider = UserProvider.instance();
    for (final azbazi in _azbazis) {
      if (azbazi.owner_id == widget.userData?.userid &&
          int.parse(azbazi.state!) <= 2 &&
          int.parse(azbazi.state!) >= -1) {
        myEditableAzbazies++;
      }
    }

    bool newCanCreate = widget.userData!.state != null &&
        widget.userData!.state! > 0 &&
        myEditableAzbazies == 0;

    if (canCreateAzbazi != newCanCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            canCreateAzbazi = newCanCreate;
          });
        }
      });
    }

    return Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showLoginForm = !_showLoginForm;
                if (_showLoginForm) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 22.0,
                    color: Colors.indigo,
                  ),
                  SizedBox(width: 2.0),
                  Icon(
                    Icons.search,
                    size: 22.0,
                    color: Colors.indigo,
                  ),

                ],
              ),
            ),
          ),
          if (_showLoginForm) _topFilters(),
          Expanded(
            child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _azbazis.length,
            itemBuilder: (BuildContext context, int index) {
              final azbazi = _azbazis[index];

              return Directionality(
                textDirection: TextDirection.rtl,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return azbazi.azbaziAccess == "normaluser" ?
                          MultiProvider(
                              providers: [
                                ChangeNotifierProvider(create: (context) => WalletNotifier()),
                                ChangeNotifierProvider(create: (context) => ZafransNotifier()),
                                ChangeNotifierProvider(create: (context) => TimeBalNotifier()),
                              ],
                              child: OneAzbaziScreen(book: _book, azbazi: azbazi, qsState: 5, userData: widget.userData, userProvider: userProvider, isOutsideClick: false,)): OneAzbaziProfileSc(book: _book, azbazi: azbazi, userData: widget.userData, userProvider: userProvider,);
                        },
                      ),
                    ).then((value) {
                      setState(() {});
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
                                              return azbazi.azbaziAccess == "normaluser" ?
                                              MultiProvider(
                                                  providers: [
                                                    ChangeNotifierProvider(create: (context) => WalletNotifier()),
                                                    ChangeNotifierProvider(create: (context) => ZafransNotifier()),
                                                    ChangeNotifierProvider(create: (context) => TimeBalNotifier()),
                                                  ],
                                                  child: OneAzbaziScreen(book: _book, azbazi: azbazi, qsState: 5, userData: widget.userData, userProvider: userProvider, isOutsideClick: false,)): OneAzbaziProfileSc(book: _book, azbazi: azbazi, userData: widget.userData, userProvider: userProvider,);
                                            },
                                          ),
                                        );
                                      },
                                      child: azbazi.thumb_link != null && azbazi.thumb_link != "" ? FadeInImage
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
                                            'کد آزبازی: ${AccessCheck().replaceFarsiNumber(azbazi.azbazi_id!)}',
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
            }),
          ),
      ]
    );
  }

  _checkAzbaziResult(azbaziModel azbazi){
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
        checkTxt = "رد درخواست!";
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
    if (widget.userData!.state != null && widget.userData!.state! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            canCreateAzbazi = true;
          });
        }
      });
    }
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
              child: Text('آزبازی وجود ندارد!...',
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

  void onChangePageTap(BuildContext context) async {
    if (pageNumber <= totalPagesCount! && pageNumber > 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return azBazihaScreen(book: _book, userData: widget.userData,
              pageNumber: pageNumber, orderBy: orderBy, orderDir: orderDir, searchText: searchText,);
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
            "اطلاعات مورد نظر پیدا نشد!",
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

  Widget _topActions(BuildContext context) => Container(
    // width: double.infinity,
    constraints: const BoxConstraints(
      maxWidth: 720,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(
      elevation: 1,
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
            Text("آزبازی های: ${_book.book_name}",
              softWrap: false,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Vazir",
                fontSize: 14,
              ),
            ),
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
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => MyBooks(widget.userData)), (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _topFilters() => Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // جستجو
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.blueGrey.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // بخش تایپ
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(fontSize: 14, color: Colors.black87, fontFamily: "Vazir"),
                      decoration: InputDecoration(
                        hintText: 'جستجوی آزبازی...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13, fontFamily: "Vazir"),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          searchText = value.trim();
                          _filterAndSortAzbazis();
                        });
                      },
                    ),
                  ),

                  // دکمه سرچ
                  IconButton(
                    icon: Icon(Icons.search_rounded, color: Colors.blueAccent),
                    splashRadius: 24,
                    onPressed: () {
                      setState(() {
                        searchText = _searchController.text.trim();
                        if(searchText.length >= 3)
                          _filterAndSortAzbazis();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // مرتب‌سازی
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                    children: [
                    Icon(Icons.sort, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Expanded(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: _sortOption,
                          items: [
                            'جدیدتر',
                            'قدیمی‌تر',
                            'امتیاز',
                            'عنوان'
                          ]
                              .map(
                                (e) => DropdownMenuItem<String>(
                              value: e,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: e == _sortOption
                                            ? Colors.blue   // رنگ آیتم انتخاب شده
                                            : Colors.black87, // رنگ آیتم‌های عادی
                                      ),
                                    ),
                                  ),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _sortOption = value;
                                _filterAndSortAzbazis();
                              });
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            offset: const Offset(0, -5),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: Radius.circular(40),
                              thickness: WidgetStateProperty.all(4),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    ]
                ),
          )


        ],
      ),
    ),
  );



  @override
  Widget build(BuildContext context) {
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   setState(() {});
    // });
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) => MyBooks(widget.userData)), (route) => false,
        );
      },
      child: Scaffold(
        floatingActionButton: canCreateAzbazi ? Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.indigo[800], onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AzbaziEditor(azbazi: azbaziModel(),book: _book,),
              ),
            );
          },
            icon: Icon(Icons.add_box_outlined, color: Colors.white,),
            label: Text("درخواست", style: TextStyle(fontFamily: "Vazir", color: Colors.white),),
          ),
        ): Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gamespace_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ChangeNotifierProvider<AzbaziProvider>(
            create: (context) =>
                AzbaziProvider.instance(
                    _book.book_id!, "", "", pageNumber, orderBy, orderDir, searchText),
            child: Consumer(
              // ignore: missing_return
                builder: (context, AzbaziProvider azbaziProvider, _) {
                  _azbazis = azbaziProvider.getBookAzbaziha;
                  totalPagesCount = azbaziProvider.getTotalPages;
                  return FutureProvider.value(
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
        ),
      ),
    );
  }
}
