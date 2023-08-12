import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/bulletPoint.dart';
import 'package:Project_Prism/ui/expandable.dart';
import 'package:Project_Prism/ui/heroDialogRoute.dart';
import 'package:Project_Prism/ui/radioButton.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_pile/flutter_face_pile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Widget? cacheOfSecondPage;

class courseInfoUi extends StatefulWidget {
  @override
  State<courseInfoUi> createState() => _courseInfoUiState();
}

class _courseInfoUiState extends State<courseInfoUi> {
  PageController pg = PageController();

  TextEditingController _text = TextEditingController();

  String _selectedDepartment = "All";

  String _selectedYear = "All";

  List<DocumentSnapshot>? courseData;

  List<String> getDepartmentFromCourseData() {
    if (courseData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in courseData!) {
      for (var y in x.get("department")) {
        map[y.toString()] = true;
      }
    }
    return map.keys.toList();
  }

  List<String> getYearFromCourseData() {
    if (courseData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in courseData!) {
      map[x.get("year")] = true;
    }
    return map.keys.toList();
  }

  List<Map<String, dynamic>> courseDataProcess() {
    List<Map<String, dynamic>> output = [];

    for (DocumentSnapshot<Object?> x in courseData!) {
      if (x.id.endsWith("_raw") == false)
        output.add(x.data() as Map<String, dynamic>);
    }
    return output;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      global.Database!.addCollection("courses", "/courses");

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("/courses").get();
      courseData = querySnapshot.docs;
      debugPrint("${courseData.toString()} ");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return courseData == null
        ? const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SpinKitThreeBounce(
                color: Colors.blue, // set the color of the spinner
                size: 50.0, // set the size of the spinner
              ),
            ))
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: PageView(
              controller: pg,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, right: 15, left: 15, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Adjust border radius as needed
                                          ),
                                          shadowColor: Colors.transparent,
                                          backgroundColor:
                                              Theme.of(context).focusColor,
                                          surfaceTintColor: Colors.transparent),
                                      onPressed: () {
                                        global.alert.quickAlert(
                                            context,
                                            GreenRadio(
                                              stringList: [
                                                "All",
                                                for (var x
                                                    in getDepartmentFromCourseData())
                                                  x
                                              ],
                                              callback: (val) {
                                                debugPrint(
                                                    "Initial : $_selectedDepartment | Changing to : $val");
                                                setState(() {
                                                  _selectedDepartment = val;
                                                });
                                              },
                                              initalValue: _selectedDepartment,
                                            ),
                                            action: null);
                                      },
                                      icon: Icon(Icons.layers),
                                      label: Text(
                                        "Department Type",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor,
                                            fontSize: 12),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0), // Adjust border radius as needed
                                          ),
                                          shadowColor: Colors.transparent,
                                          backgroundColor:
                                              Theme.of(context).focusColor,
                                          surfaceTintColor: Colors.transparent),
                                      onPressed: () {
                                        global.alert.quickAlert(
                                            context,
                                            GreenRadio(
                                              stringList: [
                                                "All",
                                                for (String x
                                                    in getYearFromCourseData())
                                                  x
                                              ],
                                              callback: (val) {
                                                setState(() {
                                                  _selectedYear = val;
                                                });
                                              },
                                              initalValue: _selectedYear,
                                            ),
                                            action: null);
                                      },
                                      icon: Icon(Icons.timeline),
                                      label: Text(
                                        "Year",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textSelectionTheme
                                                .selectionColor,
                                            fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 10,
                            child: AnimSearchBar(
                                color: Theme.of(context).focusColor,
                                closeSearchOnSuffixTap: true,
                                style: TextStyle(
                                    //fontSize: 12
                                    color: Theme.of(context)
                                        .textSelectionTheme
                                        .selectionColor,
                                    fontFamily: "Metropolis",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17),
                                rtl: true,
                                width: MediaQuery.of(context).size.width - 10,
                                textController: _text,
                                onSuffixTap: () {}),
                          )
                        ],
                      ),
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
                          child: Column(
                              children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 300),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: widget,
                                        ),
                                      ),
                                  children: [
                                for (Map<String, dynamic> entry
                                    in courseDataProcess())
                                  if (((entry["department"] as List<dynamic>)
                                              .contains(_selectedDepartment) ||
                                          _selectedDepartment == "All") &&
                                      (entry["year"] == _selectedYear ||
                                          _selectedYear == "All"))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10,
                                          left: 10,
                                          top: 8.0,
                                          bottom: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        clipBehavior: Clip.antiAlias,
                                        child: ElevatedButton(
                                          clipBehavior: Clip.hardEdge,
                                          onPressed: () {
                                            setState(() {
                                              cacheOfSecondPage =
                                                  displayCourseData(
                                                courseData: entry,
                                                callback: () {
                                                  pg.animateToPage(0,
                                                      duration: Duration(
                                                          milliseconds: 650),
                                                      curve:
                                                          Curves.easeOutExpo);
                                                },
                                              );
                                            });
                                            pg.animateToPage(1,
                                                duration:
                                                    Duration(milliseconds: 650),
                                                curve: Curves.easeOutExpo);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    8.0), // Adjust border radius as needed
                                              ),
                                              shadowColor: Colors.transparent,
                                              backgroundColor:
                                                  Theme.of(context).focusColor,
                                              surfaceTintColor:
                                                  Colors.transparent),
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                  left: 8,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      global
                                                          .textWidgetWithHeavyFont(
                                                              entry["code"]),
                                                      SizedBox(width: 15),
                                                      Text(
                                                        "${entry["year"]} | ${entry["semester"].toString()} Semester",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "roboto",
                                                            color: Theme.of(
                                                                    context)
                                                                .textSelectionTheme
                                                                .selectionHandleColor,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          entry["department"]
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "montserrat",
                                                              color: Theme.of(
                                                                      context)
                                                                  .textSelectionTheme
                                                                  .selectionHandleColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          width: 60,
                                                          height: 30,
                                                          child: FacePile(
                                                            faces: [
                                                              for (int x in [
                                                                1,
                                                                2,
                                                                3,
                                                                4
                                                              ])
                                                                FaceHolder(
                                                                    avatar: NetworkImage(
                                                                        "https://i.pravatar.cc/300?img=${x.toString()}"),
                                                                    name: "idk",
                                                                    id: x
                                                                        .toString())
                                                            ],
                                                            faceSize: 30,
                                                            facePercentOverlap:
                                                                .2,
                                                            borderColor: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                      ])
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ])),
                        ),
                      ),
                    ],
                  ),
                ),
                cacheOfSecondPage ??
                    ElevatedButton(
                        onPressed: () {
                          pg.animateToPage(0,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeOutExpo);
                        },
                        child: Text("click me"))
              ],
            ),
          );
  }
}

