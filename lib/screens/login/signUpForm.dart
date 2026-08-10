/**/
import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:card_settings/card_settings.dart';
import 'package:card_settings/widgets/text_fields/card_settings_text.dart';
import 'package:ebarge/models/results.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/services/progressLoading.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/GlobalKeys.dart';
import 'confirmOtp.dart';


typedef LabelledValueChanged<T, U> = void Function(T label, U value);

class SignUpForm extends StatefulWidget {
  const SignUpForm(
    this.orientation,
    this.showMaterialOnIOS,
    this.scaffoldKey, {
    required this.onValueChanged,
    Key? key, required this.user,
        required this.isChangePass,
  }) : super(key: key);

  final Orientation orientation;
  final bool showMaterialOnIOS;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final UserModel user;
  final bool isChangePass;

  final LabelledValueChanged<String, dynamic> onValueChanged;

  @override
  SignUpFormState createState() => SignUpFormState(user);
}

class SignUpFormState extends State<SignUpForm> {
  SignUpFormState(this.user);

  UserModel user;

  int firstPageInclude = 0;
  int lastPageInclude = 0;
  String pagesInclude = "";

  bool loaded = false;
  File? rawVideoFile;

  @override
  void initState() {
    super.initState();

    user = UserModel();
    initModel();
  }

