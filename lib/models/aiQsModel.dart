import 'dart:core';

import 'package:card_settings/models/picker_model.dart';

class aiQsModel {
  String? azbaziId;
  String? bookId;
  PickerModel? aiModel;
  String? additionalNote;
  int? qsCount;
  int? section;

  aiQsModel({
    this.azbaziId,
    this.bookId,
    this.aiModel,
    this.additionalNote,
    this.qsCount,
    this.section});


  factory aiQsModel.fromJson(Map<String, dynamic> json) => aiQsModel(
    azbaziId: json["azbaziId"],
    bookId: json["bookId"],
    aiModel: json["aiModel"],
    additionalNote: json["additionalNote"],
    qsCount: json["qsCount"],
    section: json["section"],
  );

  Map<String, dynamic> toJson() => {
    "azbaziId": azbaziId,
    "bookId": bookId,
    "aiModel": aiModel,
    "additionalNote": additionalNote,
    "qsCount": qsCount,
    "section": section,
  };
}
