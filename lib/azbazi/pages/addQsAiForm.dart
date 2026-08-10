
import 'dart:async';
import 'dart:io';

import 'package:card_settings/card_settings.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/aiQsModel.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/results.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/providers/userProvider.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/bookModel.dart';
import '../../services/GlobalKeys.dart';
import '../oneAzbaziProfileSc.dart';

typedef LabelledValueChanged<T, U> = void Function(T label, U value);

class addQsAiForm extends StatefulWidget {
  const addQsAiForm(
      this.orientation,
      this.showMaterialOnIOS,
      this.scaffoldKey, {
        required this.onValueChanged,
        Key? key, required this.azbazi,
        required this.book,
      }) : super(key: key);

  final Orientation orientation;
  final bool showMaterialOnIOS;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final azbaziModel azbazi;
  final bookModel book;

  final LabelledValueChanged<String, dynamic> onValueChanged;

  @override
  addQsAiFormState createState() => addQsAiFormState(azbazi);
}

class addQsAiFormState extends State<addQsAiForm> {
  addQsAiFormState(this.azbazi);

  azbaziModel azbazi;

  int firstPageInclude = 0;
  int lastPageInclude = 0;
  String pagesInclude = "";
  List<PickerModel> aiModels = [];
  aiQsModel aiQsData = aiQsModel();

  bool loaded = false;
  File? rawThumbFile;

  bool doChangeCover = false;

  @override
  void initState() {
    super.initState();

    initModel();
  }

