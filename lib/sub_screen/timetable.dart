import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart' show Marquee;
import 'package:Project_Prism/global.dart' as global;
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' show DateFormat;
import 'package:timelines/timelines.dart';

bool currentIsList1 = true;
bool isExpanded = false;
List<String> startTime = ["00:00", "00:00"],
    endTime = ["00:00", "00:00"],
    subjectName = ["Loading...", "Loading..."];
Widget? l1, l2;
void Function(void Function())? setStateTTS;
bool disposed = true;

var sc = ScrollController();
double scrollPos = 0;

bool fnLock = false;
Future<void> fnInit() async {
  if (fnLock == true) return;
  fnLock = true;

  bool updated = false;
  global.classroom_updateFns.add((Map newData) async {
    updated = false;

    debugPrint("Time table function update got called!");

    if (global.accountType == 2) {
      if (newData.isEmpty ||
          newData["course"] == null ||
          newData["timeTable"] == null) {
        // Data is not avail?
        return;
      }

      List courses = newData["course"];
      Map timeTable = newData["timeTable"];

      for (var x in timeTable.entries) {
        var l = [];

        for (var y in x.value) {
          Map<String, dynamic> courseItem = {};
          try {
            courseItem = courses[y];
          } catch (e) {
            debugPrint(e.toString());
            courseItem = {"name": "Unknown", "faculty": "Unknown"};
          }
          l.add(
              "${courseItem["name"]}  ${courseItem["faculty"] == "no one" ? "" : "by ${courseItem["faculty"]}"}");
        }

        if (l.length < 10) {
          for (int a = l.length; a <= 10; a++) {
            l.add("No data were given.");
          }
        }

        global.timetable_subject[(int.parse(x.key.toString()) + 1).toString()] =
            l;
      }
    } else {
      // Faculty time table update
      if (newData.isEmpty) {
        return;
      }

      Map<String, dynamic> facultyTimeTable = {};
      for (int days = 0; days <= 6; days++) {
        List daysData = List.filled(10, "Data not filled");

        for (var classes in newData.values) {
          List cCourses = classes["course"] ?? [];
          Map cTimeTable = classes["timeTable"] ?? {};

          if (cCourses.isEmpty || cTimeTable.isEmpty) {
            continue;
          }

          List acceptableCourseNum = [];

          for (Map<String, dynamic> x in cCourses) {
            if (x["faculty"] == global.loggedUID) {
              acceptableCourseNum.add(cCourses.indexOf(x));
            }
          }

          debugPrint("Acceptable : ${acceptableCourseNum.toString()}");

          int counter = 0;
          for (var x in (cTimeTable[days.toString()] ?? [])) {
            if (acceptableCourseNum.contains(x)) {
              daysData[counter] =
                  "${cCourses[x]["name"]}  ${classes["year"].toString().toUpperCase()}-${classes["section"].toString().toUpperCase()} ${classes["department"].toString().toUpperCase()}";
            }
            counter++;
          }
        }

        facultyTimeTable[(days + 1).toString()] = daysData;
      }
      global.timetable_subject = facultyTimeTable;
    }

    updated = true;
    return;
  });

  List<dynamic> ttT;
  Map<dynamic, dynamic> ttS;
  bool flag = false;

  while (true) {
    await Future.delayed(const Duration(seconds: 5));

    ttS = global.timetable_subject;
    ttT = global.timetable_timing;

    // Timing or subject data isn't there, yet.
    if (ttS.isEmpty == true ||
        ttT.isEmpty == true ||
        global.classroomEventLoaded == false ||
        updated == false) continue;

    //debugPrint("5 second check running");

    var curr = currentIsList1 == true ? 0 : 1;
    var next = currentIsList1 == false ? 0 : 1;

    var timeNow = DateTime.now();
    var nowTime =
        DateFormat("hh:mm").parse("${timeNow.hour}:${timeNow.minute}");
    var currEndTime = DateFormat("hh:mm").parse(endTime[curr]);

    // Current time is beyond current subject period timing, changing the subject.
    if (nowTime.isAfter(currEndTime)) {
      String? nextTime;
      int nextTimeIndex = 1;
      bool currTimeInList = ttT.contains(endTime[curr]);

      for (int x = 0; x < ttT.length; x++) {
        if (nowTime.isBefore(DateFormat("hh:mm").parse(ttT[x])) == true) {
          if (x == 0) {
            nextTimeIndex = -1;
            break;
          }

          nextTime = ttT[x];
          nextTimeIndex = x;
          break;
        }
      }

      if ((nextTime != null || nextTimeIndex == -1) &&
          ttS[timeNow.weekday.toString()] != null) {
        // Next subject timing exists!

        subjectName[next] = ttS[timeNow.weekday.toString()]
            [nextTimeIndex == -1 ? 0 : nextTimeIndex - 1];
        startTime[next] = ttT[nextTime != null ? nextTimeIndex - 1 : 0];
        endTime[next] = ttT[nextTime != null ? nextTimeIndex : 1];
        flag = false;

        debugPrint(
            "Next subject data : ${subjectName[next]} | ${startTime[next]} | ${endTime[next]}");
        if (global.naviIndex == 0) {
          setStateTTS!(() {
            currentIsList1 = !currentIsList1;
          });
        }
      } else if (currTimeInList == true && nextTime == null) {
        // Next subject timing does not exist, make the time to 00:00 so that it won't repeat
        subjectName[next] = "No on-going class";
        startTime[next] = "00:00";
        endTime[next] = "00:00";

        debugPrint("No on going class right now [time table short]");
        flag = false;
        setStateTTS!(() {
          currentIsList1 = !currentIsList1;
        });
      } else if (flag == false && ttS[timeNow.weekday.toString()] == null) {
        flag = true;
        subjectName[next] = "No class info";
        startTime[next] = "00:00";
        endTime[next] = "00:00";

        debugPrint("No data were feed for this day | ${timeNow.weekday}");

        setStateTTS!(() {
          currentIsList1 = !currentIsList1;
        });
      } else if (flag == false) {
        flag = true;
        subjectName[next] = "No classes";
        startTime[next] = "00:00";
        endTime[next] = "00:00";

        setStateTTS!(() {
          currentIsList1 = !currentIsList1;
        });
      }
    }
  }
}

