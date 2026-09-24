import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:ebarge/models/shopModel.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/userProvider.dart';
import '../../services/GlobalKeys.dart';
import '../../services/accessCheck.dart';
import '../../utils/hexColor.dart';
import 'myBooks.dart';

class GoldShopScreen extends StatefulWidget {
  GoldShopScreen({super.key, this.walGold, required this.shopData, required this.userData});
  int? walGold;
  final UserModel userData;
  final List<shopModel> shopData;

  @override
  State<GoldShopScreen> createState() => _GoldShopScreenState();
}

class _GoldShopScreenState extends State<GoldShopScreen> {
 // @override
  final dynamicPriceTokenController = TextEditingController();
  final productIdController = TextEditingController();
  bool connected = false;
  String status = "";
  bool consume = true;
  late bool buyBtnClicked;

  @override
  void initState() {
    buyBtnClicked = false;
    _initShop();
    super.initState();
  }

  Future<void> _initShop() async {
    String rsaKey =
        "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwC82qtzp2xcNn3tNFpc0TQZo6OkO0/U869T/JDpuFJBaGs2I3QQ0y1qojjopJRdH1740YY/JltToUj/Kh2DF8myY9AvQ2XboyGGDkY36AgSsjoU70Pljx/vXAMmDKQsrc+Njy3w8bZ3C5CZf3PJ9R73Lo+okJZgfE3KavUc5OBE3cqikfKWmXE7Lu+5wha3rV27tpOlpCksNPupUQp6/RTC1p77567iNU7dFMeMdK8CAwEAAQ==";
    try {
      connected = await FlutterPoolakey.connect(
        rsaKey,
        onDisconnected: () => showSnackBar("پرداخت قطع شد!"),
      );
    } on Exception catch (e) {
      showSnackBar(e.toString());
      setState(() {
        status = "پیام از بازار: خطا در اتصال";
      });
    }

    setState(() {
      if (!connected) {
        status = "پیام از بازار: ارتباط برقرار نشد";
      } else {
        status = "پیام از بازار: ارتباط برقرار شد";
      }
    });
  }

  purchaseProduct(
      String productId,
      int goldAmount,
      String payload,
      String? dynamicPriceToken,
      ) async {
    if (!connected) {
      showSnackBar('پیام از بازار: ارتباط برقرار نشد');
      return;
    }
    try {
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
      PurchaseInfo? response = await FlutterPoolakey.purchase(productId,
          payload: payload, dynamicPriceToken: dynamicPriceToken ?? "");
      if (consume) {
        buyBtnClicked = true;
        consumePurchasedItem(productId, goldAmount, response.purchaseToken);
      }
    } catch (e) {
      showSnackBar("پیام از بازار: خرید لغو شد!");
      return;
    }
  }

  Future<void> consumePurchasedItem(String productId, int goldAmount, String purchaseToken) async {
    if (!connected) {
      showSnackBar('پیام از بازار: ارتباط برقرار نشد');
      return;
    }

    try {
      bool? response = await FlutterPoolakey.consume(purchaseToken);

      var ebargeResponse;
      if(response){
        try {
          var url = GlobalKeys.ebargeUrl + '/index.php?option=com_jbackend&view=request&action=get&module=user&resource=goldpurchase';

          var dio = Dio();
          FormData formData = new FormData.fromMap({
            "product_id": productId,
            "purchase_token": purchaseToken,
          });

          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var cookieJar = PersistCookieJar(
              ignoreExpires: true,
              storage: FileStorage(appDocPath+"/.cookies/"));
          dio.interceptors.add(CookieManager(cookieJar));
          ebargeResponse = await dio.post(url, data: formData);

          final Map<String, dynamic> ebargeData = ebargeResponse.statusCode != 200
              ? <String, dynamic>{
                  "status": "ko",
                  "error_code": "ebarge_fail",
                  "error_description": "در ارتباط شما با ایبرگه حطایی رخ داد با پشتیبانی تماس بگیرید!",
                }
              : ebargeResponse.data;

          if(ebargeData["status"] == "ok"){
            setState(() {
              widget.walGold = widget.walGold! + goldAmount;
            });
            showSnackBar("خرید با موفقیت انجام شد...");
          }

          else
            showSnackBar(ebargeData["error_description"]);
        } catch (e) {
          showSnackBar("خطا در خرید ${e.toString()}");
        }
      } else
        showSnackBar("پیام از بازار: خطا در خرید");

    } catch (e) {
      showSnackBar("خطا در خرید ${e.toString()}");
      return;
    }
  }

