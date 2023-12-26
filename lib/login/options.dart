import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'loginRoute.dart' show route;

class Choice extends StatefulWidget {
  const Choice({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChoiceImpl();
  }
}

class ChoiceImpl extends State<Choice> {
  @override
  void initState() {
    super.initState();

    global.loginRouteCloseFn = () {
      if (global.choiceRoute == false) return;
      global.choiceRoute = false;
    };
    global.choiceRoute = true;
    global.choiceRouteCTX = context;
  }

  Container slot(
      int i, List<Color> color, String name, String info, IconData icon) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: const Alignment(-1, -1),
            end: const Alignment(1, -2),
            colors: color,
          )),
      child: ElevatedButton(
          onPressed: () {
            route(i);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25),
                  Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).canvasColor,
                      //fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      fontSize: 25,
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Text(
                    info,
                    style: TextStyle(
                      color: Theme.of(context).canvasColor,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Icon(icon, size: 100, color: Theme.of(context).splashColor)
            ],
          )),
    );
  }

  dynamic roleSlots = [
    [
      1,
      [
        Colors.deepPurple,
        const Color.fromRGBO(230, 144, 228, 1),
      ],
      " Administrator",
      "   STAFF / FACULTY",
      Icons.admin_panel_settings
    ],
    [
      2,
      [
        const Color.fromRGBO(255, 94, 203, 1),
        const Color.fromRGBO(250, 216, 130, 1),
      ],
      " Student",
      "UG / PG STUDENT",
      Icons.school_rounded
    ],
    [
      3,
      [
        const Color.fromRGBO(16, 175, 233, 1),
        const Color.fromRGBO(228, 240, 140, 1),
      ],
      "Guest      ",
      "NO LOGIN REQUIREMENT",
      Icons.account_circle_rounded
    ]
  ];

  @override
  Widget build(BuildContext context) {
    global.choiceRouteCTX = context;
    debugPrint("Building options screen");
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Theme.of(context).splashColor,
            body: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: global.loginValidated == 0 ? 0 : 10.0,
                  sigmaY: global.loginValidated == 0 ? 0 : 10.0),
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30, right: 30, top: 60, bottom: 30),
                  child: Wrap(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        child: Text("Choose Your Role",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: "Metropolis",
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor,
                            )),
                      ),
                      const SizedBox(height: 35),
                      Text("You can choose any one to proceed",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: "Metropolis",
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Theme.of(context)
                                .textSelectionTheme
                                .selectionHandleColor,
                          )),
                      const SizedBox(height: 50),
                      AnimationLimiter(
                          child: Column(
                              children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 600),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                        verticalOffset: 150.0,
                                        child: FadeInAnimation(
                                          child: widget,
                                        ),
                                      ),
                                  children: [
                            for (dynamic x in roleSlots)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 15.0),
                                child: InkWell(
                                    child: slot(x[0], x[1], x[2], x[3], x[4])),
                              ),
                          ]))),
                      const SizedBox(height: 30),
                    ],
                  )),
            )));
  }
}
