import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/noteModel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../styles.dart';
import 'GlobalKeys.dart';

/// An undoable action to a [Note].
@immutable
abstract class NoteCommand {
  final String note_id;
  final String page_id;

  /// Whether this command should dismiss the current screen.
  final bool dismiss;

  /// Defines an undoable action to a note, provides the note [id], and current user [uid].
  const NoteCommand({
    required this.note_id,
    required this.page_id,
    this.dismiss = false,
  });

  /// Returns `true` if this command is undoable.
  bool get isUndoable => true;

  /// Returns message about the result of the action.
  String get message => '';

  /// Executes this command.
  Future<void> execute();

  /// Undo this command.
  Future<void> revert();
}

/// A [NoteCommand] to update state of a [Note].
class NoteStateUpdateCommand extends NoteCommand {
  final NoteState from;
  final NoteState to;

  /// Create a [NoteCommand] to update state of a note [from] the current state [to] another.
  NoteStateUpdateCommand({
    required String note_id,
    required String page_id,
    required this.from,
    required this.to,
    bool dismiss = false,
  }) : super(note_id: note_id, page_id: page_id, dismiss: dismiss);

  @override
  String get message {
    switch (to) {
      case NoteState.deleted:
        return 'یادداشت به سطل بازیافت منتقل شد!';
      case NoteState.archived:
        return 'یادداشت بایگانی شد.';
      case NoteState.pinned:
        return from == NoteState.archived
            ? 'یادداشت بازیابی و سنجاق شد.' // pin an archived note
            : 'یادداشت سنجاق شد.';
      default:
        switch (from) {
          case NoteState.archived:
            return 'یادداشت از بایگانی خارج شد.';
          case NoteState.deleted:
            return 'یادداشت بازیابی شد.';
          case NoteState.pinned:
            return to == NoteState.unspecified
                ? 'یادداشت از سنجاق خارج شد.' // pin an archived note
                : '';
          default:
            return '';
        }
    }
  }

  @override
  Future<void> execute() => updateNoteState(to, note_id, page_id);

  @override
  Future<void> revert() => updateNoteState(from, note_id, page_id);
}

/// Mixin helps handle a [NoteCommand].
mixin CommandHandler<T extends StatefulWidget> on State<T> {
  /// Processes the given [command].
  Future<void> processNoteCommand(ScaffoldState scaffoldState, NoteCommand? command) async {
    if (command != null) {
      await command.execute();
      final msg = command.message;
      if (mounted && msg.isNotEmpty == true && command.isUndoable) {
        // ignore: deprecated_member_use
        Flushbar(
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
          mainButton: TextButton(
            onPressed: () {
              command.revert(); // result = true
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                "انصراف!",
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ),
          messageText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              msg,
              style: TextStyle(fontSize: 14.0, fontFamily: "Vazir", color: Colors.pink),
            ),
          ),
          duration:  Duration(seconds: 4),
        )..show(context);
        /*scaffoldState.showSnackBar(SnackBar(
          content: Text(msg),
          action: SnackBarAction(
            label: 'منصرف شدم!',
            onPressed: () => command.revert(),
          ),
        ));*/
      }
    }
  }
}

/// Add FireStore related methods to the [Note] model.
extension NoteStore on NoteModel {
  /// Save this note in FireStore.
  ///
  /// If this's a new note, a FireStore document will be created automatically.
  Future<dynamic> addUpdateNote(NoteModel noteData, String pageId) async {
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';
      var dio = Dio();
      FormData formData = new FormData.fromMap({
        "note_id": noteData.note_id,
        "page_id": pageId,
        "title": noteData.title,
        "thenote": noteData.thenote,
        "color": (noteData.color ?? kDefaultNoteColor).value,
        "state": (noteData.state).index,
        "action": "post",
        "module": "pages",
        "resource": "addupnote",
      });

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        //Successful
        // var loginJson = json.decode(utf8.decode(request.bytes()));
      } else {
        print("درخواست با خطا مواجه شد");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }


  /// Update this note to the given [state].
  Future<void> updateState(NoteState state, String pageId) async => note_id.isEmpty
      ? updateWith(state: state, title: '', saved_content_id: '', thenote: '', color: color as Color) // new note
      : updateNoteState(state, note_id, pageId);
}

/// Update a note to the [state], using information in the [command].
Future<bool> updateNoteState(NoteState state, String noteId, String pageId) async {
  try {
    var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';
    var dio = Dio();
    FormData formData = new FormData.fromMap({
      "note_id": noteId,
      "page_id": pageId,
      "state": state.index.toString(),
      "action": "post",
      "module": "pages",
      "resource": "addupnote",
    });

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage(appDocPath+"/.cookies/"));
    dio.interceptors.add(CookieManager(cookieJar));
    var response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      //Successful
      // var loginJson = json.decode(utf8.decode(request.bytes()));
    } else {
      print("درخواست با خطا مواجه شد");
      return false;
    }
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}