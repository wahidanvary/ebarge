import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/screens/books/myBooks.dart';
import 'package:ebarge/services/progressLoading.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:timer_button/timer_button.dart';

class ConfirmOTP extends StatefulWidget {
  const ConfirmOTP({Key? key, required this.user, required this.isOldUser}) : super(key: key);
  final UserModel user;
  final bool isOldUser;

  @override
  _ConfirmOTPState createState() => _ConfirmOTPState(user);
}

class _ConfirmOTPState extends State<ConfirmOTP> {
  _ConfirmOTPState(this.user);
  final UserModel user;

  String text = '';
  bool _firstPress = true;
  bool activeTimerBtn = true;
  int timer = 3;

  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
        child: Center(child: Text(text[position], style: const TextStyle(color: Colors.black),)),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
      );
    }
  }

  Future validateOtpAndLogin(BuildContext context, String code)async {
    UserProvider userProvider = UserProvider.instance();

    UserModel _userConfirm;
    try {
      if (_firstPress && text.length == 5) {
        _firstPress = false;

        ProgressBuilder(context).showLoadingIndicator('صبر کنید');
        _userConfirm = (await userProvider.signUpConfirm(code, user))!;
        ProgressBuilder(context).hideOpenDialog();

        if (_userConfirm.status == "ok") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) =>
                  MyBooks(_userConfirm)),
                  (Route<dynamic> route) => false
          );
        } else {
          _firstPress = true;
          Flushbar(
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            backgroundGradient: LinearGradient(
                colors: [Colors.white70, Colors.black12]),
            messageText: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                _userConfirm.error_description!,
                style: TextStyle(fontSize: 16.0,
                    color: Colors.redAccent,
                    fontFamily: "Vazir"),
              ),
            ),
            duration: Duration(seconds: 4),
          )
            ..show(context);
        }
      } else {
        Flushbar(
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          backgroundGradient: LinearGradient(
              colors: [Colors.white70, Colors.black12]),
          messageText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              "5 رقم را کامل پر نمایید!",
              style: TextStyle(fontSize: 16.0,
                  color: Colors.cyanAccent,
                  fontFamily: "Vazir"),
            ),
          ),
          duration: Duration(seconds: 4),
        )
          ..show(context);
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  Future sendCodeAgain() async {
    UserProvider userProvider = UserProvider.instance();
    var signUpResult;
    try {
      signUpResult = await userProvider.signUpUser(user);
      if (signUpResult["status"] != "ok") {
        Flushbar(
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          backgroundGradient: LinearGradient(
              colors: [Colors.white70, Colors.black12]),
          messageText: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              signUpResult["error_description"],
              style: TextStyle(fontSize: 16.0,
                  color: Colors.cyanAccent,
                  fontFamily: "Vazir"),
            ),
          ),
          duration: Duration(seconds: 4),
        )
          ..show(context);
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Colors.black12,
            ),
            child: const Icon(Icons.arrow_back_ios, color: Colors.indigo, size: 16,),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.white, systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          widget.isOldUser ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("شما قبلاً با این شماره با نام کاربری ( ${user.username!} ) عضو شده اید در صورت تائید وارد کاربری قبلی خواهید شد...", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w500))
                          ) : Container(),
                          Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text('کد 5رقمی ارسالی به تلفن همراه خود را وارد نمایید...', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))
                          ),
                          Container(
                            constraints: const BoxConstraints(
                                maxWidth: 300
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  otpNumberWidget(0),
                                  otpNumberWidget(1),
                                  otpNumberWidget(2),
                                  otpNumberWidget(3),
                                  otpNumberWidget(4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    activeTimerBtn ? new TimerButton(
                      label: "ارسال مجدد کد فرصت: " + timer.toString()+"بار",
                      timeOutInSeconds: 120,
                      onPressed: () {
                        sendCodeAgain();
                        setState(() {
                          timer--;
                          if(timer == 0) activeTimerBtn = false;
                        });
                      },
                      buttonType: ButtonType.outlinedButton,
                    ) : Container(),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      constraints: const BoxConstraints(
                          maxWidth: 500
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          validateOtpAndLogin(context, text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[800],
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(14))
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text('تائید', style: TextStyle(color: Colors.white, fontSize: 18),),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Colors.black26,
                                ),
                                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16,),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: NumericKeyboard(
                        onKeyboardTap: _onKeyboardTap,
                        textColor: Colors.indigo[900]!,
                        rightIcon: const Icon(
                          Icons.backspace,
                          color: Colors.black,
                        ),
                        rightButtonFn: () {
                          setState(() {
                            text = text.substring(0, text.length - 1);
                          });
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoaderHUD extends StatelessWidget {
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Widget progressIndicator = Container(
    width: 200,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      color: Colors.limeAccent,
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
  final bool dismissible;
  final Widget child;

  LoaderHUD({
    Key? key,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.dismissible = false,
    required this.child,
  })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!inAsyncCall) return child;

    return Stack(
      children: [
        child,
        Opacity(
          child: ModalBarrier(dismissible: dismissible, color: color),
          opacity: opacity,
        ),
        Center(child: progressIndicator),
      ],
    );
  }
}