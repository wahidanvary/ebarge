import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';


takeScreenShot(GlobalKey key) async {
  final permission = Platform.isAndroid ? Permission.storage : Permission.photos;
  final permissionStatus = await permission.request();
  if (PermissionStatus.denied == permissionStatus) {
    await openAppSettings();
    return;
  }
  if (PermissionStatus.granted != permissionStatus) {
    return;
  }
  RenderRepaintBoundary? boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
  final image = await boundary!.toImage();
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  Uint8List pngBytes = byteData!.buffer.asUint8List();

  //await ImageGallerySaver.saveImage(pngBytes);

  // Fluttertoast.showToast(
  //   msg: 'عکس در گالری ذخیره شد.',
  //   toastLength: Toast.LENGTH_LONG,
  //   gravity: ToastGravity.CENTER,
  // );
}


String pathOfImages(String name) {
  return 'assets/images/$name';
}
