/*
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/models/contentModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/models/results.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';

typedef LabelledValueChanged<T, U> = void Function(T label, U value);

class ContentForm extends StatefulWidget {
  const ContentForm(
    this.orientation,
    this.showMaterialOnIOS,
    this.scaffoldKey, {
    required this.onValueChanged,
    Key? key, required this.content, required this.pageData, required this.book, required this.pageNumToId,
  }) : super(key: key);

  final Orientation orientation;
  final bool showMaterialOnIOS;
  final GlobalKey<ScaffoldState> scaffoldKey;

  final contentModel content;
  final pageModel pageData;
  final bookModel book;
  final List<dynamic> pageNumToId;

  final LabelledValueChanged<String, dynamic> onValueChanged;

  @override
  ContentFormState createState() => ContentFormState(content, pageData, book, pageNumToId);
}

class ContentFormState extends State<ContentForm> {
  ContentFormState(this.content, this.pageData, this.book, this.pageNumToId);

  contentModel content;
  final pageModel pageData;
  final bookModel book;
  final List<dynamic> pageNumToId;

  int firstPageInclude = 0;
  int lastPageInclude = 0;
  String pagesInclude = "";

  bool loaded = false;
  File? rawVideoFile;

  @override
  void initState() {
    super.initState();

    content.isDeleteVideo = content.content_id == "" ? true : false;
    content.isMine = content.content_id != "" ? content.isMine : "1";

    final pages_include = content.pages_include;
    if (pages_include != null) {
      var includePagesNum = pages_include.split(',');
      for (var i = 0; i < pageNumToId[0].length; i++) {
        int j = i + 1;
        if (includePagesNum.first == pageNumToId[0]["$j"]) {
          firstPageInclude = j - int.parse(book.gap_pages!);
        }
        if (includePagesNum.last == pageNumToId[0]["$j"]) {
          lastPageInclude = j - int.parse(book.gap_pages!);
        }
      }
    }

    _progress = 0;

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
  final GlobalKey<FormState> _contentTitleKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _ownerNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contentNoteKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _IsTeacherKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _IsMineKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _IsDeleteVideoKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _untilPageKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _videoKey = GlobalKey<FormState>();

  final FocusNode _contentTitleNode = FocusNode();
  final FocusNode _ownerNameNode = FocusNode();
  //final FocusNode _languageNode = FocusNode();
  final FocusNode _contentNoteNode = FocusNode();

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
      labelWidth: 150,
      contentAlign: TextAlign.right,
      cardless: false,
      children: <CardSettingsSection>[
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'شناسنامه محتوا',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsText_ContentTitle(),
            _buildCardSettingsParagraph_ContentNote(5),
            _buildCardSettingsDouble_UntilPage(),
            //_buildCardSettingsText_Language(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'فایل محتوا',
            labelAlign: TextAlign.right,
            color: Colors.amberAccent,
          ),
          instructions: _buildCardSettingsInstructions(),
          children: <CardSettingsWidget>[
            _buildCardSettingsSwitch_IsDeleteVideo(),
            _buildCardSettingsVideoPicker(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'مالکیت',
            labelAlign: TextAlign.right,
            color: Colors.black12,
          ),
          divider: Divider(thickness: 1.0, color: Colors.purple),
          children: <CardSettingsWidget>[
            _buildCardSettingsSwitch_IsTeacher(),
            _buildCardSettingsSwitch_IsMine(),
            _buildCardSettingsText_OwnerName(),
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
            _buildCardSettingsButton_Reset(),
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
            label: 'شناسنامه محتوا',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          children: <CardSettingsWidget>[
            _buildCardSettingsText_ContentTitle(),
            _buildCardSettingsParagraph_ContentNote(2),
            _buildCardSettingsDouble_UntilPage(),
            //_buildCardSettingsText_Language(),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'فایل محتوا',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          instructions: _buildCardSettingsInstructions(),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsSwitch_IsDeleteVideo(),
              _buildCardSettingsVideoPicker(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'مالکیت',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsSwitch_IsTeacher(),
              _buildCardSettingsSwitch_IsMine(),
              _buildCardSettingsText_OwnerName(),
            ]),
          ],
        ),
        CardSettingsSection(
          header: CardSettingsHeader(
            label: 'عملیات',
            labelAlign: TextAlign.right,
            color: Colors.black87,
          ),
          children: <CardSettingsWidget>[
            CardFieldLayout(<CardSettingsWidget>[
              _buildCardSettingsButton_Save(),
              _buildCardSettingsButton_Reset(),
            ]),
          ],
        ),
      ],
    );
  }

  CardSettingsText _buildCardSettingsText_ContentTitle() {
    return CardSettingsText(
      key: _contentTitleKey,
      label: 'عنوان',
      hintText: 'عنوان محتوا وارد شود...',
      maxLength: 40,
      initialValue: content.content_title != null
          ? content.content_title
          : null,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _contentTitleNode,
      inputAction: TextInputAction.next,
      inputActionNode: _contentNoteNode,
      validator: (value) {
        if (value == null || value.isEmpty) return 'عنوان محتوا ضروری است!';
        return null;
      },
      onSaved: (value) => content.content_title = value!,
      onChanged: (value) {
        setState(() {
          content.content_title = value;
        });
        //widget.onValueChanged('عنوان', value);
      },
    );
  }

  CardSettingsParagraph _buildCardSettingsParagraph_ContentNote(int lines) {
    return CardSettingsParagraph(
      key: _contentNoteKey,
      label: 'توضیح محتوا',
      maxLength: 500,
      initialValue: content.content_note,
      numberOfLines: lines,
      focusNode: _contentNoteNode,
      onSaved: (value) => content.content_note = value!,
      onChanged: (value) {
        setState(() {
          content.content_note = value;
        });
        //widget.onValueChanged('توضیح محتوا', value);
      },
    );
  }

  /*CardSettingsText _buildCardSettingsText_Language() {
    return CardSettingsText(
      key: _languageKey,
      label: 'زبان',
      hintText: 'زبان آموزش محتوا...',
      initialValue: content?.language != null ? content.language : null,
      autovalidate: _autoValidate,
      focusNode: _languageNode,
      inputAction: TextInputAction.next,
      inputActionNode: _contentNoteNode,
      onSaved: (value) => content.language = value,
      onChanged: (value) {
        setState(() {
          content.language = value;
        });
        //widget.onValueChanged('زبان', value);
      },
    );
  }*/

  CardSettingsSwitch _buildCardSettingsSwitch_IsDeleteVideo() {
    return CardSettingsSwitch(
      key: _IsDeleteVideoKey,
      label: 'حذف ویدئو قبلی؟',
      initialValue: content.isDeleteVideo!,
      visible: content.content_id == "" ? false : true,
      onSaved: (value) => content.isDeleteVideo = value!,
      onChanged: (value) {
        setState(() {
          content.isDeleteVideo = value;
        });
      },
    );
  }

  CardSettingsFilePicker _buildCardSettingsVideoPicker() {
    return CardSettingsFilePicker(
      key: _videoKey,
      icon: Icon(Icons.video_library),
      label: 'ویدئوی آموزشی جدید',
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      fileType: FileType.video,
      initialValue: content.isDeleteVideo == false
          ? Uint8List(int.parse(content.size!))
          : null,
      visible: content.isDeleteVideo!,
      validator: (value) {
        if (value == null || (content.content_id == "" && value.isEmpty))
          return 'فایل ویدئویی محتوا ضروری است!';
        else if (content.isDeleteVideo! && value.isEmpty) return 'فایل ویدئویی محتوا ضروری است!';
        return null;
      },
      onSaved: (value) => content.size = value!.length.toString(),
      onChanged: (value) {
        setState(() {
          rawVideoFile = value;
        });
      },
    );
  }

  CardSettingsInstructions _buildCardSettingsInstructions() {
    return CardSettingsInstructions(
      text: 'فایل ویدئوی محتوای تولید شده.',
    );
  }

  CardSettingsNumberPicker _buildCardSettingsDouble_UntilPage() {
    int pageCount = pageNumToId[0].length - int.parse(book.gap_pages!);
    int realPageNum = int.parse(pageData.real_page_num);
    String? firstPage = firstPageInclude > 0
        ? firstPageInclude.toString()
        : pageData.real_page_num;
    return CardSettingsNumberPicker(
      key: _untilPageKey,
      label: 'از صفحه ' + firstPage + ' تا صفحه',
      confirmText: "!تائید",
      cancelText: "!لغو",
      //labelAlign: labelAlign,
      initialValue: lastPageInclude > 0 ? lastPageInclude : realPageNum,
      min: firstPageInclude > 0 ? firstPageInclude : realPageNum,
      max: pageCount,
      stepInterval: 1,
      validator: (value) {
        if (value! > pageCount) return 'از تعداد صفحات کتاب بیشتر است!';
        if (firstPageInclude == 0){
          if( value < realPageNum )
            return 'برای صفحات پایین تر به خود آن صفحه رجوع شود!';
        } else if( value < firstPageInclude)
          return 'برای صفحات پایین تر به خود آن صفحه رجوع شود!';

        return null;
      },
    //  onSaved: (value) =>
    //  content.pages_include = pagesInclude,
      onChanged: (value) {
        pagesInclude = "";
        int i;
        if(firstPageInclude == 0){
          i = realPageNum + int.parse(book.gap_pages!);
        } else {
          i = firstPageInclude + int.parse(book.gap_pages!);
        }
        int untilValue = value! + int.parse(book.gap_pages!);
        for (int j = i; j <= untilValue; j++) {
          if (j < untilValue)
            pagesInclude += pageNumToId[0]["$j"] + ',';
          else
            pagesInclude += pageNumToId[0]["$j"];
        }

        setState(() {
          content.pages_include = pagesInclude;
        });
        String showFirstTxt = firstPageInclude > 0 ? firstPageInclude.toString() : pageData.real_page_num!;
        widget.onValueChanged(
            'از صفحه ' + showFirstTxt + ' تا صفحه', value);
      },
    );
  }

  CardSettingsSwitch _buildCardSettingsSwitch_IsTeacher() {
    return CardSettingsSwitch(
      key: _IsTeacherKey,
      label: 'آیا معلم است؟',
      initialValue: content.isteacher != null
          ? content.isteacher == "1"
          : true,
      onSaved: (value) => content.isteacher = value.toString(),
      onChanged: (value) {
        setState(() {
          content.isteacher = value ? "1" : "0";
        });
        //widget.onValueChanged('آیا معلم است؟', value);
      },
    );
  }

  CardSettingsSwitch _buildCardSettingsSwitch_IsMine() {
    return CardSettingsSwitch(
      key: _IsMineKey,
      label: 'وارد کننده همان تولید کننده محتوا؟',
      initialValue: content.isMine != null ? content.isMine == "1" : true,
      onSaved: (value) => content.isMine = value.toString(),
      onChanged: (value) {
        setState(() {
          content.isMine = value ? "1" : "0";
        });
        //widget.onValueChanged('صاحب محتوا هستم؟', value);
      },
    );
  }

  CardSettingsText _buildCardSettingsText_OwnerName() {
    return CardSettingsText(
      key: _ownerNameKey,
      label: 'نام صاحب محتوا',
      hintText: 'نام تولید کننده محتوا وارد شود...',
      initialValue: content.owner_name,
      requiredIndicator: Text('*', style: TextStyle(color: Colors.red)),
      autovalidate: _autoValidate,
      focusNode: _ownerNameNode,
      inputAction: TextInputAction.next,
      inputActionNode: _contentNoteNode,
      visible: content.isMine == "0",
      validator: (value) {
        if (content.isMine == "0" && (value == null || value.isEmpty))
          return 'نام صاحب اثر وارد شود!';
        return null;
      },
      onSaved: (value) => content.owner_name = value!,
      onChanged: (value) {
        setState(() {
          content.owner_name = value;
        });
        //widget.onValueChanged('نام صاحب محتوا', value);
      },
    );
  }

  CardSettingsButton _buildCardSettingsButton_Save() {
    return CardSettingsButton(
      label: 'ذخیره',
      backgroundColor: Colors.green,
      onPressed: savePressed,
    );
  }

  CardSettingsButton _buildCardSettingsButton_Reset() {
    return CardSettingsButton(
      label: 'بازیابی',
      isDestructive: true,
      onPressed: resetPressed,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      bottomSpacing: 4.0,
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
          if(rawVideoFile != null)
            await _processVideo(rawVideoFile!);
          else if(!content.isDeleteVideo!) {
            setState(() {
              _processPhase = 'ویرایش محتوا';
              _progress = 0.0;
              _processing = false;
            });
            await _editUploadContent(null, null);
          }
          var popState = GlobalKeys.navigatorKey.currentState;
          if(popState != null)
            popState.pushNamed("contentsscreen");
          else
            Navigator.of(context).pop();
        } else {
          showErrors(context);
          setState(() => _autoValidate = true);
        }
      } catch (e) {
        print('${e.toString()}');
      } finally {
        setState(() {
          _processing = false;
        });
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
            "ارتباط برقرار نیست!",
            style: TextStyle(fontSize: 16.0,
                color: Colors.cyanAccent,
                fontFamily: "ShadowsIntoLightTwo"),
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

  Future<void> _processVideo(File rawVideoFile) async {
    if (content.isDeleteVideo!) {
      final String rand = '${new Random().nextInt(10000)}';
      final videoName = 'video$rand';
      final Directory extDir = await getApplicationDocumentsDirectory();
      final outDirPath = '${extDir.path}/Videos/$videoName';
      final videosDir = new Directory(outDirPath);
      videosDir.createSync(recursive: true);

      final rawVideoPath = rawVideoFile.path;

      setState(() {
        _processPhase = 'جلد ویدئو';
        _progress = 0.0;
      });

      final thumbFile = await VideoCompress.getFileThumbnail(
          rawVideoPath,
          quality: 50, // default(100)
          position: 1 // default(-1)
      );
      String thumbFilePath = thumbFile.path;

      setState(() {
        _processPhase = 'کدگذاری ویدئو';
        _progress = 0.0;
      });

      setState(() {
        _processPhase = 'بارگذاری ویدئو';
        _progress = 0.0;
      });
      await _editUploadContent(rawVideoPath, thumbFilePath);

      setState(() {
        _processPhase = 'ذخیره محتوا';
        _progress = 0.0;
      });
    } else {
      setState(() {
        _processPhase = 'ویرایش محتوا';
        _progress = 0.0;
        _processing = false;
      });
      await _editUploadContent(null, null);
    }
  }

  Future<dynamic> _editUploadContent(rawFilePath, thumbFilePath) async {
    var fileBasename;
    var thumbBasename;
    if (rawFilePath != null && thumbFilePath != null) {
      fileBasename = p.basename(rawFilePath);
      thumbBasename = p.basename(thumbFilePath);
    }

    if(content.pages_include == null || content.pages_include == ""){
      int i = int.parse(pageData.real_page_num!) + int.parse(book.gap_pages!);
      content.pages_include = pageNumToId[0]["$i"];
    }

    var response;
    try {
      FormData formData = new FormData.fromMap({
        "content_id": content.content_id,
        "book_id": book.book_id,
        "page_id": pageData.page_id,
        "ismine": content.isMine,
        "isdeletevideo": content.isDeleteVideo,
        "owner_name": content.owner_name,
        "isteacher": content.isteacher,
        "content_link": rawFilePath != null && thumbFilePath != null
            ? await MultipartFile.fromFile(
            rawFilePath, filename: fileBasename)
            : "",
        "thumb_link": rawFilePath != null && thumbFilePath != null
            ? await MultipartFile.fromFile(
            thumbFilePath, filename: thumbBasename)
            : "",
        "content_title": content.content_title,
        "content_note": content.content_note,
        "size": content.size,
        "language": content.language,
        "pages_include": content.pages_include,
        "reason": "txtReason",
      });

      var dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(appDocPath+"/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));

      response = await dio.post(
        GlobalKeys.ebargeUrl + '/index.php?option=com_ebarge&task=content.saveedit&tmpl=component',
        data: formData,
        onSendProgress: (int sent, int total) {
          final double progress = sent / total;
          setState(() {
            _progress = progress;
          });
          print("$sent $total");
        },
      );

      print("نتیجه بارگذاری ویدئو: $response");
    } catch (e) {
      print("دلیل خطا: $e");
    }

    return response;
  }
}*/
