import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'image_painter.dart';

// ignore: prefer_mixin
class HistoryModel with ChangeNotifier, DiagnosticableTreeMixin {
  final  List<PaintInfo>? _paintHistory = <PaintInfo>[];

  void increment() {
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }

  void addEndPoints(Offset? dx,Offset? dy, ValueNotifier<Controller> controller, Paint _painter) {
    _paintHistory!.add(
      PaintInfo(
        offset: <Offset?>[dx, dy],
        painter: _painter,
        mode: controller.value.mode,
      ),
    );
    notifyListeners();
  }


  // ignore: file_names
  void addFreeStylePoints(List<Offset?> _points, Paint _painter) {
    _paintHistory!.add(
      PaintInfo(
        offset: <Offset?>[..._points],
        painter: _painter,
        mode: PaintMode.freeStyle,
      ),
    );
    notifyListeners();
  }

  Future<void> openTextDialog(String text, Paint painter, List<Offset?> textOffset) async{
    if (text != '') {
        _paintHistory!.add(
          PaintInfo(
              mode: PaintMode.text,
              text: text,
              painter: painter,
              offset: textOffset
          ),
        );
    }
  }

  List<PaintInfo>? get paintHistory {
    return _paintHistory;
  }
}