  void showSnackBar(String TXT) {
    // NOTE: This must NOT push a route. A Flushbar is pushed onto the Navigator
    // (Flushbar.show -> Navigator.push) and removes itself with Navigator.pop()
    // when its duration expires. That self-pop can throw inside NavigatorState.pop()
    // while _debugLocked is held, which permanently locks the Navigator in debug
    // builds; the very next Navigator.push (e.g. a later tap here) then fails
    // asserts !_debugLocked. SnackBar is an overlay, so it never touches the
    // Navigator and cannot lock it.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            TXT,
            style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: "Vazir"),
          ),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.black54,
      ),
    );
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result)  async {
        if (didPop) return;
        final backNavigationAllowed = buyBtnClicked;
        if (!backNavigationAllowed) {
          if (mounted) Navigator.of(context).pop();
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) => MyBooks(widget.userData)), (route) => false,
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              !buyBtnClicked ? Navigator.of(context).pop() : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) => MyBooks(widget.userData)), (route) => false,
              );
            },
          ),
          elevation: 0,
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: InkWell(
                    child: const Icon(Icons.help_center_outlined, color: Colors.white,),
                    onTap: () {
                      showDialog(context: context, builder: (context) =>
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              title: Text('',),
                              content: Text(
                                'به ازای هر 10واحد طلای کاوش شده 1 سکه می توانید ضرب کنید و در آزبازی ها استفاده نمایید.',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontFamily: "Vazir"
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () =>
                                    Navigator.of(context).pop(), child: Text(
                                  'باشه',),)
                              ],
                            ),
                          ));
                    }
                ),
              ),
          ],
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 3,
                ),
                child: Image.asset(
                  'assets/images/mined_gold.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(width: 8),
              Text(AccessCheck().replaceFarsiNumber('${widget.walGold}'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Vazir",
                      fontSize: 20)),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/space_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Image.asset('assets/images/coin_shop_banner.png', height: 60),
                  SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        List<GoldPackageData> packages = [
                          GoldPackageData(userId: widget.userData.userid!, productId: widget.shopData[0].productId!, goldAmount: widget.shopData[0].goldAmount!, zafran: widget.shopData[0].bonusZafran!, price: widget.shopData[0].priceAmount!, bonus: widget.shopData[0].bonusPercent!, imgTXT: "1xgold.png"),
                          GoldPackageData(userId: widget.userData.userid!, productId: widget.shopData[1].productId!, goldAmount: widget.shopData[1].goldAmount!, zafran: widget.shopData[1].bonusZafran!, price: widget.shopData[1].priceAmount!, bonus: widget.shopData[1].bonusPercent!, imgTXT: "2xgold.png"),
                          GoldPackageData(userId: widget.userData.userid!, productId: widget.shopData[2].productId!, goldAmount: widget.shopData[2].goldAmount!, zafran: widget.shopData[2].bonusZafran!, price: widget.shopData[2].priceAmount!, bonus: widget.shopData[2].bonusPercent!, imgTXT: "3xgold.png"),
                          GoldPackageData(userId: widget.userData.userid!, productId: widget.shopData[3].productId!, goldAmount: widget.shopData[3].goldAmount!, zafran: widget.shopData[3].bonusZafran!, price: widget.shopData[3].priceAmount!, bonus: widget.shopData[3].bonusPercent!, imgTXT: "4xgold.png"),
                        ];
                        return GoldPackage(packageData: packages[index], purchaseProduct: purchaseProduct);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoldPackageData {
  final String userId;
  final String productId;
  final int goldAmount;
  final double zafran;
  final int price;
  final int? bonus;
  final String imgTXT;

  GoldPackageData({required this.userId, required this.productId, required this.goldAmount, required this.zafran, required this.price, this.bonus, required this.imgTXT});
}

class GoldPackage extends StatelessWidget {
  final GoldPackageData packageData;
  final Function purchaseProduct;

  const GoldPackage({Key? key, required this.packageData, required this.purchaseProduct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // MediaQuery is here now

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FloatingActionButton(
            heroTag: "btn"+packageData.productId,
            backgroundColor: Colors.transparent,
            onPressed: () {
              purchaseProduct(
                packageData.productId,
                packageData.goldAmount,
                packageData.productId+"pchPayload"+packageData.userId,
                "",
              );
              print(packageData.price);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Color(0xFF2962FF), Color(0xFF0D47A1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AvatarGlow(
                            glowColor: Colors.yellowAccent,
                            child: Material(
                              elevation: 8.0,
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                backgroundColor: Colors.yellowAccent,
                                radius: 40.0,
                                child: Image.asset(
                                  'assets/images/${packageData.imgTXT}',
                                  fit: BoxFit.contain,
                                  frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) {
                                      return child;
                                    }
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      child: child,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                    Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Text('طلا',
                            style: TextStyle(
                                color: Colors.yellowAccent,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Vazir",
                                fontSize: screenHeight * 0.016)),
                        ]),
                        Text('${AccessCheck().replaceFarsiNumber(packageData.goldAmount.toString())}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: screenHeight * 0.026,
                              shadows: [Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1))]),
                        ),
                        if (packageData.bonus != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                HexColor('#FFD700'),
                                HexColor('#FFBF00'),
                              ]),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text('+${AccessCheck().replaceFarsiNumber(packageData.bonus.toString())}% هدیه',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Vazir",
                                        fontSize: screenHeight * 0.016)),
                                  packageData.zafran > 0 ? Text(' +${AccessCheck().replaceFarsiNumber(packageData.zafran.toString())}',
                                      style: TextStyle(
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Vazir",
                                          fontSize: screenHeight * 0.016)):Container(),
                                  packageData.zafran > 0 ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 0,
                                    ),
                                    child: Image.asset(
                                      'assets/images/zafran.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                  ):Container(),
                                 ]
                            ),
                          ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              HexColor('#50C878'),
                              HexColor('#9FE2BF'),
                            ]),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)),
                          ),
                          child: Text('${AccessCheck().replaceFarsiNumber(packageData.price.toString())} تومان', style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Vazir",
                              fontSize: screenHeight * 0.020)),
                        ),
                      ],
                    ),
                  ),
                  if (packageData.bonus != null && packageData.goldAmount >= 5000)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Image.asset('assets/images/hot_tag.png', height: screenHeight * 0.08),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}