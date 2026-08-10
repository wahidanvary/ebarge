// ignore_for_file: file_names

import 'package:ebarge/azbazi/pages/game-page/game-page.dart';
import 'package:ebarge/azbazi/pages/game-page/views/my-final-result-screen.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:flutter/material.dart';
import '../../../utils/hexColor.dart';

class GameOptions extends StatelessWidget {
   GameOptions({super.key, required,required this.finalResultShow, required this.azbazi, required this.book });
  final int finalResultShow;
  final azbaziModel azbazi;
  final bookModel book;
  bool btnResShow = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if(finalResultShow == 2)
      btnResShow = true;

    String buttonTxt = btnResShow ? "مشاهده نتیجه": "برو به بازی";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(
          width: 250,
          child: FancyMainButton(
            buttonTxt: btnResShow ? "مشاهده نتیجه 🏅" : "شروع آزبازی 🎮",
            btnResShow: btnResShow,
          ),
        ),
        SizedBox(),
      ],
    );
  }
}

class FancyMainButton extends StatefulWidget {
  final String buttonTxt;
  final bool btnResShow;
  const FancyMainButton({
    super.key,
    required this.buttonTxt,
    required this.btnResShow,
  });

  @override
  State<FancyMainButton> createState() => _FancyMainButtonState();
}

class _FancyMainButtonState extends State<FancyMainButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.btnResShow
        ? const Color(0xFF6A5AE0) // رنگ بنفش مایل به آبی برای مشاهده نتیجه
        : const Color(0xFFF56E98); // رنگ صورتی-قرمز برای شروع بازی

    final Color accentColor = widget.btnResShow
        ? const Color(0xFF9C8CF5)
        : const Color(0xFFFF8FB1);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        if (widget.btnResShow) {
          Navigator.pushNamed(context, MyFinalResultScreen.route);
        } else {
          Navigator.pushNamed(context, GamePage.route, arguments: {'qIndex': -1});
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: Container(
          width: 220,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.buttonTxt,
                  style: const TextStyle(
                    fontFamily: "Vazir",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
