import 'dart:async';

import 'package:ebarge/models/noteModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/noteScreen.dart';
import 'package:ebarge/services/notes_service.dart';
import 'package:ebarge/widgets/note/color_picker.dart';
import 'package:ebarge/widgets/note/note_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../styles.dart';

/// The editor of a [Note], also shows every detail about a single note.
class NoteEditor extends StatefulWidget {
  /// Create a [NoteEditor],
  /// provides an existed [note] in edit mode, or `null` to create a new one.
  const NoteEditor({Key? key, required this.note, required this.pageData}) : super(key: key);

  final NoteModel note;
  final pageModel pageData;

  @override
  State<StatefulWidget> createState() => _NoteEditorState(note, pageData);
}


/// [State] of [NoteEditor].
class _NoteEditorState extends State<NoteEditor> with CommandHandler {
  /// Create a state for [NoteEditor], with an optional [note] being edited,
  /// otherwise a new one will be created.
  _NoteEditorState(NoteModel note, this.pageData)
    : this._note = note,
    _originNote = note.copy(),
    this._titleTextController = TextEditingController(text: note.title),
    this._thenoteTextController = TextEditingController(text: note.thenote);

  /// The note in editing
  final NoteModel _note;
  final pageModel pageData;
  /// The origin copy before editing
  final NoteModel _originNote;
  Color? get _noteColor => _note.color;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<NoteModel>? _noteSubscription;
  final TextEditingController _titleTextController;
  final TextEditingController _thenoteTextController;

  /// If the note is modified.
  bool get _isDirty => _note != _originNote;

  @override
  void initState() {
    super.initState();
    _titleTextController.addListener(() => _note.title = _titleTextController.text);
    _thenoteTextController.addListener(() => _note.thenote = _thenoteTextController.text);
  }

