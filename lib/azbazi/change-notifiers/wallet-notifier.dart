import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/shopModel.dart';
import '../../models/userModel.dart';
import '../../providers/userProvider.dart';


class WalletNotifier extends ChangeNotifier {
  WalletNotifier() {
    getWallet();
  }

  int? _walletAmount;
  UserModel? _userData;
  List<shopModel> _shopData = <shopModel>[];
  int? get walletAmount => _walletAmount;
  UserModel? get userData => _userData;
  List<shopModel> get shopData => _shopData;

  Future<void> getWallet() async {
    UserProvider userProvider = UserProvider.instance();
    _userData = await userProvider.onStartUp();
    _shopData = await userProvider.goldShopData();

    SharedPreferences.getInstance().then((SharedPreferences pref) {
      int? wallet = pref.getInt('myWallet');

      if (_userData != null) {
        _walletAmount = _userData?.walletAmount;
        updateWalletAmount(_walletAmount);
      } else if (wallet != null) {
        _walletAmount = wallet;
        notifyListeners();
      }
    });
  }

  get changeWallet {
    return (newWalletCount){
      updateWalletAmount(newWalletCount);
    };
  }

  updateWalletAmount(newWalletAmount) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("myWallet", newWalletAmount);
    _walletAmount = newWalletAmount;
    notifyListeners();
  }
}