class timetable_short extends StatefulWidget {
  @override
  State<timetable_short> createState() => _timetable_shortState();
}

Widget createTTSWidget(int index) {
  final context = global.rootCTX!;
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Theme.of(context).focusColor,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      onPressed: (() {
        debugPrint("time table short ui got clicked!");
        timetable_expand();
        setStateTTS!(() {
          isExpanded = true;
          //subjectName[1] = "You have CLICKED tHiS??";
          //currentIsList1 = !currentIsList1;
        });
        // TODO : Expand the time table ui into timeline
      }),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: SizedBox.fromSize(
          size: Size(double.infinity, 70),
          child: Stack(
            children: [
              Text("Current on-going class : ",
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .textSelectionTheme
                          .selectionHandleColor)),
              Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Marquee(
                      text: subjectName[index],
                      //  textDirection: TextDirection.rtl,
                      blankSpace: 20,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway"),
                      pauseAfterRound: Duration(seconds: 8),
                      crossAxisAlignment: CrossAxisAlignment.start)),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(startTime[index],
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionHandleColor))),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(endTime[index],
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionHandleColor)))
            ],
          ),
        ),
      ));
}

class _timetable_shortState extends State<timetable_short> {
  @override
  void initState() {
    global.timetableCTX = context;
    super.initState();
    setStateTTS = setState;
    disposed = false;
    fnInit();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Widget build(BuildContext context) {
    setStateTTS = setState;
    l1 = createTTSWidget(0);
    l2 = createTTSWidget(1);
    debugPrint("Time table short rebuild");
    return global.accountType != 3
        ? AnimatedCrossFade(
            duration: const Duration(milliseconds: 1250),
            crossFadeState: isExpanded == true
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            secondChild: SizedBox.fromSize(
                size: const Size(double.infinity, 150),
                child: const Center(child: Card())),
            firstChild: AnimatedCrossFade(
              firstChild: l1!,
              secondChild: l2!,
              crossFadeState: currentIsList1 == true
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 1250),
            ),
          )
        : SizedBox.fromSize(
            size: const Size(double.infinity, 150),
            child: Center(
                child: Card(
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    color: Theme.of(context).focusColor)));
  }
}

