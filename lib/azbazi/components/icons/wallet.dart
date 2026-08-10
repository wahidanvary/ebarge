import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../models/shopModel.dart';
import '../../../models/userModel.dart';
import '../../../screens/books/goldShop.dart';
import '../../../services/accessCheck.dart';
import '../../change-notifiers/wallet-notifier.dart';

//ignore: must_be_immutable
class WalletView extends StatelessWidget {
  WalletView({super.key, required this.walletAmount, required this.shopData});
  int? walletAmount = 0;
  UserModel? userData;
  List<shopModel> shopData = <shopModel>[];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //launchWalletConverter(context);
        Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GoldShopScreen(walGold: walletAmount,userData: userData!, shopData: shopData,),
              ),
            );
      },
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 6,
            ),
            Transform.translate(
              offset: const Offset(0.0, 1.0),
              child: Image.asset(
                'assets/images/mined_gold.png',
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Consumer<WalletNotifier>(
              builder: (_, walletProvider, child) {
                walletAmount = walletProvider.walletAmount;
                userData = walletProvider.userData;
                shopData = walletProvider.shopData;

                if(walletProvider.walletAmount != null)
                  return Text(
                    '${AccessCheck().replaceFarsiNumber(walletProvider.walletAmount.toString())}',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold, fontFamily: "Vazir"
                    ),
                  );
                else
                  return SpinKitPulse(
                    color: Colors.indigo[900],
                    size: 18.0,
                  );
              },
            ),
            const SizedBox(
              width: 6,
            ),
            const Icon(
              Icons.add_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(
              width: 4,
            )
          ],
        ),
      ),
    );
  }
}
