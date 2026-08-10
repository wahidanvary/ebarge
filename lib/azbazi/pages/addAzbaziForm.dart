import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:card_settings/card_settings.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/results.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:extended_image/extended_image.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as myPath;

import '../../models/bookModel.dart';
import '../../screens/books/myBooks.dart';
import '../../services/GlobalKeys.dart';

typedef LabelledValueChanged<T, U> = void Function(T label, U value);

class addAzbaziForm extends StatefulWidget {
  const addAzbaziForm(
      this.orientation,
      this.showMaterialOnIOS,
      this.scaffoldKey, {
        required this.onValueChanged,
        Key? key,
        required this.azbazi,
        required this.book,
      }) : super(key: key);

  final Orientation orientation;
  final bool showMaterialOnIOS;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final azbaziModel azbazi;
  final bookModel book;

  final LabelledValueChanged<String, dynamic> onValueChanged;

  @override
  addAzbaziFormState createState() => addAzbaziFormState(azbazi);
}

class addAzbaziFormState extends State<addAzbaziForm> {
  addAzbaziFormState(this.azbazi);

  azbaziModel azbazi;

  int firstPageInclude = 0;
  int lastPageInclude = 0;
  String pagesInclude = "";

  bool loaded = false;
  File? rawThumbFile;
  Uint8List? initialThumbBytes;

  bool doChangeCover = false;

  @override
  void initState() {
    super.initState();
    initModel();
  }

