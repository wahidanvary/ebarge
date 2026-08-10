import 'package:ebarge/models/noteModel.dart';
import 'package:flutter/material.dart';

//import 'package:flt_keep/models.dart' show Note;

import 'note_item.dart';

/// Grid view of [Note]s.
class NotesGrid extends StatelessWidget {
  final List<NoteModel> notes;
  final void Function(NoteModel) onTap;

  const NotesGrid({
    Key? key,
    required this.notes,
    required this.onTap,
  }) : super(key: key);

  static NotesGrid create({
    Key? key,
    required List<NoteModel> notes,
    required void Function(NoteModel) onTap,
  }) => NotesGrid(
    key: key,
    notes: notes,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1 / 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => _noteItem(context, notes[index]),
        childCount: notes.length,
      ),
    ),
  );

  Widget _noteItem(BuildContext context, NoteModel note) => InkWell(
    onTap: () => onTap.call(note),
    child: NoteItem(note: note),
  );
}
