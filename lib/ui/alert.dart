import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';

// !!!

// USE global.alert TO ACCESS THIS CLASS

class Alert {
  Future<dynamic> quickAlert(BuildContext ctx, Widget body,
      {Function()? bodyFn,
      Widget? title,
      bool dismissible = true,
      bool popable = false,
      double opacity = 0.9,
      List<FloatingActionButton>? action,
      Function? popFn}) {
    return showGeneralDialog(
      barrierDismissible: dismissible,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) =>
          StatefulBuilder(builder: (context, StateSetter setState) {
        global.quickAlertGlobalVar = setState;
        return WillPopScope(
            onWillPop: () async {
              try {
                popFn!();
              } catch (e) {}
              return dismissible | popable;
            },
            child: AlertDialog(
                title: title,
                content: bodyFn == null ? body : bodyFn(),
                backgroundColor:
                    Theme.of(context).focusColor.withOpacity(opacity),
                actions: action ??
                    [
                      FloatingActionButton(
                          child: Text("Okay"),
                          mini: true,
                          onPressed: () {
                            if (popFn != null) popFn();
                            Navigator.of(context).pop();
                          })
                    ]));
      }),
      transitionBuilder: (ctx, animation, anim2, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
              scale: animation.drive(
                Tween(begin: 1.5, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: animation.value * 8, sigmaY: animation.value * 8),
                child: child,
              ))),
      context: ctx,
    );
  }

  Future<dynamic> customAlertNoAction(
      BuildContext context, Widget Content, Widget? Title) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) =>
          StatefulBuilder(builder: (context, StateSetter setState) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Title,
            content: Content,
            backgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
            elevation: 10,
          ),
        );
      }),
      transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: 3 * anim1.value, sigmaY: 3 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      ),
      context: context,
    );
  }

  Future<dynamic> customAlertNoActionWithoutPopScope(
      BuildContext context,
      Widget Content,
      Widget? Title,
      Function callbackFn,
      Function postCallbackFn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => postCallbackFn());

    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, anim1, anim2) =>
          StatefulBuilder(builder: (context, StateSetter setState) {
        return WillPopScope(
          onWillPop: () async {
            callbackFn();
            return true;
          },
          child: AlertDialog(
            title: Title,
            content: Content,
            backgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
            elevation: 10,
          ),
        );
      }),
      transitionBuilder: (ctx, animation, anim2, child) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
              scale: animation.drive(
                Tween(begin: 1.5, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: animation.value * 8, sigmaY: animation.value * 8),
                child: child,
              ))),
      context: context,
    );
  }
}
