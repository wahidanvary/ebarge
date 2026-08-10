import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:external_path/external_path.dart';


// ignore: must_be_immutable
class RequestDownload extends StatefulWidget {
  String downloadUrl;
  String ebargePath;
  String fileName;
  bool allowBack;
  bool allowExecute;

  RequestDownload({Key? key, required this.downloadUrl, required this.ebargePath, required this.fileName, required this.allowBack, required this.allowExecute}) : super(key: key);

  @override
  _RequestDownloadState createState() => _RequestDownloadState(this.downloadUrl, this.ebargePath, this.fileName, this.allowBack, this.allowExecute);
}

class _RequestDownloadState extends State<RequestDownload> {
  String? downloadUrl;
  String? ebargePath;
  String? fileName;
  bool? allowBack;
  bool? allowExecute;
  _RequestDownloadState(this.downloadUrl, this.ebargePath, this.fileName, this.allowBack, this.allowExecute);

  double? percentage;
  bool? _proccessing;
  String? fullPath;

  @override
  void initState() {
    // TODO: implement initState
    percentage = 0;
    _proccessing = true;

    _doDownload(downloadUrl!, ebargePath!, fileName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
              padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red, Colors.purpleAccent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      tileMode: TileMode.clamp)),
              child: SafeArea(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SleekCircularSlider(
                            appearance: appearance01,
                            initialValue: percentage!,
                          ),
                          allowBack! ? MaterialButton(
                            height: 35.0,
                            highlightElevation: 2.0,
                            highlightColor: HexColor('#FED1CD'),
                            shape: StadiumBorder(),
                            color: HexColor('#FEA78D').withOpacity(0.9),
                            child: Text('بازگشت!',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w200,
                                    color: HexColor('#BD0016'))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ): Container(),
                          !_proccessing! ?
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                allowExecute! ? MaterialButton(
                                height: 35.0,
                                highlightElevation: 2.0,
                                highlightColor: HexColor('#FED1CD'),
                                shape: StadiumBorder(),
                                color: HexColor('#FEA78D').withOpacity(0.9),
                                child: Text('اجرا'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w200,
                                        color: HexColor('#BD0016'))),
                                onPressed: () {
                                  OpenFile.open(fullPath);
                                },
                              ) : Container(),
                                Text('مسیر ذخیره شده:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w200,
                                        color: HexColor('#f7efec'))),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(fullPath!,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w200,
                                          color: HexColor('#f7efec'))),
                                ),
                              ]) : Container(),

                        ]),
                  )
              )
          ),
        )
    );
  }

  void _doDownload(String downloadUrl, String ebargePath, fileName) async {
    Map<Permission, PermissionStatus> permissions = await [Permission.storage,]
        .request();
    print(permissions[Permission.storage]);
    if (permissions[Permission.storage] == PermissionStatus.granted) {
      String rootStorage = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
      if (await Directory(rootStorage + ebargePath).exists() != true) {
        print("Directory not exist");
        new Directory(rootStorage + ebargePath).create(recursive: true);
      } else {
        print("Directoryexist");
      }
      fullPath = rootStorage + ebargePath + "/" + fileName;
      print('full path $fullPath');

      try {
        var dio = Dio();
        Response response = await dio.get(
          downloadUrl,
          onReceiveProgress: showDownloadProgress,
          //Received data with List<int>
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );

        File file = File(fullPath!);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
      } catch (e) {
        print(e);
      }
    } else {
      print('Permission request fail!');
    }
  }

  showDownloadProgress(received, total) {
    if (received < total) {
      //print((received / total * 100).toStringAsFixed(0) + "%");
      setState(() {
        _proccessing = true;
      });
      percentage = received / total * 100;
    } else {
      setState(() {
        percentage = 100;
        _proccessing = false;
      });
      /* Future.delayed(Duration(seconds: 6)).then((onValue) {
        print("تمام شد!");
        setState(() {
          _proccessing = false;
        });
      });*/
    }
  }
}

final customWidth01 =
CustomSliderWidths(trackWidth: 2, progressBarWidth: 20, shadowWidth: 50);
final customColors01 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#FF8282').withOpacity(0.6),
    progressBarColors: [
      HexColor('#FFE2E2').withOpacity(0.9),
      HexColor('#FFAD8D').withOpacity(0.9),
      HexColor('#FE6490').withOpacity(0.5)
    ],
    shadowColor: HexColor('#FFD7E2'),
    shadowMaxOpacity: 0.08);

final info = InfoProperties(
    mainLabelStyle: TextStyle(
        color: Colors.white, fontSize: 60, fontWeight: FontWeight.w100));

final CircularSliderAppearance appearance01 = CircularSliderAppearance(
    customWidths: customWidth01,
    customColors: customColors01,
    infoProperties: info,
    startAngle: 180,
    angleRange: 180,
    size: 250.0);