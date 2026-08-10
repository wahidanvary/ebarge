import 'dart:core';

class azbaziModel {
  String? azbazi_id;
  String? book_id;
  String? book_name;
  String? owner_id;
  String? editor_id;
  String? owner_name;
  String? isTeacher;
  String? thumb_link;
  String? title;
  String? note;
  String? qCount;
  int? allHoles;
  int? max_score;
  String? first_pageq;
  String? until_pageq;
  String? averageScores;
  String? rate;
  String? allRateCount;
  String? entrantCount;
  int? allQViewCount;
  String? created_date;
  String? modified_date;
  String? state;
  String? azbaziAccess;
  List<dynamic>? rejectReasons;
  int? myCoins;
  double? myScore;
  int? myViewCount;
  int? mySolvedCount;
  int? myFSolvedCount;
  int? myFSolvedHoles;
  int? qs_try_streak;
  String? myRate;
  String? myVisitDate;
  String? myAzState;
  List<dynamic>? aiModels;
  String? status;
  String? error_code;
  String? error_description;

  azbaziModel({
      this.azbazi_id,
      this.book_id,
      this.book_name,
      this.editor_id,
      this.owner_id,
      this.owner_name,
      this.isTeacher,
      this.thumb_link,
      this.title,
      this.note,
      this.qCount,
      this.allHoles,
      this.max_score,
      this.first_pageq,
      this.until_pageq,
      this.averageScores,
      this.rate,
      this.allRateCount,
      this.entrantCount,
      this.allQViewCount,
      this.created_date,
      this.modified_date,
      this.state,
      this.azbaziAccess,
      this.rejectReasons,
      this.myCoins,
      this.myScore,
      this.myViewCount,
      this.mySolvedCount,
      this.myFSolvedCount,
      this.myFSolvedHoles,
      this.qs_try_streak,
      this.myRate,
      this.myVisitDate,
      this.myAzState,
      this.aiModels,
      this.status,
      this.error_code,
      this.error_description});


  factory azbaziModel.fromJson(Map<String, dynamic> json) => azbaziModel(
    azbazi_id: json["azbazi_id"],
    book_id: json["book_id"],
    book_name: json["book_name"],
    editor_id: json["editor_id"],
    owner_id: json["owner_id"],
    owner_name: json["owner_name"],
    isTeacher: json["isteacher"],
    thumb_link: json["thumb_link"],
    title: json["title"],
    note: json["note"],
    qCount: json["qcount"],
    allHoles: json["allholes"],
    max_score: json["max_score"],
    first_pageq: json["first_pageq"],
    until_pageq: json["until_pageq"],
    averageScores: json["average_scores"],
    rate: json["rate"],
    allRateCount: json["rate_count"],
    entrantCount: json["entrant_count"],
    allQViewCount: json["qview_count"],
    created_date: json["created_date"],
    modified_date: json["modified_date"],
    state: json["state"],
    azbaziAccess: json["azbaziaccess"],
    rejectReasons: json["rejectreasons"],
    myCoins: json["mycoins"],
    myScore: json["myscore"],
    myViewCount: json["myview_count"],
    mySolvedCount: json["mysolved_count"],
    myFSolvedCount: json["myfsolved_count"],
    myFSolvedHoles: json["myfsolved_holes"],
    qs_try_streak: json["qs_try_streak"],
    myRate: json["myrate"],
    myVisitDate: json["myvisit_date"],
    myAzState: json["mystate"],
    aiModels: json["aiModels"],
    status: json["status"],
    error_code: json["error_code"],
    error_description: json["error_description"],
  );

  Map<String, dynamic> toJson() => {
    "azbazi_id": azbazi_id,
    "book_id": book_id,
    "book_name": book_name,
    "editor_id": editor_id,
    "owner_id": owner_id,
    "owner_name": owner_name,
    "isteacher": isTeacher,
    "thumb_link": thumb_link,
    "title": title,
    "note": note,
    "qcount": qCount,
    "allholes": allHoles,
    "max_score": max_score,
    "first_pageq": first_pageq,
    "until_pageq": until_pageq,
    "average_scores": averageScores,
    "rate": rate,
    "rate_count": allRateCount,
    "entrant_count": entrantCount,
    "qview_count": allQViewCount,
    "created_date": created_date,
    "modified_date": modified_date,
    "state": state,
    "azbaziaccess": azbaziAccess,
    "rejectreasons": rejectReasons.toString(),
    "mycoins": myCoins,
    "myscore": myScore,
    "myview_count": myViewCount,
    "mysolved_count": mySolvedCount,
    "myfsolved_count": myFSolvedCount,
    "myfsolved_holes": myFSolvedHoles,
    "qs_try_streak": qs_try_streak,
    "myrate": myRate,
    "myvisit_date": myVisitDate,
    "mystate": myAzState,
    "aiModels": aiModels.toString(),
    "status": status,
    "error_code": error_code,
    "error_description": error_description,
  };
}
