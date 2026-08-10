import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebarge/azbazi/change-notifiers/scores-notifier.dart';
import '../../../services/accessCheck.dart';
import '../../../utils/hexColor.dart';

class ScoreView extends StatefulWidget {
  const ScoreView({super.key});

  @override
  State<ScoreView> createState() => _ScoreViewState();
}

class _ScoreViewState extends State<ScoreView> {
  double _opacity = 1.0;
  double _currentScore = 0.0;
  late ScoresNotifier _scoreNotifier; // 🔹 ذخیره reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // فقط یکبار listener اضافه شود
    if (!mounted) return;
    _scoreNotifier = Provider.of<ScoresNotifier>(context, listen: false);
    _scoreNotifier.addListener(_onScoreChanged);
  }

  @override
  void dispose() {
    // از context استفاده نمی‌کنیم، مستقیم به notifier دسترسی داریم
    _scoreNotifier.removeListener(_onScoreChanged);
    super.dispose();
  }

  void _onScoreChanged() async {
    final newScore = _scoreNotifier.score;

    if (newScore != _currentScore) {
      _currentScore = newScore!;
      await _blinkEffect();
    }
  }

  Future<void> _blinkEffect() async {
    if (!mounted) return;
    setState(() => _opacity = 0.4);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _opacity = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: HexColor("#005b96"),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Image.asset(
              'assets/images/score.png',
              height: 24,
              width: 24,
            ),
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: Consumer<ScoresNotifier>(
              builder: (_, scoreNotifier, __) {
                return Text(
                  '${AccessCheck().replaceFarsiNumber(scoreNotifier.score.toString())}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    fontFamily: "Vazir",
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