  void initModel() async {
    setState(() => loaded = true);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  // keys for fields
  // this is desirable because the fields may change order, in this example
  // when the screen is rotated, and this will preserve what state is
  // attached to what field.
  final GlobalKey<FormState> _phoneNumberKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _familyKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _userNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _password2Key = GlobalKey<FormState>();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _familyNode = FocusNode();
  final FocusNode _userNameNode = FocusNode();

  final thumbWidth = 320;
  final thumbHeight = 180;
  bool _processing = false;
  String _processPhase = '';
  double _progress = 0.0;
  bool _firstPress = true;

  @override
  Widget build(BuildContext context) {
    if (!_processing) {
      if (loaded) {
        return Form(
            key: _formKey,
            child: (widget.orientation == Orientation.portrait)
                ? _buildPortraitLayout()
                : _buildLandscapeLayout(),
          );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    } else {
      return Center(child: _getProgressBar());
    }
  }

  _getProgressBar() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Text(_processPhase),
          ),
          LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  CardSettings _buildPortraitLayout() {
    return CardSettings.sectioned(
      showMaterialonIOS: widget.showMaterialOnIOS,
      labelWidth: 100,
      contentAlign: TextAlign.right,
      cardless: false,
      children: <CardSettingsSection>[
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'شماره تلفن همراه',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          instructions: _buildCardSettingsInstructions(),
          children: <CardSettingsWidget>[
            _buildCardSettingsInt_PhoneNumber(),
          ],
        ),
        if (!widget.isChangePass) CardSettingsSection(
          header: CardSettingsHeader(
            label: 'اطلاعات کاربری',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsText_Name(),
            _buildCardSettingsText_Family(),
            _buildCardSettingsText_UserName(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'رمز عبور',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          divider: Divider(thickness: 1.0, color: Colors.purple),
          children: <CardSettingsWidget>[
            _buildCardSettingsPassword(),
            _buildCardSettingsPassword2(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'عملیات',
            labelAlign: TextAlign.right,
            color: Colors.black26,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsButton_Save(),
            //_buildCardSettingsButton_Reset(),
          ],
        ),
      ],
    );
  }

  CardSettings _buildLandscapeLayout() {
    return CardSettings.sectioned(
      showMaterialonIOS: widget.showMaterialOnIOS,
      labelPadding: 12.0,
      children: <CardSettingsSection>[
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'شماره تلفن همراه',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          instructions: _buildCardSettingsInstructions(),
          children: <CardSettingsWidget>[
            _buildCardSettingsInt_PhoneNumber(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'اطلاعات کاربری',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          instructions: _buildCardSettingsInstructions(),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsText_Name(),
              _buildCardSettingsText_Family(),
              _buildCardSettingsText_UserName(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'مالکیت',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsPassword(),
              _buildCardSettingsPassword2(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'عملیات',
            labelAlign: TextAlign.right,
            color: Colors.black26,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsButton_Save(),
              //_buildCardSettingsButton_Reset(),
            ]),
          ],
        ),
      ],
    );
  }


  CardSettingsInstructions _buildCardSettingsInstructions() {
    return CardSettingsInstructions(
      text: 'به منظور فعالسازی کاربری',
    );
  }

 CardSettingsInt _buildCardSettingsInt_PhoneNumber() {
    return CardSettingsInt(
      key: _phoneNumberKey,
      label: 'تلفن همراه',
      hintText: 'مثل: 09123456789',
      labelWidth: 130,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      icon: new Icon(Icons.phone_iphone, color: Colors.black,),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: 11,
      validator: (value) {
        if (value == null) return 'تلفن همراه ضروری است!';
        if (value.toString().length < 10) return 'شماره تلفن بایستی 11رقمی باشد!';
        return null;
      },
      onSaved: (value) => user.tell_mobile = value.toString(),
      onChanged: (value) {
        setState(() {
          user.tell_mobile = value.toString();
        });
      },
        autofocus: true,
      style: TextStyle(color: Colors.blueGrey, fontSize: 1, fontFamily: "Vazir"),
    );
  }


 /*  CardSettingsPhone _buildCardSettingsInt_PhoneNumber() {
    return CardSettingsPhone(
      key: _phoneNumberKey,
      label: 'تلفن همراه',
      //initialValue: _ponyModel.boxOfficePhone,
      maxLength: 11,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      icon: new Icon(Icons.phone_iphone, color: Colors.black,),
      autovalidate: _autoValidate,
      validator: (value) {
        if (value == null) return 'تلفن همراه ضروری است!';
        if (value.toString().length < 10) return 'شماره تلفن بایستی 11رقمی باشد!';
        return null;
      },
      onSaved: (value) => user.mobile = value.toString(),
      onChanged: (value) {
        setState(() {
          user.mobile = value.toString();
        });
      },
    );
  }
  */

  CardSettingsText _buildCardSettingsText_Name() {
    return CardSettingsText(
      key: _nameKey,
      label: 'نام',
      hintText: '_____',
      labelWidth: 120,
      maxLength: 40,
      initialValue: user.name != null
          ? user.name
          : null,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _nameNode,
      inputAction: TextInputAction.next,
      inputActionNode: _nameNode,
      validator: (value) {
        if (value!.isEmpty && !widget.isChangePass) return 'نام ضروری است!';
        return null;
      },
      onSaved: (value) => user.name = value!,
      onChanged: (value) {
        setState(() {
          user.name = value;
        });
      },
    );
  }

  CardSettingsText _buildCardSettingsText_Family() {
    return CardSettingsText(
      key: _familyKey,
      label: 'نام خانوادگی',
      hintText: '_____',
      labelWidth: 120,
      maxLength: 40,
      initialValue: user.family != null
          ? user.family
          : null,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _familyNode,
      inputAction: TextInputAction.next,
      inputActionNode: _familyNode,
      validator: (value) {
        if ((value == null || value.isEmpty) && !widget.isChangePass) return 'نام خانوادگی ضروری است!';
        return null;
      },
      onSaved: (value) => user.family = value!,
      onChanged: (value) {
        setState(() {
          user.family = value;
        });
      },
    );
  }

  CardSettingsText _buildCardSettingsText_UserName() {
    return CardSettingsText(
      key: _userNameKey,
      label: 'نام کاربری',
      labelWidth: 130,
      hintText: 'با دقت وارد کنید...',
      maxLength: 40,
      icon: new Icon(Icons.account_box, color: Colors.black,),
      initialValue: user.username != null
          ? user.username
          : null,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _userNameNode,
      inputAction: TextInputAction.next,
      inputActionNode: _userNameNode,
      validator: (value) {
        if(!widget.isChangePass){
          if(value == null || value.isEmpty) return 'نام کاربری ضروری است!';
          if(value.length < 5)  return 'حداقل 5 حرف نیاز است!';
        }
        return null;
      },
      onSaved: (value) {
        user.username = value!;
      },
      onChanged: (value) {
        setState(() {
          user.username = value;
        });
      },
    );
  }

  CardSettingsPassword _buildCardSettingsPassword() {
    return CardSettingsPassword(
      key: _passwordKey,
      icon: Icon(Icons.lock),
      label: 'رمز عبور',
      hintText: '_____',
      labelWidth: 120,
      initialValue: user.password != null
          ? user.password
          : null,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null) return 'رمز عبور ضروری است!';
        if (value.length < 8) return 'حداقل طول رمز ۸کاراکتر مجاز است!';
        if(!isPasswordCompliant(value)) return 'حداقل 1حرف و حداقل 1رقم نیاز است!';
        return null;
      },
      onSaved: (value) => user.password = value!,
      onChanged: (value) {
        setState(() {
          user.password = value;
        });
      },
    );
  }

  CardSettingsPassword _buildCardSettingsPassword2() {
    String password2;
    return CardSettingsPassword(
      key: _password2Key,
      icon: Icon(Icons.lock),
      label: 'تکرار رمز',
      hintText: '_____',
      labelWidth: 120,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value != user.password) return 'رمز عبور مطابقت ندارد!';
        return null;
      },
      onSaved: (value) => password2 = value!,
      onChanged: (value) {
        setState(() {
          password2 = value;
        });
      },
    );
  }

  bool isPasswordCompliant(String password) {
    bool isComplient = false;
    bool hasUppercase  = false;
    bool hasDigits = false;
    bool hasLowercase = false;
   // bool hasSpecialCharacters = false;
    var character='';
    var i=0;
    print(password);
    if (password.isNotEmpty) {
      // Check if valid special characters are present
      //hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      while (i < password.length){
        character = password.substring(i,i+1);
        //print(character);

        if (isDigit(character , 0)){
          hasDigits=true;
        }else{
          if (character == character.toUpperCase()) {
            hasUppercase=true;
          }
          if (character == character.toLowerCase()){
            hasLowercase=true;
          }
        }
        i++;
      }
    }
    isComplient = hasDigits & (hasUppercase || hasLowercase);
    return isComplient;
  }

  bool isDigit(String s, int idx) =>
      "0".compareTo(s[idx]) <= 0 && "9".compareTo(s[idx]) >= 0;


  // ignore: non_constant_identifier_names
  CardSettingsButton _buildCardSettingsButton_Save() {
    return CardSettingsButton(
      label: 'ادامه',
      textColor: Colors.white,
      backgroundColor: Colors.indigo[800],
      onPressed: continuePressed,
    );
  }

  // ignore: non_constant_identifier_names
 /* CardSettingsButton _buildCardSettingsButton_Reset() {
    return CardSettingsButton(
      label: 'بازیابی',
      isDestructive: true,
      onPressed: resetPressed,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      bottomSpacing: 4.0,
    );
  }*/


  Future continuePressed() async {
    if(await GlobalKeys.checkInternetConnection()) {
      UserProvider userProvider = UserProvider.instance();
      final form = _formKey.currentState;

      var signUpResult;
      try {
        if (form!.validate() && _firstPress) {
          _firstPress = false;
          form.save();

          ProgressBuilder(context).showLoadingIndicator('صبر کنید');
          signUpResult = await userProvider.signUpUser(user);
          ProgressBuilder(context).hideOpenDialog();
          if (signUpResult != null && signUpResult["status"] == "ok") {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  bool isOldUser = false;
                  if(signUpResult["username"] != null){
                    user.username = signUpResult["username"];
                    isOldUser = true;
                  }
                  return ConfirmOTP(user: user, isOldUser: isOldUser,);
                },
              ),
            );
          } else {
            _firstPress = true;
            String errorMessage = "";
            if( signUpResult == null )
              errorMessage = "پیغامی از سمت سرور دریافت نشد!";
            else
              errorMessage = signUpResult["error_description"];
            Flushbar(
              margin: EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(8),
              backgroundGradient: LinearGradient(
                  colors: [Colors.white70, Colors.black12]),
              messageText: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  errorMessage,
                  style: TextStyle(fontSize: 16.0,
                      color: Colors.purple,
                      fontFamily: "Vazir"),
                ),
              ),
              duration: Duration(seconds: 4),
            )
              ..show(context);
          }
        } else {
          showErrors(context);
          setState(() => _autoValidate = true);
        }
      } catch (e) {
        print('${e.toString()}');
      }
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
            "ارتباط اینترنتی قطع می باشد!",
            style: TextStyle(fontSize: 16.0,
                color: Colors.purple,
                fontFamily: "Vazir"),
          ),
        ),
        duration: Duration(seconds: 4),
      )
        ..show(context);
    }
  }

  void resetPressed() {
    setState(() => loaded = false);

    initModel();

    _formKey.currentState!.reset();
  }

  String getFileExtension(String fileName) {
    final exploded = fileName.split('.');
    return exploded[exploded.length - 1];
  }
}