  @override
  void dispose() {
    _noteSubscription?.cancel();
    _titleTextController.dispose();
    _thenoteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final userId = page_id;//Provider.of<UserProvider>(context).data.uid;
    //_watchNoteDocument(page_id);
    return ChangeNotifierProvider(
      create: (_) => _note,
      child: Consumer<NoteModel>(
        builder: (_, __, ___) => Hero(
          tag: 'یادداشت${_note.note_id}',
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: _noteColor,
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: 0,
              ),
              scaffoldBackgroundColor: _noteColor, bottomAppBarTheme: BottomAppBarThemeData(color: _noteColor),
            ),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: _noteColor,
                systemNavigationBarColor: _noteColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  actions: _buildTopActions(context, pageData.page_id),
                  leading: IconButton(
                    icon: Icon(Icons.check, color: Colors.black),
                    onPressed: () {
                      _buildBody(context, pageData.page_id);
                      _onPop(pageData.page_id);
                    }
                  ),
                  bottom: const PreferredSize(
                    preferredSize: Size(0, 24),
                    child: SizedBox(),
                  ),
                ),
                body: _buildBody(context, pageData.page_id),
                bottomNavigationBar: _buildBottomAppBar(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String page_id) => Directionality(
    textDirection: TextDirection.rtl,
    child: DefaultTextStyle(
      style: kNoteTextLargeLight,
      child: PopScope(
        canPop: false,
        onPopInvoked : (didPop){
          _onPop(page_id)!;
        },
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: _buildNoteDetail(),
          ),
        ),
      ),
    ),
  );

  Widget _buildNoteDetail() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      TextField(
        controller: _titleTextController,
        style: kNoteTitleLight,
        decoration: const InputDecoration(
          hintText: 'عنوان',
          border: InputBorder.none,
          counter: const SizedBox(),
        ),
        maxLines: null,
        maxLength: 1024,
        textCapitalization: TextCapitalization.sentences,
        readOnly: !_note.state.canEdit,
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _thenoteTextController,
        style: kNoteTextLargeLight,
        decoration: const InputDecoration.collapsed(hintText: 'یادداشت'),
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        readOnly: !_note.state.canEdit,
      ),
    ],
  );

  List<Widget> _buildTopActions(BuildContext context, String page_id) => [
    if (_note.state != NoteState.deleted) IconButton(
        icon: Icon(_note.pinned == true ? Icons.local_offer : Icons.comment, color: Colors.black,),
        tooltip: _note.pinned == true ? 'عادی' : 'سنجاق',
        onPressed: () => _updateNoteState(page_id, _note.pinned ? NoteState.unspecified : NoteState.pinned),
    ),
    if (_note.state < NoteState.archived) IconButton(
      icon: const Icon(Icons.archive, color: Colors.black,),
      tooltip: 'بایگانی',
      onPressed: () => Navigator.pop(context, NoteStateUpdateCommand(
        note_id: _note.note_id,
        page_id: page_id,
        from: _note.state,
        to: NoteState.archived,
      ))
    ),
    if (_note.state == NoteState.archived) IconButton(
      icon: const Icon(Icons.unarchive, color: Colors.black,),
      tooltip: 'خروج از بایگانی',
      onPressed: () => _updateNoteState(page_id, NoteState.unspecified),
    ),
  ];

  Widget _buildBottomAppBar(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BottomAppBar(
      child: Container(
        height: kBottomBarSize,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Text('ویرایش شده ${_note.strLastModified}'),
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: kIconTintLight,
              onPressed: () => _showNoteBottomSheet(context),
            ),
          ],
        ),
      ),
    ),
  );

  void _showNoteBottomSheet(BuildContext context) async {
    final command = await showModalBottomSheet<NoteCommand>(
      context: context,
      backgroundColor: _noteColor,
      builder: (context) => ChangeNotifierProvider.value(
        value: _note,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Consumer<NoteModel>(
            builder: (_, note, __) => Container(
              color: note.color,
              padding: const EdgeInsets.symmetric(vertical: 19),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  NoteActions(),
                  if (_note.state.canEdit) const SizedBox(height: 16),
                  if (_note.state.canEdit) LinearColorPicker(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (command != null) {
      if (command.dismiss) {
        Navigator.pop(context, command);
      } else {
        processNoteCommand(_scaffoldKey.currentState!, command);
      }
    }
  }

  /// Callback before the user leave the editor.
  Future<bool>? _onPop(String pageId) {
    if (_isDirty && ( _note.isNotEmpty)) {
      _note
        ..modified_date = Jalali.now().toDateTime()
        ..addUpdateNote(_note, pageId);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NoteScreen(pageData),
      ),
    );
    return null;
  }

  /// Callback when the FireStore copy of this note updated.
  /*void _onCloudNoteUpdated(NoteModel note) {
    if (!mounted || note?.isNotEmpty != true || _note == note) {
      return;
    }

    final refresh = () {
      _titleTextController.text = _note.title ?? '';
      _thenoteTextController.text = _note.thenote ?? '';
      _originNote.update(note, updateTimestamp: false);
      _note.update(note, updateTimestamp: false);
    };

    if (_isDirty) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: const Text('یادداشت داخل ابر بروزرسانی شد.'),
        action: SnackBarAction(
          label: 'بازیابی',
          onPressed: refresh,
        ),
        duration: const Duration(days: 1),
      ));
    } else {
      refresh();
    }
  }*/

  /// Update this note to the given [state]
  void _updateNoteState(page_id, NoteState state) {
    Color? _color;
    // new note, update locally
    if (_note.note_id.isEmpty) {
      _note.updateWith(state: state, title: '', saved_content_id: '', color: _color!, thenote: '');
      return;
    }

    // otherwise, handles it in a undoable manner
    processNoteCommand(_scaffoldKey.currentState!, NoteStateUpdateCommand(
      note_id: _note.note_id,
      page_id: page_id,
      from: _note.state,
      to: state,
    ));
  }
}
