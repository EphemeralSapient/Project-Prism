import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/ui/radioButton.dart';
import 'package:Project_Prism/ui/searchButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_pile/flutter_face_pile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

List<Widget?> cacheOfPages = [];

class classroomUpdateUi extends StatefulWidget {
  @override
  State<classroomUpdateUi> createState() => _classroomUpdateUiState();
}

class _classroomUpdateUiState extends State<classroomUpdateUi> {
  PageController pg = PageController();

  TextEditingController _text = TextEditingController();

  String _selectedDepartment = "All";

  String _selectedYear = "All";

  List<DocumentSnapshot>? classroomData;

  List<String> getDepartmentFromClassData() {
    if (classroomData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in classroomData!) {
      map[x.get("department")] = true;
    }
    return map.keys.toList();
  }

  List<String> getYearFromClassData() {
    if (classroomData == null) return [];

    Map<String, bool> map = {};
    for (DocumentSnapshot x in classroomData!) {
      map[x.get("year")] = true;
    }
    return map.keys.toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      global.Database!.addCollection("classroom", "/classroom");

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("/classroom").get();
      classroomData = querySnapshot.docs;
      debugPrint("${classroomData.toString()} ");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return classroomData == null
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
                                                    in getDepartmentFromClassData())
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
                                                for (var x
                                                    in getYearFromClassData())
                                                  x + " - Year"
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
                                for (var entry in classroomData!)
                                  if ((entry["department"] ==
                                              _selectedDepartment ||
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
                                            setState(() {});
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
                                                      global.textWidgetWithHeavyFont(
                                                          "${entry["year"]} ${entry["class"]}-${entry["section"]}"),
                                                      SizedBox(width: 15),
                                                      Text(
                                                        "",
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
                for (Widget? x in cacheOfPages)
                  x ??
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
