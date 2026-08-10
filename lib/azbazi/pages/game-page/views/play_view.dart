import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/material.dart';
import 'package:ebarge/models/questionModel.dart';

import '../../../../utils/hexColor.dart';

class PlayView extends StatefulWidget {
  final Function populateQuestion;
  final Function populateBox1ContentHtml;
  final String qBox1ContentHtml;
  List blankChars;
  final Function getDragables;
  final List dragables;
  final Function usePageOrHint;
  final Function fetchNewQuestion;
  late Function changeCoinsNotifier;
  late Function changeScoreNotifier;
  final bool showHint;
  azbaziModel azbazi;
  final questionModel question;
  PlayView({super.key,
    required this.populateQuestion,
    required this.populateBox1ContentHtml,
    required this.qBox1ContentHtml,
    required this.blankChars,
    required this.getDragables,
    required this.dragables,
    required this.usePageOrHint,
    required this.fetchNewQuestion,
    required this.changeCoinsNotifier,
    required this.changeScoreNotifier,
    required this.showHint,
    required this.azbazi,
    required this.question,
  });

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {

  List<Widget> qBox1Widgets = [];
  String qBox1ContentHtmlCopy = "";

  @override
  void initState() {
    super.initState();
  }

  double _getYOffsetOf(GlobalKey key) {
   // if (key.currentContext == null) return 0;
    final box = key.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero).dy;
  }

  void _resolveSameRowBlank(List rowBlankChars) {
    var middle = (rowBlankChars.length / 2.0).floor();
    for (int keyIndex = 0; keyIndex < middle; keyIndex++) {
      int lbCharPoint = rowBlankChars[keyIndex]["holePoint"];
      int rbCharPoint = rowBlankChars[rowBlankChars.length - keyIndex - 1]["holePoint"];
      for(int pointIndex = lbCharPoint - 1; pointIndex < rbCharPoint; pointIndex++){
        if( lbCharPoint == widget.blankChars[pointIndex]["holePoint"] )
          widget.blankChars[pointIndex]["holePoint"] = rbCharPoint;
        else if( rbCharPoint == widget.blankChars[pointIndex]["holePoint"] )
          widget.blankChars[pointIndex]["holePoint"] = lbCharPoint;
      }
    }
  }

