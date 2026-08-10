// ignore_for_file: file_names

import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/azbazi/change-notifiers/azStreak-notifier.dart';
import 'package:ebarge/azbazi/change-notifiers/scores-notifier.dart';
import 'package:ebarge/azbazi/change-notifiers/timeBal-notifier.dart';
import 'package:ebarge/azbazi/change-notifiers/wallet-notifier.dart';
import 'package:ebarge/azbazi/change-notifiers/zafrans-notifier.dart';
import 'package:ebarge/azbazi/pages/game-page/play-controls/play_controls.dart';
import 'package:ebarge/database/azbaziQueries.dart';
import 'package:ebarge/database/userQueries.dart';
import 'package:ebarge/models/questionModel.dart';
import 'package:ebarge/azbazi/change-notifiers/coins-notifier.dart';
import 'package:ebarge/azbazi/pages/game-page/text.dart';
import 'package:ebarge/azbazi/pages/game-page/views/play_view.dart';

import 'package:ebarge/azbazi/pages/game-page/views/results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/azbaziModel.dart';
import '../../../models/bookModel.dart';
import '../../../models/pageModel.dart';
import '../../../models/userModel.dart';
import '../../../providers/userProvider.dart';
import '../../../screens/pageScreen/paint_screen.dart';
import '../../../services/GlobalKeys.dart';
import '../../../services/accessCheck.dart';
import '../../../utils/hexColor.dart';
import '../../change-notifiers/game-mode-notifier.dart';
import '../../controllers/question_processor.dart';
import 'blank_spot.dart';
import 'header-bar.dart';

class GamePage extends StatefulWidget {
  static const String route = '/game-page';
  final azbaziModel azbazi;
  final bookModel book;

  const GamePage({super.key, required this.azbazi, required this.book});

  @override
  _GamePageState createState() => _GamePageState(this.azbazi);
}

class _GamePageState extends State<GamePage> {
  _GamePageState(this.azbazi);
  azbaziModel azbazi;

  List<dynamic>? _pageNumToId;
  pageModel? onePageData;
  bool paintClick = false;

  String displayedBoxStr = '';
  late String _gameMode = '';
  List blankChars = [];
  List dragables = [];
  late List<Color> borderColor = [];
  bool isQuestionFound = false;
  bool showHint = false;
  bool showPage = false;
  late Function changeCoinsNotifier;
  late Function changeScoreNotifier;
  late Function changeZafranNotifier;
  late Function changeTimeBalNotifier;
  late Function changAzQStreakNotifier;
  late Function changeWalletNotifier;
  late questionModel question;
  bool enableRewardButton = true;
  final QuestionProcessor _questionProcessor = QuestionProcessor();
  bool isLoadingDialogueOpen = false;

  bool _waitCheckAnswer = false;
  bool finalResultShow = false;
  bool _isPageViewDisabled = false;
  //  Ads ads = Ads();

  @override
  void initState() {
    super.initState();
    fetchPagesData(widget.book.book_id!);
    question = questionModel();
  }

  @override
  void didChangeDependencies() {
    paintClick = false;
    changeCoinsNotifier =
        Provider.of<CoinsNotifier>(context, listen: false).changeCoins;
    changeScoreNotifier =
        Provider.of<ScoresNotifier>(context, listen: false).changeScore;
    changeZafranNotifier =
        Provider.of<ZafransNotifier>(context, listen: false).changeZafran;
    changeTimeBalNotifier =
        Provider.of<TimeBalNotifier>(context, listen: false).changeTimeBalance;
    changAzQStreakNotifier =
        Provider.of<AzQStreakNotifier>(context, listen: false).changeAzQStreak;
    changeWalletNotifier =
        Provider.of<WalletNotifier>(context, listen: false).changeWallet;
    changeCoinsNotifier(azbazi.myCoins, azbazi.azbazi_id);
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    // ads.disposeAds();
    super.dispose();
  }

  showBannerAd() {
    isLoadingDialogueOpen = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    ).then((_){
      isLoadingDialogueOpen = false;
    }).catchError((_){
      isLoadingDialogueOpen = false;
    });

