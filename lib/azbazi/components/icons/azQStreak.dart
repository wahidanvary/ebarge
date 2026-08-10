import 'package:ebarge/azbazi/change-notifiers/azStreak-notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/accessCheck.dart';
import '../../../utils/hexColor.dart';

class AzQStreakView extends StatefulWidget {
  const AzQStreakView({super.key});

  @override
  State<AzQStreakView> createState() => _AzQStreakViewState();
}

class _AzQStreakViewState extends State<AzQStreakView> {
  double _opacity = 1.0;
  int _currentAzQStreak = 0;
  late AzQStreakNotifier _azQStreakNotifier; // 🔹 ذخیره reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // فقط یکبار listener اضافه شود
    if (!mounted) return;
    _azQStreakNotifier = Provider.of<AzQStreakNotifier>(context, listen: false);
    _azQStreakNotifier.addListener(_onAzQStreakChanged);
  }

  @override
  void dispose() {
    // از context استفاده نمی‌کنیم، مستقیم به notifier دسترسی داریم
    _azQStreakNotifier.removeListener(_onAzQStreakChanged);
    super.dispose();
  }

  void _onAzQStreakChanged() async {
    final newAzQStreak = _azQStreakNotifier.azQStreak;

    if (newAzQStreak != _currentAzQStreak) {
      _currentAzQStreak = newAzQStreak!;
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
              'assets/images/AzQStreak.png',
              height: 24,
              width: 24,
            ),
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: Consumer<AzQStreakNotifier>(
              builder: (_, azQStreakNotifier, __) {
                return Text(
                  '${AccessCheck().replaceFarsiNumber(azQStreakNotifier.azQStreak.toString())}',
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
