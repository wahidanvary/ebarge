
class PaintedObjectsList {
  final List<PaintedObject>? paintedObjects;

  PaintedObjectsList(this.paintedObjects);

  PaintedObjectsList.fromJson(Map<String, dynamic> json)
      : paintedObjects = json['paintedObjects']! != null ? List<PaintedObject>.from(json['paintedObjects']) : null;

  Map<String, dynamic> toJson()  =>
      {
        'paintedObjects': paintedObjects,
      };
}

class PaintedObject {
  final String? mode;
  final String? color;
  final double? strokeWidth;
  final String? style;
  final List<MyOffset>? offsets;
  final String? pText;

  PaintedObject(this.mode, this.color, this.strokeWidth, this.style, this.offsets, this.pText);

  PaintedObject.fromJson(Map<String, dynamic> json)
      : mode = json['mode'],
        color = json['color'],
        strokeWidth = json['strokeWidth'],
        style = json['style'],
        offsets = json['offsets']! != null ? List<MyOffset>.from(json['offsets']) : null,
        pText = json['pText'];

  Map<String, dynamic> toJson() => {
    'mode' : mode,
    'color' : color,
    'strokeWidth' : strokeWidth,
    'style' : style,
    'offsets' : offsets,
    'pText' : pText
  };
}

class MyOffset {
  final double dx;
  final double dy;

  MyOffset(this.dx, this.dy);

  MyOffset.fromJson(Map<String, dynamic> json)
      : dx = json['dx'],
        dy = json['dy'];

  Map<String, dynamic> toJson() => {
    'dx' : dx,
    'dy' : dy
  };
}