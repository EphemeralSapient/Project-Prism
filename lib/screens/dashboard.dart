import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/sub_screen/assignments.dart';
import 'package:Project_Prism/sub_screen/moreActions.dart';
import 'package:Project_Prism/sub_screen/timetable.dart';
import 'package:Project_Prism/ui/booking/create.dart';
import 'package:Project_Prism/ui/booking/remove.dart';
import 'package:Project_Prism/ui/classroom/create.dart';
import 'package:Project_Prism/ui/classroom/remove.dart';
import 'package:Project_Prism/ui/classroom/update.dart';
import 'package:Project_Prism/ui/course/create.dart';
import 'package:Project_Prism/ui/course/info.dart';
import 'package:Project_Prism/ui/course/remove.dart';
import 'package:Project_Prism/ui/course/update.dart';
import 'package:Project_Prism/ui/face_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'
    show
        AnimationConfiguration,
        AnimationLimiter,
        FadeInAnimation,
        SlideAnimation;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../sub_screen/events.dart';
import '../ui/booking/modify.dart';

class dash extends StatefulWidget {
  const dash({super.key});

  @override
  State<dash> createState() => _dashState();
}

bool allowedSubOptionCheck(int perm) {
  return (global.accObj!.permissionLevel ?? 0) == perm;
}

bool allowSubOptionCheckList(List<int>? perm, int accType) {
  if (perm != null &&
      perm.length == 1 &&
      perm.first == -1 &&
      global.accountType != 2) {
    perm = null;
  }

  if (accType == 2) {
    debugPrint("$perm | $accType");
    return (perm ?? []).contains(-1);
  }

  if (perm != null) {
    for (int x in perm) {
      if (allowedSubOptionCheck(x)) {
        return true;
      }
    }
    return false;
  }
  return true;
}

int countSubOption(List<dynamic> list) {
  int estimate = 0;
  for (List<dynamic> subOptions in list) {
    bool skip = false;
    if (global.accountType != 2 &&
        subOptions.length == 4 &&
        subOptions[3].contains(-1) &&
        subOptions[3].length == 1) {
      skip = true;
    }
    for (int permLevel
        in ((subOptions.length == 3 || skip ? null : subOptions[3]) ??
            [global.accObj!.permissionLevel ?? 0]) as List<int>) {
      debugPrint(">>>>>>>${global.accObj!.permissionLevel}");
      if (global.accountType == 1) {
        estimate += allowedSubOptionCheck(permLevel) ? 1 : 0;
      } else if (global.accountType == 2) {
        estimate +=
            subOptions.length == 4 && subOptions[3].contains(-1) ? 1 : 0;
      } else {
        estimate +=
            subOptions.length == 4 && subOptions[3].contains(-2) ? 1 : 0;
      }
    }
  }
  return estimate;
}

