import 'dart:math';
import 'package:ebarge/models/questionModel.dart';
import 'package:flutter/material.dart';

import '../../../services/accessCheck.dart';
import '../game-page/game-page.dart';


class Chapter {
  final int chapterNum;
  final int questionCount;

  Chapter(this.chapterNum, this.questionCount);
}

class QuestionNumList extends StatefulWidget {
  final List<questionModel> questionsGlobalList;

  const QuestionNumList(this.questionsGlobalList, {super.key});

  @override
  _QuestionNumListState createState() => _QuestionNumListState();
}

class _QuestionNumListState extends State<QuestionNumList> {
  late List<Chapter> chapters = [];
  bool canSolveNext = true;
  int lastSolvable = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    int bookChapter = 0;
    int ChapterQCount = 0;
    for (int k = 0; k < widget.questionsGlobalList.length; k++) {
      bookChapter = int.parse(widget.questionsGlobalList[k].book_chapter!);
      final index = chapters.indexWhere((Chapter) => Chapter.chapterNum == bookChapter);
      if(index >= 0) {
        ChapterQCount = chapters[index].questionCount + 1;
        chapters[index] = Chapter(bookChapter, ChapterQCount);
        ChapterQCount = 0;
      } else {
        chapters.add(Chapter(bookChapter, 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    canSolveNext = true;
    lastSolvable = 0;
    int totalQuestions = chapters.fold(0, (sum, chapter) => sum + chapter.questionCount);
    int totalSlides = totalQuestions~/12;
    if(totalQuestions % 12 != 0) totalSlides++;
    //print(totalQuestions);
    return SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: totalSlides,
          itemBuilder: (context, index) {

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Wrap(
                    spacing: 1.0,
                    runSpacing: 1.0,
                    children: [
                      // Limit questions per page (optional)
                      for (int qNum = (index * 12) + 1; qNum <= min(totalQuestions, (index + 1) * 12); qNum++)
                        myPadding(totalQuestions, qNum),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
  }

  Widget myPadding(int totalQuestions, int qNum) {
    Color? itemColor = Colors.white54;
    Color? qNumColor = Colors.black87;
    int bookChapter = 0;
    bookChapter = int.parse(widget.questionsGlobalList[qNum-1].book_chapter!);
    if(widget.questionsGlobalList[qNum-1].qstate != "5" || (canSolveNext && widget.questionsGlobalList[qNum-1].solved_date != "" && widget.questionsGlobalList[qNum-1].uvstate == 2)) {
   // if(widget.questionsGlobalList[qNum-1].solved_date != "" && widget.questionsGlobalList[qNum-1].uvstate == 2) {
      switch (bookChapter % 5) {
        case 1:
          itemColor = Colors.blue[200]!;
          break;
        case 2:
          itemColor = Colors.pink[200]!;
          break;
        case 3:
          itemColor = Colors.green[200]!;
          break;
        case 4:
          itemColor = Colors.red[200]!;
          break;
        case 0:
          itemColor = Colors.yellow[200]!;
      }
    }
    if(widget.questionsGlobalList[qNum-1].qstate == "5") {
      if (qNum < totalQuestions) {
        if (widget.questionsGlobalList[qNum].solved_date == "" ||
            widget.questionsGlobalList[qNum].uvstate != 2) {
          canSolveNext = false;
          lastSolvable++;
          if (lastSolvable == 1) {
            itemColor = Colors.purple[200]!;
            qNumColor = Colors.white;
          }
        }
      } else if (qNum == totalQuestions &&
          widget.questionsGlobalList[totalQuestions - 1].uvstate == 2) {
        lastSolvable = totalQuestions;
        itemColor = Colors.purple[200]!;
        qNumColor = Colors.white;
      }
    }else{
      lastSolvable = totalQuestions;
      if (qNum == totalQuestions &&
          widget.questionsGlobalList[totalQuestions - 1].uvstate == 2) {
        lastSolvable = totalQuestions;
        itemColor = Colors.purple[200]!;
        qNumColor = Colors.white;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: () {
              // Button's action
              if((qNum - 1) <= lastSolvable) Navigator.pushNamed(context, GamePage.route, arguments: {'qIndex': qNum-1});
            },
            child: Text(
              '${AccessCheck().replaceFarsiNumber(qNum.toString())}',
              style: const TextStyle(fontSize: 16.0, fontFamily: "Vazir"),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: qNumColor,
              backgroundColor: itemColor,
              shadowColor: Colors.lightBlueAccent,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  AccessCheck().replaceFarsiNumber(bookChapter.toString()),
                  style: TextStyle(
                    color: qNumColor,
                    fontSize: 10,
                    fontFamily: "Vazir"
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
