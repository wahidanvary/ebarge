import 'dart:io';
import 'package:app_links/app_links.dart'; // ✅ مدیریت لینک‌های بیرونی
import 'package:ebarge/database/ebargeDBHelper.dart';
import 'package:ebarge/screens/books/myBooks.dart';
import 'package:ebarge/screens/login/linkLoaderPage.dart';
import 'package:ebarge/screens/login/login.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ebarge/models/userModel.dart';

// ✅ نگهداری ID آزبازی برای زمانی که کاربر هنوز لاگین نکرده
String? pendingAzbaziId;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  await ebargeDBHelper().database;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(OurEbargeApp()));
}

class OurEbargeApp extends StatefulWidget {
  @override
  State<OurEbargeApp> createState() => _OurEbargeAppState();
}

class _OurEbargeAppState extends State<OurEbargeApp> {
  late final AppLinks _appLinks;
  late UserProvider userProvider = UserProvider.instance();

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // لینک اولیه (وقتی اپ از لینک باز میشه)
    final uri = await _appLinks.getInitialLink();
    if (uri != null) _handleUri(uri, isInitial: true);

    // لینک در حال اجرا
    _appLinks.uriLinkStream.listen((uri) {
      userProvider.pendingAzbaziLink = uri.toString();
      _handleUri(uri, isInitial: false);
    });
  }

  void _handleUri(Uri uri, {bool isInitial = false}) async {
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'azbazi') {
      final azbaziId = uri.pathSegments[1];
      debugPrint("🎯 Deep Link دریافت شد: $azbaziId | isInitial = $isInitial");

      if (isInitial) {
        userProvider.pendingAzbaziLink = uri.toString();
        return;
      }

      final user = userProvider.getUserProvider;
      if (userProvider.status == Status.Authenticated && user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 🔸 تأخیر کوتاه برای اطمینان از آزاد شدن Navigator
          await Future.delayed(const Duration(milliseconds: 100));

          if (navigatorKey.currentState != null) {
            debugPrint("🚀 هدایت به LinkLoaderPage...");
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => LinkLoaderPage(
                  uri: uri,
                  user: user,
                  userProvider: userProvider,
                ),
              ),
            );
          } else {
            debugPrint("⚠️ navigatorKey هنوز آماده نیست.");
          }
        });
      } else {
        debugPrint("🔒 کاربر احراز هویت نشده، ذخیره لینک برای بعد از ورود");
        userProvider.pendingAzbaziLink = uri.toString();
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<UserProvider>(
      create: (_) => userProvider,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          switch (userProvider.status!) {
            case Status.Uninitialized:
              return _splash("Uninitialized");
            case Status.Authenticating:
              return _splash("Authenticating");
            case Status.Unauthenticated:
              return MaterialApp(
                navigatorKey: navigatorKey,
                home: Builder(
                  builder: (context) => OurLogin(
                    onLoginSuccess: () {
                      UserModel? user = userProvider.getUserProvider;
                      var pendingLink = userProvider.pendingAzbaziLink;

                      // بعد از اینکه MaterialApp واقعاً ساخته شد:
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (pendingLink != null) {
                          userProvider.pendingAzbaziLink = null;
                          Uri uri = Uri.parse(pendingLink);

                          Navigator.of(context, rootNavigator: true).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => LinkLoaderPage(
                                uri: uri,
                                user: user!,
                                userProvider: userProvider,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context, rootNavigator: true).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => MyBooks(user),
                            ),
                          );
                        }
                      });
                    },
                    userProvider: userProvider,
                  ),
                ),
              );
            case Status.Authenticated:
              UserModel? user = userProvider.getUserProvider;
              final pendingLink = userProvider.pendingAzbaziLink;
              if (pendingLink != null && user != null) {
                userProvider.pendingAzbaziLink = null;
                Uri uri = Uri.parse(pendingLink);
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  home: LinkLoaderPage(uri: uri, user: user, userProvider: userProvider),
                );
              } else {
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  home: MyBooks(userProvider.getUserProvider),
                );
              }
          }
        },
      ),
    );
  }

  Widget _splash(String status) {
    return MediaQuery(
      data: MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFCFFFFFF), Color(0xff3ec7fd)],
                      begin: Alignment.centerRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/ebargelogo.png', height: 200),
                    SizedBox(height: 20),
                    SpinKitFadingGrid(color: Colors.white, size: 50),
                    if (status == "Uninitialized")
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          "اتصال اینترنتی برقرار نیست!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.pink,
                            fontFamily: "Vazir",
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// صفحه اسپلاش
class Splash extends StatelessWidget {
  const Splash(this._status, {super.key});
  final String _status;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFCFFFFFF), Color(0xff3ec7fd)],
                    begin: Alignment.centerRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Image.asset('assets/ebargelogo.png', height: 250),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SpinKitFadingGrid(
                            color: Colors.white, size: 50.0),
                        if (_status == "Uninitialized")
                          const Text(
                            "اتصال اینترنتی برقرار نیست!",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.pink,
                              fontFamily: "Vazir",
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ نادیده‌گرفتن گواهی SSL برای دامنه‌های داخلی یا تستی
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
