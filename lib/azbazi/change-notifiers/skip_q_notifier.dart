// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkipQuestionNotifier extends ChangeNotifier {
  SkipQuestionNotifier() {
    getSkipsLeft();
  }

  int? _skipsLeft;

  int get skipsLeft {
    if (_skipsLeft == null) {
      getSkipsLeft();
      return 10;
    }
    return _skipsLeft!;
  }

  void getSkipsLeft() {
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      String? lastDate0 = pref.getString('lastDateSkipsUpdated');
      var today = DateTime.now();
      int todayInMilliSecs = DateTime.now().millisecondsSinceEpoch;
      if (lastDate0 == null) {
        _skipsLeft = 10;
        // Update date to today
        pref.setString('lastDateSkipsUpdated', todayInMilliSecs.toString());
        pref.setInt('skipsLeftForToday', 10);
      } else {
        var lastDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(lastDate0));
        var dateDiff = DateTime(today.year, today.month, today.day)
            .difference(
            DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (dateDiff > 0) {
          _skipsLeft = 10;
          // Update date to today
          pref.setString('lastDateSkipsUpdated', todayInMilliSecs.toString());
          pref.setInt('skipsLeftForToday', 10);
        } else {
          _skipsLeft = pref.getInt('skipsLeftForToday');
        }
      }
      notifyListeners();
    });
  }

  updateSkipsLeft(skipsLeft) async {
    _skipsLeft = skipsLeft;
    notifyListeners();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('skipsLeftForToday', skipsLeft);
  }
}