class displayCourseData extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final Function()? callback;
  displayCourseData({super.key, required this.courseData, this.callback});

  @override
  State<displayCourseData> createState() => _displayCourseDataState();
}

class _displayCourseDataState extends State<displayCourseData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textSelectionTheme.selectionColor),
          onPressed: () => (widget.callback ?? () {})(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.courseData["code"],
              style: TextStyle(
                  fontFamily: "montserrat",
                  color:
                      Theme.of(context).textSelectionTheme.selectionHandleColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
            SizedBox(width: 5),
            Text(
              widget.courseData["title"],
              style: TextStyle(
                  fontFamily: "montserrat",
                  color:
                      Theme.of(context).textSelectionTheme.selectionHandleColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 200),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) {
                              return Center(
                                  child: promptCourseDesc(
                                      widget.courseData, context));
                            },
                          ));
                        },
                        child: Hero(
                          tag: "CourseDesc",
                          child: Material(
                              color: Theme.of(context).focusColor,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "About course",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textSelectionTheme
                                          .selectionHandleColor,
                                      fontFamily: "lato"),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: FacePile(
                          faces: [
                            for (int x in [1, 2, 3, 4])
                              FaceHolder(
                                  avatar: NetworkImage(
                                      "https://i.pravatar.cc/300?img=${x.toString()}"),
                                  name: "idk",
                                  id: x.toString())
                          ],
                          faceSize: 30,
                          facePercentOverlap: .2,
                          borderColor: Colors.transparent,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, HeroDialogRoute(
                            builder: (BuildContext context) {
                              return Center(
                                  child: promptLTPC(
                                      widget.courseData["LTPC"], context));
                            },
                          ));
                        },
                        child: Hero(
                          tag: "LTPC",
                          child: Material(
                              color: Theme.of(context).focusColor,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "L \tT \tP \tC\n${widget.courseData["LTPC"].join(" \t")}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textSelectionTheme
                                          .selectionHandleColor,
                                      fontFamily: "lato"),
                                ),
                              )),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  CustomExpansionWidget(
                      header: "Course objectives",
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String x in widget.courseData["objectives"])
                            global.textWidget(x + "\n")
                        ],
                      )),
                  CustomExpansionWidget(
                      header: "Course outcomes",
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String x in widget.courseData["outcomes"])
                            global.textWidget(x + "\n")
                        ],
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  for (int x in List.generate(
                      widget.courseData["syllabus_topic"].length,
                      (index) => index))
                    CustomExpansionWidget(
                        header: widget.courseData["syllabus_topic"][x] +
                            "\t\t( ${widget.courseData["syllabus_credits"][x].toString()} )",
                        body: BulletPoints(
                          widget.courseData["syllabus_subtopic"][x].split(";"),
                          TextStyle(
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor,
                              fontSize: 12),
                        )),
                  SizedBox(
                    height: 30,
                  ),
                  CustomExpansionWidget(
                      header: "Textbook",
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String x in widget.courseData["textbook"])
                            global.textWidget(x + "\n")
                        ],
                      )),
                  CustomExpansionWidget(
                      header: "Reference book",
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (String x in widget.courseData["reference"])
                            global.textWidget(x + "\n")
                        ],
                      )),
                  SizedBox(height: 30),
                  CustomExpansionWidget(
                      header: "Materials",
                      body: global.textWidget("None so far.")),
                  SizedBox(
                    height: 50,
                  )
                ],
              )),
        ),
      ),
    );
  }
}