List<List<Object>> names = [
  [
    "Admin", // Option name
    Icons.settings, // Option icon
    [
      // Sub option contents

      // Icon,  Title name, OnTap fn,   Permission levels allowed
      [Icons.person_add, "Create an account or user", () {}],
      [Icons.security, "User Permissions Management", () {}],
      [Icons.block, "Account Deactivation or Suspension", () {}],
      [Icons.analytics, "Analytics and reports of a user", () {}],
      [Icons.storage, "User Data Management", () {}],
    ],

    [1, 2, 3], // Option permitted to specific account type
    List.generate(10, (index) => index + 14)
  ],
  [
    "Course",
    Icons.class_,
    [
      [
        Icons.add_circle_outline,
        "Create the course data",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(courseCreateUi());
        }
      ],
      [
        Icons.info_outline,
        "Get the information about existing course",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(courseInfoUi());
        },
        [-1]
      ],
      [
        Icons.edit_outlined,
        "Modify the course data",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(courseUpdateUi());
        }
      ],
      [
        Icons.remove_circle_outline,
        "Remove the course data",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(courseRemoveUi());
        }
      ],
    ],
    [1, 2],
    List.generate(10, (index) => index + 9) + [-1]
  ],
  [
    "Classroom",
    Icons.meeting_room,
    [
      [
        Icons.add_box,
        "Create a classroom",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(createClassroomUi());
        }
      ],
      [
        Icons.group_add,
        "Update the classroom",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(classroomUpdateUi());
        }
      ],
      [
        Icons.delete_forever,
        "Delete a classroom",
        () {
          debugPrint("huh?");
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(classroomRemoveUi());
        }
      ],
      [
        Icons.analytics_outlined,
        "Get Report or Analytics of the classroom",
        () {},
        [-1]
      ],
    ],
    [1, 2, 3],
    List.generate(10, (index) => index + 9) + [-1]
  ],
  [
    "Compliant",
    Icons.feedback_rounded,
    [
      [
        Icons.sentiment_dissatisfied,
        "Bad food quality",
        () {},
        [-1]
      ],
      [
        Icons.payment,
        "Billing/payment issues",
        () {},
        [-1]
      ],
      [
        Icons.clean_hands,
        "Unclean dining area",
        () {},
        [-1]
      ],
      [
        Icons.delete_outline,
        "Food waste",
        () {},
        [-1]
      ],
    ],
    [1, 2, 3]
  ],
  [
    "Booking",
    Icons.event_seat,
    [
      [
        Icons.add_circle_outline,
        "Add New Hall",
        () {
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(CreateSeminarHallBookingUi());
        },
        List.generate(10, (index) => index + 9)
      ],
      [
        Icons.search,
        "Book or Modify The Hall",
        () {
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(hallInfoUi());
        },
        List.generate(10, (index) => index + 9)
      ],
      [
        Icons.delete_outline,
        "Delete A Hall",
        () {
          Navigator.pop(global.rootCTX!);
          global.switchToSecondaryUi(const HallRemoveUi());
        },
        List.generate(10, (index) => index + 9) + [3]
      ],
    ],
    [1, 2],
    List.generate(10, (index) => index + 9) + [3]
  ],
  [
    "Schedules",
    Icons.schedule_rounded,
    [
      [
        Icons.timelapse,
        "Change the timetable timing",
        () {},
        List.generate(10, (index) => index + 11)
      ],
      [
        Icons.calendar_month,
        "Change month schedule days",
        () {},
        List.generate(10, (index) => index + 14)
      ],
      [
        Icons.update,
        "Change bus schedule and information",
        () {},
        List.generate(10, (index) => index + 14) + [3]
      ],
    ],
    [3],
    List.generate(10, (index) => index + 11) + [3]
  ],
  [
    "Bus",
    Icons.bus_alert,
    [
      [
        Icons.location_on,
        "Real-time Bus Tracking",
        () {},
        [-1]
      ],
      [
        Icons.schedule,
        "Bus Schedule and Route Information",
        () {},
        [-1]
      ],
      [
        Icons.people,
        "Bus Capacity and Availability",
        () {},
        [-1]
      ],
      [
        Icons.feedback,
        "Bus Report or Feedback",
        () {},
        [-1]
      ],
    ],
    [1, 2, 3],
  ],
  [
    "ML Tools",
    FontAwesomeIcons.brain,
    [
      [
        Icons.face,
        "Face Detection",
        () {
          Navigator.pop(global.rootCTX!);
          global.cameraShotFn = null;
          global.switchToSecondaryUi(const FaceDetection());
        },
        [-1]
      ],
      [
        Icons.view_comfy,
        "Object Classification",
        () {},
        [-1]
      ]
    ],
    [1, 2, 3]
  ],
  [
    "Compilers",
    FontAwesomeIcons.code,
    [
      [
        FontAwesomeIcons.c,
        "C program",
        () {},
        [-1]
      ]
    ],
    [1, 2, 3]
  ]
];

int i = 0; // Widget [promptOptions] runs the animation twice; so using counter
// It init and disposes it 3 times; therefore ++i%3 is considered.

class promptOptions extends StatefulWidget {
  final dynamic name;
  final BuildContext context;

  const promptOptions({super.key, required this.name, required this.context});

  @override
  _promptOptionsState createState() => _promptOptionsState();
}

class _promptOptionsState extends State<promptOptions> {
  @override
  void initState() {
    i += 1;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic name = widget.name;
    i += 1;
    debugPrint(i.toString());
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).focusColor,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: SizedBox(
          height: 200.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 30,
                ),
                Icon(
                  name[1],
                  color: Theme.of(context).textSelectionTheme.selectionColor,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  name[0],
                  maxLines: 1,
                  style: TextStyle(
                      color: Theme.of(context).textSelectionTheme.cursorColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto",
                      fontSize: 14),
                )
              ],
            ),
            const SizedBox(height: 10),
            AnimationLimiter(
              child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: -50.0,
                  //verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  for (dynamic subChoice in name[2])
                    if ((i % 3 == 0) &&
                        allowSubOptionCheckList(
                                subChoice.length == 4
                                    ? subChoice[3]
                                    : (global.accountType == 1
                                        ? [global.accObj?.permissionLevel ?? 0]
                                        : []),
                                global.accountType == 2 &&
                                        subChoice.length == 4 &&
                                        subChoice[3].contains(-1)
                                    ? 2
                                    : 0) ==
                            true)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: .0, right: 20, left: 20),
                        child: ElevatedButton.icon(
                            onPressed: subChoice[2],
                            icon: Icon(
                              subChoice[0],
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor,
                            ),
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(
                                subChoice[1],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textSelectionTheme
                                        .cursorColor),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).focusColor,
                              shadowColor: Colors.transparent,
                            )),
                      )
                ],
              )),
            )
          ])),
    );
  }
}

Widget promptOption(name, context) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: 60 + (60 * countSubOption(name[2])).toDouble() + 15,
        child: Hero(
            tag: name[0], child: promptOptions(name: name, context: context)),
      ),
    ),
  );
}

class _dashState extends State<dash> {
  @override
  void initState() {
    super.initState();
    debugPrint("CAAAAALLLEDDD");
    i = 0;
  }

