import 'package:ebarge/utils/hexColor.dart';
import 'package:flutter/material.dart';

class OurContainer extends StatelessWidget {
  final Widget child;

  const OurContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: HexColor('#FFFAFA')
                  .withOpacity(0.6),
              offset: const Offset(1.1, 4.0),
              blurRadius: 8.0),
        ],
        gradient: LinearGradient(
          colors: <HexColor>[
            HexColor('#cccccc'),
            HexColor('#FFFAFA'),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(54.0),
        ),
      ),
      padding: EdgeInsets.all(20.0),
      child: child,
    );
  }
}
