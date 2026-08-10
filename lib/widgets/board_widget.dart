import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/models/paintedObjects.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/utils/bus_state.dart';
import 'package:extended_image/extended_image.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_painter/history_model.dart';
import 'package:image_painter/image_painter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';


class BoardWidget extends StatefulWidget {
  const BoardWidget({Key? key, required this.pageData, required this.showActions}) : super(key: key);

  final pageModel pageData;
  final int showActions;

  @override
  State<StatefulWidget> createState() => BoardWidgetState(pageData, showActions);
}

class BoardWidgetState extends BusState<BoardWidget> {
  final pageModel pageData;
  int showActions = 1;
  BoardWidgetState(this.pageData, showActions);

  final _boardGlobalKey = GlobalKey();

  final GlobalKey<ExtendedImageGestureState> gestureKey =
  GlobalKey<ExtendedImageGestureState>();

  File? imgFile;

  GlobalKey<ImagePainterState>? _imageKey;
  final _controller = ValueNotifier<Controller?>(null);

  @override
  void initState() {
    super.initState();
    _controller.value =  ValueNotifier(
        const Controller(color: Colors.blue, mode: PaintMode.line, strokeWidth: 4.0)).value;
    _imageKey = GlobalKey<ImagePainterState>();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadPaintedHistory());
  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void saveImage() async {
    try {
      // خروجی تصویر از ویجت
      final image = await _imageKey!.currentState!.exportImage();
      if (image == null) return;

      // مسیر پوشه دانلود (Scan‌شده و مجاز)
      String downloadPath =
      await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_PICTURES);

      // پوشه اختصاصی داخل Download
      String folderPath = "$downloadPath/ebarge/images";
      Directory(folderPath).createSync(recursive: true);

      String filePath =
          "$folderPath/${DateTime.now().millisecondsSinceEpoch}.png";

      // ذخیره فایل
      final file = File(filePath);
      await file.writeAsBytes(image);

      // پیام موفقیت
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient: LinearGradient(
          colors: [Colors.white70, Colors.black12],
        ),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(filePath),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("مشاهده!", style: TextStyle(color: Colors.amber, fontSize: 16)),
          ),
        ),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("تصویر با موفقیت ذخیره شد!",
              style: TextStyle(fontSize: 14, color: Colors.pink, fontFamily: "Vazir")),
        ),
        duration: Duration(seconds: 4),
      ).show(context);

    } catch (e) {
      print("ERROR saving image: $e");

      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("خطا در ذخیره تصویر!",
              style: TextStyle(fontSize: 14, color: Colors.red, fontFamily: "Vazir")),
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  void shareImage() async {
    try {
      final box = context.findRenderObject() as RenderBox?;

      // خروجی تصویر از ویجت
      final image = await _imageKey!.currentState!.exportImage();
      if (image == null) return;

      // مسیر cache معتبر برای اندروید
      final tempDir = await getTemporaryDirectory();
      final filePath =
          "${tempDir.path}/ebarge_${DateTime.now().millisecondsSinceEpoch}.png";

      // ذخیره فایل در cache
      final file = File(filePath);
      await file.writeAsBytes(image);

      // اشتراک‌گذاری با shareXFiles
      await Share.shareXFiles(
        [XFile(filePath)],
        text: "",
        subject: "",
        sharePositionOrigin:
        box!.localToGlobal(Offset.zero) & box.size,
      );

    } catch (e) {
      print("ERROR shareImage: $e");
    }
  }



  Future<String> getImagePath() async {
    String ebargeImgPath = '/ebarge/images';
    String rootStorage = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
    new Directory(rootStorage + ebargeImgPath).createSync(recursive: true);
    String fullPath = rootStorage + ebargeImgPath + "/" + '${DateTime
        .now()
        .millisecondsSinceEpoch}.png';

    return fullPath;
  }

  Future<void> loadPaintedHistory() async {
    final storage = new FlutterSecureStorage();
    String? paintedListJson = await storage.read(key: 'page_id'+pageData.page_id);

    if(paintedListJson != null){
      List<dynamic> decodedPaintedObjectList = jsonDecode(paintedListJson);
      decodedPaintedObjectList.map((elem) => jsonDecode(elem));

      for (var onePaint in decodedPaintedObjectList) {
        Offset? _start;
        Offset? _end;
        final _points = <Offset?>[];

        List<dynamic> offsetsList =  onePaint['offsets'];
        for( var i = 0 ; i < offsetsList.length; i++ ) {
          if( i == 0 )
            _start = Offset(offsetsList[i]["dx"], offsetsList[i]["dy"]);
          if(i == offsetsList.length - 1)
            _end = Offset(offsetsList[i]["dx"], offsetsList[i]["dy"]);

          _points.add(Offset(offsetsList[i]["dx"], offsetsList[i]["dy"]));
        }

        int value = int.parse(onePaint["color"], radix: 16);
        Color paintColor = new Color(value);

        Paint _painter = Paint()
          ..color = paintColor
          ..strokeWidth = onePaint["strokeWidth"]
          ..style =  onePaint["style"] == "PaintingStyle.stroke" ? PaintingStyle.stroke : PaintingStyle.fill;

        final PaintMode? _mode;
        switch (onePaint["mode"]) {
          case 'PaintMode.freeStyle': _mode = PaintMode.freeStyle; break;
          case 'PaintMode.line': _mode = PaintMode.line; break;
          case 'PaintMode.rect': _mode = PaintMode.rect; break;
          case 'PaintMode.text': _mode = PaintMode.text; break;
          case 'PaintMode.arrow': _mode = PaintMode.arrow; break;
          case 'PaintMode.circle': _mode = PaintMode.circle; break;
          case 'PaintMode.dashLine': _mode = PaintMode.dashLine; break;
          default: _mode = PaintMode.none; break;
        }

        ValueNotifier<Controller>? _controller = ValueNotifier(
            Controller(mode: _mode, color: Colors.black));

        if (_start != null && _end != null && (onePaint["mode"] == "PaintMode.freeStyle")) {
          _points.add(null);
          context.read<HistoryModel>().addFreeStylePoints(_points, _painter);
          //_addFreeStylePoints();
          _points.clear();
        } else if (_start != null && _end != null && onePaint["mode"] != "PaintMode.text") {
          context.read<HistoryModel>().addEndPoints(_start, _end, _controller, _painter);
          // _addEndPoints();
        } else if (onePaint["pText"] != ''){
          context.read<HistoryModel>().openTextDialog(onePaint["pText"] , _painter, _points);
        }
      }
    }
  }

  void saveHistory() async {
    List<PaintInfo> paintedHistoryList = context.read<HistoryModel>().paintHistory!;

    List<PaintedObject>? thisPagePaintedList = <PaintedObject>[];
    for( var j in paintedHistoryList ) {
      Color color = j.painter!.color;
      String colorHex = color.value.toRadixString(16).padLeft(8, '0'); // ARGB


      List<MyOffset>? myOffsetsList = <MyOffset>[];
      for( var k in j.offset!){
        if( k != null ){
          MyOffset? _oneOffset = MyOffset(k.dx, k.dy);
          myOffsetsList.add(_oneOffset);
        }
      }

      String? pText = j.text != null ? j.text : "";

      var pHistoryItem = PaintedObject(
        j.mode.toString(),
          colorHex,
        j.painter!.strokeWidth,
        j.painter!.style.toString(),
        myOffsetsList,
        pText!
      );

      thisPagePaintedList.add(pHistoryItem);
    }

      late String _encodedHistory;
      _encodedHistory = jsonEncode(thisPagePaintedList);

      final storage = new FlutterSecureStorage();
      await storage.write(key: "page_id"+pageData.page_id, value: _encodedHistory);

    Flushbar(
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundGradient: LinearGradient(colors: [Colors.white70, Colors.black12]),
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          "تغییرات طراحی اعمال شد!",
          style: TextStyle(fontSize: 14.0, color: Colors.pink, fontFamily: "Vazir",),
        ),
      ),
      duration:  Duration(seconds: 2),
    )..show(context);
  }

 /* void tempImage() async {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    final image = Image.network(GlobalKeys.ebargeUrl + '/' + _pageData.page_image);
    //final byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
        .buffer
        .asUint8List();

    Uint8List image = await Image.network(GlobalKeys.ebargeUrl + '/' + _pageData.page_image);
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    String fullPath = '$directory/${DateTime
        .now()
        .millisecondsSinceEpoch}.png';
    imgFile = new File('$fullPath');
  }*/

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boardGlobalKey,
      child: Container(
        child: ValueListenableBuilder<Controller?>(
            valueListenable: _controller,
            builder: (_, ctrl, __) {
              return Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 720,
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      elevation: 2,
                      child: SizedBox(
                        width: AppBar().preferredSize.height,
                        height: AppBar().preferredSize.height * 5 / 6,
                        child: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: AppBar().preferredSize.height,
                            height: AppBar().preferredSize.height,
                            child: PopupMenuButton(
                              tooltip: "نمایش منو",
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                              itemBuilder: (context) =>
                              [
                                PopupMenuItem(
                                  value: 3,
                                  child:
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: ListTile(
                                      leading: IconTheme(
                                          data: const IconThemeData(
                                              opacity: 1.0),
                                          child: Icon(
                                            Icons.save, color: Colors.blue,
                                            size: 24,)
                                      ),
                                      title: Text("ذخیره طراحی",
                                          style: TextStyle(color: Colors.blue,
                                            fontSize: 15,
                                            fontFamily: "Vazir",)),
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: ListTile(
                                      leading: IconTheme(
                                          data: const IconThemeData(
                                              opacity: 1.0),
                                          child: Icon(
                                            Icons.share, color: Colors.pink,
                                            size: 24,)
                                      ),
                                      title: Text("اشتراک با دیگری",
                                          style: TextStyle(color: Colors.pink,
                                            fontSize: 15,
                                            fontFamily: "Vazir",)),
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child:
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: ListTile(
                                      leading: IconTheme(
                                          data: const IconThemeData(
                                              opacity: 1.0),
                                          child: Icon(Icons.file_download,
                                            color: Colors.green,
                                            size: 24,)
                                      ),
                                      title: Text(
                                          "ذخیره در گالری", style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 15,
                                        fontFamily: "Vazir",)),
                                    ),
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 1) {
                                  saveImage();
                                }
                                if (value == 2) {
                                  shareImage();
                                }
                                if (value == 3) {
                                  saveHistory();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ImagePainter.network(
                      GlobalKeys.ebargeUrl + '/' + pageData.page_image,
                      key: _imageKey!,
                      scalable: true,
                      initialPaintMode: PaintMode.none,),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  /*void _openMainColorPicker() async {
    await showDialog<Color>(
        context: context,
        builder: (_) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ValueListenableBuilder<Controller?>(
              valueListenable: _controller,
              builder: (_, value, __) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(6.0),
                  title: const Text("یک رنگ انتخاب کن...", style: TextStyle(fontFamily: "Vazir", fontSize: 17),),
                  content: OColorPicker(
                    selectedColor: value!.color,
                    colors: primaryColorsPalette,
                    onColorChange: (color) {
                      _updateController(value.copyWith(color: color));
                    },
                  ),
                  actions: [
                    TextButton(
                        child: const Text('تائید', style: TextStyle(fontFamily: "Vazir", fontSize: 16),),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }*/
}

class SelectionItems extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const SelectionItems({Key? key, required this.isSelected, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isSelected ? Colors.white70 : Colors.transparent,
                shape: BoxShape.circle),
            child: Icon(icon,
                color: isSelected ? Colors.blue : Colors.white, size: 20),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.green),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
      ],
    );
  }
}
