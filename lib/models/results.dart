import 'package:flutter/material.dart';

void showErrors(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('خطای بارگذاری'),
          content: Text('لطفا قبل از ارسال فرم تمام فیلدهای ضروری بررسی گردد!'),
          actions: <Widget>[
            TextButton(
              child: Text("خروج"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

/*Widget _buildResultsRow(String name, dynamic value, {bool linebreak: false}) {
  return Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildValueInline(value, linebreak),
        ],
      ),
      _buildValueOnOwnRow(value, linebreak),
      Container(height: 12.0),
    ],
  );
}

Widget _buildValueInline(dynamic value, bool linebreak) {
  return (linebreak) ? Container() : Text(value.toString());
}

Widget _buildValueOnOwnRow(dynamic value, bool linebreak) {
  return (linebreak) ? Text(value.toString()) : Container();
}*/
