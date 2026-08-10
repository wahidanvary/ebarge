import 'package:ebarge/azbazi/change-notifiers/timeBal-notifier.dart';
import 'package:ebarge/azbazi/oneAzBaziScreen.dart';
import 'package:ebarge/models/azbaziModel.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/providers/bookProvider.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/services/azbazi_service.dart';
import 'package:ebarge/screens/books/myBooks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../azbazi/change-notifiers/wallet-notifier.dart';
import '../../azbazi/change-notifiers/zafrans-notifier.dart';
import '../../models/userModel.dart';

class LinkLoaderPage extends StatefulWidget {
  final Uri uri;
  final UserModel user;
  final UserProvider userProvider;

  LinkLoaderPage({
    required this.uri,
    required this.user,
    required this.userProvider,
  });

  @override
  _LinkLoaderPageState createState() => _LinkLoaderPageState();
}

class _LinkLoaderPageState extends State<LinkLoaderPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    try {
      final uri = widget.uri;
      String? azbaziId = uri.queryParameters['id'] ??
          (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'azbazi'
              ? uri.pathSegments[1]
              : null);

      if (azbaziId == null || azbaziId.isEmpty) {
        return _showErrorAndRedirect("لینک به درستی وارد نشده است...!");
      }

      setState(() => _isLoading = true);

      azbaziModel? _azbazi = azbaziModel()..azbazi_id = azbaziId;
      _azbazi =
      await AzbaziService().addUpAzScoreRate(_azbazi, "", widget.userProvider);

      if (!mounted || _azbazi == null || _azbazi.book_id == null) {
        return _showErrorAndRedirect("آزبازی نامعتبر است یا حذف شده است...!");
      }

      BookProvider bookProvider =
      BookProvider.instance(widget.user.userid!, _azbazi.book_id!, true);
      List<bookModel> _books = await bookProvider.getBooksData(
          widget.user.userid!, _azbazi.book_id!, true);

      if (!mounted || _books.isEmpty) {
        return _showErrorAndRedirect("کتاب مرتبط با این آزمون یافت نشد.");
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WalletNotifier()),
              ChangeNotifierProvider(create: (_) => ZafransNotifier()),
              ChangeNotifierProvider(create: (_) => TimeBalNotifier()),
            ],
            child: OneAzbaziScreen(
              azbazi: _azbazi!,
              book: _books.first,
              userData: widget.user,
              userProvider: widget.userProvider,
              qsState: 5,
              isOutsideClick: true,
            ),
          ),
        ),
      );
    } catch (e) {
      _showErrorAndRedirect("خطا در بارگذاری داده‌ها. لطفاً دوباره تلاش کنید.");
    }
  }


  // 🔹 تابع نمایش پیام و هدایت به MyBooks
  void _showErrorAndRedirect(String message) async {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });

    await Future.delayed(Duration(seconds: 2)); // کمی توقف برای نمایش پیام

    if (mounted) {
      Future.microtask(() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MyBooks(widget.userProvider.getUserProvider),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? "خطا در بارگذاری داده‌ها",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Vazir",
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
