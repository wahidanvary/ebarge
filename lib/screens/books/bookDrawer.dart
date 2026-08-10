import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/screens/books/checkContents.dart';
import 'package:ebarge/screens/books/myConfirmedQuestions.dart';
import 'package:ebarge/screens/books/myNewQuestions.dart';
import 'package:ebarge/screens/books/myRejectedQuestions.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:ebarge/widgets/note/drawer_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'bargesScreen.dart';
import 'myBookSarbarg.dart';

/// Navigation drawer for the app.
// ignore: must_be_immutable
class BookDrawer extends StatelessWidget {
  var _userPassData = List.filled(2, '', growable: false);
  bookModel _book;
  String bWalletAmount;
  BookDrawer(this._book, this.bWalletAmount);

  @override
  Widget build(BuildContext context) {
    setUserPassStorage();
    return Column(
      children: <Widget>[
        _drawerHeader(context),
        if (isNotIOS) const SizedBox(height: 25),
        InkWell(
          child: Column(
              children: <Widget>[
                Icon(Icons.money, size: 16, color: Colors.purpleAccent,),
                Directionality(textDirection:TextDirection.rtl,child: Text("${AccessCheck().replaceFarsiNumber(bWalletAmount)} برگ", style: TextStyle(fontSize: 17, fontFamily: "Vazir", color: Colors.green),)),
              ]
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => bargesScreen(_book.book_id!),
              ),
            );
          },
        ),
        const Divider(),
        DrawerFilterItem(
          icon: Icons.check_box_outline_blank,
          title: 'سوالات امتحانی جدید',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyNewQuestions(_userPassData, _book)),
            );
          },
        ),
        DrawerFilterItem(
          icon: Icons.check_box_outlined,
          title: 'سوالات تائید شده',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyConfirmedQuestions(_userPassData, _book)),
            );
          },
        ),
        DrawerFilterItem(
          icon: Icons.indeterminate_check_box_outlined,
          title: 'سوالات نیاز به ویرایش',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyRejectedQuestions(_userPassData, _book)),
            );
          },
        ),
        const Divider(),
        DrawerFilterItem(
          icon: Icons.video_collection,
          title: 'همه محتواهای من',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return CheckContents(book: _book, contentState: "", contentAccess: "imadder", pageNumber: 1,);
                },
              ),
            );
          },
        ),
        DrawerFilterItem(
          icon: Icons.edit_rounded,
          title: 'سربرگ های امتحانی',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyBookSarbarg(_userPassData, _book)),
            );
          },
        ),
      ],
    );
  }

  Future<void> setUserPassStorage() async {
    final storage = new FlutterSecureStorage();
    String? _username = await storage.read(key: 'username');
    String? _password = await storage.read(key: 'password');
    _userPassData[0] = _username!;
    _userPassData[1] = _password!;
  }


  Widget _drawerHeader(BuildContext context) => SafeArea(
    child:  DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image:  AssetImage('assets/drawerheaderbg.jpg'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            right: 16.0,
            child: Text("عملکرد من در این کتاب",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: "Vazir",
                    fontWeight: FontWeight.w500))),
      ])),
  );
}
