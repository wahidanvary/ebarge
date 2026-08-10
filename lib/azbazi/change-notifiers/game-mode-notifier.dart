// ignore_for_file: file_names

import 'package:flutter/material.dart';

class GameModeNotifier extends ChangeNotifier {
  GameModeNotifier() {
    //getMode();
  }

  static final holesObj = {
    "": [1, 2],
    "easy": [2, 3],
    "medium": [4, 5],
    "hard": [6, 7, 8],
    "pro": [6, 7, 8]
  };

  static getLevelBonus(gameMode) {
    if (gameMode == 'easy') {
      return 1;
    }
    if (gameMode == 'medium') {
      return 2;
    }
    if (gameMode == 'hard') {
      return 3;
    }
    if (gameMode == 'pro') {
      return 4;
    }
  }

  /*static QuestionModel updateQuestionModel(gameMode, QuestionModel questionModel){
    if (gameMode == 'easy') {
      //questionModel.usedInEasy = true;
    }else if (gameMode == 'medium') {
      //questionModel.usedInMedium = true;
    }else if (gameMode == 'hard') {
      //questionModel.usedInHard = true;
    }else if (gameMode == 'pro') {
      //questionModel.usedInPro = true;
    }
    return questionModel;
  }

  static Map? getWhereCondition(gameMode){
    if (gameMode == 'easy') {
      return {
        'column' : AppDataBase.usedInEasy,
        'min-length' : 5,
        'max-length' : 8
      };
    }
    if (gameMode == 'medium') {
      return {
        'column' : AppDataBase.usedInMedium,
        'min-length' : 8,
        'max-length' : 11
      };
    }
    if (gameMode == 'hard') {
      return {
        'column' : AppDataBase.usedInHard,
        'min-length' : 10,
        'max-length' : 20
      };
    }
    if (gameMode == 'pro') {
      return {
        'column' : AppDataBase.usedInPro,
        'min-length' : 10,
        'max-length' : 20
      };
    }
    return null;
  }

  final List<Map<String, Object>> _options = [
    {
      'mode': 'easy',
      'title': 'Easy',
      'subTitle': '2 or 3 missing characters in a question',
      'selected': false
    },
    {
      'mode': 'medium',
      'title': 'Medium',
      'subTitle': '4 or 5 missing characters in a question',
      'selected': false
    },
    {
      'mode': 'hard',
      'title': 'Hard',
      'subTitle': '6 to 8 missing characters in a question',
      'selected': false
    },
    // {
    //   'mode': 'pro',
    //   'title': 'Pro',
    //   'subTitle': 'Play without Hints',
    //   'selected': false
    // }
  ];

  String? _mode;

  String get mode {
    if (_mode == null) {
      getMode();
      return 'easy';
    }
    return _mode!;
  }

  List<Map<String, Object>> get options {
    List<Map<String, Object>> newOptions = [];
    for (var option in _options) {
      option['selected'] = option['mode'] == mode;
      newOptions.add(option);
    }
    return newOptions;
  }

  void getMode() {
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      String? mode = pref.getString('mode');
      if (mode == null) {
        mode = 'easy';
        updateGameMode(mode);
      } else {
        mode = mode;
        notifyListeners();
      }
    });
  }

  updateGameMode(selectedMode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("mode", selectedMode);
    _mode = selectedMode;
    notifyListeners();
  }*/
}
