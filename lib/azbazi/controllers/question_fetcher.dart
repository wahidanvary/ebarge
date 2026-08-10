// ignore_for_file: file_names
import 'package:ebarge/database/azbaziQueries.dart';
import 'package:ebarge/models/questionModel.dart';

class QuestionFetcher {
  static QuestionFetcher _singleton = QuestionFetcher._internal();

  factory QuestionFetcher() {
    return _singleton;
  }

  QuestionFetcher._internal();

  List<questionModel> _tempQuestions = [];
  final azbazisQueries _databaseService = azbazisQueries();

  Future<questionModel> getQuestion(String azbaziState, String azbaziId, int qIndex) async {
    if (_tempQuestions.isEmpty || _tempQuestions[0].azbazi_id != azbaziId || azbaziState != "5") {
      _tempQuestions = await _databaseService.getQuestions(azbaziId);
    }
    questionModel question = questionModel();
    if (_tempQuestions.isNotEmpty) {
      question = _tempQuestions.first;
      for (int qNum = 0; qNum < _tempQuestions.length; qNum++) {
        int? uvState = 0;
        if (_tempQuestions[qNum].uvstate != null)
          uvState = _tempQuestions[qNum].uvstate;
        if (qIndex < 0) {
          if (uvState! < 2) {
            question = _tempQuestions[qNum];
            break;
          }
        } else if (qIndex == qNum && (uvState == 2 || azbaziState != "5")) {// bara estexraj soalat hal shode karbar
            question = _tempQuestions[qNum];
            break;
          }
      }
    }
    return question;
  }
}
