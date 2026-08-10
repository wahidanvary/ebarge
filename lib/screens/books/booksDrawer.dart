import 'package:ebarge/azbazi/checkAzbazis.dart';
import 'package:ebarge/models/bookModel.dart';
import 'package:ebarge/screens/AboutUs.dart';
import 'package:ebarge/screens/login/editUserScreen.dart';
import 'package:ebarge/screens/login/editEbuserScreen.dart';
import 'package:ebarge/screens/login/login.dart';
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:ebarge/widgets/note/drawer_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../Donation.dart';

/// Navigation drawer for the app.
// ignore: must_be_immutable
class BooksDrawer extends StatelessWidget {
  var _userPassData = List.filled(2, '', growable: false);
  BooksDrawer(this.isEditAllow);

  final bool isEditAllow;

  @override
  Widget build(BuildContext context) {
    setUserPassStorage();
    return Drawer(
      child: ListView(
        children: <Widget>[
          _drawerHeader(context),
          if (isNotIOS) const SizedBox(height: 16),
          isEditAllow ?
          ListTile(
             // icon: Icons.checklist_rtl,
            leading: Icon(Icons.checklist_rtl),
              title: Text('بررسی طراحی آزبازی ها', style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 15,
                  fontFamily: "Vazir"
              ),),
              tileColor: Colors.green[100],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckAzbazis(book: bookModel(), azbaziState: '2', azbaziAccess: 'admin', pageNumber: 1,)),
                );
              },
          ): Container(),
          isEditAllow ?
          ListTile(
            // icon: Icons.checklist_rtl,
            leading: Icon(Icons.checklist_rtl),
            title: Text('بررسی درخواست آزبازی', style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 15,
                fontFamily: "Vazir"
            ),),
            tileColor: Colors.lightBlue[100],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CheckAzbazis(book: bookModel(), azbaziState: '0', azbaziAccess: 'admin', pageNumber: 1,)),
              );
            },
          ): Container(),
          const Divider(),
          DrawerFilterItem(
            icon: Icons.edit_rounded,
            title: 'ویرایش اطلاعات کاربری',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditUserScreen(_userPassData)),
              );
            },
          ),
          DrawerFilterItem(
            icon: Icons.edit_outlined,
            title: 'ویرایش اطلاعات آموزشی',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditEbuserScreen(_userPassData)),
              );
            },
          ),
          const Divider(),
          DrawerFilterItem(
            icon: Icons.description,
            title: 'درباره ایبرگه',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUs()),
              );
            },
          ),
          // DrawerFilterItem(
          //   icon: Icons.card_giftcard,
          //   title: 'حمایت',
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Donation()),
          //     );
          //   },
          // ),
          const Divider(),
          DrawerFilterItem(
            icon: Icons.exit_to_app,
            title: 'خروج از کاربری',
            onTap: () async {
              UserProvider _UserProvider = Provider.of(context, listen: false);
              String _returnString = await _UserProvider.signOut();
              if (_returnString == "success" || _returnString == "ko") {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => OurLogin(userProvider: UserProvider.instance(),)), (route) => false,
                );
              }
            },
          ),
          /*DrawerFilterItem(
            icon: Icons.help_outline,
            title: 'درباره',
            onTap: (){} // =>launch('https://github.com/xinthink/flutter-keep'),
          ),*/
        ],
      ),
    );
  }

  Future<void> setUserPassStorage() async {
    final storage = new FlutterSecureStorage();
    String? _username = await storage.read(key: 'username');
    String? _password = await storage.read(key: 'password');
    if(_username != null && _password != null){
      _userPassData[0] = _username;
      _userPassData[1] = _password;
    }
  }


  Widget _drawerHeader(BuildContext context) => SafeArea(
    child:  DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fitHeight,
                image:  AssetImage('assets/drawerheaderbg.jpg'))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              right: 16.0,
              child: Text("مشاهده و ویرایش اطلاعات",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Vazir",
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500))),
        ])),
  );
}