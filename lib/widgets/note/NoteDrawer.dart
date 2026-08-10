import 'package:ebarge/models/filter.dart';
import 'package:ebarge/models/noteModel.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';
import 'drawer_filter.dart';

/// Navigation drawer for the app.
class NoteDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<NoteFilter>(
    builder: (context, filter, _) => Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _drawerHeader(context),
          if (isNotIOS) const SizedBox(height: 25),
          DrawerFilterItem(
            icon: Icons.speaker_notes,
            title: 'یادداشتها',
            isChecked: filter.noteState == NoteState.unspecified,
            onTap: () {
              filter.noteState = NoteState.unspecified;
              Navigator.pop(context);
            },
          ),
//        DrawerFilterItem(
//          icon: AppIcons.notifications,
//          title: 'Reminders',
//        ),
          const Divider(),
          DrawerFilterItem(
            icon: Icons.archive,
            title: 'بایگانی',
            isChecked: filter.noteState == NoteState.archived,
            onTap: () {
              filter.noteState = NoteState.archived;
              Navigator.pop(context);
            },
          ),
          DrawerFilterItem(
            icon: Icons.delete_outline,
            title: 'سطل بازیافت',
            isChecked: filter.noteState == NoteState.deleted,
            onTap: () {
              filter.noteState = NoteState.deleted;
              Navigator.pop(context);
            },
          ),
          const Divider(),
         /* DrawerFilterItem(
            icon: Icons.settings_applications,
            title: 'تنظیمات',
            onTap: () {
              Navigator.popAndPushNamed(context, '/settings');
            },
          ),
          DrawerFilterItem(
            icon: Icons.help_outline,
            title: 'درباره',
            onTap: (){} // =>launch('https://github.com/xinthink/flutter-keep'),
          ),*/
        ],
      ),
    ),
  );

  Widget _drawerHeader(BuildContext context) => SafeArea(
    child: Container(
      padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: kHintTextColorLight,
            fontSize: 26,
            fontWeight: FontWeights.light,
            letterSpacing: -2.5,
          ),
          children: [
            const TextSpan(
              text: "مدیریت یادداشت ها",
              style: TextStyle(
                color: kAccentColorLight,
                fontWeight: FontWeights.medium,
                fontStyle: FontStyle.italic,
                fontSize: 22
              ),
            ),
            //const TextSpan(text: ' Keep'),
          ],
        ),
      ),
    ),
  );
}
