
import 'package:ebarge/azbazi/components/icons/coins.dart';
import 'package:ebarge/azbazi/components/icons/scores.dart';
import 'package:flutter/material.dart';

import '../../../utils/hexColor.dart';


class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      height: 60,
      child: Row(
        children: <Widget>[
          IconButton(
            color: HexColor("#005b96"),
            icon: Icon(
              Icons.maps_home_work_outlined,
              color: HexColor("#005b96"),
            ),
            onPressed: () {
              //Navigator.of(context).pop();
              Navigator.popAndPushNamed(context, '/');
            },
            tooltip: "خانه",
          ),
          const Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 15,
                ),
                ScoreView(),
                SizedBox(
                  width: 15,
                ),
                CoinsView(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
