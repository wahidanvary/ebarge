//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

//import 'package:flt_keep/styles.dart';

/// Settings screen.
class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.copyWith(
        bodySmall: Theme.of(context).textTheme.headlineSmall!.copyWith(
          color: Colors.blueAccent.shade400,
          fontWeight: FontWeights.medium,
        ),
      ),
    ),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('تنظیمات'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints.tightFor(width: 720),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildCaption(context, 'کاربری'),
                  ListTile(
                    title: Text('خروج'),
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildCaption(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text('کاربری', style: Theme.of(context).textTheme.titleMedium),
  );

  void _signOut(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('آیا مطمئن هستید که می خواهید از این کاربری خارج شوید؟'),
        actions: <Widget>[
          TextButton(
            child: const Text('خیر'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('بله'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (yes!) {
     // FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  }
}
