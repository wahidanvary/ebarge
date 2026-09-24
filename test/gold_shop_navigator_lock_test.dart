import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ebarge/models/shopModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/screens/books/goldShop.dart';

// Regression test for the crash reported on the gold shop screen:
//   package button tap -> purchaseProduct() -> !connected -> showSnackBar()
//   -> Flushbar.show() -> Navigator.push -> assert(!_debugLocked) [navigator.dart:5080]
//
// The lock got stuck because an earlier Flushbar removed itself via a duration
// Timer calling Navigator.pop(); that pop threw an internal assertion while
// _debugLocked was held, so it was never cleared. Repeating the notification on
// top of a still-present one must not lock the Navigator.
void main() {
  testWidgets('repeated !connected notification does not lock the Navigator', (tester) async {
    final List<shopModel> shopData = List<shopModel>.generate(
      4,
      (int i) => shopModel(
        productId: 'p$i',
        priceAmount: 1000,
        bonusPercent: 10,
        bonusZafran: 1.0,
        goldAmount: 100,
        sellStatus: 'ok',
      ),
    );
    final UserModel userData = UserModel(userid: 'u1', walletAmount: 100);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoldShopScreen(shopData: shopData, userData: userData, walGold: 100),
    ));

    // _initShop() finishes; the poolakey plugin is absent so `connected` stays false.
    await tester.pump(const Duration(milliseconds: 1500));

    // First tap: purchaseProduct() takes the !connected branch -> showSnackBar().
    expect(find.byType(FloatingActionButton), findsWidgets);
    await tester.tap(find.byType(FloatingActionButton).first);
    await tester.pump(const Duration(milliseconds: 200));

    // Let the 3s notification duration elapse (this is what used to stick the lock).
    await tester.pump(const Duration(seconds: 4));

    // Second tap: the exact operation that used to trip assert(!_debugLocked).
    await tester.tap(find.byType(FloatingActionButton).first);
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });
}
