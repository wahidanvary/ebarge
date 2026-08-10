import 'package:ebarge/screens/login/linkLoaderPage.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:ebarge/models/userModel.dart';
import 'package:ebarge/screens/books/myBooks.dart';
import 'package:ebarge/screens/login/user_editor.dart';
import 'package:ebarge/services/progressLoading.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/hexColor.dart';
import 'package:ebarge/widgets/ourContainer.dart';

class OurLoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final UserProvider userProvider;
  const OurLoginForm({Key? key, this.onLoginSuccess, required this.userProvider}) : super(key: key);

  @override
  _OurLoginFormState createState() => _OurLoginFormState();
}

class _OurLoginFormState extends State<OurLoginForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showLoginForm = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final Color primaryColor = HexColor('#6A1B9A'); // Deep Purple
  final Color accentColor = HexColor('#FFA000'); // Amber
  final Color textColorDark = HexColor('#424242'); // Dark Gray
  final Color textColorMedium = HexColor('#757575'); // Medium Gray
  final Color fillColorLight = HexColor('#F5F5F5'); // Light Gray for input fields
  final Color errorColor = HexColor('#DC143C'); // Crimson

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.5).animate(_animationController);

    // Add listeners to text controllers
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState); // Remove listener to prevent memory leaks
    _passwordController.removeListener(_updateFormState); // Remove listener
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // New method to update form state
  void _updateFormState() {
    // Calling setState here will trigger a rebuild and re-evaluate _isFormFilled
    // We only need to call setState if the _isFormFilled value might change.
    // However, for simplicity and to ensure the button's state is always correct,
    // calling setState whenever text changes is a common practice.
    setState(() {});
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    ProgressBuilder(context).showLoadingIndicator('صبر کنید...');

    try {
      UserProvider userProvider = UserProvider.instance();
      UserModel? user = await userProvider.sendLoginRequest(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // بستن دیالوگ و حذف حالت لودینگ
      if (mounted) {
        ProgressBuilder(context).hideOpenDialog();
        setState(() => _isLoading = false);
      }

      if (user != null && user.status == "ok") {
        // ✅ اگر onLoginSuccess از main.dart ارسال شده بود:
        if (widget.onLoginSuccess != null) {
          // اجرای ناوبری در فریم بعدی تا مطمئن شویم context معتبر است
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoginSuccess!();
          });
          return;
        }

        // ✅ اگر لینک آزبازی در حالت pending است
        final pendingLink = userProvider.pendingAzbaziLink;
        if (pendingLink != null) {
          userProvider.pendingAzbaziLink = null;
          Uri uri = Uri.parse(pendingLink);

          // کمی تأخیر برای اطمینان از بسته شدن دیالوگ
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LinkLoaderPage(
                  uri: uri,
                  user: user,
                  userProvider: widget.userProvider,
                ),
              ),
            );
          });
        }
        // ✅ در حالت ورود مستقیم
        else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MyBooks(user)),
                  (route) => false,
            );
          });
        }
      } else {
        _showFlushbar('نام کاربری یا رمز عبور اشتباه است!');
      }
    } catch (e) {
      print("❌ خطای نامنتظره در لاگین: $e");
      if (mounted) {
        ProgressBuilder(context).hideOpenDialog();
        setState(() => _isLoading = false);
        _showFlushbar('در ارتباط اینترنتی مشکلی رخ داد، لطفاً دوباره تلاش کنید.');
      }
    }
  }


  void _showFlushbar(String message) {
    Flushbar(
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      backgroundGradient: LinearGradient(
        colors: [primaryColor.withOpacity(0.8), accentColor.withOpacity(0.8)],
      ),
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: "Vazir"),
        ),
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  bool get _isFormFilled =>
      _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return OurContainer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: primaryColor,
                  ),
                  onPressed: () {
                    UserModel? newUser = UserModel();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserEditor(user: newUser, isChangePass: false,),
                      ),
                    );
                  },
                  child: Text(
                    "عضویت (اگر عضو نیستید!)".toUpperCase(),
                    style: TextStyle(fontSize: 14.0, fontFamily: "Vazir"),
                  ),
                ),
              ),
              SizedBox(height: 18.0),
              InkWell(
                onTap: () {
                  setState(() {
                    _showLoginForm = !_showLoginForm;
                    if (_showLoginForm) {
                      _animationController.reverse();
                    } else {
                      _animationController.forward();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ورود برای اعضا",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Vazir",
                          color: primaryColor,
                          decoration: _showLoginForm ? TextDecoration.underline : TextDecoration.none,
                          decorationColor: primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      RotationTransition(
                        turns: _animation,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 28.0,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.0),
              if (_showLoginForm)
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _usernameController,
                          // Add onChanged to trigger rebuild on text input
                          onChanged: (_) => _updateFormState(),
                          decoration: InputDecoration(
                            labelText: "نام کاربری",
                            labelStyle: TextStyle(color: textColorMedium, fontFamily: "Vazir"),
                            prefixIcon: Icon(Icons.perm_identity, color: textColorMedium),
                            filled: true,
                            fillColor: fillColorLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: textColorMedium.withOpacity(0.5), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: errorColor, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: errorColor, width: 2.0),
                            ),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'نام کاربری را وارد کنید' : null,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          // Add onChanged to trigger rebuild on text input
                          onChanged: (_) => _updateFormState(),
                          decoration: InputDecoration(
                            labelText: "رمز عبور",
                            labelStyle: TextStyle(color: textColorMedium, fontFamily: "Vazir"),
                            prefixIcon: Icon(Icons.lock_outline, color: textColorMedium),
                            filled: true,
                            fillColor: fillColorLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: textColorMedium.withOpacity(0.5), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: primaryColor, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: errorColor, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: errorColor, width: 2.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: textColorMedium,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                                // No need to call _updateFormState here, as setState already rebuilds
                              },
                            ),
                          ),
                          onFieldSubmitted: (_) => _isFormFilled && !_isLoading ? _loginUser() : null,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'رمز عبور را وارد کنید' : null,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading || !_isFormFilled ? null : _loginUser,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "ورود",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Vazir"),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextButton(
                        onPressed: () {
                          UserModel? newUser = UserModel();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserEditor(user: newUser, isChangePass: true,),
                            ),
                          );
                        },
                        child: Text(
                          "تغییر رمز عبور و ورود با شماره موبایل",
                          style: TextStyle(fontFamily: "Vazir", fontSize: 12, color: primaryColor, decoration: TextDecoration.underline),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}