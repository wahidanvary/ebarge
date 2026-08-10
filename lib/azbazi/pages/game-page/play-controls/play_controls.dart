import 'package:ebarge/azbazi/change-notifiers/coins-notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayControls extends StatefulWidget {
  final Function useHint;
  final bool showHint;

  const PlayControls({
    super.key,
    required this.useHint,
    required this.showHint,
  });

  @override
  State<PlayControls> createState() => _PlayControlsState();
}

class _PlayControlsState extends State<PlayControls> {
  bool _isHintBTNDisabled = false;

  Future<void> _handleHintBTN(BuildContext context) async {
    if (_isHintBTNDisabled) return;

    setState(() {
      _isHintBTNDisabled = true;
    });

    try {
      await widget.useHint(context, isPageView: false);
    } catch (e) {
      debugPrint("خطا در دریافت راهنمایی: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isHintBTNDisabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // بررسی اینکه آیا دکمه باید فعال باشد یا خیر
    final bool isEnabled = !widget.showHint && !_isHintBTNDisabled;

    return Column(
      children: <Widget>[
        Consumer<CoinsNotifier>(
          builder: (_, coinsRef, child) {
            return Container(
              width: 80, // کمی عریض‌تر برای زیبایی
              height: 40, // ارتفاع بیشتر برای لمس راحت‌تر
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14), // گوشه‌های کاملا گرد
                boxShadow: [
                  // سایه رنگی و جذاب (Glow Effect)
                  BoxShadow(
                    color: isEnabled
                        ? Colors.tealAccent.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 1,
                  ),
                ],
                // گرادینت برای زیبایی بیشتر
                gradient: isEnabled
                    ? const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], // ترکیب آبی اقیانوسی و فیروزه‌ای
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: isEnabled ? () => _handleHintBTN(context) : null,
                  child: Center(
                    child: _isHintBTNDisabled
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // آیکون سکه با کمی سایه
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ]
                          ),
                          child: Image.asset(
                            'assets/images/help.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'راهنما',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold, // فونت ضخیم‌تر
                            letterSpacing: 0.5,
                            fontFamily: 'Vazir', // اگر فونت فارسی دارید اینجا ست کنید
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}