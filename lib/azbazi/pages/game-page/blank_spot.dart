

import 'package:ebarge/azbazi/pages/game-page/text.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:like_button/like_button.dart';

class BlankSpot extends StatefulWidget {
  final String character;
  final int holPoint;
  final Function onAcceptChar;
  final Color borderColor;
  final int index;
  final Function updateBlanks;
  const BlankSpot({super.key,
    required this.character,
    required this.holPoint,
    required this.onAcceptChar,
    required this.borderColor,
    required this.index,
    required this.updateBlanks,
  });

  @override
  _BlankSpotState createState() => _BlankSpotState();
}

class _BlankSpotState extends State<BlankSpot> {
  double scaleFactor = 1;
  final GlobalKey _blankSpotKey = GlobalKey();
  Color boxColor = Colors.white;

  Widget empty() {
    return SizedBox(
      key: _blankSpotKey,
      width: 70 * scaleFactor,
      height: 45 * scaleFactor,
      child: LikeButton(
        size: 40,
        circleColor:
        CircleColor(start: Color(0xff00ddff), end: Color(
            0xff0099cc)),
        bubblesColor: BubblesColor(
          dotPrimaryColor: Color(0xff33b5e5),
          dotSecondaryColor: Color(0xff0099cc),
        ),
        likeBuilder: (bool isLiked) {
          return Icon(
            Icons.add,
            color: boxColor,
            size: 40,
          );
        },
      ),
    );
  }

  Widget textWithCard(char) {
    return SizedBox(
      width: 45,
      // height: 30,
      child: Card(
        elevation: 4,
        child: TextWidget(text: char),
      ),
    );
  }

  Widget highLightedTextWithCard(
    char, {
    scale = 1.0,
    x = 0.0,
    y = 0.0,
    grayColor = false,
  }) {
    String processedChar= AccessCheck().preprocessLatex(char);
    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          child: Card(
              color: grayColor ? Colors.pinkAccent : Theme.of(context).focusColor,
              elevation: 4,
              child: HtmlWidget(processedChar,//_______
                customWidgetBuilder: (element) {
                  if (element.localName == 'latex-inline') {
                    final formulaEncoded = element.attributes['data'] ?? '';
                    var formula = Uri.decodeComponent(formulaEncoded);
                    formula = AccessCheck().replaceFarsiNumber(formula);

                    return InlineCustomWidget(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        // ✅ تغییر مهم: اجبار جهت چپ به راست برای فرمول
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Math.tex(
                            formula,
                            textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.black, fontFamily: "Vazir"
                            ),
                            mathStyle: MathStyle.text,
                            onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                      ),
                    );
                  }

                  // ب) فرمول‌های بلوکی (Block)
                  if (element.localName == 'latex-block') {
                    final formulaEncoded = element.attributes['data'] ?? '';
                    var formula = Uri.decodeComponent(formulaEncoded);
                    formula = AccessCheck().replaceFarsiNumber(formula);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Math.tex(
                          formula,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: "Vazir"
                          ),
                          mathStyle: MathStyle.display,
                          onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                renderMode: RenderMode.column,
                // set the default styling for text
                textStyle: const TextStyle(fontSize: 14,),
              ),
            ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //keys = new Keys();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Offset localOffset = renderBox.globalToLocal(Offset(-45, 0));

      final bounds = context.globalPaintBounds;
      if (bounds != null) {
        // print('Global coordinates: ${bounds.toString()}');
        // print(localOffset);
      } else {
        print('Could not get global bounds');
      }

    });
    String processedCharacter= AccessCheck().preprocessLatex(widget.character);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 70 * scaleFactor,
      height: 45 * scaleFactor,
      child: Container(
        // key: UniqueKey(),
        alignment: Alignment.center,
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            style: BorderStyle.solid,
            color: widget.borderColor, //Theme.of(context).accentColor,
          ),
          borderRadius: BorderRadius.circular(4.0),
          color: boxColor,
        ),
        child: Center(
          child: DragTarget<List>(
            builder: (BuildContext con, List<List?> incoming, List rejected) {
              if (widget.character == "") {
                return empty();
              } else {
                return Draggable<List>(
                  data: ["-1", widget.character, widget.holPoint],
                  childWhenDragging: const TextWidget(text: ""),
                  feedback: highLightedTextWithCard(
                    widget.character,
                    scale: 1.25,
                    x: 0.0,
                    y: 0.0,
                  ),
                  onDragCompleted: () {
                    widget.updateBlanks(
                      ["-1", "", "0"],
                      widget.index,
                      context,
                      updateDragables: false,
                    );
                  },
                  onDraggableCanceled: (_, __) {
                    widget.updateBlanks(
                      ["-1", "", "0"],
                      widget.index,
                      context,
                    );
                  },
                  // onDragEnd: (details) {
                  //   if(details.offset.dx != 0 && details.offset.dy != 0){
                  //     final RenderBox blankSpotRenderBox = _blankSpotKey.currentContext!.findRenderObject() as RenderBox;
                  //     final blankSpotPosition = blankSpotRenderBox.localToGlobal(Offset.zero);
                  //     final dropPosition = details.offset;
                  //     final offsetDifference = dropPosition.dx - blankSpotPosition.dx;
                  //     widget.updateBlanks(["-1", "", "0"], widget.index, context, offsetDifference: offsetDifference);
                  //   }
                  // },
                  child: HtmlWidget(processedCharacter,
                      customWidgetBuilder: (element) {
                        if (element.localName == 'latex-inline') {
                          final formulaEncoded = element.attributes['data'] ?? '';
                          var formula = Uri.decodeComponent(formulaEncoded);
                          formula = AccessCheck().replaceFarsiNumber(formula);

                          return InlineCustomWidget(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              // ✅ تغییر مهم: اجبار جهت چپ به راست برای فرمول
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Math.tex(
                                  formula,
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black, fontFamily: "Vazir"
                                  ),
                                  mathStyle: MathStyle.text,
                                  onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                                ),
                              ),
                            ),
                          );
                        }

                        // ب) فرمول‌های بلوکی (Block)
                        if (element.localName == 'latex-block') {
                          final formulaEncoded = element.attributes['data'] ?? '';
                          var formula = Uri.decodeComponent(formulaEncoded);
                          formula = AccessCheck().replaceFarsiNumber(formula);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Math.tex(
                                formula,
                                textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontFamily: "Vazir"
                                ),
                                mathStyle: MathStyle.display,
                                onErrorFallback: (err) => Text(formula, style: const TextStyle(color: Colors.red)),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    textStyle:  TextStyle(fontSize:13, height: 1.0),),
                );
              }
            },
            onWillAcceptWithDetails: (details) {
              setState(() {
                boxColor = Colors.black12;
                scaleFactor = 1;
              });
              return true;
            },
            onAcceptWithDetails: (details) {
              widget.onAcceptChar(details.data);
              setState(() {
                boxColor = Colors.white;
                scaleFactor = 1;
              });
            },
            onLeave: (List? data) {
              setState(() {
                boxColor = Colors.white;
                scaleFactor = 1;
              });
            },
          ),
        ),
      ),
    );
  }
}

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject(); // Get the RenderObject associated with the widget
    final translation = renderObject?.getTransformTo(null).getTranslation(); // Get its transformation matrix and extract translation

    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y); // Convert translation to Offset
      return renderObject!.paintBounds.shift(offset); // Shift the paint bounds by the offset
    } else {
      return null;
    }
  }
}