  void initModel() async {
    setState(() => loaded = true);
    aiModels = azbazi.aiModels!.map((item) {
      return PickerModel(
        item.toString(),
        code: item.toString().toLowerCase(),
        icon: const Icon(Icons.smart_toy, color: Colors.blue),
      );
    }).toList();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AutovalidateMode _autoValidateMode = AutovalidateMode.onUserInteraction;
  // keys for fields
  // this is desirable because the fields may change order, in this example
  // when the screen is rotated, and this will preserve what state is
  // attached to what field.

  final GlobalKey<FormState> _AiModelKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _qsCountKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _qsSectionKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _qsAdditionalNoteKey = GlobalKey<FormState>();

  final FocusNode _azbaziTitleNode = FocusNode();
  final FocusNode _azbaziNoteNode = FocusNode();

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
            label: 'مدل هوش مصنوعی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsListPicker_AiModel(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'اطلاعات تکمیلی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsInt_QsCount(),
            _buildCardSettingsInt_QsSection(),
            _buildCardSettingsParagraph_QsAdditionalNote(2),
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
            label: 'مدل هوش مصنوعی',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsListPicker_AiModel(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'اطلاعات تکمیلی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsInt_QsCount(),
            _buildCardSettingsInt_QsSection(),
            _buildCardSettingsParagraph_QsAdditionalNote(2),
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

  // CardSettingsInstructions _buildCardSettingsInstructions() {
  //   return CardSettingsInstructions(
  //     text: 'به منظور فعالسازی آزبازی',
  //   );
  // }



  CardSettingsListPicker _buildCardSettingsListPicker_AiModel() {
    return CardSettingsListPicker<PickerModel>(
      key: _AiModelKey,
      label: 'مدل AI',
      initialItem: aiModels.first,
      hintText: 'یک مدل انتخاب کنید',
      autovalidateMode: _autoValidateMode,
      items: aiModels,
      validator: (PickerModel? value) {
        if (value == null || value.toString().isEmpty) {
          return 'شما باید مدلی انتخاب کرده باشید.';
        }
        return null;
      },
      onSaved: (value) => aiQsData.aiModel = value,
      onChanged: (value) {
        setState(() {
          aiQsData.aiModel = value!;
        });
        widget.onValueChanged('مدل هوش مصنوعی', value);
      },
    );
  }

  CardSettingsInt _buildCardSettingsInt_QsCount() {
    return CardSettingsInt(
      key: _qsCountKey,
      label:  'تعداد سوالات',
      hintText: 'زیر 15 وارد شود...',
      labelWidth: 130,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      //icon: new Icon(Icons.numbers, color: Colors.black,),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: 2,
      validator: (value) {
        if (value == null || value < 0) return 'تعداد سوالات ضروری است!';
        if (value > 15) return 'تعداد سوال زیر 15 مجاز است!';
        return null;
      },
      onSaved: (value) => aiQsData.qsCount = value,
      onChanged: (value) {
        setState(() {
          aiQsData.qsCount = value;
        });
      },
      autofocus: true,
      style: TextStyle(color: Colors.blueGrey, fontSize: 1, fontFamily: "Vazir"),
    );
  }

  CardSettingsInt _buildCardSettingsInt_QsSection() {
    return CardSettingsInt(
      key: _qsSectionKey,
      label: 'فصل یا بخش',
      hintText: 'اگر خالی بگذارید یعنی همه کتاب...',
      labelWidth: 130,
      maxLength: 2,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      focusNode: _azbaziTitleNode,
      inputAction: TextInputAction.next,
      inputActionNode: _azbaziNoteNode,
      onSaved: (value) => aiQsData.section = value,
      onChanged: (value) {
        setState(() {
          aiQsData.section = value;
        });
      },
    );
  }

  CardSettingsParagraph _buildCardSettingsParagraph_QsAdditionalNote(int lines) {
    return CardSettingsParagraph(
      key: _qsAdditionalNoteKey,
      label: 'درخواست تکمیلی',
      maxLength: 500,
      initialValue: aiQsData.additionalNote,
      numberOfLines: lines,
      focusNode: _azbaziNoteNode,
      onSaved: (value) => aiQsData.additionalNote = value,
      onChanged: (value) {
        setState(() {
          aiQsData.additionalNote = value;
        });
        //widget.onValueChanged('توضیح آزبازی', value);
      },
    );
  }

  bool isDigit(String s, int idx) =>
      "0".compareTo(s[idx]) <= 0 && "9".compareTo(s[idx]) >= 0;


  // ignore: non_constant_identifier_names
  CardSettingsButton _buildCardSettingsButton_Save() {
    return CardSettingsButton(
      label: 'شروع',
      textColor: Colors.white,
      backgroundColor: Colors.indigo[800],
      onPressed: savePressed,
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

  Future savePressed() async {
    UserProvider userProvider = UserProvider.instance();
    UserModel? userData = await userProvider.onStartUp();

    if ((userData?.status == "ok" && userData?.userid != "0") ||
        userData?.error_code == "USR_ALI") {
      final form = _formKey.currentState;

      if (form!.validate() && _firstPress) {
        _firstPress = false;
        form.save();

        setState(() {
          _processing = true;
          _progress = 0.0;
          _processPhase = "در انتظار دریافت پاسخ از هوش مصنوعی...";
        });

        // نمایش Dialog لودینگ
        _showLoadingDialog();

        try {
          var response = await _requestAINewQs();

          Navigator.of(context, rootNavigator: true).pop(); // بستن Dialog لودینگ

          if (response != null &&
              response.data != null &&
              response.data["status"] == "ok") {
            // سوالات معتبر دریافت شد
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => OneAzbaziProfileSc(
                  book: widget.book,
                  azbazi: azbazi,
                  userData: userData,
                  userProvider: userProvider,
                ),
              ),
                  (route) => false,
            );
            _showServerDialog("نتیجه درخواست: ${response.data["message"]}");
          } else {
            // خطا یا خروجی نامعتبر
            Navigator.of(context, rootNavigator: true).pop(); // بستن Dialog لودینگ
            var errors = response?.data?["message"] ?? [" خطایی رخ داده است."];
            _showServerDialog(errors);
          }
        } catch (e) {
          Navigator.of(context, rootNavigator: true).pop(); // بستن Dialog لودینگ
          print("Exception: $e");
          _showServerDialog("مشکلی در ارتباط با سرور پیش آمد. لطفاً دوباره تلاش کنید.");
        } finally {
          setState(() {
            _processing = false;
          });
        }
      } else {
        showErrors(context);
      }
    } else {
      _showServerDialog("ارتباط برقرار نیست! لطفاً بعداً تلاش کنید.");
    }
  }

  Future<dynamic> _requestAINewQs() async {
    var response;
    try {
      var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request';

      FormData formData = FormData.fromMap({
        "azbazi_id": azbazi.azbazi_id,
        "book_id": widget.book.book_id,
        "aiModel": aiQsData.aiModel,
        "qsCount": aiQsData.qsCount,
        "qsSection": aiQsData.section,
        "additionalNote": aiQsData.additionalNote,
        "action": "post",
        "module": "books",
        "resource": "requestAINewQs",
      });

      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage(appDocPath + "/.cookies/"),
      );
      dio.interceptors.add(CookieManager(cookieJar));

      response = await dio.post(
        url,
        data: formData,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final double progress = received / total;
            setState(() {
              _progress = progress;
              _processPhase =
              "در حال دریافت پاسخ... ${(progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );
    } catch (e) {
      print("دلیل خطا: $e");
      _showServerDialog("خطایی در ارسال یا دریافت داده‌ها رخ داد.");
    }

    return response;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // کاربر نتونه دیالوگ رو ببندهe3
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(value: _progress > 0 ? _progress : null),
                  SizedBox(height: 16),
                  Text(_processPhase, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showServerDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("راز  پیغام دریافتی از سرور"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("باشه"),
            ),
          ],
        ),
      ),
    );
  }

  void resetPressed() {
    setState(() => loaded = false);

    initModel();

    _formKey.currentState!.reset();
  }
}
