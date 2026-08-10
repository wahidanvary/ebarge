
import 'package:ebarge/azbazi/change-notifiers/coins-notifier.dart';
import 'package:ebarge/azbazi/change-notifiers/scores-notifier.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class CoinsConverter extends StatefulWidget {
  final Function pop;
  const CoinsConverter({super.key, required this.pop});

  @override
  _CoinsConverterState createState() => _CoinsConverterState();
}

class _CoinsConverterState extends State<CoinsConverter> {
  //Ads ads = Ads();
  int currentValue = 0;
  bool enableRewardButton = true;
  Function? changeCoinsNotifier;
  Function? changeScoreNotifier;
  // Function? changeZafranNotifier;
  // Function? changeTimeBalNotifier;
  Function? updateCoinCount;
  Function? updateScoreCount;
  @override
  void initState() {
    super.initState();
  //  ads.initAds();
  }

  @override
  void dispose() {
    // ads.disposeAds();
    super.dispose();
  }

  showBannerAd() {
    setState(() {
      enableRewardButton = false;
    });
   // ads.showRewardAd(awardRewardPoints, enableRewardButtonFn);
  }

  awardRewardPoints() {
    int coins = 50;
    /*Fluttertoast.showToast(
      msg: "Bonus $coins coins credited",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );*/
    //changeCoinsNotifier!(coins);
    //changeScoreNotifier!(score);
  }

  enableRewardButtonFn() {
    setState(() {
      enableRewardButton = true;
    });
  }

  double getMaxKeys(BuildContext context) {
    int? coins = Provider.of<CoinsNotifier>(context, listen: false).coins;
    return (coins! ~/ 50).toDouble();
  }

  createKeys(BuildContext context) {
    widget.pop();
    int? coins = Provider.of<CoinsNotifier>(context, listen: false).coins;
    int remainingCoins = coins! - currentValue * 50;
    updateCoinCount!(remainingCoins);
    var scores = Provider.of<ScoresNotifier>(context, listen: false).score;
    updateScoreCount!(scores! + currentValue);
  }

  @override
  Widget build(BuildContext context) {
    changeCoinsNotifier =
        Provider.of<CoinsNotifier>(context, listen: false).changeCoins;
    updateCoinCount =
        Provider.of<CoinsNotifier>(context, listen: false).updateCoinCount;
    updateScoreCount =
        Provider.of<ScoresNotifier>(context, listen: false).updateScoreCount;
    return Container(
      width: 350.0,
      height: 300.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Coins Exchange",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColorDark,
                shadows: const <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 10.0,
                    color: Color.fromARGB(55, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
          if (getMaxKeys(context) == 0)
            Container(
              width: 270.0,
              height: 120.0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Center(
                child: Text(
                  "Not enough coins available to buy Hints, watch Ad to earn coins.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    // color: Colors.grey,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 10.0,
                        color: Color.fromARGB(95, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (getMaxKeys(context) > 0)
            SizedBox(
              width: 270.0,
              height: 120.0,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  Slider.adaptive(
                    min: 0.0,
                    max: getMaxKeys(context),
                    value: currentValue.toDouble(),
                    divisions: getMaxKeys(context).toInt(),
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey,
                    label: "${currentValue * 50} Coins",
                    onChanged: (double newValue) {
                      print(newValue);
                      setState(() {
                        currentValue = newValue.round().toInt();
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          "0",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              getMaxKeys(context).toInt().toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                              ),
                              child: Image.asset(
                                'assets/images/score.png',
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 270.0,
            child: Column(
              children: <Widget>[
                OutlinedButton(
                  onPressed: enableRewardButton ? showBannerAd : null,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Colors.deepOrange),
                  ),
                  child: SizedBox(
                    width: 200.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_library,
                          size: 30,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Earn 50 Coins",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Transform.translate(
                          offset: const Offset(0.0, 0.0),
                          child: Image.asset(
                            'assets/images/coin-heap-3x.png',
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.green,
                      shadowColor: Colors.red,
                      elevation: 4,
                    ),
                    onPressed: getMaxKeys(context).toInt() == 0
                        ? null
                        : () {
                      createKeys(context);
                    },
                    child: const SizedBox(
                      width: 200.0,
                      child: Center(
                        child: Text(
                          "Convert",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