    setState(() {
      enableRewardButton = false;
    });
  }

  /* awardTriplePoints() {
    num coins = 3 * (dragables.length + getLevelBonus());
    Fluttertoast.showToast(
      msg: "Bonus $coins coins credited",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    changeCoinsNotifier(coins);
    //changeScoreNotifier(score);
  }*/

  enableRewardButtonFn() {
    if (enableRewardButton == false && isLoadingDialogueOpen) {
      Navigator.of(context).pop();
    }
    setState(() {
      enableRewardButton = true;
    });
  }

  fetchNewQuestion({displayPreviouslyStoredQuestion = false, int qIndex = -1}) async {
    Map questionInfo = await _questionProcessor.processQuestion(azbazi.state!, azbazi.azbazi_id!, qIndex,
        _gameMode, displayPreviouslyStoredQuestion);
    setState(() {
      displayedBoxStr = questionInfo['displayedBoxStr'];
      blankChars = questionInfo['blankChars'];
      dragables = questionInfo['dragables'];
      borderColor  = List.filled(blankChars.length, Theme.of(context).colorScheme.inversePrimary);
      question = questionInfo['questionModel'];
      isQuestionFound = false;
      showHint = false;
      showPage = false;
    });
  }

  Widget textWithCard(char, {scale = 1.0, x = 0.0, y = 0.0, grayColor = false}) {
    String processedChar = AccessCheck().preprocessLatex(char['char']);
    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          child: Card(
            color: grayColor ? Theme.of(context).focusColor: Colors.lightBlueAccent ,
            elevation: 6,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: HtmlWidget(processedChar,//_______
                customWidgetBuilder: (element) {
                  if (element.localName == 'latex-inline') {
                    final formulaEncoded = element.attributes['data'] ?? '';
                    var formula = Uri.decodeComponent(formulaEncoded);
                    formula = AccessCheck().replaceFarsiNumber(formula);

                    return InlineCustomWidget(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        // ✅ تغییر مهم: اجبار جهت چپ به راست برای فرمول
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Math.tex(
                            formula,
                            textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.black, fontFamily: "Vazir"
                            ),
                            mathStyle: MathStyle.text,
                            onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                      ),
                    );
                  }

                  // ب) فرمول‌های بلوکی (Block)
                  if (element.localName == 'latex-block') {
                    final formulaEncoded = element.attributes['data'] ?? '';
                    var formula = Uri.decodeComponent(formulaEncoded);
                    formula = AccessCheck().replaceFarsiNumber(formula);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Math.tex(
                          formula,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: "Vazir"
                          ),
                          mathStyle: MathStyle.display,
                          onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                renderMode: RenderMode.column,
                // set the default styling for text
                textStyle: TextStyle(fontSize: 14, color: grayColor ? Colors.white:  Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getDragables(List dragables) {
    List<Widget> dragableList = [];
    for (var index = 0; index < dragables.length; index++) {
      Map char = dragables[index];
      if (!char['hide']) {
        dragableList.add(Draggable<List>(
          key: UniqueKey(),
          data: [
            index.toString(),
            char['char'],
            char['pointer'],
          ],
          feedback: textWithCard(
            char,
            scale: 1.25,
            x: 0.0,
            y: 0.0,
          ),
          childWhenDragging: textWithCard(char, grayColor: true),
          onDragCompleted: () {
            dragables[index]['hide'] = true;
            setState(() {
              dragables = dragables;
            });
          },
          child: textWithCard(char),
        ));
      } else {
        dragableList.add(
          textWithCard(char, grayColor: true),
        );
      }
    }
    return dragableList;
  }

  updateBlanks(
      List data,
      int index,
      BuildContext _context, {
        updateDragables = true,
      }) async {
    var _blankChars = blankChars;
    var _newDragables = [...dragables];
    var _isQuestionFound = false;
    String? qType = question.que_type;

    if (updateDragables) {
      var existingDraggedChar = _blankChars[index]['char'];
      var length = dragables.length;
      var i = 0;
      while (i < length) {
        if (_newDragables[i]['char'] == existingDraggedChar &&
            _newDragables[i]['hide']) {
          _newDragables[i]['hide'] = false;
          break;
        }
        i++;
      }
      setState(() {
        dragables = _newDragables;
      });
    }


    _blankChars[index]['char'] = data[1];
    List<Color> newBorderColor =
    List.filled(_blankChars.length, Theme
        .of(context)
        .colorScheme
        .inversePrimary);

    UserProvider userProvider = UserProvider.instance();
    UserModel? _user = await userProvider.onStartUp();

    if (await GlobalKeys.checkInternetConnection() && _user != null) {
      int qMaxCoinScore = question.max_score!.toInt();
      int myAzbaziCoins = azbazi.myCoins!;
      int myWalletAmount = _user.walletAmount!;
      double allCoinsAmount = (myWalletAmount / 10) + myAzbaziCoins;
      if (allCoinsAmount >= qMaxCoinScore) {
        List<String> selectedPointer = [];
        switch (qType) {
          case 'jaykhali':
          case 'jurkardani':
            if (data[1] == "" || data[0] != "-1") {
              List tempAllBlank =  [..._blankChars];
              bool rtlFlutterErrorDetect = false;
              if(!question.que_content!.contains("<table")) { // dar halat rtl ba vojud jadval irad render flutter raf mishavad
                tempAllBlank.sort((a, b) =>
                    a['holePoint'].compareTo(b['holePoint']));
                rtlFlutterErrorDetect = true;
              }

              for (int blankIndex = 0; blankIndex < tempAllBlank.length; blankIndex++) {
                if (tempAllBlank[blankIndex]['char'] != "") {
                  for(int dragIndex = 0; dragIndex < _newDragables.length; dragIndex++) {
                    if (_newDragables[dragIndex]['char'] == tempAllBlank[blankIndex]['char'])
                      selectedPointer.add((dragIndex + 1).toString());// jamavari pointer karbar
                  }
                  if(blankIndex == tempAllBlank.length - 1){
                    setState(() {
                      _waitCheckAnswer = true;
                    });

                    Map<String, dynamic>? updatedUAzUQV = await azbazisQueries().upUVQOnlineDB(question.question_id!, "", selectedPointer);// update soal online

                    if(updatedUAzUQV!.isNotEmpty && updatedUAzUQV["havecoin"]) {
                      int countFalse = 0;

                      for (int bI1 = 0; bI1 < tempAllBlank.length; bI1++) {
                        if (updatedUAzUQV["uqanswerdetail"][bI1])
                          newBorderColor[bI1] = Colors.green;
                        else{
                          newBorderColor[bI1] = Colors.red;
                          countFalse++;
                        }
                      }

                      if(rtlFlutterErrorDetect){
                        final allBlankRowMap = tempAllBlank.groupBy((m) => m['row']);
                        int maxRow = tempAllBlank.fold<int>(0, (max, e) => e['row'] > max ? e['row'] : max);
                        for(int row = 1; row <= maxRow; row++){
                          List rowBlankChars = [...allBlankRowMap[row]!];
                          int minHoleIndex = rowBlankChars.fold<int>(rowBlankChars[0]['holePoint'], (min, e) => e['holePoint'] < min ? e['holePoint'] : min) - 1;
                          int maxHoleIndex = rowBlankChars.fold<int>(1, (max, e) => e['holePoint'] > max ? e['holePoint'] : max) - 1;
                          for (int bI2 = minHoleIndex; bI2 < maxHoleIndex; bI2++) {
                            Color tempLBCharColor = newBorderColor[bI2];
                            newBorderColor[bI2] = newBorderColor[maxHoleIndex];
                            newBorderColor[maxHoleIndex] = tempLBCharColor;
                            maxHoleIndex--;
                          }
                        }
                      }

                      if (countFalse == 0) _isQuestionFound = true;
                      if (updatedUAzUQV.containsKey('myqscore'))
                        question.myqscore = updatedUAzUQV["myqscore"].toDouble();
                      if (updatedUAzUQV.containsKey('qview_count'))
                        question.qview_count = question.qview_count! + 1;
                      if (updatedUAzUQV.containsKey('visit_date'))
                        question.visit_date = updatedUAzUQV["visit_date"];
                      if (updatedUAzUQV.containsKey('solved_date'))
                        question.solved_date = updatedUAzUQV["solved_date"];
                      if (updatedUAzUQV.containsKey('uvstate'))
                        question.uvstate = updatedUAzUQV["uvstate"];
                      if (updatedUAzUQV.containsKey('que_answer'))
                        question.que_answer = updatedUAzUQV["que_answer"];
                      if (updatedUAzUQV.containsKey('mycoins'))
                        azbazi.myCoins = updatedUAzUQV["mycoins"];
                      if (updatedUAzUQV.containsKey('myscore'))
                        azbazi.myScore = updatedUAzUQV["myscore"].toDouble();
                      if (updatedUAzUQV.containsKey('mysolved_count'))
                        azbazi.mySolvedCount = azbazi.mySolvedCount! + 1;
                      if (updatedUAzUQV.containsKey('myfsolved_count'))
                        azbazi.myFSolvedCount = azbazi.myFSolvedCount! + 1;
                      if (updatedUAzUQV.containsKey('myfsolved_holes'))
                        azbazi.myFSolvedHoles = (azbazi.myFSolvedHoles! +  updatedUAzUQV["myfsolved_holes"]).toInt();
                      if (updatedUAzUQV.containsKey('zafran')) {
                        _user.zafran = _user.zafran! + updatedUAzUQV["zafran"].toDouble();
                        changeZafranNotifier(_user.zafran);
                        userQueries().updateUser(_user);
                      }
                      // 1. دریافت و آپدیت زمان قفل‌گشایی (Time Balance)
                      if (updatedUAzUQV.containsKey('time_balance')) {
                        // فرض بر این است که متغیر timeBalance را به کلاس یوزر اضافه کرده‌اید
                        _user.time_balance = updatedUAzUQV["time_balance"];
                        // باید یک Notifier برای آپدیت هدر (Header) اپلیکیشن بسازید
                        changeTimeBalNotifier(_user.time_balance);
                        userQueries().updateUser(_user);
                      }
                      // 2. دریافت استریک متوالی کاربر برای آزمون‌بازی فعلی
                      if (updatedUAzUQV.containsKey('current_streak')) {
                        // فرض بر این است که متغیر qsTryStreak را به کلاس azbazi اضافه کرده‌اید
                        azbazi.qs_try_streak = updatedUAzUQV["current_streak"];
                        // می‌توانید یک Notifier برای نمایش آیکون شعله روشن کنید
                        changAzQStreakNotifier(azbazi.qs_try_streak, azbazi.azbazi_id);
                      }

                      // 3. دریافت پاداش‌ها و نمایش انیمیشن / اسنک‌بار هیجان‌انگیز
                      if (updatedUAzUQV.containsKey('base_time') && updatedUAzUQV['base_time'] > 0) {
                        int baseTime = updatedUAzUQV["base_time"];
                        String rewardMessage = "آفرین! $baseTime ثانیه زمان گرفتی!";

                        // بررسی پاداش‌های اضافی (Speed & Lucky)
                        if (updatedUAzUQV.containsKey('bonuses') && updatedUAzUQV['bonuses'].isNotEmpty) {
                          Map<String, dynamic> bonuses = updatedUAzUQV['bonuses'];

                          if (bonuses.containsKey('speed')) {
                            int speedVal = bonuses['speed']['value'];
                            String speedMsg = bonuses['speed']['message'];
                            rewardMessage += "\n⚡ $speedMsg ($speedVal+ ثانیه)";
                          }

                          if (bonuses.containsKey('streak')) {
                            int streakVal = bonuses['streak']['value'];
                            String streakMsg = bonuses['streak']['message'];
                            rewardMessage += "\n🔥 $streakMsg ($streakVal+ ثانیه)";
                          }

                          if (bonuses.containsKey('lucky')) {
                            int luckyVal = bonuses['lucky']['value'];
                            String luckyMsg = bonuses['lucky']['message'];
                            rewardMessage += "\n🎁 $luckyMsg ($luckyVal+ ثانیه)";
                          }
                        }

                        // نمایش پیام به کاربر (شما می‌توانید به جای اسنک‌بار، یک دیالوگ یا انیمیشن Lottie فراخوانی کنید)
                        showSnackBar(rewardMessage);
                      }
                      if (updatedUAzUQV.containsKey('wallet_gold')) {
                        _user.walletAmount = updatedUAzUQV["wallet_gold"];
                        changeWalletNotifier(_user.walletAmount);
                        userQueries().updateUser(_user);
                      }
                      if(updatedUAzUQV.containsKey('print_count'))
                        question.print_count = (int.parse(question.print_count!) + 1).toString();
                      if(updatedUAzUQV.containsKey('first_solver'))
                        question.first_solver = updatedUAzUQV["first_solver"];

                      azbazisQueries().updateQuestion(question);
                      azbazisQueries().updateAzbazi(azbazi);

                      changeCoinsNotifier(azbazi.myCoins, azbazi.azbazi_id);
                      changeScoreNotifier(azbazi.myScore, azbazi.azbazi_id);
                      updateAzbAndQInDB(); // pasokh savaye inke dorost bashe ya nabashe natije sabt mishe
                    } else {
                      showSnackBar('سکه کافی ندارید!');
                    }
                  }
                } else break; // isFilledHoles = false;
              }
            }
            break;
          default: // testi ya sahihqalat
          //data[1] == "" yaani baray halati ke drag az gozine be gozine dige taqyir kamel mishe
          //data[0] == "0" Yani halati ke qozine avalin bar az beyne entekhab az payin ettefag biofte
            if (data[1] == "" || data[0] == "0") {
              List tempAllBlank =  [..._blankChars];
              tempAllBlank.sort((a, b) => a['holePoint'].compareTo(b['holePoint']));
              for (int blankIndex = 0; blankIndex < tempAllBlank.length; blankIndex++) {
                if (tempAllBlank[blankIndex]['char'] != "") {
                  setState(() {
                    _waitCheckAnswer = true;
                  });
                  selectedPointer.add((blankIndex + 1).toString());
                  Map<String, dynamic>? updatedUAzUQV = await azbazisQueries().upUVQOnlineDB(question.question_id!, "", selectedPointer);// update soal online

                  if(updatedUAzUQV!.isNotEmpty && updatedUAzUQV["havecoin"]) {
                    if (updatedUAzUQV["uqanswerdetail"][0]) {
                      _isQuestionFound = true;
                      newBorderColor =
                          List.filled(tempAllBlank.length, Colors.green);
                    } else
                      newBorderColor =
                          List.filled(tempAllBlank.length, Colors.red);
                    if (updatedUAzUQV.containsKey('myqscore'))
                      question.myqscore = updatedUAzUQV["myqscore"].toDouble();
                    if (updatedUAzUQV.containsKey('qview_count'))
                      question.qview_count = question.qview_count! + 1;
                    if (updatedUAzUQV.containsKey('visit_date'))
                      question.visit_date = updatedUAzUQV["visit_date"];
                    if (updatedUAzUQV.containsKey('solved_date'))
                      question.solved_date = updatedUAzUQV["solved_date"];
                    if (updatedUAzUQV.containsKey('uvstate'))
                      question.uvstate = updatedUAzUQV["uvstate"];
                    if (updatedUAzUQV.containsKey('que_answer'))
                      question.que_answer = updatedUAzUQV["que_answer"];
                    if (updatedUAzUQV.containsKey('mycoins'))
                      azbazi.myCoins = updatedUAzUQV["mycoins"];
                    if (updatedUAzUQV.containsKey('myscore'))
                      azbazi.myScore = updatedUAzUQV["myscore"].toDouble();
                    if(updatedUAzUQV.containsKey('mysolved_count'))
                      azbazi.mySolvedCount = azbazi.mySolvedCount! + 1;
                    if (updatedUAzUQV.containsKey('myfsolved_count'))
                      azbazi.myFSolvedCount = azbazi.myFSolvedCount! + 1;
                    if (updatedUAzUQV.containsKey('myfsolved_holes'))
                      azbazi.myFSolvedHoles = (azbazi.myFSolvedHoles! +  updatedUAzUQV["myfsolved_holes"]).toInt();
                    if (updatedUAzUQV.containsKey('zafran')) {
                      _user.zafran = _user.zafran! + updatedUAzUQV["zafran"].toDouble();
                      changeZafranNotifier(_user.zafran);
                      userQueries().updateUser(_user);
                    }
                    // 1. دریافت و آپدیت زمان قفل‌گشایی (Time Balance)
                    if (updatedUAzUQV.containsKey('time_balance')) {
                      // فرض بر این است که متغیر timeBalance را به کلاس یوزر اضافه کرده‌اید
                      _user.time_balance = updatedUAzUQV["time_balance"];
                      // باید یک Notifier برای آپدیت هدر (Header) اپلیکیشن بسازید
                      changeTimeBalNotifier(_user.time_balance);
                      userQueries().updateUser(_user);
                    }
                    // 2. دریافت استریک متوالی کاربر برای آزمون‌بازی فعلی
                    if (updatedUAzUQV.containsKey('current_streak')) {
                      // فرض بر این است که متغیر qsTryStreak را به کلاس azbazi اضافه کرده‌اید
                      azbazi.qs_try_streak = updatedUAzUQV["current_streak"];
                      // می‌توانید یک Notifier برای نمایش آیکون شعله روشن کنید
                      changAzQStreakNotifier(azbazi.qs_try_streak, azbazi.azbazi_id);
                    }

                    // 3. دریافت پاداش‌ها و نمایش انیمیشن / اسنک‌بار هیجان‌انگیز
                    if (updatedUAzUQV.containsKey('base_time') && updatedUAzUQV['base_time'] > 0) {
                      int baseTime = updatedUAzUQV["base_time"];
                      String rewardMessage = "آفرین! $baseTime ثانیه زمان گرفتی!";

                      // بررسی پاداش‌های اضافی (Speed & Lucky)
                      if (updatedUAzUQV.containsKey('bonuses') && updatedUAzUQV['bonuses'].isNotEmpty) {
                        Map<String, dynamic> bonuses = updatedUAzUQV['bonuses'];

                        if (bonuses.containsKey('speed')) {
                          int speedVal = bonuses['speed']['value'];
                          String speedMsg = bonuses['speed']['message'];
                          rewardMessage += "\n⚡ $speedMsg ($speedVal+ ثانیه)";
                        }

                        if (bonuses.containsKey('streak')) {
                          int streakVal = bonuses['streak']['value'];
                          String streakMsg = bonuses['streak']['message'];
                          rewardMessage += "\n🔥 $streakMsg ($streakVal+ ثانیه)";
                        }

                        if (bonuses.containsKey('lucky')) {
                          int luckyVal = bonuses['lucky']['value'];
                          String luckyMsg = bonuses['lucky']['message'];
                          rewardMessage += "\n🎁 $luckyMsg ($luckyVal+ ثانیه)";
                        }
                      }

                      // نمایش پیام به کاربر (شما می‌توانید به جای اسنک‌بار، یک دیالوگ یا انیمیشن Lottie فراخوانی کنید)
                      showSnackBar(rewardMessage);
                    }
                    if (updatedUAzUQV.containsKey('wallet_gold')) {
                      _user.walletAmount = updatedUAzUQV["wallet_gold"];
                      changeWalletNotifier(_user.walletAmount);
                      userQueries().updateUser(_user);
                    }
                    if(updatedUAzUQV.containsKey('print_count'))
                      question.print_count = (int.parse(question.print_count!) + 1).toString();
                    if(updatedUAzUQV.containsKey('first_solver'))
                      question.first_solver = updatedUAzUQV["first_solver"];

                    azbazisQueries().updateQuestion(question);
                    azbazisQueries().updateAzbazi(azbazi);
                    changeCoinsNotifier(azbazi.myCoins, azbazi.azbazi_id);
                    changeScoreNotifier(azbazi.myScore, azbazi.azbazi_id);

                    updateAzbAndQInDB(); // pasokh savaye inke dorost bashe ya nabashe natije sabt mishe
                  } else {
                    showSnackBar('سکه کافی ندارید!');
                  }
                }
              }
            }
            break;
        }
        setState(() {
          finalResultShow = azbazi.mySolvedCount.toString() == azbazi.qCount ? true : false;
          isQuestionFound = _isQuestionFound;
          borderColor = newBorderColor;
          blankChars = _blankChars;
        });
      } else {
        showSnackBar('سکه کافی ندارید!');
      }
    } else {
      showSnackBar('دسترسی قطع است، لطفا لحاظتی بعد مجددآ تلاش کنید!');
    }
    setState(() {
      _waitCheckAnswer = false;
    });
  }

  usePageOrHint(
      BuildContext _context, {
        isPageView = true,
      }) async {
    UserProvider userProvider = UserProvider.instance();
    UserModel? _user = await userProvider.onStartUp();

    if (await GlobalKeys.checkInternetConnection() && _user != null) {
      int qMaxCoinScore = question.max_score!.toInt();
      int myAzbaziCoins = azbazi.myCoins!;
      int myWalletAmount = _user.walletAmount!;
      double allCoinsAmount = (myWalletAmount / 10) + myAzbaziCoins;
      if (allCoinsAmount >= qMaxCoinScore) {
        // setState(() {
        //   _waitCheckAnswer = true;
        // });

        int kasrMaqsumAleih = 3; //belfarz estefade az rahnema
        if( isPageView ){
          kasrMaqsumAleih = 2;
        }

        //double myOldAzbaziScore = azbazi.myScore!;
        int kolKasrEzafe = (qMaxCoinScore / kasrMaqsumAleih).ceil();
        //double myTempAzbaziScore = myOldAzbaziScore + kolKasrEzafe;
        bool _reqHintOrPage = await _reqHintOrPagePopup(kolKasrEzafe.toString());

        if(_reqHintOrPage){
          Map<String, dynamic>? upUVQPageHint = await azbazisQueries().upUVQPageHint(question.question_id!, isPageView);// update Page Or Hint online

          if(upUVQPageHint!.isNotEmpty && upUVQPageHint["havecoin"]) {
            if (upUVQPageHint.containsKey('mycoins') && upUVQPageHint.containsKey('myscore')){
              azbazi.myCoins = upUVQPageHint["mycoins"];
              azbazi.myScore = upUVQPageHint["myscore"].toDouble();
              if (upUVQPageHint.containsKey('wallet_gold')) {
                _user.walletAmount = upUVQPageHint["wallet_gold"];
                changeWalletNotifier(_user.walletAmount);
                userQueries().updateUser(_user);
              }

              azbazisQueries().updateAzbazi(azbazi);
              changeCoinsNotifier(azbazi.myCoins, azbazi.azbazi_id);
              changeScoreNotifier(azbazi.myScore, azbazi.azbazi_id);
              setState(() {
                if( isPageView )
                  showPage = true;
                else
                  showHint = true;
              });
            } else {
              showSnackBar('به این امکان دسترسی ندارید!');
            }
          } else {
            showSnackBar('سکه کافی ندارید!');
          }
        }
      } else {
        showSnackBar('سکه کافی ندارید!');
      }
    } else {
      showSnackBar('دسترسی قطع است، لطفا لحاظتی بعد مجددآ تلاش کنید!');
    }
  }

  Future<bool> _reqHintOrPagePopup( String kolKasrEzafe) async{
    final deleteResult = await showOkCancelAlertDialog(
      context: context,
      title: '!درخواست یادگیری',
      message: 'با کمک گرفتن از این درخواست با کسر مقدار: '+ kolKasrEzafe + ' سکه به همان میزان به نمره تراز شما اضافه می گردد. آیا مایلید ادامه دهید؟',
      okLabel: 'تائید',
      cancelLabel: 'لغو',
      style: AdaptiveStyle.iOS,
      isDestructiveAction: false,
    );

    String result = deleteResult.index.toString();
    if (result == "0") {//yani tayiid hazf
      return true;
    } else {
      return false;
    }
  }

  void showSnackBar(String TXT) {
    Flushbar(
      margin: EdgeInsets.all(100),
      borderRadius: BorderRadius.circular(8),
      backgroundGradient: LinearGradient(
          colors: [Colors.white70, Colors.black12]),
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text( TXT,
          style: TextStyle(fontSize: 13.0,
            color: Colors.pinkAccent,
            fontFamily: "Vazir", ),
        ),
      ),
      duration: Duration(seconds: 3),
    )
      ..show(context);
  }

  updateAzbAndQInDB() async {
    if( isQuestionFound ){
      _questionProcessor.clearActiveQuestion();
    }
  }

  List<Widget> populateQuestion( List questionData, BuildContext context) {
    List<Widget> questionWidgets = [];

    for (var index = 0; index < questionData.length; index++) {
      var question = questionData[index];
      if (question["hidden"]) {
        questionWidgets.add(
            _waitCheckAnswer? Container(margin:EdgeInsets.all(6) ,child: CircularProgressIndicator()):
            BlankSpot(
              character: question["char"],
              holPoint: question["holePoint"],
              index: index,
              onAcceptChar: (data) {
                updateBlanks(data, index, context);
              },
              updateBlanks: updateBlanks,
              borderColor: borderColor[index],
            ));
      } else {
        questionWidgets.add(
          SizedBox(
            width: 40,
            child: TextWidget(text: question["char"]),
          ),
        );
      }
    }
    return questionWidgets;
  }

  String populateBox1ContentHtml(String qEditedBox1Html, BuildContext context) {
    if(qEditedBox1Html == "") qEditedBox1Html = displayedBoxStr;
    String questionEditedBox1Html = qEditedBox1Html;
    bool containHole = true;
    int hole = 0;
    String counter;
    if (questionEditedBox1Html.contains("[[رو:]]")) {
      questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[رو:]]", "<ru>");
      questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[رو]]", "</ru>");
    }

    switch (question.que_type) {
      case 'jaykhali':
      case 'jurkardani':
        while (containHole) {
          hole++;
          counter = hole.toString();
          if (questionEditedBox1Html.contains("[[خ$counter]]")) {
            questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[خ$counter]]", "<kh$counter>[[خ$counter]]</kh$counter>");
          }else {
            containHole = false;
          }
        }
        break;
      default: // testi ya sahihqalat
        int countOption = 4;
        if(question.que_type == "sahihqalat")
          countOption = 2;
        String gozine = "الف)";
        for(int counter = 1; counter <= countOption; counter++){
          switch (counter){
            case 1:
              gozine = "الف)";
              break;
            case 2:
              gozine = "ب)";
              break;
            case 3:
              gozine = "ج)";
              break;
            case 4:
              gozine = "د)";
              break;
          }

          if (questionEditedBox1Html.contains("[[گ$counter:]]")) {
            questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[گ$counter:]]", "$gozine <kh$counter>[[خ$counter]]</kh$counter>"+"<g$counter>");
            questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[گ$counter]]", "</g$counter>");
          }
        }
        while (containHole) {
          hole++;
          counter = hole.toString();
          if (questionEditedBox1Html.contains("[[خ$counter]]")) {
            questionEditedBox1Html = questionEditedBox1Html.replaceAll("[[خ$counter]]", "<kh$counter>[[خ$counter]]</kh$counter>");
          }else {
            containHole = false;
          }
        }

        break;
    }
    return questionEditedBox1Html;
  }

  getLevelBonus() {
    return GameModeNotifier.getLevelBonus(_gameMode);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getQPageData();
    });
    //_gameMode = Provider.of<GameModeNotifier>(context, listen: false).mode;
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    int _qIndex = arguments['qIndex'];
    _gameMode = 'easy';

    if (displayedBoxStr.isEmpty) {
      fetchNewQuestion(displayPreviouslyStoredQuestion: false, qIndex: _qIndex);
    }
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Column(
        children: <Widget>[
          const HeaderBar(),
          !isQuestionFound ?
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Stack(
                  children: <Widget>[
                    PlayView(
                      qBox1ContentHtml: displayedBoxStr,
                      blankChars: blankChars,
                      dragables: dragables,
                      fetchNewQuestion: fetchNewQuestion,
                      getDragables: getDragables,
                      populateQuestion: populateQuestion,
                      populateBox1ContentHtml: populateBox1ContentHtml,
                      usePageOrHint: usePageOrHint,
                      changeCoinsNotifier: changeCoinsNotifier,
                      changeScoreNotifier: changeScoreNotifier,
                      showHint: showHint,
                      azbazi: azbazi,
                      question: question,
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        // child: Image.asset(_lastPagesData.imagePath),
                        child: onePageData != null  && !_isPageViewDisabled? thisPageThumbView(): SpinKitPulse(
                          color: Colors.indigo[900],
                          size: 18.0,
                        ),
                      ),
                    ),
                    question.guide != "" ? Positioned(
                      top: 10,
                      right: 10,
                      child: SizedBox(
                        height: 80,
                        // child: Image.asset(_lastPagesData.imagePath),
                        child: PlayControls(
                          showHint: showHint,
                          useHint: usePageOrHint,
                        ),
                      ),
                    ): Container(),
                  ]
              ),
            ),
          ): Expanded(
            flex: 5,
            child: ResultsView(
              dragables: dragables,
              fetchNewQuestion: fetchNewQuestion,
              getLevelBonus: getLevelBonus,
              solution: question.que_answer,
              question: question,
              tripleScore: showBannerAd,
              enableRewardButton: enableRewardButton,
              finalResultShow: finalResultShow,
            ),
          ),
        ],
      ),
    );
  }

  Widget thisPageThumbView() {
    String startColor = (math.Random().nextDouble() * 0xFFFFFF)
        .toInt()
        .toString();
    String endColor = (math.Random().nextDouble() * 0xFFFFFF)
        .toInt()
        .toString();
    return Container(
      width: double.infinity,
      child: Container(
        child: InkWell(
          child: SizedBox(
            width: 120,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 2, right: 2, bottom: 20),
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
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5, left: 5, right: 2, bottom: 2),
                        child: Image.network(GlobalKeys.ebargeUrl + '/' +
                            onePageData!.page_thumb,
                          fit: BoxFit.cover,
                          // loadingBuilder: (BuildContext context,
                          //     Widget child,
                          //     ImageChunkEvent? loadingProgress) {
                          //   if (loadingProgress == null) return child;
                          //   return Center(
                          //     child: CircularProgressIndicator(
                          //       value: loadingProgress.expectedTotalBytes !=
                          //           null ?
                          //       loadingProgress.cumulativeBytesLoaded /
                          //           loadingProgress.expectedTotalBytes!
                          //           : null,
                          //     ),
                          //   );
                          // },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 5,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    // child: Image.asset(_lastPagesData.imagePath),
                    child: Text(
                      '${AccessCheck().replaceFarsiNumber(onePageData!.real_page_num)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Vazir",
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.2,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          onTap:(!showPage)
              ? () {
            _handlePageViewTap(context);
          }: null,
        ),
      ),
    );
  }

  void getQPageData() async {
    if(_pageNumToId != null){
      int pageCount =  _pageNumToId![0].length - int.parse(widget.book.gap_pages!);

      int realPageNumIndex = question.page_num! + int.parse(widget.book.gap_pages!);
      if(realPageNumIndex <= pageCount &&  realPageNumIndex > 0 && !paintClick){
        paintClick = true;
        await getOnePageData(_pageNumToId![0][realPageNumIndex.toString()]);
      }
    }
  }

  Future<void> _handlePageViewTap(BuildContext context) async {
    if (_isPageViewDisabled) return; // اگر هنوز پاسخ نیومده، جلوشو بگیر

    setState(() {
      _isPageViewDisabled = true; // 🔒 دکمه غیرفعال تا اتمام عملیات
    });

    try {
      await usePageOrHint(context, isPageView: true);
      if(showPage){
        await getOnePageData(
            onePageData!.page_id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: Scaffold(
                    extendBodyBehindAppBar: true,
                    body: Stack(
                        children: [
                          PaintScreen(onePageData!, widget.book, _pageNumToId!),
                          const SizedBox(width: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            child: InkWell(
                              child: Column(
                                  children: <Widget>[
                                    Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.blue,),
                                  ]
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ]
                    )
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint("خطا در دریافت صفحه: $e");
    } finally {
      // دکمه رو دوباره فعال نکن مگر بخوای دوباره اجازه بده
      setState(() {
        _isPageViewDisabled = false; // 🔓 دوباره فعال (درصورت نیاز)
      });
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
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getOnePageData(String pageId) async {
    bool isAccess = await AccessCheck().hasAccessTime();
    if (!isAccess) {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=getpages';
      if (!mounted) {
        paintClick = false;
        return;
      }
      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "book_id": widget.book.book_id,
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
    } catch (e) {
      print(e);
    }
  }
}


extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}