  // تغییر ۱: تبدیل به Future برای استفاده از await
  Future<void> _loadThumb() async {
    if (azbazi.thumb_link != null && azbazi.thumb_link!.isNotEmpty) {
      final url = GlobalKeys.ebargeUrl + azbazi.thumb_link!;

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          // نیازی به setState در اینجا نیست چون در initModel هندل می شود
          // اما برای اطمینان مقدار را ست می کنیم
          initialThumbBytes = response.bodyBytes;
        }
      } catch (e) {
        print("Error loading thumb: $e");
      }
    }
  }

  // تغییر ۲: انتظار برای اتمام دانلود عکس قبل از نمایش فرم
  void initModel() async {
    await _loadThumb();
    if (mounted) {
      setState(() => loaded = true);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  final GlobalKey<FormState> _azbaziTitleKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _azbaziNoteKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _IsTeacherKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _thumbKey = GlobalKey<FormState>();

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
            label: 'بنر آزبازی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsThumbPicker(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'شناسنامه آزبازی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsText_AzbaziTitle(),
            _buildCardSettingsParagraph_AzbaziNote(2),
            _buildCardSettingsSwitch_IsTeacher(),
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
            label: 'بنر آزبازی',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsThumbPicker(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'شناسنامه آزبازی',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsText_AzbaziTitle(),
            _buildCardSettingsParagraph_AzbaziNote(2),
            _buildCardSettingsSwitch_IsTeacher(),
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
            ]),
          ],
        ),
      ],
    );
  }

  CardSettingsFilePicker _buildCardSettingsThumbPicker() {
    return CardSettingsFilePicker(
      key: _thumbKey,
      icon: Icon(Icons.image_outlined),
      label: 'تصویر بنر جدید',
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      fileType: FileType.image,
      initialValue: initialThumbBytes, // اکنون این مقدار قبل از بیلد پر شده است
      unattachDialogConfirm: 'حذف ضمیمه',
      unattachDialogCancel: 'لغو',
      unattachDialogTitle: 'حذف ضمیمه تصویر کاور؟',
      validator: (value) {
        // لاجیک ولیدیشن کمی ساده‌سازی شد تا خواناتر باشد اما عملکرد همان است
        bool hasInitialImage = azbazi.thumb_link != null && azbazi.thumb_link!.isNotEmpty;
        bool hasNewImage = (value != null && value.isNotEmpty);

        if (!hasInitialImage && !hasNewImage) {
          return 'تصویر بنر آزبازی ضروری است!';
        }

        return null;
      },
      onChanged: (value) {
        setState(() {
          rawThumbFile = value;
          doChangeCover = true;
        });
      },
    );
  }

  CardSettingsText _buildCardSettingsText_AzbaziTitle() {
    return CardSettingsText(
      key: _azbaziTitleKey,
      label: 'عنوان',
      hintText: 'عنوان آزبازی وارد شود...',
      maxLength: 40,
      initialValue: azbazi.title,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _azbaziTitleNode,
      inputAction: TextInputAction.next,
      inputActionNode: _azbaziNoteNode,
      validator: (value) {
        if (value == null || value.isEmpty) return 'عنوان آزبازی ضروری است!';
        return null;
      },
      onSaved: (value) => azbazi.title = value!,
      onChanged: (value) {
        setState(() {
          azbazi.title = value;
        });
      },
    );
  }

  CardSettingsParagraph _buildCardSettingsParagraph_AzbaziNote(int lines) {
    return CardSettingsParagraph(
      key: _azbaziNoteKey,
      label: 'توضیح آزبازی',
      maxLength: 500,
      initialValue: azbazi.note,
      numberOfLines: lines,
      focusNode: _azbaziNoteNode,
      onSaved: (value) => azbazi.note = value!,
      onChanged: (value) {
        setState(() {
          azbazi.note = value;
        });
      },
    );
  }

  CardSettingsSwitch _buildCardSettingsSwitch_IsTeacher() {
    return CardSettingsSwitch(
      key: _IsTeacherKey,
      label: 'آیا معلم هستید؟',
      trueLabel: 'درحال حاضر تدریس می کنم',
      falseLabel: 'خیر',
      initialValue: azbazi.isTeacher != null ? azbazi.isTeacher == "1" : true,
      onSaved: (value) => azbazi.isTeacher = value.toString(),
      onChanged: (value) {
        setState(() {
          azbazi.isTeacher = value ? "1" : "0";
        });
      },
    );
  }

  bool isPasswordCompliant(String password) {
    bool hasUppercase = false;
    bool hasDigits = false;
    bool hasLowercase = false;
    var character = '';
    var i = 0;

    if (password.isNotEmpty) {
      while (i < password.length) {
        character = password.substring(i, i + 1);
        if (isDigit(character, 0)) {
          hasDigits = true;
        } else {
          if (character == character.toUpperCase()) {
            hasUppercase = true;
          }
          if (character == character.toLowerCase()) {
            hasLowercase = true;
          }
        }
        i++;
      }
    }
    return hasDigits & (hasUppercase || hasLowercase);
  }

  bool isDigit(String s, int idx) =>
      "0".compareTo(s[idx]) <= 0 && "9".compareTo(s[idx]) >= 0;

  CardSettingsButton _buildCardSettingsButton_Save() {
    return CardSettingsButton(
      label: 'ادامه',
      textColor: Colors.white,
      backgroundColor: Colors.indigo[800],
      onPressed: savePressed,
    );
  }

  Future savePressed() async {
    UserProvider userProvider = UserProvider.instance();
    UserModel? userData = await userProvider.onStartUp();
    if ((userData?.status == "ok" && userData?.userid != "0") ||
        userData?.error_code == "USR_ALI") {
      final form = _formKey.currentState;

      setState(() {
        _processing = true;
      });

      try {
        if (form!.validate() && _firstPress) {
          _firstPress = false;
          form.save();
          // اگر فایل جدیدی توسط کاربر انتخاب شده باشد
          if (rawThumbFile != null) {
            await _processImage(rawThumbFile!);
          }
          // اگر فایلی انتخاب نشده اما نیاز به ویرایش اطلاعات متنی هست
          else {
            // اگر آزبازی قدیمی است (ویرایش)
            if (azbazi.azbazi_id != null && azbazi.azbazi_id != "") {
              setState(() {
                _processPhase = 'ویرایش آزبازی';
                _progress = 0.0;
              });
              await _editUploadAzbazi(null); // اینجا null درست است چون عکسی عوض نشده
            }
          }

          if (mounted) {
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyBooks(userData)),
                  (route) => false,
            );
          }
        } else {
          showErrors(context);
          setState(() => _autoValidate = true);
        }
      } catch (e) {
        print('${e.toString()}');
      } finally {
        // برای جلوگیری از ست استیت در صورت دیسپوز شدن
        if(mounted) {
          setState(() {
            _processing = false;
          });
        }
      }
    } else {
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient:
        LinearGradient(colors: [Colors.white70, Colors.black12]),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "ارتباط برقرار نیست!",
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.cyanAccent,
                fontFamily: "ShadowsIntoLightTwo"),
          ),
        ),
        duration: Duration(seconds: 4),
      )..show(context);
    }
  }

  Future<void> _processImage(File rawImageFile) async {
    // مسیر فایل را می‌گیریم
    final thumbFilePath = rawImageFile.path;

    if (azbazi.azbazi_id == null || azbazi.azbazi_id == "") {
      // منطق مربوط به ذخیره سازی لوکال برای آیتم جدید (اختیاری ولی در کد شما بود)
      final String rand = '${new Random().nextInt(10000)}';
      final thumbName = 'thumb$rand';
      final Directory extDir = await getApplicationDocumentsDirectory();
      final outDirPath = '${extDir.path}/Pictures/$thumbName';
      final picturesDir = new Directory(outDirPath);
      picturesDir.createSync(recursive: true);

      // اگر نیاز دارید فایل را کپی کنید وگرنه همان مسیر اصلی کافیست
      // ...

      setState(() {
        _processPhase = 'بارگذاری کاور';
        _progress = 0.0;
      });

      // ارسال فایل برای آزبازی جدید
      await _editUploadAzbazi(thumbFilePath);

      setState(() {
        _processPhase = 'ذخیره آزبازی';
        _progress = 0.0;
      });
    } else {
      setState(() {
        _processPhase = 'ویرایش آزبازی و آپلود تصویر';
        _progress = 0.0;
        _processing = true; // تغییر به true چون داریم آپلود می‌کنیم
      });

      await _editUploadAzbazi(thumbFilePath);
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

  Future<dynamic> _editUploadAzbazi(thumbFilePath) async {
    var thumbBasename;
    bool finalDoChangeCover = true;
    if (thumbFilePath != null)
      thumbBasename = myPath.basename(thumbFilePath);
    else  // پس اگر عکس قدیمی وجود دارد، نباید به سرور بگوییم عکس را عوض کن.
      finalDoChangeCover = false;

    var response;
    try {
      FormData formData = new FormData.fromMap({
        "azbazi_id": azbazi.azbazi_id,
        "book_id": widget.book.book_id,
        "isteacher": azbazi.isTeacher,
        "thumb_link": thumbFilePath != null
            ? await MultipartFile.fromFile(thumbFilePath, filename: thumbBasename)
            : "",
        "title": azbazi.title,
        "note": azbazi.note,
        "dochangecover": finalDoChangeCover,
      });

      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true, storage: FileStorage(appDocPath + "/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));

      response = await dio.post(
        GlobalKeys.ebargeUrl +
            '/index.php?option=com_ebarge&task=azbazi.saveedit&tmpl=component',
        data: formData,
        onSendProgress: (int sent, int total) {
          final double progress = sent / total;
          setState(() {
            _progress = progress;
          });
          print("$sent $total");
        },
      );

      print("نتیجه بارگذاری کاور: $response");
    } catch (e) {
      print("دلیل خطا: $e");
    }

    return response;
  }

  // متد کمکی برای نمایش خطاها اگر در پروژه تعریف نشده باشد
  void showErrors(BuildContext context) {
    // پیاده سازی نمایش خطا
  }
}