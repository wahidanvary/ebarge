import 'package:flutter/material.dart';
import 'package:ebarge/screens/login/loginForm.dart';

import '../../providers/userProvider.dart';

class OurLogin extends StatelessWidget {
  final VoidCallback? onLoginSuccess; // ✅ تابع برگشتی برای موفقیت در ورود
  final UserProvider userProvider;

  const OurLogin({Key? key, this.onLoginSuccess, required this.userProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/ebargelogo.png"),
              ),
              // ✅ انتقال مستقیم تابع لاگین موفق به فرم
              OurLoginForm(onLoginSuccess: onLoginSuccess, userProvider: userProvider,),
            ],
          ),
        ),
      ),
    );
  }
}

