import 'dart:io';
import 'dart:ui';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'filter.dart';

enum NoteStatus { ExistNotes, BlankNotes, Initializing, Uninitialized }

/// Data model of a note.
class NoteModel extends ChangeNotifier {
  var _NoteInstance;
  final String note_id;
  String page_id = '';
  String user_id = '';
  String saved_content_id = '';
  String title = '';
  String thenote = '';
  Color? color;
  NoteState state = NoteState.unspecified;
  final DateTime created_date;
  DateTime? modified_date;
  String status = '';
  String error_code = '';
  String error_description = '';
  List<NoteModel> _notes = <NoteModel>[];

  NoteStatus _noteStatus = NoteStatus.Uninitialized;

  /// Instantiates a [NoteModel].
  NoteModel({
    required this.note_id,
    required this.page_id,
    required this.user_id,
    required this.saved_content_id,
    required this.title,
    required this.thenote,
    required this.color,
    required this.state,
    required DateTime created_date,
    required DateTime? modified_date,
    required this.status,
    required this.error_code,
    required this.error_description,
  }) : this.created_date = created_date,
    this.modified_date = modified_date;

  NoteModel.instance(String pageId, NoteFilter filter, this.note_id, this.created_date)
      : _NoteInstance = NoteModel(
    note_id: '',
    created_date:  Jalali.now().toDateTime(), page_id: '', state: NoteState.unspecified, title: '', color: null, error_description: '', status: '', thenote: '', saved_content_id: '', error_code: '', modified_date: null, user_id: '',
  ) {

    //if(NoteState.unspecified == state)
      //fetchNotes(pageId, filter);
  }

  List<NoteModel> get getPageNotes => _notes;
  NoteStatus get noteStatus => _noteStatus;

