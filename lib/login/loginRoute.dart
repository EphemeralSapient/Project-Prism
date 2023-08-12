//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute, Navigator;
import 'package:flutter/foundation.dart';
import 'staff.dart' show staffLogin;
import 'student.dart' show studentLogin;
import 'package:Project_Prism/global.dart' as global;
import 'terminate.dart' show terminateFn;
import 'package:firebase_auth/firebase_auth.dart';

void route(type) {
  if (type == 1) {
    Navigator.push(global.choiceRouteCTX!,
        CupertinoPageRoute(builder: (context) => const staffLogin()));
  } else if (type == 2) {
    Navigator.push(global.choiceRouteCTX!,
        CupertinoPageRoute(builder: (context) => const studentLogin()));
  } else if (type == 3) {
    Future.delayed(const Duration(seconds: 0), () async {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      global.account = cred.user;
      global.loggedUID = cred.user!.uid;
      debugPrint(global.account.toString());
    });
    global.accountType = 3;
    global.isLoggedIn = true;
    terminateFn();
  } else {
    Error();
  }
}
