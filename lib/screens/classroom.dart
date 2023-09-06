import 'dart:ui';

import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/leaveForm.dart';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:semicircle_indicator/semicircle_indicator.dart';

dynamic data;
List<String> depart = ["All"];
List<String> programmes = [];
List<String> selectedProgramme = [];
List<String> years = ["I", "II", "III", "IV"];
List<String> selectedYear = [];

List<dynamic> selectedClasses = [];

Map<String, String> selectedClass = {
  "class": "CSE",
  "year": "I",
  "section": "A",
};

class classroom extends StatefulWidget {
  const classroom({super.key});

  @override
  State<classroom> createState() => _classroomState();
}

class _classroomState extends State<classroom> {
  Map<dynamic, dynamic> info = {};
  List<dynamic> allClassInfo = [];
  bool loading = true;
  bool isDisposed = false;

  int selfAbsentCount = 0;
  int selfOnDutyCount = 0;

  int classAbsentCount = 0;
  int classOnDutyCount = 0;

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void initState() {
    super.initState();

    if (global.accountType == 3) return;

    Future.delayed(const Duration(), () async {
      if (global.accountType == 2) {
        data = global.classroom_data;

        //Counting the data for absent and on duty
        String selfRollNo = (int.parse(global.accObj!.rollNo!
                .substring(global.accObj!.rollNo!.length - 3)))
            .toString();

        selfAbsentCount = data["absents"]?[selfRollNo.toString()]?.length ?? 0;
        selfOnDutyCount = data["onDuties"]?[selfRollNo.toString()]?.length ?? 0;
        classAbsentCount = data["absent"] ?? 0;
        classOnDutyCount = data["onDuty"] ?? 0;
      } else {
        var fetch = await global.Database!.firestore
            .collection(
                "/department/${global.accObj!.parentDepartment}/subdepartments/")
            .get();
        if (programmes.isEmpty) {
          for (var x in fetch.docs) {
            programmes.add(x.id);
          }
          setState(() {});
        }

        CollectionReference collectionRef =
            global.Database!.addCollection("classroom", "/class");
        QuerySnapshot querySnapshot = await collectionRef.get();
        allClassInfo = querySnapshot.docs.map((doc) => doc.data()).toList();
      }

      if (isDisposed == false) {
        setState(() => loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> departments = ["All"];
    for (Map<String, dynamic> x in allClassInfo) {
      if (x.containsKey("department") &&
          departments.contains(x["department"]) == false) {
        departments.add(x["department"]);
      }
    }

    var chosenDateStr =
        DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();

    String per(int? strength, int? count) {
      if (strength == null || count == null) {
        return "-";
      } else {
        return ((count / strength) * 100).toInt().toString();
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).focusColor,
      body: global.accountType == 2
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: ShaderMask(
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
                    stops: [0.01, 0.05, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 300),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: [
                            global.padHeight(20),
                            global.textWidget(
                                "This UI is subjected to overhaul and will be done sooner as possible. | ${global.accObj!.branchCode ?? "NONE"}"),
                            global.padHeight(10),
                            Card(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.3),
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              borderOnForeground: false,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "         ${global.accObj!.branchCode} ${global.accObj!.year!.toUpperCase()}-${global.accObj!.section!.toUpperCase()}          ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textSelectionTheme
                                          .selectionHandleColor,
                                      fontSize: 23),
                                ),
                              ),
                            ),
                            global.padHeight(45),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).focusColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (c, a1, a2) =>
                                              attendanceChecklist(
                                                  year: global.accObj!.year!
                                                      .toUpperCase(),
                                                  section: global
                                                          .accObj!.section!
                                                          .toUpperCase() ??
                                                      "A",
                                                  programme: global
                                                          .accObj!.branchCode ??
                                                      ""),
                                          opaque: false,
                                          transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) =>
                                              FadeTransition(
                                                  opacity: animation,
                                                  child: ScaleTransition(
                                                      scale: animation.drive(
                                                        Tween(
                                                                begin: 1.5,
                                                                end: 1.0)
                                                            .chain(CurveTween(
                                                                curve: Curves
                                                                    .easeOutCubic)),
                                                      ),
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(
                                                            sigmaX: animation
                                                                    .value *
                                                                20,
                                                            sigmaY: animation
                                                                    .value *
                                                                20),
                                                        child: child,
                                                      ))),
                                          transitionDuration:
                                              const Duration(seconds: 1)));
                                },
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  style: ListTileStyle.list,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).focusColor,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context)
                                          .textSelectionTheme
                                          .selectionColor,
                                      size: 24,
                                    ),
                                  ),
                                  title: global.textWidgetWithHeavyFont(
                                    "Attendance",
                                  ),
                                  subtitle: global.textWidget_ns(
                                    "Check the class attendance information",
                                  ),
                                ),
                              ),
                            ),
                            global.padHeight(20),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).focusColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (c, a1, a2) =>
                                              attendanceChecklist(
                                                  year: global.convertToRoman(
                                                      global.accObj!.year),
                                                  section:
                                                      global.accObj!.section ??
                                                          "A",
                                                  programme: global
                                                          .accObj!.programme ??
                                                      ""),
                                          opaque: false,
                                          transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) =>
                                              FadeTransition(
                                                  opacity: animation,
                                                  child: ScaleTransition(
                                                      scale: animation.drive(
                                                        Tween(
                                                                begin: 1.5,
                                                                end: 1.0)
                                                            .chain(CurveTween(
                                                                curve: Curves
                                                                    .easeOutCubic)),
                                                      ),
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(
                                                            sigmaX: animation
                                                                    .value *
                                                                20,
                                                            sigmaY: animation
                                                                    .value *
                                                                20),
                                                        child: child,
                                                      ))),
                                          transitionDuration:
                                              const Duration(seconds: 1)));
                                },
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  style: ListTileStyle.list,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).focusColor,
                                    child: const Icon(
                                      Icons.poll,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  title: global.textWidgetWithHeavyFont(
                                    "Polls",
                                  ),
                                  subtitle: global.textWidget_ns(
                                    "The insights and opinions from others",
                                  ),
                                ),
                              ),
                            ),
                            global.padHeight(20),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).focusColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  leaveFormPrompt(context);
                                },
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  style: ListTileStyle.list,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).focusColor,
                                    child: const Icon(
                                      Icons.directions_run,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  title: global.textWidgetWithHeavyFont(
                                    "Leave/On-duty Application",
                                  ),
                                  subtitle: global.textWidget_ns(
                                    "Check your status on leave/on-duty forms",
                                  ),
                                ),
                              ),
                            ),
                            global.padHeight(20),
                            global.textWidgetWithHeavyFont("PERSONAL RECORD"),
                            global.padHeight(10),
                            Card(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.3),
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              borderOnForeground: false,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 130,
                                                width: 110,
                                                child: Card(
                                                  color: Theme.of(context)
                                                      .focusColor
                                                      .withOpacity(0.6),
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  borderOnForeground: false,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: global
                                                                .textWidget(
                                                                    "Attendance"),
                                                          ),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: global.textDoubleSpanWiget(
                                                                  "Absent: ",
                                                                  selfAbsentCount
                                                                      .toString())),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: global.textDoubleSpanWiget(
                                                                  "On-Duty: ",
                                                                  selfOnDutyCount
                                                                      .toString())),
                                                        ],
                                                      )),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 130,
                                                width: 110,
                                                child: Card(
                                                  color: Theme.of(context)
                                                      .focusColor
                                                      .withOpacity(0.6),
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  borderOnForeground: false,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: global
                                                                .textWidget(
                                                                    "Test score"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Center(
                                                              child:
                                                                  SemicircularIndicator(
                                                                radius: 30,
                                                                strokeWidth: 2,
                                                                progress: 0.35,
                                                                contain: true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                color:
                                                                    Colors.blue,
                                                                bottomPadding:
                                                                    0,
                                                                child: Text(
                                                                  '35%',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textSelectionTheme
                                                                          .cursorColor),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                            ),
                            global.padHeight(),
                            global.textDoubleSpanWiget(
                                "Status :", " Present on the class right now."),
                            global.padHeight(45),
                            global.textWidgetWithHeavyFont("CLASS RECORD"),
                            global.padHeight(10),
                            Card(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.3),
                              surfaceTintColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              borderOnForeground: false,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 130,
                                                width: 110,
                                                child: Card(
                                                  color: Theme.of(context)
                                                      .focusColor
                                                      .withOpacity(0.6),
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  borderOnForeground: false,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: global
                                                                .textWidget_ns(
                                                                    "Attendance"),
                                                          ),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: global.textDoubleSpanWiget(
                                                                  "Absent: ",
                                                                  classAbsentCount
                                                                      .toString())),
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: global.textDoubleSpanWiget(
                                                                  "On-Duty: ",
                                                                  classOnDutyCount
                                                                      .toString())),
                                                        ],
                                                      )),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 130,
                                                width: 110,
                                                child: Card(
                                                  color: Theme.of(context)
                                                      .focusColor
                                                      .withOpacity(0.6),
                                                  surfaceTintColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  borderOnForeground: false,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: global
                                                                .textWidget(
                                                                    "Avg score"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Center(
                                                              child:
                                                                  SemicircularIndicator(
                                                                radius: 30,
                                                                strokeWidth: 2,
                                                                progress: 0.35,
                                                                contain: true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                color:
                                                                    Colors.blue,
                                                                bottomPadding:
                                                                    0,
                                                                child: Text(
                                                                  '35%',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .textSelectionTheme
                                                                          .cursorColor),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                            ),
                            global.padHeight(30),
                            const SizedBox(height: 40)
                          ],
                        ))),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(28.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    global.textWidget(
                        "This UI is subjected to overhaul and will be done sooner as possible."),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            selectedClasses.clear();
                            selectedProgramme.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.school, color: Colors.white),
                          label: const Text(
                            "Programme",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .focusColor
                                .withOpacity(
                                    0.2), // Customize the background color
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
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
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (String name in programmes)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3.0, right: 3.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (selectedProgramme
                                                  .contains(name) ==
                                              false) {
                                            for (var x in (await global
                                                    .Database!.firestore
                                                    .collection(
                                                        "/department/${global.accObj!.parentDepartment}/subdepartments/$name/year_section")
                                                    .get())
                                                .docs) {
                                              var data = x.data();
                                              data["programme"] = name;
                                              data["_year"] = global
                                                  .convertToRoman(data["year"]);
                                              if (selectedYear.contains(
                                                  global.convertToRoman(
                                                      data["year"]))) {
                                                selectedClasses.add(data);
                                              }
                                            }
                                            selectedProgramme.add(name);
                                          } else {
                                            var repo = selectedClasses.toList();
                                            for (var x in repo) {
                                              if (x["programme"] == name) {
                                                selectedClasses.remove(x);
                                              }
                                            }
                                            selectedProgramme.remove(name);
                                          }
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .focusColor
                                              .withOpacity(selectedProgramme
                                                          .contains(name) ==
                                                      false
                                                  ? 0.8
                                                  : 0.2),
                                        ),
                                        child: global.textWidget_ns(name),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            selectedClasses.clear();
                            selectedYear.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.layers, color: Colors.white),
                          label: const Text(
                            "Year",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .focusColor
                                .withOpacity(
                                    0.2), // Customize the background color
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
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
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (String name in years)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3.0, right: 3.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (selectedYear.contains(name) ==
                                              false) {
                                            for (var prog
                                                in selectedProgramme) {
                                              for (var x in (await global
                                                      .Database!.firestore
                                                      .collection(
                                                          "/department/${global.accObj!.parentDepartment}/subdepartments/$prog/year_section")
                                                      .get())
                                                  .docs) {
                                                var data = x.data();
                                                if (global.convertToRoman(
                                                        data["year"]) ==
                                                    name) {
                                                  data["_year"] = name;
                                                  data["programme"] = prog;
                                                  selectedClasses.add(data);
                                                }
                                              }
                                            }
                                            selectedYear.add(name);
                                          } else {
                                            var repo = selectedClasses.toList();
                                            for (var x in repo) {
                                              if (x["_year"] == name) {
                                                selectedClasses.remove(x);
                                              }
                                            }
                                            selectedYear.remove(name);
                                          }
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .focusColor
                                              .withOpacity(
                                                  selectedYear.contains(name) ==
                                                          false
                                                      ? 0.8
                                                      : 0.2),
                                        ),
                                        child: global.textWidget_ns(name),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 300),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              for (var x in selectedClasses)
                                Card(
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  clipBehavior: Clip.antiAlias,
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2),
                                  child: InkWell(
                                    onTap: () {
                                      data = x;
                                      global.switchToSecondaryUi(
                                          const classInfoUI());
                                    },
                                    child: Container(
                                      height: 50, // Reduced height
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                          10.0), // Reduced padding
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).focusColor,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(width: 5),
                                              global.textWidget_ns(
                                                "${x["_year"].toString().toUpperCase()} ${x["programme"]}-${x["section"].toString().toUpperCase()}",
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  color: Colors.green,
                                                  size: 16),
                                              const SizedBox(width: 5),
                                              global.textWidget_ns(
                                                x["date"] != null &&
                                                        x["date"] ==
                                                            chosenDateStr
                                                    ? x["absent"].toString()
                                                    : "-",
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // Adjusted spacing
                                              const Icon(Icons.access_time,
                                                  color: Colors.orange,
                                                  size: 16),
                                              const SizedBox(width: 5),
                                              global.textWidget_ns(
                                                x["date"] != null &&
                                                        x["date"] ==
                                                            chosenDateStr
                                                    ? x["onDuty"].toString()
                                                    : "-",
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // Adjusted spacing
                                              const Icon(Icons.people_alt,
                                                  color: Colors.blue, size: 16),
                                              const SizedBox(width: 5),
                                              global.textWidget_ns(
                                                "Total: ${x["endRoll"] != null && x["startRoll"] != null ? (x["endRoll"] - x["startRoll"]).toString() : "NA"}",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ) // Stagged animation
                          ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

class classInfoUI extends StatelessWidget {
  const classInfoUI({super.key});

  @override
  Widget build(BuildContext context) {
    var x = data ?? {};
    return Scaffold(
      backgroundColor: Theme.of(context).focusColor.withOpacity(0.0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          data = null;
          global.switchToPrimaryUi();
        },
        label: const Text(
          "Done",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.done),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(right: 30, left: 30, top: 20, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              global.textWidgetWithHeavyFont(
                  "${x["_year"].toString().toUpperCase()}  ${x["programme"].toString().toUpperCase()}-${x["section"].toString().toUpperCase()}"),
              const SizedBox(height: 40),
              Card(
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).focusColor.withOpacity(0.5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                      onTap: () {
                        debugPrint("Prompting attendance checklist UI");
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => attendanceChecklist(
                                    year: x["_year"],
                                    programme: x["programme"],
                                    section: x["section"]),
                                opaque: false,
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                            scale: animation.drive(
                                              Tween(begin: 1.5, end: 1.0).chain(
                                                  CurveTween(
                                                      curve:
                                                          Curves.easeOutCubic)),
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: animation.value * 20,
                                                  sigmaY: animation.value * 20),
                                              child: child,
                                            ))),
                                transitionDuration:
                                    const Duration(seconds: 1)));
                      },
                      child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Text("Attendance Checklist",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textSelectionTheme
                                                  .selectionColor,
                                              fontSize: 16,
                                              letterSpacing: 1.3,
                                              fontFamily: "Metropolis")))),
                              Container(
                                height: double.infinity,
                                width: 7,
                                color: Colors.lightBlue,
                              )
                            ],
                          )))),
              const SizedBox(height: 15),
              Card(
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).focusColor.withOpacity(0.5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                      onTap: () {
                        debugPrint("Prompting Time Table [Edit] UI");
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => timeTableEditUi(
                                    year: x["_year"],
                                    section: x["section"],
                                    programme: x["programme"]),
                                opaque: false,
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                            scale: animation.drive(
                                              Tween(begin: 1.5, end: 1.0).chain(
                                                  CurveTween(
                                                      curve:
                                                          Curves.easeOutCubic)),
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: animation.value * 20,
                                                  sigmaY: animation.value * 20),
                                              child: child,
                                            ))),
                                transitionDuration:
                                    const Duration(seconds: 1)));
                      },
                      child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Text("Update Time Table",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textSelectionTheme
                                                  .selectionColor,
                                              fontSize: 17,
                                              letterSpacing: 1.3,
                                              fontFamily: "Metropolis")))),
                              Container(
                                height: double.infinity,
                                width: 7,
                                color: Colors.deepPurpleAccent,
                              )
                            ],
                          )))),
              const SizedBox(height: 15),
              Card(
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).focusColor.withOpacity(0.5),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: InkWell(
                      onTap: () {
                        debugPrint("Prompting Class Info [Edit] UI");
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => classInfoEditUi(
                                    year: x["_year"],
                                    section: x["section"],
                                    programme: x["programme"]),
                                opaque: false,
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                            scale: animation.drive(
                                              Tween(begin: 1.5, end: 1.0).chain(
                                                  CurveTween(
                                                      curve:
                                                          Curves.easeOutCubic)),
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: animation.value * 20,
                                                  sigmaY: animation.value * 20),
                                              child: child,
                                            ))),
                                transitionDuration:
                                    const Duration(seconds: 1)));
                      },
                      child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Text("Update Class Information",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textSelectionTheme
                                                  .selectionColor,
                                              fontSize: 17,
                                              letterSpacing: 1.3,
                                              fontFamily: "Metropolis")))),
                              Container(
                                height: double.infinity,
                                width: 7,
                                color: Colors.brown,
                              )
                            ],
                          )))),
              const SizedBox(height: 40),
              global.textWidget(
                  "Adding more data in here, such as Absentees name [current day], and then class info in an overview [class strength, roll start to end no.]")
            ],
          ),
        ),
      ),
    );
  }
}

