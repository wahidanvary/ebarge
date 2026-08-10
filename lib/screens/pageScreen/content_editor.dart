
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/screens/pageScreen/contentForm.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContentEditor extends StatefulWidget {
  const ContentEditor({Key? key, required this.content, required this.pageData, required this.book, required this.pageNumToId}) : super(key: key);
  final contentModel content;
  final pageModel pageData;
  final bookModel book;
  final List<dynamic> pageNumToId;
  @override
  _ContentEditorState createState() => _ContentEditorState(content, pageData, book, pageNumToId);
}

class _ContentEditorState extends State<ContentEditor> {
  _ContentEditorState(this.content, this.pageData, this.book, this.pageNumToId);
  final contentModel content;
  final pageModel pageData;
  final bookModel book;
  final List<dynamic> pageNumToId;

  bool _showMaterialonIOS = true;

  GlobalKey<ScaffoldState> _contentScaffoldKey = GlobalKey<ScaffoldState>();
 // GlobalKey<ContentFormState> _formWidgetKey =
 // GlobalKey<ContentFormState>();

  void didChangeDependencies() async {
    super.didChangeDependencies();
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
   // final form = ContentForm(orientation, _showMaterialonIOS, _contentScaffoldKey,
   //     key: _formWidgetKey, onValueChanged: showSnackBar, content: content, pageData: pageData, book: book, pageNumToId: pageNumToId);

    return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                key: _contentScaffoldKey,
                backgroundColor: Theme.of(context).canvasColor,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: Text("محتوا برای صفحه "+AccessCheck().replaceFarsiNumber(pageData.real_page_num), style: TextStyle(fontFamily: "Vazir", fontSize: 17),),
                  actions: <Widget>[
                    _cupertinoSwitchButton(),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed:(){}
                      //(_formWidgetKey.currentState == null)
                         // ? null
                        //  : _formWidgetKey.currentState!.savePressed,
                    ),
                  ],
                  leading: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed:(){}
                    //(_formWidgetKey.currentState == null)
                     //   ? null
                   //     : _formWidgetKey.currentState!.resetPressed,
                  ),
                ),
                //body: form,
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

  Widget _cupertinoSwitchButton() {
    // dont show this button on web
    if (kIsWeb) return Container();

    return Container(
      child: Platform.isIOS
          ? IconButton(
        icon: (_showMaterialonIOS)
            ? FaIcon(FontAwesomeIcons.apple)
            : Icon(Icons.android),
        onPressed: () {
          setState(() {
            _showMaterialonIOS = !_showMaterialonIOS;
          });
        },
      )
          : null,
    );
  }
}