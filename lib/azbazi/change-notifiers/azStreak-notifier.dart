// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/azbaziModel.dart';

class AzQStreakNotifier extends ChangeNotifier {
  AzQStreakNotifier(azbaziModel azbazi) {
    getAzQStreak(azbazi);
  }

  int? _azQStreak;
  int? get azQStreak => _azQStreak;

  void getAzQStreak(azbaziModel azbazi) {
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      int? myAzQStreak = pref.getInt('myAzQStreak'+azbazi.azbazi_id!);
      if (myAzQStreak == null) {
        _azQStreak = azbazi.qs_try_streak!;
        updateAzQStreakCount(_azQStreak, azbazi.azbazi_id);
      } else {
        _azQStreak = myAzQStreak;
        notifyListeners();
      }
    });
  }

  get changeAzQStreak {
    return (newAzQStreak, azbaziId){
      updateAzQStreakCount(newAzQStreak, azbaziId);
    };
  }

  updateAzQStreakCount(newAzQStreak, azbaziId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble("myAzQStreak"+azbaziId, newAzQStreak);
    _azQStreak = newAzQStreak;
    notifyListeners();
  }

}
