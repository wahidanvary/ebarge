// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/userModel.dart';
import '../../providers/userProvider.dart';

class ZafransNotifier extends ChangeNotifier {
  ZafransNotifier() {
    getZafrans();
  }

  double? _zafrans;
  double? get zafrans => _zafrans;

  Future<void> getZafrans() async {
    UserModel? _user;
    UserProvider userProvider = UserProvider.instance();
    _user = await userProvider.onStartUp();

    SharedPreferences.getInstance().then((SharedPreferences pref) {
      double? zafrans = pref.getDouble('myzafran');

      if (_user != null) {
        _zafrans = _user.zafran!;
        updateZafranCount(_zafrans);
        notifyListeners();
      } else if (zafrans != null) {
        _zafrans = zafrans;
        notifyListeners();
      }
    });
  }

  get changeZafran {
    return (newZafran){
      updateZafranCount(newZafran!);
    };
  }

  updateZafranCount(newZafran) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble("myzafran", double.parse(newZafran.toStringAsFixed(2)));
    _zafrans = double.parse(newZafran.toStringAsFixed(2));
    notifyListeners();
  }
}
