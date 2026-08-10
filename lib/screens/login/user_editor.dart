
import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/screens/login/signUpForm.dart';
import 'package:flutter/material.dart';

class UserEditor extends StatefulWidget {
  const UserEditor({Key? key, required this.user, required this.isChangePass}) : super(key: key);
  final UserModel user;
  final bool isChangePass;

  @override
  _UserEditorState createState() => _UserEditorState(user);
}

class _UserEditorState extends State<UserEditor> {
  _UserEditorState(this.user);
  final UserModel user;

  bool _showMaterialOnIOS = true;

  final GlobalKey<ScaffoldState> _userScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SignUpFormState> _userFormWidgetKey =
  GlobalKey<SignUpFormState>();

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery
        .of(context)
        .orientation;
    final form = SignUpForm(orientation, _showMaterialOnIOS, _userScaffoldKey,
        key: _userFormWidgetKey, onValueChanged: showSnackBar, user: user, isChangePass: widget.isChangePass,);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _userScaffoldKey,
        backgroundColor: Theme
            .of(context)
            .colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("عضویت در ایبرگه", style: TextStyle(fontFamily: "Vazir", fontSize: 17),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: (_userFormWidgetKey.currentState == null)
                  ? null
                  : _userFormWidgetKey.currentState!.continuePressed,
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (_userFormWidgetKey.currentState == null)
                ? null
                : _userFormWidgetKey.currentState!.resetPressed,
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

