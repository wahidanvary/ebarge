// ignore_for_file: file_names

import 'package:ebarge/azbazi/components/icons/coins.dart';
import 'package:ebarge/azbazi/components/icons/scores.dart';
import 'package:ebarge/azbazi/pages/landing-page/questionsNumList.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/providers/questionProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/bookModel.dart';
import '../../../models/questionModel.dart';
import '../../../providers/userProvider.dart';
import '../../../services/accessCheck.dart';
import './game-options.dart';

enum AuthStatus { notLoggedIn, loggedIn }
// ignore: must_be_immutable
class LandingPage extends StatefulWidget {
  static const String route = '/';
  azbaziModel azbazi;
  bookModel book;
  int qsState;

  LandingPage({Key? key, required this.azbazi, required this.book, required this.qsState}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState(azbazi, book, qsState);
}

class _LandingPageState extends State<LandingPage> {
  azbaziModel _azbazi;
  bookModel _book;
  int _qsState;
  int finalResultShow = 0;

  _LandingPageState(this._azbazi, this._book, this._qsState);

  //final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<questionModel> _questionsGlobalData = <questionModel>[];

  int? inputValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    bool isAccess = await AccessCheck().hasAccessTime();
    if (!isAccess) {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    if(_azbazi.mySolvedCount == int.parse(_azbazi.qCount!))
      finalResultShow = 2;
    else if(_azbazi.mySolvedCount! < int.parse(_azbazi.qCount!))
      finalResultShow = 1;
    else
      finalResultShow = 0;
  }

  _showLoadingTitle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          SpinKitFadingCube(
            color: Colors.indigo,
            size: 45.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          Expanded(
            flex: 2,
            child: Text('در حال فراهم سازی سوالبازی ها!',
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
            Icon(
              Icons.video_collection_outlined, color: Colors.indigo, size: 50,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Expanded(
              flex: 2,
              child: Text('منتظر بمانید...',
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuestionProvider>(
        create: (context) =>
            QuestionProvider.instance(_azbazi.azbazi_id!, _qsState),
        child: Consumer(
          // ignore: missing_return
            builder: (context, QuestionProvider questionProvider, _) {
              _questionsGlobalData = questionProvider.getAzbaziQuestions;
              return FutureProvider.value(
                value: null,
                initialData: null,
                child: Scaffold(
                  backgroundColor: Colors.white70,
                  body: SafeArea(
                    child: Column(
                      children: <Widget>[
                         Padding(
                          padding: EdgeInsets.only(top: 1.0, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("${_azbazi.title}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black, fontFamily: "Vazir"),),
                              SizedBox(
                                width: 15,
                              ),
                              ScoreView(),
                              SizedBox(
                                width: 15,
                              ),
                              CoinsView(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 340,
                          child: Padding(
                            padding: EdgeInsets.only(top: 25.0, bottom: 20),
                            child: questionProvider.questionStatus ==
                                QuestionStatus.Initializing ?
                            _showLoadingTitle() :
                            questionProvider.questionStatus ==
                                QuestionStatus.Uninitialized ?
                            _showCircularIndicator()
                                : questionProvider.questionStatus ==
                                QuestionStatus.BlankQuestions ?
                            _showBlankTitle() : QuestionNumList(
                                _questionsGlobalData),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            OutlinedButton.icon(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.deepPurple,
                                size: 30,
                              ),
                              label: const Text(
                                'اشتراک',
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              onPressed: () {
                                 Share.share(
                                    "https://ebarge.ir/azbazi/" + _azbazi.azbazi_id! + "\n" + _azbazi.title! + " را بازی کن، یاد بگیر، ارز زفران کسب کن " + "\n کتاب: " + _book.book_name!);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: const BorderSide(
                                    color: Colors.transparent),
                              ),
                            ),
                            /*OutlinedButton.icon(
                              icon: const Icon(
                                Icons.rate_review,
                                color: Colors.deepOrange,
                                size: 30,
                              ),
                              label: const Text(
                                'بازبینی',
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                              onPressed: () {
                                // LaunchReview.launch(androidAppId: "");
                              },
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: const BorderSide(
                                    color: Colors.transparent),
                              ),
                            ),*/
                          ],
                        ),
                        questionProvider.questionStatus ==
                            QuestionStatus.ExistQuestions ? Expanded(
                          flex: 4,
                          child: GameOptions(finalResultShow: finalResultShow, azbazi: _azbazi, book: _book),
                        ): Container()
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }
}

