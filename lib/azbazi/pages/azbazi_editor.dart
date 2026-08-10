
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../models/azbaziModel.dart';
import '../../models/bookModel.dart';
import 'addAzbaziForm.dart';

class AzbaziEditor extends StatefulWidget {
  const AzbaziEditor({Key? key, required this.azbazi, required this.book}) : super(key: key);
  final azbaziModel azbazi;
  final bookModel book;

  @override
  _AzbaziEditorState createState() => _AzbaziEditorState(azbazi);
}

class _AzbaziEditorState extends State<AzbaziEditor> {
  _AzbaziEditorState(this.azbazi);
  final azbaziModel azbazi;

  bool _showMaterialOnIOS = true;

  final GlobalKey<ScaffoldState> _azbaziScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<addAzbaziFormState> _azbaziFormWidgetKey =
  GlobalKey<addAzbaziFormState>();

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery
        .of(context)
        .orientation;
    final form = addAzbaziForm(orientation, _showMaterialOnIOS, _azbaziScaffoldKey,
        key: _azbaziFormWidgetKey, onValueChanged: showSnackBar, azbazi: azbazi, book: widget.book,);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _azbaziScaffoldKey,
        backgroundColor: Theme
            .of(context)
            .colorScheme.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("ثبت درخواست طراحی آزبازی", style: TextStyle(fontFamily: "Vazir", fontSize: 17),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: (_azbaziFormWidgetKey.currentState == null)
                  ? null
                  : _azbaziFormWidgetKey.currentState!.savePressed,
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (_azbaziFormWidgetKey.currentState == null)
                ? null
                : _azbaziFormWidgetKey.currentState!.resetPressed,
          ),
        ),
        body: form,
      ),
    );
  }

  void showSnackBar(String label, dynamic value) {
    Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
      messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(label + ' = ' + value.toString(),
            style: TextStyle(fontSize: 14.0, color: Colors.purpleAccent, fontFamily: "Vazir"),
          )
      ),
      duration:  Duration(seconds: 2),
    )..show(context);
  }

}