  List<Widget> suboptions() {
    return [
      for (dynamic name in names)
        if (name[3].contains(global.accountType) &&
            allowSubOptionCheckList(
                (name.length == 5 ? name[4] : null) as List<int>?,
                global.accountType == 2 &&
                        (name.length == 5 ? name[4] : []).contains(-1)
                    ? 2
                    : 0))
          GestureDetector(
            onTap: () {
              Navigator.push(context, HeroDialogRoute(
                builder: (BuildContext context) {
                  return Center(child: promptOption(name, context));
                },
              ));
            },
            child: Hero(
              tag: name[0],
              child: Material(
                color: Theme.of(context).focusColor,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
                child: Container(
                  color: Colors.transparent,
                  width: 100.0,
                  height: 100.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        name[1],
                        color:
                            Theme.of(context).textSelectionTheme.selectionColor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        name[0],
                        style: TextStyle(
                            color: Theme.of(context)
                                .textSelectionTheme
                                .cursorColor,
                            fontWeight: FontWeight.w300,
                            fontFamily: "Roboto",
                            fontSize: 14),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
    ];
  }

  @override
  Widget build(context) {
    debugPrint("building dash screen | Account type : ${global.accountType}");
    return Scaffold(
      backgroundColor: Theme.of(context).focusColor,
      body: //ShaderMask(

          //shaderCallback: (Rect rect) {
          //return const LinearGradient(
          //begin: Alignment.center,
          //end: Alignment.bottomCenter,
          //colors: [
          //Colors.transparent,
          //Colors.transparent,
          //Colors.black
          //],
          //stops: [0.0, 0.5, 1.0],
          //).createShader(rect);
          //},
          //blendMode: BlendMode.dstOut,

          //child:
          ShaderMask(
        shaderCallback: (Rect rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey,
              Colors.transparent,
              Colors.transparent,
              Colors.black
            ],
            stops: [0.001, 0.05, 0.8, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: SingleChildScrollView(
            child: Stack(
          children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: -150.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
              children: [
                SizedBox(
                  height: 200,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.transparent,
                              border: Border.all(
                                width: 1.1,
                                color: Colors.red,
                              ),
                            ),
                            width: 45,
                            height: 45,
                            child: ClipOval(
                              child: global.account?.isAnonymous != true
                                  ? FadeInImage.assetNetwork(
                                      placeholder: "asset/images/loading.gif",
                                      image: global.account!.photoURL!)
                                  : const Icon(Icons.person),
                            ),
                          ),
                          Positioned(
                              top: 20,
                              left: 60,
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Welcome, ",
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .selectionHandleColor,
                                        fontFamily: "Montserrat")),
                                TextSpan(
                                    text: global.account!.isAnonymous == true
                                        ? "Guest"
                                        : (global.accObj != null &&
                                                global.accObj?.firstName !=
                                                    null)
                                            ? "${global.accObj!.title ?? ""} ${global.accObj!.firstName} ${global.accObj!.lastName}"
                                            : "${global.account!.displayName ?? ""}!",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .cursorColor,
                                        fontFamily: "Montserrat"))
                              ]))),
                          Padding(
                            padding: const EdgeInsets.only(top: 60, left: 75),
                            child: timetable_short(),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 180,
                      ),
                      eventsUi(), // Can be accessed by any member I guess

                      const SizedBox(
                        height: 25,
                      ),

                      global.accountType != 3
                          ? moreActionsShort()
                          : const SizedBox(),

                      global.accountType == 2
                          ? assignmentUi()
                          : const SizedBox(),

                      //global.accountType == 1 ? modifyTimetableUi() : const SizedBox(),
                      const SizedBox(height: 30),
                      // Menu options
                      Column(
                        children: [
                          Row(children: [
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              "MENU ",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textSelectionTheme
                                      .selectionColor,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                  fontFamily: "Montserrat",
                                  fontSize: 12),
                            ),
                          ]),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 25,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: suboptions(),
                            ),
                          ),
                          const SizedBox(
                            height: 300,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 200)
              ]),
        )),
      ),
      //),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isOpen = false;

  // AnimatedContainer dimensions:
  double width = 55, height = 55;

  // AnimatedPositioned positions:
  double left = 20, bottom = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              child: AnimatedOpacity(
                // If the widget is visible, animate to 0.0 (invisible).
                // If the widget is hidden, animate to 1.0 (fully visible).
                opacity: isOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                // The green box must be a child of the AnimatedOpacity widget.
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              onTap: () {
                if (isOpen) {
                  setState(() {
                    width = 55;
                    height = 55;
                    left = 20;
                    bottom = 20;
                    isOpen = false;
                  });
                }
              },
            ),
          ),
          AnimatedPositioned(
            left: 0,
            bottom: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: GestureDetector(
              child: AnimatedContainer(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(28)),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                // child: dialog container content goes here,
              ),
              onTap: () {
                if (!isOpen) {
                  setState(() {
                    width = 200;
                    height = 200;
                    left = 60;
                    bottom = 60;
                    isOpen = !isOpen;
                  });
                }
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 17,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: !isOpen ? 1.0 : 0.0,
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String? get barrierLabel => "lol";
}
