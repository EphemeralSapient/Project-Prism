import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/radioButton.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_pile/flutter_face_pile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Widget? cacheOfSecondPage;

class courseUpdateUi extends StatefulWidget {
  @override
  State<courseUpdateUi> createState() => _courseUpdateUiState();
}

class _courseUpdateUiState extends State<courseUpdateUi> {
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
                                                for (String x
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
                                                  courseOverrideUi(
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

class courseOverrideUi extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final Function callback;
  courseOverrideUi(
      {super.key, required this.courseData, required this.callback});

  @override
  _courseOverrideUiState createState() => _courseOverrideUiState();
}

class _courseOverrideUiState extends State<courseOverrideUi> {
  TextEditingController _courseCodeController = TextEditingController();
  TextEditingController _courseTitleController = TextEditingController();
  TextEditingController _courseDescriptionController = TextEditingController();
  TextEditingController _courseLTPCController = TextEditingController();
  TextEditingController _courseSyllabusController = TextEditingController();
  TextEditingController _courseTotalPeriodsController = TextEditingController();
  TextEditingController _courseObjectivesController = TextEditingController();
  TextEditingController _courseOutcomesController = TextEditingController();
  TextEditingController _coursePrerequisitesController =
      TextEditingController();
  TextEditingController _courseTextbookController = TextEditingController();
  TextEditingController _courseReferenceController = TextEditingController();

  var paddingEdgeVar = EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: global.textWidgetWithHeavyFont('Course Form'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).textSelectionTheme.selectionColor),
            onPressed: () {
              widget.callback();
            },
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 16.0, left: 16, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              global.textField('Course Code',
                  controller: _courseCodeController),
              SizedBox(height: 15),
              global.textField('Course Title',
                  controller: _courseTitleController),
              SizedBox(height: 15),
              global.textField('Course Description',
                  controller: _courseDescriptionController),
              SizedBox(height: 15),
              global.textField('Course LTPC',
                  controller: _courseLTPCController),
              SizedBox(height: 15),
              global.textField('Course Syllabus',
                  controller: _courseSyllabusController),
              SizedBox(height: 15),
              global.textField('Course Total Periods',
                  controller: _courseTotalPeriodsController),
              SizedBox(height: 15),
              global.textField('Course Objectives',
                  controller: _courseObjectivesController),
              SizedBox(height: 15),
              global.textField('Course Outcomes',
                  controller: _courseOutcomesController),
              SizedBox(height: 15),
              global.textField('Course Prerequisites',
                  controller: _coursePrerequisitesController),
              SizedBox(height: 15),
              global.textField('Course Textbook',
                  controller: _courseTextbookController),
              SizedBox(height: 15),
              global.textField('Course Reference',
                  controller: _courseReferenceController),
              SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  shadowColor: Colors.transparent,
                  backgroundColor: Theme.of(context).focusColor,
                  surfaceTintColor: Colors.transparent,
                ),
                onPressed: () {
                  global.alert.quickAlert(context,
                      global.textWidget("WIP, soon implemention, maybe?"));
                },
                icon: Icon(Icons.done),
                label: global.textWidgetWithHeavyFont("Update"),
              ),
              SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
