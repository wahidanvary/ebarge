import 'package:ebarge/azbazi/change-notifiers/coins-notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/accessCheck.dart';
import '../../../utils/hexColor.dart';

class CoinsView extends StatefulWidget {
  const CoinsView({super.key});

  @override
  State<CoinsView> createState() => _CoinsViewState();
}

class _CoinsViewState extends State<CoinsView> {

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        decoration: BoxDecoration(
          color: HexColor("#005b96"),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            Transform.translate(
              offset: const Offset(0.0, 1.0),
              child: Image.asset(
                'assets/images/coin-heap.png',
                height: 20,
                width: 20,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Consumer<CoinsNotifier>(
              builder: (_, CoinsNotifier, child) {
                return Text(
                    '${AccessCheck().replaceFarsiNumber(CoinsNotifier.coins.toString())}',
                  style: const TextStyle(
                    color: Colors.white,
                      fontSize: 13.0,
                    fontWeight: FontWeight.bold, fontFamily: "Vazir"
                  ),
                );
              },
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
      );
  }
}