  List<Widget>? getHint() {
    if (widget.question.guide != null && widget.question.guide!.length > 5) {
      var guide = widget.question.guide;
      return [
        const SizedBox(
          width: double.infinity,
          child: Text(
            "راهنما:",
            style: TextStyle(
              fontSize: 20,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.arrow_forward_ios),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  guide ?? '',
                  style: const TextStyle(fontSize: 16),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),

      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    qBox1ContentHtmlCopy = widget.populateBox1ContentHtml(qBox1ContentHtmlCopy, context);
    qBox1Widgets = widget.populateQuestion(widget.blankChars, context);

    final keys = <GlobalKey<_WidgetSpanWrapperState>>[];
    nextKey() {
      var key = GlobalKey<_WidgetSpanWrapperState>();
      keys.add(key);
      return key;
    }

    //dasturat zir be dalil irad dar RTL haste flutter va adam taviz dorost widgethaye jaykhali emal shode ast
    //ma bara hal moshkel pointer jakhali ro dobare chinesh mikonim ta entekhab karbar bedorosti sanjide shavad
    // satr(row) balaye 0 bashe yani yekbar qablan chinesh shode va niyazi be chinesh mojadad nis
    if(widget.blankChars.isNotEmpty && widget.blankChars[0]["row"] == 0){
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        List<GlobalKey<_WidgetSpanWrapperState>>? sameRow;
        List tempAllBlank =  [...widget.blankChars];
        List sameRowBlank = [];

        if(keys.isNotEmpty) {
          int bRow = 1; // satri ke jakhali dar an qarar qerefte ast
          int keyIndex = 0;
          GlobalKey<_WidgetSpanWrapperState> prev = keys.removeAt(0);
          var prevBlank = tempAllBlank.removeAt(0);
          widget.blankChars[keyIndex]["row"] = bRow;
          for (var key in keys) {
            keyIndex ++;
            //     print(_getYOffsetOf(key).toString() +"DDD"+ _getYOffsetOf(prev).toString());
            if (_getYOffsetOf(key) == _getYOffsetOf(prev)) {
              widget.blankChars[keyIndex]["row"] = bRow;
              sameRow ??= [prev];
              if(sameRowBlank.isEmpty)
                sameRowBlank.add(prevBlank);
              sameRow.add(key);
              sameRowBlank.add(tempAllBlank[keyIndex-1]);

            } else if (sameRow != null) {
              //_resolveSameRow(sameRow);
              _resolveSameRowBlank(sameRowBlank);
              bRow++;
              widget.blankChars[keyIndex]["row"] = bRow;
              sameRow = null;
              sameRowBlank = [];
            } else {
              bRow++;
              widget.blankChars[keyIndex]["row"] = bRow;
            }

            prev = key;// done done mire jolo
            prevBlank = widget.blankChars[keyIndex];
          }
          if (sameRow != null) {
            widget.blankChars[keyIndex]["row"] = bRow;
            //_resolveSameRow(sameRow);
            _resolveSameRowBlank(sameRowBlank);
          }

        }
      });
    }

    String processedHtml = AccessCheck().preprocessLatex(qBox1ContentHtmlCopy);

    return  Directionality(
      textDirection: TextDirection.rtl,
      child: FantasyFillBlankBox(
        backgroundColor: HexColor("#d4efdf"),
        padding: const EdgeInsets.all(14),
        border: Border.all(color: HexColor("#1e8449"), width: 3),
        child: PrimaryScrollController(
          controller: ScrollController(),
          child: ListView(
            primary: false,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              Container(
                child: Center(
                  child: InteractiveViewer(
                    panEnabled: false,
                    boundaryMargin: const EdgeInsets.all(80),
                    minScale: 0.5,
                    maxScale: 4,
                    child: HtmlWidget(
                      processedHtml,
                      customWidgetBuilder: (element) {
                        // بخش ۱: جای‌خالی‌ها
                        if (qBox1Widgets.length > 0 && element.localName != null && element.localName!.startsWith('kh')) {
                          int? hole = int.tryParse(element.localName!.substring(2));
                          if (hole != null && hole >= 1 && hole <= qBox1Widgets.length) {
                            return InlineCustomWidget(
                              alignment: PlaceholderAlignment.middle,
                              child: WidgetSpanWrapper(
                                key: nextKey(),
                                child: holeWidget(blankWidget: qBox1Widgets[hole - 1], order: hole,
                                ),
                              ),
                            );
                          }
                        }

                        // بخش ۲: فرمول‌های ریاضی
                        // الف) فرمول‌های درون خطی (Inline)
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
                            // ✅ تغییر مهم: اجبار جهت چپ به راست برای فرمول
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
                      // افزایش ارتفاع خط برای اینکه فرمول‌های بزرگتر با متن تداخل نکنند
                      textStyle: const TextStyle(fontSize: 16, height: 2.2),
                    ),

                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Divider(),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: widget.getDragables(widget.dragables),
                  ),
                ),
              ),
              widget.question.guide != null && widget.question.guide!.length > 5 ? FractionallySizedBox(
                widthFactor: 0.9,
                child: widget.showHint
                    ? SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      ...getHint()!,
                    ],
                  ),
                )
                    : Container(),
              ): Container(),

              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class holeWidget extends StatelessWidget {
  final Widget blankWidget;
  final int order;

  holeWidget({Key? key, required this.blankWidget, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return blankWidget;
  }
}

class WidgetSpanWrapper extends StatefulWidget {
  const WidgetSpanWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<WidgetSpanWrapper> createState() => _WidgetSpanWrapperState();
}

class _WidgetSpanWrapperState extends State<WidgetSpanWrapper> {
  Offset offset = Offset.zero;

  void updateXOffset(double xOffset) {

    setState(() {
      offset = Offset(0.0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate( // Use Transform.translate for visual offset
      offset: offset,
      child: widget.child,
    );
  }
}

class FantasyFillBlankBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final DecorationImage? backgroundImage;

  const FantasyFillBlankBox({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.backgroundColor = const Color.fromRGBO(245, 222, 179, 0.8), // Parchment-like
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.border = const Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(139, 69, 19, 0.5), width: 2), // Dark wood border
    ),
    this.boxShadow = const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
    this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        image: backgroundImage,
      ),
      padding: padding,
      child: child,
    );
  }
}