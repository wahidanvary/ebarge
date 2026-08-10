import 'package:ebarge/models/noteModel.dart';
import 'package:ebarge/services/notes_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provide actions for a single [Note], used in a [BottomSheet].
class NoteActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final note = Provider.of<NoteModel>(context);
    final state = note.state;
    final note_id = note.note_id;
    final page_id = note.page_id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note_id.isNotEmpty && state < NoteState.archived) ListTile(
          leading: const Icon(Icons.archive),
          title: Text('بایگانی', style: TextStyle(fontFamily: "Vazir",)),
          onTap: ()=> Navigator.pop(context, NoteStateUpdateCommand(
            note_id: note_id,
            page_id: page_id,
            from: state,
            to: NoteState.archived,
            dismiss: true,
          )),
        ),
        if (state == NoteState.archived) ListTile(
          leading: const Icon(Icons.unarchive),
          title: Text('خروج از بایگانی', style: TextStyle(fontFamily: "Vazir",)),
          onTap: ()=> Navigator.pop(context, NoteStateUpdateCommand(
            note_id: note_id,
            page_id: page_id,
            from: state,
            to: NoteState.unspecified,
          )),
        ),
        if (state != NoteState.deleted) ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text('حذف', style: TextStyle(fontFamily: "Vazir",)),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            note_id: note_id,
            page_id: page_id,
            from: state,
            to: NoteState.deleted,
            dismiss: true,
          )),
        ),
//        if (id != null) ListTile(
//          leading: const Icon(AppIcons.copy),
//          title: Text('Make a copy', style: textStyle),
//        ),
        if (state == NoteState.deleted) ListTile(
          leading: const Icon(Icons.restore),
          title: Text('بازیابی', style: TextStyle(fontFamily: "Vazir",)),
          onTap: () => Navigator.pop(context, NoteStateUpdateCommand(
            note_id: note_id,
            page_id: page_id,
            from: state,
            to: NoteState.unspecified,
          )),
        ),
      ],
    );
  }
}