void timetable_expand() {
  bool test = false;
  var dlc = DashedLineConnector(
    thickness: 1,
    gap: 10,
    space: 35,
    //indent: 5,
    //endIndent: 5,
  );
  global.alert.customAlertNoActionWithoutPopScope(
      global.timetableCTX!,
      FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 0.8,
        child: Stack(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: global.textWidget(
                    "${global.accObj!.department!.toUpperCase()}  [${global.accObj!.year!.toUpperCase()}]  - ${global.accObj!.section!.toUpperCase()} | ${DateFormat('EEEE').format(DateTime.now())}")),
//
//
            ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black,
                    Colors.black
                  ],
                  stops: [0.0, 0.1, 0.3, 0.7, 0.9, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: ListWheelScrollView(
                  physics: BouncingScrollPhysics(),
                  controller: sc,
                  perspective: 0.0025,
                  squeeze: 1.04,
                  itemExtent: 150,
                  children: test == false
                      ? createTTE()
                      : [
                          TimelineTile(
                            oppositeContents: global.textWidget('08:00'),
                            contents: SizedBox(
                              height: 140,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: global
                                      .textWidget("College commencement")),
                            ),
                            node: TimelineNode(
                              position: 0.25,
                              indicator: OutlinedDotIndicator(
                                borderWidth: 1,
                              ),
                              startConnector: null,
                              endConnector: dlc,
                            ),
                          ),
                          TimelineTile(
                            oppositeContents: global.textWidget('09:00'),
                            contents: SizedBox(
                              height: 140,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      global.textWidget("HS3251 - English ?")),
                            ),
                            node: TimelineNode(
                              position: 0.25,
                              indicator: OutlinedDotIndicator(
                                borderWidth: 1,
                              ),
                              startConnector: dlc,
                              endConnector: dlc,
                            ),
                          ),
                          TimelineTile(
                            oppositeContents: global.textWidget('10:00'),
                            contents: SizedBox(
                              height: 140,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: global.textWidget("Interval")),
                            ),
                            node: TimelineNode(
                              position: 0.25,
                              indicator: OutlinedDotIndicator(
                                borderWidth: 1,
                              ),
                              startConnector: dlc,
                              endConnector: dlc,
                            ),
                          ),
                          TimelineTile(
                            oppositeContents: global.textWidget('05:00'),
                            contents: SizedBox(
                              height: 140,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      global.textWidget("College cessation")),
                            ),
                            node: TimelineNode(
                              position: 0.25,
                              indicator: OutlinedDotIndicator(
                                borderWidth: 1,
                              ),
                              endConnector: null,
                              startConnector: dlc,
                            ),
                          ),
                        ]),
            ),
          ],
        ),
      ),
      null, () {
    setStateTTS!(() {
      isExpanded = false;
    });
  }, () {
    // Post event
    sc.animateTo(scrollPos,
        duration: const Duration(milliseconds: 2500), curve: Curves.elasticOut);
  });
}

List<Widget> createTTE() {
  List<Widget> l = [];

  List<dynamic> ttT = global.timetable_timing;
  Map<dynamic, dynamic> ttS = global.timetable_subject;

  var timeNow = DateTime.now();

  var dlc = const DashedLineConnector(
    thickness: 1,
    gap: 10,
    space: 35,
    //indent: 5,
    //endIndent: 5,
  );

  var dlcGray = const DashedLineConnector(
    thickness: 1,
    gap: 10,
    space: 35,
    color: Colors.grey,
    //indent: 5,
    //endIndent: 5,
  );

  // ignore: prefer_function_declarations_over_variables
  Widget widget(String timeStr, String contentStr,
          {bool coloredGray = false, bool startC = true, bool endC = true}) =>
      TimelineTile(
        oppositeContents: global.textWidgetWithHeavyFont(timeStr),
        contents: SizedBox(
          height: 140,
          child: Align(
              alignment: Alignment.centerLeft,
              child: global.textWidgetWithHeavyFont(contentStr)),
        ),
        node: TimelineNode(
          position: 0.25,
          indicator: OutlinedDotIndicator(
            borderWidth: 1,
            color: coloredGray != false ? Colors.grey : null,
          ),
          startConnector:
              startC == true ? (coloredGray != false ? dlcGray : dlc) : null,
          endConnector:
              endC == true ? (coloredGray != false ? dlcGray : dlc) : null,
        ),
      );

  scrollPos = 10;

  if (ttT.isEmpty == true || ttS.isEmpty == true) {
    l.add(widget(
        "??", "Time table information is not available or not provided yet."));
  } else if (ttS[timeNow.weekday.toString()] == null) {
    l.add(widget(
        "00:00", "Time table data is not provided for this specific day."));
  } else {
    List<dynamic> todayTTS = ttS[timeNow.weekday.toString()];

    timeNow = DateFormat("hh:mm").parse("${timeNow.hour}:${timeNow.minute}");

    l.add(widget(ttT.first, todayTTS.first,
        startC: false,
        coloredGray: timeNow.isAfter(DateFormat("hh:mm").parse(ttT[0]))));

    for (int i = 1; i < ttT.length - 1; i++) {
      bool isAfter = timeNow.isAfter(DateFormat("hh:mm").parse(ttT[i + 1]));
      l.add(widget(ttT[i], todayTTS[i], coloredGray: isAfter));
      scrollPos += isAfter == true ? 155 : 0;
    }

    l.add(widget(ttT.last, "Class Over", endC: false));
  }

  return l;
}
