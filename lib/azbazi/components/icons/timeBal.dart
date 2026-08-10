
import 'package:ebarge/azbazi/change-notifiers/timeBal-notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../services/accessCheck.dart';
import '../coins-converter.view.dart';

class TimeBalView extends StatefulWidget {
  const TimeBalView({super.key});

  @override
  _TimeBalViewState createState() => _TimeBalViewState();
}

class _TimeBalViewState extends State<TimeBalView> {
  void launchCoinsConverter(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CoinsConverter(
              pop: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
              color: Colors.deepPurple,
              strokeAlign: BorderSide.strokeAlignCenter)
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            child: Image.asset(
              'assets/images/timebal.png',
              height: 24,
              width: 24,
            ),
          ),
          Consumer<TimeBalNotifier>(
            builder: (_, timeBalNotifier, child) {
              if(timeBalNotifier.timeBal != null)
                return Text('${AccessCheck().replaceFarsiNumber(timeBalNotifier.timeBal.toString())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Vazir",
                      fontSize: 13.0,
                    ));
              else
                return SpinKitPulse(
                  color: Colors.white,
                  size: 18.0,
                );
            },
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
