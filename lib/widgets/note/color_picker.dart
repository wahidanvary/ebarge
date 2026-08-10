import 'package:collection_ext/iterables.dart';
import 'package:ebarge/models/noteModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';

/// Note color picker in a horizontal list style.
class LinearColorPicker extends StatelessWidget {
  /// Returns color of the note, fallbacks to the default color.
  Color _currColor(NoteModel note) => note.color ?? kDefaultNoteColor;

  @override
  Widget build(BuildContext context) {
    NoteModel note = Provider.of<NoteModel>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kNoteColors.flatMapIndexed((i, color) => [
          if (i == 0) const SizedBox(width: 17),
          InkWell(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: kColorPickerBorderColor),
              ),
              child: color == _currColor(note) ? const Icon(Icons.check, color: kColorPickerBorderColor) : null,
            ),
            onTap: () {
              if (color != _currColor(note)) {
                note.updateWith(color: color, saved_content_id: '', thenote: '', state: NoteState.unspecified, title: '');
              }
            },
          ),
          SizedBox(width: i == kNoteColors.length - 1 ? 17 : 20),
        ]).asList(),
      ),
    );
  }
}
