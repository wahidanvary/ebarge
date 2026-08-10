// ignore_for_file: file_names

import 'dart:convert';
import 'dart:math';
import 'package:ebarge/azbazi/change-notifiers/game-mode-notifier.dart';
import 'package:ebarge/azbazi/controllers/question_fetcher.dart';
import 'package:ebarge/models/questionModel.dart';

class QuestionProcessor {
  static final QuestionProcessor _singleton = QuestionProcessor._internal();


  factory QuestionProcessor() {
    return _singleton;
  }

  QuestionProcessor._internal();

  var fetcher = QuestionFetcher();

  Map<String, dynamic> activeQuestion = {};

  List<int>? getHoles(mode) {
    return GameModeNotifier.holesObj[mode];
  }

  String? _prevMode;

  clearActiveQuestion(){
    activeQuestion = {};
  }

  Future<Map> processQuestion(String azbaziState, String azbaziId, int qIndex, String mode, bool getActiveQuestion) async {
    if (getActiveQuestion &&
        activeQuestion['questionModel'] != null && activeQuestion['questionModel'].azbazi_id == azbaziId && _prevMode == mode) {

      return {...activeQuestion};
    }
    _prevMode = mode;
    questionModel question = (await fetcher.getQuestion(azbaziState, azbaziId, qIndex));

    String? displayedBox1Str = question.que_content;

    List blankChars = [];
    switch (question.que_type) {
      case 'jaykhali':
      case 'jurkardani':
      bool containHole = true;
      int hole = 0;
      String holeCounter;
      while (containHole) {
        hole++;
        holeCounter = hole.toString();
        if (displayedBox1Str!.contains("[[خ$holeCounter]]")) {
          var objBlank = {
            "char": "",
            "holePoint": hole,
            "hidden": true,
            "row": 0,
          };
          blankChars.add(objBlank);
        }else {
          containHole = false;
        }
      }
        break;
      default: // testi ya sahihqalat
        int countOption = 4;// be farz testi bashad
        if(question.que_type == "sahihqalat")
          countOption = 2;
        for(int counter = 1; counter <= countOption; counter++){
          var objBlank = {
            "char": "",
            "holePoint": counter,
            "hidden": true,
            "row": 0,
          };
          blankChars.add(objBlank);
        }

        break;
    }

    //var answerMapJson = json.encode(question.answer_map);
    List answerMapJsonList = jsonDecode(question.answer_map!);
    List dragableChars = [];
    for( var i = 0 ; i < answerMapJsonList.length; i++ ) {
      var objDrag = {
        "char": answerMapJsonList[i],
        "pointer": "",
        "hide": false,
      };
      dragableChars.add(objDrag);
    }

    // Store Current question
    activeQuestion = {
      'displayedBoxStr': displayedBox1Str,
      'blankChars': blankChars,
      'dragables': dragableChars,
      'questionModel': question
    };

    return activeQuestion;
  }
}
