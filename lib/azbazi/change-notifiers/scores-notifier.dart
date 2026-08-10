// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/azbaziModel.dart';

class ScoresNotifier extends ChangeNotifier {
  ScoresNotifier(azbaziModel azbazi) {
    getScore(azbazi);
  }

  double? _score;
  double? get score => _score;

  void getScore(azbaziModel azbazi) {
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      double? myscore = pref.getDouble('myscore'+azbazi.azbazi_id!);
      if (myscore == null) {
        _score = azbazi.myScore!;
        updateScoreCount(_score, azbazi.azbazi_id);
      } else {
        _score = myscore;
        notifyListeners();
      }
    });
  }

  get changeScore {
    return (newScore, azbaziId){
      updateScoreCount(newScore, azbaziId);
    };
  }

  updateScoreCount(newScore, azbaziId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble("myscore"+azbaziId, newScore);
    _score = newScore;
    notifyListeners();
  }

}