  /// Transforms the Firestore query [snapshot] into a list of [NoteModel] instances.
 // static List<NoteModel> fromQuery(QuerySnapshot snapsphot) => snapshot != null ? snapshot.toNotes() : [];
  Future<List<NoteModel>?> fetchNotes(String pageId, NoteFilter filter) async {
    try {
      _noteStatus = NoteStatus.Initializing;
      //notifyListeners();
      bool isAccess = await AccessCheck().hasAccessTime();
      if(!isAccess){
        UserProvider userProvider = UserProvider.instance();
        await userProvider.onStartUp();
      }

      _notes = <NoteModel>[];
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=pages&resource=usernotes';
      var body = Map<String, dynamic>();
      body["page_id"] = pageId;
      body["filter"] = filter.noteState.index;
      body["orderdir"] = 'desc';
      body["orderby"] = 'state';
     // body["limit"] = '6';

      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "page_id": pageId,
        "filter": filter.noteState.index,
        "orderdir": "desc",
        "orderby": "state",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        var unotesJson = response.data["unotes"];
       // return pagesJson.toNotes();
       // map.forEach((k, pagesJson) => list.add(NoteModel(k, pagesJson)));
        for (var data in unotesJson) {
          var noteItem = NoteModel(
              note_id: data['note_id'],
              page_id: data['page_id'],
              user_id: data['user_id'],
              saved_content_id: data['saved_content_id'],
              title: data['title'],
              thenote: data['thenote'],
              color: Color(int.parse(data['color'])),
              state: NoteState.values[int.parse(data['state'])],
              created_date: (DateTime.parse(data['created_date'])),
              modified_date: (DateTime.parse(data['modified_date'])),
              status: "",
              error_code: "",
              error_description: "");
          _notes.add(noteItem);
        }
        if (_notes.length > 0) {
          _noteStatus = NoteStatus.ExistNotes;
          notifyListeners();
        } else {
          _noteStatus = NoteStatus.BlankNotes;
          notifyListeners();
        }
        return _notes;
      } else {
        print("اتصال به سرور با مشکل روبرو شد!");
      }
    } catch (e) {
      _noteStatus = NoteStatus.Uninitialized;
      notifyListeners();
      print(e);
    }
    return null;
  }

  /// Whether this note is pinned
  bool get pinned => state == NoteState.pinned;

  /// Returns an numeric form of the state
  int get stateValue => (state).index;

  bool get isNotEmpty => title.isNotEmpty == true || thenote.isNotEmpty == true;

  /// Formatted last modified time
  String get strLastModified => DateFormat.MMMd().format(modified_date!);

  /// Update this note with another one.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modified_date` will be updated to `DateTime.now()`, otherwise, the value of `modified_date`
  /// will also be copied from [other].
  void update(NoteModel other, {bool updateTimestamp = true}) {
    saved_content_id = other.saved_content_id;
    title = other.title;
    thenote = other.thenote;
    color = other.color;
    state = other.state;

    if (updateTimestamp || other.modified_date == null) {
      modified_date = Jalali.now().toDateTime();
    } else {
      modified_date = other.modified_date;
    }
    notifyListeners();
  }

  /// Update this note with specified properties.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modified_date` will be updated to `DateTime.now()`.
  NoteModel updateWith({
    required String saved_content_id,
    required String title,
    required String thenote,
    required Color color,
    required NoteState state,
    bool updateTimestamp = true,
  }) {
    if (saved_content_id != '') this.saved_content_id = saved_content_id;
    if (title != '') this.title = title;
    if (thenote != '') this.thenote = thenote;
    this.color = color;
    if (state != NoteState.unspecified) this.state = state;
    if (updateTimestamp) modified_date = Jalali.now().toDateTime();
    notifyListeners();
    return this;
  }

  /// Serializes this note into a JSON object.
  Map<String, dynamic> toJson() => {
    'saved_content_id': saved_content_id,
    'title': title,
    'thenote': thenote,
    'color': color!.value,
    'state': stateValue,
    'created_date': (created_date).millisecondsSinceEpoch,
    'modified_date': (modified_date!).millisecondsSinceEpoch,
  };

  /// Make a copy of this note.
  ///
  /// If [updateTimestamp] is `true`, the defaults is `false`,
  /// timestamps both of `created_date` & `modified_date` will be updated to `DateTime.now()`,
  /// or otherwise be identical with this note.
  NoteModel copy({bool updateTimestamp = false}) => NoteModel(
    note_id: note_id,
    created_date: (updateTimestamp) ? Jalali.now().toDateTime() : Jalali.fromDateTime(created_date).toDateTime(), page_id: '', state: NoteState.unspecified, title: '', color: null, error_description: '', status: '', thenote: '', saved_content_id: '', error_code: '', modified_date: null, user_id: '',
  )..update(this, updateTimestamp: updateTimestamp);

  @override
  bool operator ==(other) => other is NoteModel &&
    (other.note_id) == (note_id) &&
    (other.title) == (title) &&
    (other.thenote) == (thenote) &&
    other.stateValue == stateValue &&
    (other.color) == (color);

  @override
  int get hashCode => note_id.hashCode;
}

/// State enum for a note.
enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
}

/// Add properties/methods to [NoteState]
extension NoteStateX on NoteState {
  /// Checks if it's allowed to create a new note in this state.
  bool get canCreate => this <= NoteState.pinned;

  /// Checks if a note in this state can edit (modify / copy).
  bool get canEdit => this < NoteState.deleted;

  bool operator <(NoteState other) => (this.index) < (other.index);
  bool operator <=(NoteState other) => (this.index) <= (other.index);

  /// Message describes the state transition.
  String get message {
    switch (this) {
      case NoteState.archived:
        return 'یادداشت بایگانی شده است!';
      case NoteState.deleted:
        return 'یادداشت به سطل بازیافت منتقل شده است!';
      default:
        return '';
    }
  }

  /// Label of the result-set filtered via this state.
  String get filterName {
    switch (this) {
      case NoteState.archived:
        return 'بایگانی';
      case NoteState.deleted:
        return 'سطل بازیافت';
      default:
        return '';
    }
  }

  /// Short message explains an empty result-set filtered via this state.
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archived:
        return 'یادداشت آرشیو شده ندارید...';
      case NoteState.deleted:
        return 'سطل بازیافت خالی است!';
      default:
        return 'یادداشتی ندارید!(یادداشت ها فقط برای خودتان قابل مشاهده است.)';
    }
  }
}

