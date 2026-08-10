import 'package:ebarge/services/accessCheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ebarge/azbazi/pages/game-page/views/my-final-result-screen.dart';
import 'package:ebarge/models/questionModel.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../../utils/hexColor.dart';

class ResultsView extends StatelessWidget {
  final solution;
  final questionModel question;
  final dragables;
  final void Function()? fetchNewQuestion;
  final Function getLevelBonus;
  final FlutterTts flutterTts = FlutterTts();
  final void Function()? tripleScore;
  final bool enableRewardButton;
  final bool finalResultShow;

  ResultsView({
    super.key,
    @required this.solution,
    required this.question,
    @required this.dragables,
    required this.fetchNewQuestion,
    required this.getLevelBonus,
    required this.tripleScore,
    required this.enableRewardButton,
    required this.finalResultShow,
  });

  speakQuestion() async {
    await flutterTts.stop();
    await flutterTts.speak(question.question_id!);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // 🔹 بخش اسکرول شونده
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // اسکرول نرم
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        right: 14, top: 8, bottom: 10, left: 14,
                      ),
                      child: _buildSolutionBox(),
                    ),

                    const SizedBox(height: 20),

                    _buildScoreBox(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // 🔥 دکمه پایین ثابت
          SafeArea(
            top: false,
            child: _buildBottomButton(context),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 🔷 بخش "پاسخ تشریحی"
  // ----------------------------------------------------
  Widget _buildSolutionBox() {
    String processedSolution = AccessCheck().preprocessLatex(solution);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.teal.shade700, size: 26),
                const SizedBox(width: 8),
                Text(
                  "پاسخ تشریحی:",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                    fontFamily: "Vazir",
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.teal.withOpacity(0.2)),

          // HTML Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: HtmlWidget(
              processedSolution,
              textStyle: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
                fontFamily: "Vazir",
              ),
              renderMode: RenderMode.column,
              customWidgetBuilder: (element) {
                // Inline formula
                if (element.localName == 'latex-inline') {
                  String formula = Uri.decodeComponent(
                      element.attributes['data'] ?? '');
                  formula = AccessCheck().replaceFarsiNumber(formula);

                  return InlineCustomWidget(
                    alignment: PlaceholderAlignment.middle,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Math.tex(
                        formula,
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.teal.shade900,
                          fontFamily: "Vazir",
                        ),
                      ),
                    ),
                  );
                }

                // Block formula
                if (element.localName == 'latex-block') {
                  String formula = Uri.decodeComponent(
                      element.attributes['data'] ?? '');
                  formula = AccessCheck().replaceFarsiNumber(formula);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Math.tex(
                        formula,
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.teal.shade900,
                          fontFamily: "Vazir",
                        ),
                      ),
                    ),
                  );
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 🔷 بخش "امتیاز"
  // ----------------------------------------------------
  Widget _buildScoreBox() {
    String emtiazTXT = question.myqscore! > 0.0
        ? "${question.myqscore}+"
        : "${question.myqscore}";
    Color emtiazColor = question.myqscore! > 0.0 ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "امتیاز شما:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontFamily: "Vazir",
            ),
          ),

          // Max score
          Row(
            children: [
              Text(
                "${AccessCheck().replaceFarsiNumber((question.max_score! / 100).toString())}+",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: "Vazir",
                ),
              ),
              const SizedBox(width: 8),
              Image.asset('assets/images/zafran.png', height: 28, width: 28),
            ],
          ),

          // My score
          Row(
            children: [
              Text(
                AccessCheck().replaceFarsiNumber(emtiazTXT),
                style: TextStyle(
                  color: emtiazColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: "Vazir",
                ),
              ),
              const SizedBox(width: 8),
              Image.asset('assets/images/score.png', height: 28, width: 28),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 🔷 دکمه پایین صفحه
  // ----------------------------------------------------
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: !finalResultShow
          ? ElevatedButton.icon(
        onPressed: fetchNewQuestion,
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          "ادامه بازی",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Vazir",
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor('#F56E98'),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      )
          : ElevatedButton.icon(
        onPressed: () =>
            Navigator.pushNamed(context, MyFinalResultScreen.route),
        icon: const Icon(Icons.assignment_turned_in_rounded, size: 26),
        label: const Text(
          "مشاهده نتیجه نهایی",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Vazir",
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
