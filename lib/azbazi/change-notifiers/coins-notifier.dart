
import 'package:ebarge/models/azbaziModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsNotifier extends ChangeNotifier {
  CoinsNotifier(azbaziModel azbazi) {
    getCoins(azbazi);
  }

  int? _coins;
  int? get coins => _coins;

  void getCoins(azbaziModel azbazi) {
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      int? coins = pref.getInt('mycoins'+azbazi.azbazi_id!);
      if (coins == null) {
        _coins = azbazi.myCoins!;
        updateCoinCount(_coins, azbazi.azbazi_id);
      } else {
        _coins = coins;
        notifyListeners();
      }
    });
  }

  get changeCoins {
    return (newCoinCount, azbaziId){
      updateCoinCount(newCoinCount, azbaziId);
    };
  }

  updateCoinCount(newCoins, azbaziId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("mycoins"+azbaziId, newCoins);
    _coins = newCoins;
    notifyListeners();
  }
}
