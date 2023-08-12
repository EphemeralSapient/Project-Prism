import 'package:flutter/material.dart' show Navigator;
import 'package:flutter/widgets.dart';
import '../global.dart' as global;
import '../routeToDash.dart' show toDashbaord;

void terminateFn() async {
  if (global.loginRoute) {
    Navigator.pop(global.loginRouteCTX!);
  }

  if (global.choiceRoute == false) return;
  global.loginRouteCloseFn!();

  await Future.delayed(const Duration(milliseconds: 100), () {});
  toDashbaord();
}