class attendanceChecklist extends StatefulWidget {
  final String section;
  final String year;
  final String programme;
  const attendanceChecklist(
      {super.key,
      required this.section,
      required this.year,
      required this.programme});

  @override
  State<attendanceChecklist> createState() => _attendanceChecklistState();
}

class _attendanceChecklistState extends State<attendanceChecklist> {
  DateTime chosenDay = DateTime.now();
  final int startRoll = data["startRoll"] ?? 1;
  final int endRoll = data["endRoll"] ?? 60;
  Map studentInfo = {}; // Specified for current classCode
  String chosenDateStr = "";

  Map<String, dynamic> absent = {};
  Map<String, dynamic> onDuty = {};
  Map<String, dynamic> prevAbsent = {};
  Map<String, dynamic> prevOnDuty = {};

  int indexPos = 0;
  final _scrollController = FixedExtentScrollController();

  dynamic fetchedData;

  bool loaded = false;
  bool sheetEmpty = false;
  bool errored = false;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    chosenDateStr = DateFormat("dd-MM-yyyy").format(chosenDay).toString();
    super.initState();
    debugPrint("Loading Attendance for $chosenDateStr");
    Future.delayed(const Duration(), () async {
      loaded = false;
      try {
        var leaveDatas = await global.Database!.get(
            global.Database!.firestore.collection(
                "/department/${global.accObj!.parentDepartment}/subdepartments/${widget.programme}/year_section/${widget.year}_${widget.section}/attendance"),
            chosenDateStr);

        // If empty leave as it is, or else update the data
        if (leaveDatas.status == db_fetch_status.nodata) {
          sheetEmpty = true;
          debugPrint("data is empty for given class");
        } else {
          var leaveData = {};
          for (var x in (leaveDatas.data as Map).entries) {
            leaveData[x.key.toString()] = x.value;
          }

          for (var x in (leaveData["absent"].last as Map).entries) {
            absent[x.key] = true;
          }
          for (var x in (leaveData["onDuty"].last as Map).entries) {
            onDuty[x.key] = true;
          }
          fetchedData = leaveData;
          prevAbsent = Map.from(absent);
          prevOnDuty = Map.from(onDuty);
          indexPos = leaveData["absent"].length - 1;
        }

        //var get = await global.collectionMap["acc"]!.where("class", isEqualTo: data["classCode"]).get();

        // Loading register number mapped names in the sheet [if found]
        for (dynamic x in global.accountsInDatabase.values) {
          if (x["registerNum"] != null) {
            studentInfo[int.parse(x["registerNum"]
                    .toString()
                    .substring(x["registerNum"].toString().length - 3))] =
                "${x["firstName"]} ${x["lastName"]}";
          }
        }

        loaded = true;
        setState(() {});
        _scrollController.animateToItem(indexPos,
            duration: const Duration(seconds: 1), curve: Curves.decelerate);
      } catch (e) {
        debugPrint(e.toString());
        errored = true;
      }
      //loaded = true;
    });
  }

  bool odCheck = false;
  Map od = {};

  @override
  Widget build(BuildContext context) {
    String chosenDateStr =
        DateFormat("dd-MM-yyyy").format(chosenDay).toString();

    //debugPrint(data["leaveData"][chosenDateStr].toString());
    return Scaffold(
      backgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
      appBar: AppBar(
        title: global.textWidgetWithHeavyFont("Attendance update sheet"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textSelectionTheme.selectionHandleColor,
          ),
        ),
        backgroundColor: Theme.of(context).focusColor.withOpacity(0.8),
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(35),
              bottomLeft: Radius.circular(35)),
        ),
      ),
      floatingActionButton: (global.accountType == 1 && loaded)
          ? FloatingActionButton.extended(
              onPressed: () async {
                Navigator.pop(context);

                // Map newMap = {
                //   "checkBy":
                //       "${global.accObj!.title} ${global.accObj!.firstName} ${global.accObj!.lastName}"
                // };

                //Removing the cache
                // data["leaveData"][chosenDateStr].remove(data["leaveData"][chosenDateStr].last);

                // if(data["leaveData"][chosenDateStr].isEmpty || data["leaveData"][chosenDateStr].last["checkBy"] != newMap["checkBy"]) {
                //   data["leaveData"][chosenDateStr].add(newMap);

                // } else {
                //   data["leaveData"][chosenDateStr].last = newMap;
                // }

                debugPrint("Updating attendance | ${data.toString()}");
                var success = true;

                // Specific roll number leave and on duty
                var mark = "$chosenDateStr ${indexPos.toString()}";
                var absents = {};
                for (var x in absent.entries) {
                  absents[x.key] = fetchedData?["absents"]?.add(mark) ?? [mark];
                }
                var onDuties = {};
                for (var x in onDuties.entries) {
                  onDuties[x.key] =
                      fetchedData?["onDuties"]?.add(mark) ?? [mark];
                }

                if (sheetEmpty == true) {
                  final get = await global.Database!.create(
                      global.Database!.firestore.collection(
                          "/department/${global.accObj!.parentDepartment}/subdepartments/${widget.programme}/year_section/${widget.year}_${widget.section}/attendance"),
                      chosenDateStr,
                      {
                        "absent": [absent],
                        "onDuty": [onDuty],
                        "checkedBy": [
                          "${global.accObj!.title} ${global.accObj!.firstName} ${global.accObj!.lastName}"
                        ],
                      });

                  if (get.status != db_fetch_status.success) {
                    global.snackbarText(
                        "Failed create attendance | ${get.data.toString()}");
                    success = false;
                  } else {
                    global.snackbarText("Successfully created attendance!");
                  }
                } else {
                  (fetchedData["absent"] as List).add(absent);
                  (fetchedData["onDuty"] as List).add(onDuty);
                  (fetchedData["checkedBy"] as List).add(
                      "${global.accObj!.title} ${global.accObj!.firstName} ${global.accObj!.lastName}");

                  final get = await global.Database!.update(
                      global.Database!.firestore.collection(
                          "/department/${global.accObj!.parentDepartment}/subdepartments/${widget.programme}/year_section/${widget.year}_${widget.section}/attendance"),
                      chosenDateStr,
                      global.convertDynamicToMap(fetchedData));

                  if (get.status != db_fetch_status.success) {
                    success = false;
                    global.snackbarText(
                        "Failed update attendance | ${get.data.toString()}");
                  } else {
                    global.snackbarText("Successfully updated attendance!");
                  }
                }

                if (success) {
                  data = (await global.Database!.firestore
                          .collection(
                              "/department/${global.accObj!.parentDepartment}/subdepartments/${widget.programme}/year_section/")
                          .doc("${widget.year}_${widget.section}")
                          .get())
                      .data();
                  // data["absentUpdate"] = {chosenDateStr: absent.length};
                  // data["onDutyUpdate"] = {chosenDateStr: onDuty.length};
                  data["absents"] = absents;
                  data["date"] = chosenDateStr;
                  data["onDuties"] = onDuties;
                  data["absent"] = data["absent"] == null
                      ? absent.length
                      : (data["absent"] + (absent.length - prevAbsent.length));
                  data["onDuty"] = data["onDuty"] == null
                      ? onDuty.length
                      : (data["onDuty"] + (onDuty.length - prevOnDuty.length));
                  await global.Database!.update(
                      global.Database!.firestore.collection(
                          "/department/${global.accObj!.parentDepartment}/subdepartments/${widget.programme}/year_section/"),
                      "${widget.year}_${widget.section}",
                      data);
                }
              },
              label: const Text(
                "UPDATE",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(CupertinoIcons.refresh_thick),
            )
          : null,
      body: loaded == true
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 60,
                          height: 130,
                          child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstOut,
                            child: ClickableListWheelScrollView(
                              scrollController: _scrollController,
                              itemCount: fetchedData?["checkedBy"]?.length ?? 0,
                              itemHeight: 40,
                              onItemTapCallback: (index) {
                                setState(() {
                                  indexPos = index;
                                  absent = {};
                                  onDuty = {};
                                  for (var x
                                      in (fetchedData["absent"][index] as Map)
                                          .entries) {
                                    absent[x.key] = true;
                                  }
                                  for (var x
                                      in (fetchedData["onDuty"][index] as Map)
                                          .entries) {
                                    onDuty[x.key] = true;
                                  }
                                });
                              },
                              child: ListWheelScrollView.useDelegate(
                                perspective: 0.006,
                                itemExtent: 40,
                                controller: _scrollController,
                                physics: const FixedExtentScrollPhysics(),
                                overAndUnderCenterOpacity: 0.5,
                                childDelegate: ListWheelChildBuilderDelegate(
                                    childCount:
                                        fetchedData?["checkedBy"]?.length ?? 0,
                                    builder: (context, index) =>
                                        AnimatedContainer(
                                          duration: const Duration(seconds: 1),
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape
                                                .circle, // You can use like this way or like the below line
                                            //borderRadius: new BorderRadius.circular(30.0),
                                            color: indexPos != index
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.lightBlueAccent,
                                          ),
                                          child: Center(
                                              child:
                                                  Text((index + 1).toString())),
                                        )),
                              ),
                            ),
                          ),
                        )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .textSelectionTheme
                                        .selectionColor!),
                                borderRadius: BorderRadius.circular(10)),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  // Just for effects used inkwell
                                },
                                child: DateTimeField(
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    mode: DateTimeFieldPickerMode.date,
                                    dateTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .selectionColor),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                    selectedDate: chosenDay,
                                    onDateSelected: (DateTime value) {
                                      chosenDay = value;
                                      chosenDateStr = DateFormat("dd-MM-yyyy")
                                          .format(chosenDay)
                                          .toString();
                                      loaded = false;
                                      debugPrint(
                                          "Loading Attendance for $chosenDateStr");
                                      setState(() {});
                                      Future.delayed(const Duration(),
                                          () async {
                                        try {
                                          var leaveDatas =
                                              await global.Database!.get(
                                                  global.Database!
                                                      .addCollection(
                                                          "attendance",
                                                          "/attendance"),
                                                  "$chosenDateStr ${data["classCode"]}");

                                          absent = {};
                                          onDuty = {};
                                          prevOnDuty = {};
                                          prevAbsent = {};

                                          // If empty leave as it is, or else update the data
                                          if (leaveDatas.status ==
                                              db_fetch_status.nodata) {
                                            sheetEmpty = true;
                                            fetchedData = {};
                                          } else {
                                            sheetEmpty = false;
                                            var leaveData = {};
                                            for (var x
                                                in (leaveDatas.data as Map)
                                                    .entries) {
                                              leaveData[x.key.toString()] =
                                                  x.value;
                                            }

                                            for (var x in (leaveData["absent"]
                                                    .last as Map)
                                                .entries) {
                                              absent[x.key] = true;
                                            }
                                            for (var x in (leaveData["onDuty"]
                                                    .last as Map)
                                                .entries) {
                                              onDuty[x.key] = true;
                                            }
                                            fetchedData = leaveData;
                                            prevAbsent = Map.from(absent);
                                            prevOnDuty = Map.from(onDuty);
                                            indexPos =
                                                fetchedData["absent"].length -
                                                    1;
                                          }

                                          //var get = await global.collectionMap["acc"]!.where("class", isEqualTo: data["classCode"]).get();
                                          debugPrint(
                                              global.classroom_data.toString());

                                          // Loading register number mapped names in the sheet [if found]
                                          for (dynamic x in global
                                              .accountsInDatabase.values) {
                                            if (x["registerNum"] != null) {
                                              studentInfo[int.parse(x[
                                                          "registerNum"]
                                                      .toString()
                                                      .substring(
                                                          x["registerNum"]
                                                                  .toString()
                                                                  .length -
                                                              3))] =
                                                  "${x["firstName"]} ${x["lastName"]}";
                                            }
                                          }

                                          loaded = true;
                                          setState(() {});
                                          _scrollController.animateToItem(
                                              indexPos,
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.decelerate);
                                        } catch (e) {
                                          debugPrint(e.toString());
                                          errored = true;
                                        }
                                        //loaded = true;
                                      });

                                      setState(() {});
                                    }),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              //clipBehavior: Clip.antiAlias,
                              color: Theme.of(context).focusColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var x in [
                                      [
                                        Icons.warning,
                                        "Class information is not defined properly [such as starting/end roll no]; Advised to update classroom info.",
                                        data["startRoll"] == null ||
                                            data["endRoll"] == null
                                      ],
                                      [
                                        Icons.info,
                                        "Attendance has been checked by ${fetchedData?["checkedBy"] != null ? fetchedData["checkedBy"][indexPos] : "null"}",
                                        fetchedData?["checkedBy"] != null
                                      ],
                                      [
                                        Icons.info_outline_rounded,
                                        "Attendance has not been checked for this day.",
                                        sheetEmpty
                                      ]
                                    ]..iterator)
                                      if (x[2] == true)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                  child: Icon(x[0] as IconData,
                                                      color: Theme.of(context)
                                                          .textSelectionTheme
                                                          .selectionHandleColor)),
                                              Flexible(
                                                  flex: 8,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: global.textWidget(
                                                        x[1] as String),
                                                  )),
                                            ],
                                          ),
                                        )
                                  ],
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        global.textWidgetWithHeavyFont(
                            "Select roll no. to mark as absent"),
                        const SizedBox(height: 10),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 60, top: 5, left: 8, right: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  clipBehavior: Clip.antiAlias,
                                  children: [
                                    for (int i = startRoll; i <= endRoll; i++)
                                      ChoiceChip(
                                        onSelected: (bool val) {
                                          setState(() {
                                            if (val) {
                                              absent[i.toString()] = val;
                                            } else {
                                              absent.remove(i.toString());
                                            }
                                          });
                                        },
                                        selected: absent[i.toString()] ?? false,
                                        label: Text(
                                          "${i.toString()}${studentInfo[i] != null ? "- ${studentInfo[i]}" : ""}",
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        global.textWidgetWithHeavyFont(
                            "Select roll no. to mark On-Duty"),
                        const SizedBox(height: 10),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 60, top: 5, left: 8, right: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  clipBehavior: Clip.antiAlias,
                                  children: [
                                    for (int i = startRoll; i <= endRoll; i++)
                                      ChoiceChip(
                                        selectedColor: Colors.orangeAccent,
                                        onSelected: (bool val) {
                                          setState(() {
                                            if (val) {
                                              onDuty[i.toString()] = val;
                                            } else {
                                              onDuty.remove(i.toString());
                                            }
                                          });
                                        },
                                        selected: onDuty[i.toString()] ?? false,
                                        label: Text(
                                          "${i.toString()}${studentInfo[i] != null ? "- ${studentInfo[i]}" : ""}",
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SpinKitRing(
              color: Theme.of(context).textSelectionTheme.selectionColor!),
    );
  }
}

class timeTableEditUi extends StatefulWidget {
  final String section;
  final String year;
  final String programme;
  const timeTableEditUi(
      {super.key,
      required this.section,
      required this.year,
      required this.programme});

  @override
  State<timeTableEditUi> createState() => _timeTableEditUiState();
}

class _timeTableEditUiState extends State<timeTableEditUi> {
  Map timetable = {};
  List courseList = [
    {
      "code": "Lunch",
      "faculty": "no one",
      "full": "Break",
      "name": "Lunch - Break"
    },
    {
      "code": "Morning",
      "faculty": "no one",
      "full": "Interval",
      "name": "Morning Interval"
    },
    {
      "code": "Evening",
      "faculty": "no one",
      "full": "Interval",
      "name": "Evening Interval"
    },
  ];
  Map isExpanded = {};
  Map facultyList = {};
  List options = [
    ["No one", "no one"],
    ["Custom name instead of choice", "cn"]
  ];

  @override
  void initState() {
    super.initState();
    timetable = (data["timeTable"] ?? {});
    courseList = data["course"] ??
        [
          {
            "code": "Lunch",
            "faculty": "no one",
            "full": "Break",
            "name": "Lunch - Break"
          },
          {
            "code": "Morning",
            "faculty": "no one",
            "full": "Interval",
            "name": "Morning Interval"
          },
          {
            "code": "Evening",
            "faculty": "no one",
            "full": "Interval",
            "name": "Evening Interval"
          },
        ];
    data["course"] = courseList;
    Future.delayed(const Duration(), () async {
      var get = await global.Database!
          .addCollection("acc", "/acc")
          .where("isStudent", isEqualTo: false)
          .get();
      for (var x in get.docs) {
        Map<String, dynamic> data = x.data() as Map<String, dynamic>;
        if (data["phoneNo"] != null) {
          Map<dynamic, dynamic> xy = data;
          facultyList[x.reference.id] = xy;
          debugPrint(xy.toString());
          options.add([
            "${xy["title"]} ${xy["firstName"]} ${xy["lastName"]}",
            x.reference.id
          ]);
        }
      }
      debugPrint(options.toString());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
        appBar: AppBar(
          title: global.textWidgetWithHeavyFont("Time Table update sheet"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionHandleColor,
            ),
          ),
          backgroundColor: Theme.of(context).focusColor.withOpacity(0.8),
          shadowColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(35),
                bottomLeft: Radius.circular(35)),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.pop(context);

            debugPrint(data.toString());
            final get = await global.Database!.update(
                global.Database!.addCollection("class", "/class"),
                data["classCode"],
                data);

            ScaffoldMessenger.of(global.rootCTX!).showSnackBar(SnackBar(
              content: Text(get.status == db_fetch_status.success
                  ? "Successfully updated the attendance!"
                  : "Failed to update, ${get.data.toString()}"),
            ));
          },
          label: const Text(
            "UPDATE",
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(CupertinoIcons.refresh_thick),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 5,
                  children: [
                    ChoiceChip(
                      label: const Text(
                        "Create a new course data",
                        style: TextStyle(fontSize: 13),
                      ),
                      avatar: const Icon(Icons.create),
                      selected: false,
                      onSelected: (bool val) {
                        TextEditingController codeName =
                            TextEditingController();
                        TextEditingController fullName =
                            TextEditingController();
                        TextEditingController facultyName =
                            TextEditingController();

                        String chosenF = "no one";

                        global.alert.quickAlert(context, const SizedBox(),
                            bodyFn: () => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    global.textWidget(
                                        "Fill the following details"),
                                    const SizedBox(height: 20),
                                    global.textField("Subject Code Name",
                                        controller: codeName),
                                    const SizedBox(height: 10),
                                    global.textField("Subject Full Name",
                                        controller: fullName),
                                    const SizedBox(height: 20),
                                    DropdownButton(
                                      items: [
                                        for (var x in options)
                                          DropdownMenuItem(
                                            value: x[1],
                                            child: global.textWidget(x[0]),
                                          )
                                      ],
                                      onChanged: (val) {
                                        global.quickAlertGlobalVar(
                                            () => chosenF = val.toString());
                                      },
                                      value: chosenF,
                                      dropdownColor:
                                          Theme.of(context).focusColor,
                                    ),
                                    const SizedBox(height: 20),
                                    if (chosenF == "cn")
                                      global.textField("Faculty name",
                                          controller: facultyName)
                                  ],
                                ),
                            action: [
                              FloatingActionButton(
                                  onPressed: () {
                                    Navigator.pop(context);

                                    Future.delayed(const Duration(), () async {
                                      String message =
                                          "Successfully added the course in the list";

                                      if (codeName.text == "" ||
                                          fullName.text == "") {
                                        message =
                                            "Failed, field values was not properly filled!";
                                      } else {
                                        courseList.add({
                                          "name":
                                              "${codeName.text} - ${fullName.text}",
                                          "code": codeName.text,
                                          "full": fullName.text,
                                          "faculty": chosenF == "cn"
                                              ? facultyName.text
                                              : chosenF
                                        });
                                        data["course"] = courseList;

                                        var get = await global.Database!.update(
                                            global.collectionMap["classroom"]!,
                                            data["classCode"],
                                            data);

                                        if (get.status !=
                                            db_fetch_status.success) {
                                          message = "Error, ${get.data}";
                                        }
                                      }

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(message),
                                      ));
                                      setState(() {});
                                    });
                                  },
                                  child: const Text("Submit"))
                            ]);
                      },
                    ),
                    ChoiceChip(
                      label: const Text(
                        "Change the timing",
                        style: TextStyle(fontSize: 13),
                      ),
                      avatar: const Icon(Icons.timeline),
                      selected: false,
                      onSelected: (bool val) {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                global
                    .textWidget("Drag and drop the courses into specific day"),
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints:
                      BoxConstraints.loose(const Size(double.infinity, 200)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          global.textWidgetWithHeavyFont("COURSES   :"),
                          for (var x in courseList)
                            Draggable(
                              data: x,
                              feedback: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.redAccent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      //height: 35,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(x["name"],
                                              style: const TextStyle(
                                                fontSize: 15,
                                              )))),
                                ],
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.lightBlue),
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 35,
                                  //width: 250,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: global.textWidget(x["name"]),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                DragTarget(
                  onAccept: (dataa) {
                    debugPrint("Ok deleting the ${dataa.toString()}");
                    int val = courseList.indexOf(dataa);
                    var fakeTimeTable = Map.from(timetable);
                    debugPrint(fakeTimeTable.toString());
                    var success = "";
                    try {
                      for (var x in fakeTimeTable.entries) {
                        int indexs = 0;
                        for (var y in List.from(x.value ?? [])) {
                          if (y == val) {
                            (timetable[x.key] as List).removeAt(indexs);
                            indexs--;
                          } else if (y > val) {
                            timetable[x.key][indexs] = y - 1;
                          }
                          indexs++;
                        }
                      }
                      courseList.remove(dataa);
                    } catch (e) {
                      debugPrint(e.toString());
                      success = e.toString();
                    }

                    Future.delayed(const Duration(), () async {
                      debugPrint("Delete operation on future function");
                      String message =
                          "Successfully removed the course in the list";

                      if (success == "") {
                        data["timeTable"] = timetable;
                        data["course"] = courseList;

                        debugPrint("Removed the data from the list");
                        var get = await global.Database!.update(
                            global.collectionMap["classroom"]!,
                            data["classCode"],
                            data);

                        if (get.status != db_fetch_status.success) {
                          message = "Error, ${get.data}";
                        }
                      } else {
                        message = "Failed to update, $success";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message),
                      ));
                      setState(() {});
                    });
                  },
                  onWillAccept: (data) => true,
                  builder: (BuildContext buildContext, List a, List b) =>
                      Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        global.textWidget("Remove The Course [Drag it here]"),
                      ],
                    ),
                  ),
                ),
                DragTarget(
                  onAccept: (dynamic dataa) {
                    TextEditingController codeName =
                        TextEditingController(text: dataa["code"]);
                    TextEditingController fullName =
                        TextEditingController(text: dataa["full"]);
                    TextEditingController facultyName =
                        TextEditingController(text: dataa["faculty"]);

                    String chosenF = "no one";

                    global.alert.quickAlert(context, const SizedBox(),
                        bodyFn: () => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                global.textWidget("Fill the following details"),
                                const SizedBox(height: 20),
                                global.textField("Subject Code Name",
                                    controller: codeName),
                                const SizedBox(height: 10),
                                global.textField("Subject Full Name",
                                    controller: fullName),
                                const SizedBox(height: 20),
                                DropdownButton(
                                  items: [
                                    for (var x in options)
                                      DropdownMenuItem(
                                        value: x[1],
                                        child: global.textWidget(x[0]),
                                      )
                                  ],
                                  onChanged: (val) {
                                    global.quickAlertGlobalVar(
                                        () => chosenF = val.toString());
                                  },
                                  value: chosenF,
                                  dropdownColor: Theme.of(context).focusColor,
                                ),
                                const SizedBox(height: 20),
                                if (chosenF == "cn")
                                  global.textField("Faculty name",
                                      controller: facultyName)
                              ],
                            ),
                        action: [
                          FloatingActionButton(
                              onPressed: () {
                                Navigator.pop(context);

                                Future.delayed(const Duration(), () async {
                                  String message =
                                      "Successfully updated the course in the list";

                                  if (codeName.text == "" ||
                                      fullName.text == "") {
                                    message =
                                        "Failed, field values was not properly filled!";
                                  } else {
                                    courseList[courseList.indexOf(dataa)] = {
                                      "name":
                                          "${codeName.text} - ${fullName.text}",
                                      "code": codeName.text,
                                      "full": fullName.text,
                                      "faculty": chosenF == "cn"
                                          ? facultyName.text
                                          : chosenF
                                    };
                                    data["course"] = courseList;

                                    var get = await global.Database!.update(
                                        global.collectionMap["classroom"]!,
                                        data["classCode"],
                                        data);

                                    if (get.status != db_fetch_status.success) {
                                      message = "Error, ${get.data}";
                                    }
                                  }

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(message),
                                  ));
                                  setState(() {});
                                });
                              },
                              child: const Text("Update"))
                        ]);
                  },
                  onWillAccept: (data) => true,
                  builder: (BuildContext buildContext, List a, List b) =>
                      Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        global.textWidget(
                            "Update The Course data [Drag it here]"),
                      ],
                    ),
                  ),
                ),
                Wrap(children: [
                  for (var x in {
                    "0": "Monday",
                    "1": "Tuesday",
                    "2": "Wednesday",
                    "3": "Thursday",
                    "4": "Friday",
                    "5": "Saturday"
                  }.entries)
                    DragTarget(
                      onAccept: (dynamic dataa) {
                        //List info = [dataa["name"], dataa["faculty"]];

                        if (timetable[x.key] != null &&
                            timetable[x.key].isNotEmpty) {
                          timetable[x.key].add(courseList.indexOf(dataa));
                        } else {
                          timetable[x.key] = [courseList.indexOf(dataa)];
                        }
                        debugPrint(courseList.indexOf(dataa).toString());

                        setState(() {
                          data["timeTable"] = timetable;
                        });
                      },
                      onWillAccept: (data) => true,
                      builder: (BuildContext buildContext, List a, List b) =>
                          InkWell(
                        onTap: () {
                          setState(() => isExpanded[x.key] =
                              isExpanded[x.key] == null
                                  ? true
                                  : !isExpanded[x.key]);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(isExpanded[x.key] == null
                              ? 1
                              : (isExpanded[x.key] ? 4 : 1)),
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 500),
                            crossFadeState: isExpanded[x.key] == null
                                ? CrossFadeState.showFirst
                                : (isExpanded[x.key]
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst),
                            firstChild: ChoiceChip(
                              selected: false,
                              clipBehavior: Clip.antiAlias,
                              //color: Colors.white,
                              //shadowColor: Colors.transparent,
                              //surfaceTintColor: Colors.transparent,
                              label: Text(
                                "${x.value.toString()} [${(timetable[x.key] ?? []).length}]",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            secondChild: Wrap(
                              runAlignment: WrapAlignment.center,
                              runSpacing: 0,
                              spacing: 0,
                              //mainAxisSize: MainAxisSize.min,
                              children: [
                                global.textWidgetWithHeavyFont("${x.value} :"),
                                for (int y in timetable[x.key] ?? {})
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      height: 30,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.cyanAccent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() =>
                                                  timetable[x.key].remove(y));
                                              data["timeTable"] = timetable;
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 8.0,
                                                  bottom: 8),
                                              child: Icon(
                                                Icons.close,
                                                color: Theme.of(context)
                                                    .textSelectionTheme
                                                    .selectionColor,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 5,
                                                left: 3,
                                                top: 2,
                                                bottom: 2),
                                            child: global.textWidget(
                                                courseList[y]["name"]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                ]),
                const SizedBox(height: 40),
                const SizedBox(height: 30)
              ],
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class classInfoEditUi extends StatelessWidget {
  TextEditingController startRoll =
      TextEditingController(text: data["startRoll"].toString());
  TextEditingController endRoll =
      TextEditingController(text: data["endRoll"].toString());

  final String section;
  final String year;
  final String programme;
  classInfoEditUi(
      {super.key,
      required this.section,
      required this.year,
      required this.programme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
        appBar: AppBar(
          title: global.textWidgetWithHeavyFont("Class Info update sheet"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionHandleColor,
            ),
          ),
          backgroundColor: Theme.of(context).focusColor.withOpacity(0.8),
          shadowColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(35),
                bottomLeft: Radius.circular(35)),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.pop(context);
            data = (await global.Database!.firestore
                    .collection(
                        "/department/${global.accObj!.parentDepartment}/subdepartments/$programme/year_section/")
                    .doc("${year}_$section")
                    .get())
                .data();
            data["startRoll"] = int.parse(startRoll.text);
            data["endRoll"] = int.parse(endRoll.text);

            debugPrint(data.toString());
            final get = await global.Database!.update(
                global.Database!.firestore.collection(
                    "/department/${global.accObj!.parentDepartment}/subdepartments/$programme/year_section/"),
                "${year}_$section",
                data);

            ScaffoldMessenger.of(global.rootCTX!).showSnackBar(SnackBar(
              content: Text(get.status == db_fetch_status.success
                  ? "Successfully updated the class information!"
                  : "Failed to update, ${get.data.toString()}"),
            ));
          },
          label: const Text(
            "UPDATE",
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(CupertinoIcons.refresh_thick),
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: global.textWidgetWithHeavyFont("Roll number structure"),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    global.textField("Starting Roll No",
                        controller: startRoll,
                        keyboardType: TextInputType.number,
                        inputFormats: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 3),
                    const SizedBox(width: 30),
                    global.textField("Ending Roll No",
                        controller: endRoll,
                        keyboardType: TextInputType.number,
                        inputFormats: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 3),
                  ],
                ),
              ),
            )
          ],
        )));
  }
}
