// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/userModel.dart';
import '../../providers/userProvider.dart';

class TimeBalNotifier extends ChangeNotifier {
  TimeBalNotifier() {
    getTimeBal();
  }

  int? _timeBal;
  int? get timeBal => _timeBal;

  Future<void> getTimeBal() async {
    UserModel? _user;
    UserProvider userProvider = UserProvider.instance();
    _user = await userProvider.onStartUp();

    SharedPreferences.getInstance().then((SharedPreferences pref) {
      int? timeBal = pref.getInt('mytimebal');

      if (_user != null) {
        _timeBal = _user.time_balance!;
        updateTimeBalCount(_timeBal);
        notifyListeners();
      } else if (timeBal != null) {
        _timeBal = timeBal;
        notifyListeners();
      }
    });
  }

  get changeTimeBalance {
    return (newTimeBal){
      updateTimeBalCount(newTimeBal!);
    };
  }

  updateTimeBalCount(newTimeBal) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("mytimebal", newTimeBal);
    _timeBal = newTimeBal;
    notifyListeners();
  }
}