Widget promptLTPC(List<dynamic> list, BuildContext context) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: 650,
        child: Hero(
            tag: "LTPC",
            child: Material(
                clipBehavior: Clip.hardEdge,
                color: Theme.of(context).focusColor,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: BulletPoints(
                      const [
                        "Lecture Tutorial Practical Credit [Period]\n",
                        "Lecture: It is something what you get in your classroom. Mostly comprised of theory and might have relevancy with the real world. The scenario can be hypothetical(Imaginary) or may be real sometimes. When you attain a lecture, you com to know the concept only and have to relate by yourself with the reality or imagination.\n",
                        "Tutorial: These are the experimentation of the Lectures. Whatever is taught to your in your lectures, the tutorial comprised of its implementation. You will like the tutorial always over lectures, as they will tell you what the real implementation is.\n",
                        "Practical: This is something complicated. Many a times what you learn through Lectures or Tutorials are helpful in your practicals. But most o the times, your experience earned through your lectures or tutorials is what required as the scenario can be way far different from the reality and you can come across many obstructions which you never had seen during your lectures or tutorials.\n",
                        "Credit: The points that you earned out of the everything you do, if there is any scoring. These are just points that help you in proving your credibility and excellence in a particular stream.\n"
                      ],
                      TextStyle(
                          color: Theme.of(context)
                              .textSelectionTheme
                              .selectionColor,
                          fontFamily: "Open Sans")),
                ))),
      ),
    ),
  );
}

Widget promptCourseDesc(var courseData, BuildContext context) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Hero(
          tag: "CourseDesc",
          child: Material(
              clipBehavior: Clip.hardEdge,
              color: Theme.of(context).focusColor,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(courseData["description"],
                    style: TextStyle(
                        color:
                            Theme.of(context).textSelectionTheme.selectionColor,
                        fontFamily: "Open Sans")),
              ))),
    ),
  );
}
