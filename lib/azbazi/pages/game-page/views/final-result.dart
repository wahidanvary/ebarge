import 'package:ebarge/azbazi/pages/game-page/views/result-theme.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../models/azbaziModel.dart';
import '../../../../models/bookModel.dart';
import '../../../../services/accessCheck.dart';

class AzbaziFinalResult extends StatelessWidget {
  final azbaziModel azbazi;
  final bookModel book;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const AzbaziFinalResult(
      {Key? key, required this.azbazi, required this.book, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ۱️⃣ امتیاز عملکرد کلی (پایه اصلی)
    double baseScoreRatio = (azbazi.myScore! / azbazi.max_score!);
    // اگر امتیاز منفی بود، حداقل ۰ در نظر بگیریم تا نمره منفی ندهد
    baseScoreRatio = baseScoreRatio.clamp(0, 1);
    double baseScore = baseScoreRatio * 4; // وزن 20٪
    // ۲️⃣ سرعت پاسخ‌گویی — نسبت پاسخ‌های درست در اولین فرصت
    double speedRatio = (azbazi.myFSolvedCount! / azbazi.mySolvedCount!.clamp(1, 999));
    double speedScore = speedRatio * 10; // وزن 50٪
    // ۳️⃣ دقت کلی پاسخ‌ها (براساس تعداد جای‌خالی‌ها / پاسخ‌های صحیح)
    double accuracyRatio = (azbazi.myFSolvedHoles! / azbazi.allHoles!.clamp(1, 999));
    double accuracyScore = accuracyRatio * 6; // وزن 30٪
    // ۴️⃣ سکه‌های باقی‌مانده (نشانه‌ی کارآمدی در مصرف منابع)
    //double coinScore = (azbazi.myCoins! / 100).clamp(0, 1.5); // وزن ۷.۵٪
    // ۵️⃣ مشارکت در بازی (بازدیدها یا دفعات ورود)
    //double engagementScore = (azbazi.myViewCount! / 10).clamp(0, 0.5); // وزن ۲.۵٪
    // ۶️⃣ جمع نهایی
    double totalScore = baseScore + speedScore + accuracyScore;
    // محدودسازی نهایی در بازه ۰ تا ۲۰
    totalScore = totalScore.clamp(0, 20);
    // ۷️⃣ گرد کردن نمره به بازه‌های ۰.۲۵

    double roundToQuarter(double value) {
      // ضرب در 4 و گردکردن به نزدیک‌ترین عدد صحیح
      double rounded = (value * 4).roundToDouble() / 4.0;

      // پاک کردن خطاهای اعشاری با رندکردن به دو رقم اعشار
      return double.parse(rounded.toStringAsFixed(2));
    }
    double finalScoreFrom20 = roundToQuarter(totalScore);

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: ResultTheme.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ResultTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#097969')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                'حل شده ها در اولین فرصت',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "Vazir",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  letterSpacing: -0.1,
                                                  color: ResultTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                // SizedBox(
                                                //   width: 28,
                                                //   height: 28,
                                                //   child: Image.asset(
                                                //       "assets/fitness_app/eaten.png"),
                                                // ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    '${AccessCheck().replaceFarsiNumber((azbazi.myFSolvedCount! * animation!.value).toInt().toString())}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:"Vazir",
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 14,
                                                      color: ResultTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    'تا از',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      ResultTheme
                                                          .fontName,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 13,
                                                      letterSpacing: -0.2,
                                                      color: ResultTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    '${AccessCheck().replaceFarsiNumber((azbazi.mySolvedCount! * animation!.value).toInt().toString())}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:"Vazir",
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 14,
                                                      color: ResultTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    'سوال',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      ResultTheme
                                                          .fontName,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: ResultTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        height: 48,
                                        width: 2,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F56E98')
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 2),
                                              child: Text(
                                                'جاخالی های درست',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "Vazir",
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  letterSpacing: -0.1,
                                                  color: ResultTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                // SizedBox(
                                                //   width: 28,
                                                //   height: 28,
                                                //   child: Image.asset(
                                                //       "assets/fitness_app/burned.png"),
                                                // ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    '${AccessCheck().replaceFarsiNumber((azbazi.myFSolvedHoles! * animation!.value).toInt().toString())}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: "Vazir",
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 14 ,
                                                      color: ResultTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 8, bottom: 3),
                                                  child: Text(
                                                    'دونه از',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      ResultTheme
                                                          .fontName,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: ResultTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    '${AccessCheck().replaceFarsiNumber((azbazi.allHoles! * animation!.value).toInt().toString())}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:"Vazir",
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 14,
                                                      color: ResultTheme
                                                          .darkerText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 4, bottom: 3),
                                                  child: Text(
                                                    'جاخالی',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                      ResultTheme
                                                          .fontName,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 12,
                                                      letterSpacing: -0.2,
                                                      color: ResultTheme
                                                          .grey
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: ResultTheme.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: new Border.all(
                                            width: 4,
                                            color: ResultTheme
                                                .nearlyDarkBlue
                                                .withOpacity(0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${AccessCheck().replaceFarsiNumber((azbazi.myScore! * animation!.value).toInt().toString())} از ${AccessCheck().replaceFarsiNumber((azbazi.max_score! * animation!.value).toInt().toString())}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: "Vazir",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.0,
                                              color: ResultTheme
                                                  .nearlyDarkBlue,
                                            ),
                                          ),
                                          Text(
                                            'تراز نهایی',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                              ResultTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                              color: ResultTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CustomPaint(
                                      painter: CurvePainter(
                                          colors: [
                                            ResultTheme.nearlyDarkBlue,
                                            HexColor("#8A98E8"),
                                            HexColor("#8A98E8")
                                          ],
                                          angle: (azbazi.myScore!/azbazi.max_score!.toInt())  *
                                                  (360 /*- animation!.value*/)),
                                      child: SizedBox(
                                        width: 108,
                                        height: 108,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: ResultTheme.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'بازدید',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: ResultTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    color: ResultTheme.darkText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    height: 4,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color:
                                      HexColor('#87A0E5').withOpacity(0.2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: ((70 / 1.2) * animation!.value),
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              HexColor('#87A0E5'),
                                              HexColor('#87A0E5')
                                                  .withOpacity(0.5),
                                            ]),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${AccessCheck().replaceFarsiNumber(azbazi.myViewCount.toString())}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Vazir",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color:
                                      ResultTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'وضعیت',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: ResultTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: ResultTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F56E98')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 ) *
                                                  animationController!.value),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                LinearGradient(colors: [
                                                  HexColor('#F56E98')
                                                      .withOpacity(0.2),
                                                  HexColor('#F56E98'),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'اتمام',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "Vazir",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: ResultTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'سکه ها',
                                      style: TextStyle(
                                        fontFamily: ResultTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: ResultTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 0, top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#F1B440')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: ((70 / 2.5) *
                                                  animationController!.value),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                LinearGradient(colors: [
                                                  HexColor('#F1B440')
                                                      .withOpacity(0.1),
                                                  HexColor('#F1B440'),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '${AccessCheck().replaceFarsiNumber(azbazi.myCoins.toString())}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "Vazir",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: ResultTheme.grey
                                              .withOpacity(0.5),
                                        ),
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
                    FinalScoreWidget(score: finalScoreFrom20,)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shadowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shadowPaint);

    shadowPaint.color = Colors.grey.withOpacity(0.3);
    shadowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shadowPaint);

    shadowPaint.color = Colors.grey.withOpacity(0.2);
    shadowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shadowPaint);

    shadowPaint.color = Colors.grey.withOpacity(0.1);
    shadowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shadowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}

class ScoreTier {
  final String label;
  final String message;
  final Color startColor;
  final Color endColor;
  final String actionText;

  ScoreTier(this.label, this.message, this.startColor, this.endColor, this.actionText);
}

ScoreTier getScoreTier(double score) {
  if (score >= 19.0) {
    return ScoreTier("استثنایی 🎉", "تبریک! تسلط عالی — آماده چالش‌های پیشرفته هستی.",
        const Color(0xFFFFC107), const Color(0xFFFFD700), "چالش پیشرفته");
  } else if (score >= 16.0) {
    return ScoreTier("خیلی خوب 💪", "عملکرد بسیار خوب — تسلط قابل توجه.",
        const Color(0xFF43A047), const Color(0xFF81C784), "مرحله بعد");
  } else if (score >= 13.0) {
    return ScoreTier("خوب 🌿", "نتیجه خوبیه؛ چند نکته رو بهتر کن تا کامل بشه.",
        const Color(0xFF4CAF50), const Color(0xFFA5D6A7), "تمرین‌های تکمیلی");
  } else if (score >= 10.0) {
    return ScoreTier("متوسط 📘", "پیشرفتت مشخصه — ادامه بده!",
        const Color(0xFFFBC02D), const Color(0xFFFFEE58), "چالش بعدی");
  } else if (score >= 6.0) {
    return ScoreTier("ضعیف 🧩", "هنوز نواقصی هست. روی نقاط ضعف تمرکز کن.",
        const Color(0xFFF57C00), const Color(0xFFFFB74D), "مرور اشتباهات");
  } else {
    return ScoreTier("خیلی ضعیف ❗", "نیاز فوری به تمرین — از پایه شروع کن.",
        const Color(0xFFD32F2F), const Color(0xFFEF5350), "شروع دوباره");
  }
}

double roundToQuarter(double value) {
  double rounded = (value * 4).roundToDouble() / 4.0;
  return double.parse(rounded.toStringAsFixed(2));
}

class FinalScoreWidget extends StatelessWidget {
  final double score; // نمره از 20
  const FinalScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final double roundedScore = roundToQuarter(score);
    final ScoreTier tier = getScoreTier(roundedScore);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: roundedScore),
        duration: const Duration(seconds: 2),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          double progress = value / 20.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 دایره پیشرفت گرادیان‌دار
              CustomPaint(
                painter: GradientCirclePainter(
                  progress: progress,
                  startColor: tier.startColor,
                  endColor: tier.endColor,
                ),
                child: SizedBox(
                  height: 140,
                  width: 140,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${AccessCheck().replaceFarsiNumber(roundToQuarter(value).toString())}',
                          style: TextStyle(
                            fontFamily: "Vazir",
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: tier.startColor,
                          ),
                        ),
                        const Text(
                          "از ۲۰",
                          style: TextStyle(
                            fontFamily: "Vazir",
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                tier.label,
                style: TextStyle(
                  fontFamily: "Vazir",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: tier.startColor,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  tier.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Vazir",
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: tier.startColor,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     padding:
              //     const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              //   ),
              //   child: Text(
              //     tier.actionText,
              //     style: const TextStyle(
              //       fontFamily: "Vazir",
              //       fontSize: 17,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}

/// 🎨 نقاش گرادیان روی دایره
class GradientCirclePainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;

  GradientCirclePainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepAngle = 2 * math.pi * progress;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
        colors: [startColor, endColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
