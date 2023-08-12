import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void promptViewLeaveForms() {
  Widget which =
      global.accountType == 2 ? viewLeaveStudent() : viewLeaveFaculty();

  global.switchToSecondaryUi(which);
}

class viewLeaveStudent extends StatefulWidget {
  @override
  State<viewLeaveStudent> createState() => _viewLeaveStudentState();
}

class _viewLeaveStudentState extends State<viewLeaveStudent> {
  List pending = [];
  List completed = [];
  Map faculty = {};
  bool updated = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(), () async {
      var get = await global.collectionMap["acc"]!
          .where("isStudent", isEqualTo: false)
          .where("phoneNo", isNotEqualTo: null)
          .get();
      for (var x in get.docs) {
        if ((x.data() as Map)["phoneNo"] != null) {
          faculty[x.reference.id] = x.data();
        }
      }

      get = await global.Database!
          .addCollection("leaveForms", "/leaveForms")
          .where("initPerson", isEqualTo: global.loggedUID!)
          .get();
      for (var x in get.docs) {
        var getData = x.data() as Map;
        getData["classAdvisor"] = faculty[getData["classAdvisor"]];
        getData["tutor"] = faculty[getData["tutor"]];
        getData["hod"] = faculty[getData["hod"]];
        getData["isExpanded"] = false;
        if (getData["hodApproval"] == "Not yet") {
          pending.add(getData);
        } else {
          completed.add(getData);
        }
      }

      setState(() => updated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: global.textWidgetWithHeavyFont("Student Leave Applications"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              global.switchToPrimaryUi();
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
        backgroundColor: Colors.transparent,
        body: (updated == true)
            ? SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        SizedBox(height: 30),
                        Text(
                          "     PENDING",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionHandleColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2),
                        ),
                        SizedBox(height: 30),
                        if (pending.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Center(
                              child: Text(
                                "THERE IS NO PENDING APPLICATIONS.",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .textSelectionTheme
                                        .selectionHandleColor,
                                    //fontWeight: FontWeight.bold,
                                    letterSpacing: 2),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              children: [
                                for (Map x in pending)
                                  Card(
                                      color: Theme.of(context).focusColor,
                                      shadowColor: Colors.transparent,
                                      surfaceTintColor: Colors.transparent,
                                      elevation: 0,
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          x["isExpanded"] = !x["isExpanded"];
                                          setState(() {});
                                        },
                                        child: ExpansionPanelList(
                                          elevation: 0,
                                          expansionCallback:
                                              (panelIndex, isExpanded) {
                                            x["isExpanded"] = !x["isExpanded"];
                                            setState(() {});
                                          },
                                          dividerColor: Colors.transparent,
                                          children: [
                                            ExpansionPanel(
                                              backgroundColor:
                                                  Colors.transparent,
                                              headerBuilder:
                                                  (context, isExpanded) {
                                                return isExpanded == false
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            global.textWidgetWithHeavyFont(x[
                                                                        "type"] ==
                                                                    "sick"
                                                                ? "Sick Leave"
                                                                : (x["type"] ==
                                                                        "duty"
                                                                    ? "On Duty"
                                                                    : "Other type")),
                                                            global.textWidget(
                                                                "${DateFormat("dd/MM").format(x["startDate"].toDate())} - ${DateFormat("dd/MM").format(x["endDate"].toDate())}  ${DateFormat("yyyy").format(x["endDate"].toDate())} ")
                                                          ],
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15.0),
                                                        child: global
                                                            .textWidgetWithHeavyFont(x[
                                                                        "type"] ==
                                                                    "sick"
                                                                ? "Sick Leave"
                                                                : (x["type"] ==
                                                                        "duty"
                                                                    ? "On Duty"
                                                                    : "Other type")),
                                                      );
                                              },
                                              body: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15.0,
                                                    left: 15,
                                                    right: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0,
                                                              right: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          global.textDoubleSpanWiget(
                                                              "Start Date : ",
                                                              DateFormat(
                                                                      "dd-MM-yyyy")
                                                                  .format(x[
                                                                          "startDate"]
                                                                      .toDate())),
                                                          global.textDoubleSpanWiget(
                                                              "End Date : ",
                                                              DateFormat(
                                                                      "dd-MM-yyyy")
                                                                  .format(x[
                                                                          "endDate"]
                                                                      .toDate())),
                                                        ],
                                                      ),
                                                    ),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0,
                                                                right: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            global.textDoubleSpanWiget(
                                                                "Class Tutor : ",
                                                                "${x["tutor"]["firstName"]} ${x["tutor"]["lastName"]}"),
                                                            x["tutorApproval"] ==
                                                                    "Not yet"
                                                                ? Icon(Icons
                                                                    .pending)
                                                                : Icon(
                                                                    Icons
                                                                        .done_rounded,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                            x["tutorApproval"] ==
                                                                    "Not yet"
                                                                ? global.textWidget(
                                                                    "Not approved yet")
                                                                : global.textWidget(DateFormat(
                                                                        "dd-MM-yyyy hh:mm")
                                                                    .format(x[
                                                                            "tutorApproval"]
                                                                        .toDate()))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0,
                                                                right: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            global.textDoubleSpanWiget(
                                                                "Class Advisor : ",
                                                                "${x["classAdvisor"]["firstName"]} ${x["classAdvisor"]["lastName"]}"),
                                                            x["classAdvisorApproval"] ==
                                                                    "Not yet"
                                                                ? Icon(Icons
                                                                    .pending)
                                                                : Icon(
                                                                    Icons
                                                                        .done_rounded,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                            x["classAdvisorApproval"] ==
                                                                    "Not yet"
                                                                ? global.textWidget(
                                                                    "Not approved yet")
                                                                : global.textWidget(DateFormat(
                                                                        "dd-MM-yyyy hh:mm")
                                                                    .format(x[
                                                                            "classAdvisorApproval"]
                                                                        .toDate()))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0,
                                                              right: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          global.textDoubleSpanWiget(
                                                              "Head of Department : ",
                                                              "${x["hod"]["firstName"]} ${x["hod"]["lastName"]}"),
                                                          x["hodApproval"] ==
                                                                  "Not yet"
                                                              ? Icon(
                                                                  Icons.pending)
                                                              : Icon(
                                                                  Icons
                                                                      .done_rounded,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                          x["hodApproval"] ==
                                                                  "Not yet"
                                                              ? global.textWidget(
                                                                  "Not approved yet")
                                                              : global.textWidget(DateFormat(
                                                                      "dd-MM-yyyy hh:mm")
                                                                  .format(x[
                                                                          "hodApproval"]
                                                                      .toDate()))
                                                        ],
                                                      ),
                                                    ),
                                                    global.textDoubleSpanWiget(
                                                        "Reason : ",
                                                        x["reason"]),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0,
                                                                right: 15),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  global.alert.quickAlert(
                                                                      context,
                                                                      global.textWidget(
                                                                          "Not implemented yet"));
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      Text(
                                                                        "DELETE",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color: Colors
                                                                                .red,
                                                                            letterSpacing:
                                                                                2,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ]))
                                                  ],
                                                ),
                                              ),
                                              isExpanded: x["isExpanded"],
                                            )
                                          ],
                                        ),
                                      ))
                              ],
                            ),
                          ),
                        SizedBox(height: 30),
                        Text(
                          "     COMPLETED",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionHandleColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2),
                        ),
                        SizedBox(height: 30),
                        (completed.isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Center(
                                  child: Text(
                                    "THERE IS NO COMPLETED APPLICATIONS.",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .selectionHandleColor,
                                        //fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(15),
                                child: Wrap(
                                  children: [
                                    for (Map x in completed)
                                      Card(
                                          color: Theme.of(context).focusColor,
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          elevation: 0,
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: () {
                                              x["isExpanded"] =
                                                  !x["isExpanded"];
                                              setState(() {});
                                            },
                                            child: ExpansionPanelList(
                                              elevation: 0,
                                              expansionCallback:
                                                  (panelIndex, isExpanded) {
                                                x["isExpanded"] =
                                                    !x["isExpanded"];
                                                setState(() {});
                                              },
                                              dividerColor: Colors.transparent,
                                              children: [
                                                ExpansionPanel(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  headerBuilder:
                                                      (context, isExpanded) {
                                                    return isExpanded == false
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                global.textWidgetWithHeavyFont(x[
                                                                            "type"] ==
                                                                        "sick"
                                                                    ? "Sick Leave"
                                                                    : (x["type"] ==
                                                                            "duty"
                                                                        ? "On Duty"
                                                                        : "Other type")),
                                                                global.textWidget(
                                                                    "${DateFormat("dd/MM").format(x["startDate"].toDate())} - ${DateFormat("dd/MM").format(x["endDate"].toDate())}  ${DateFormat("yyyy").format(x["endDate"].toDate())} ")
                                                              ],
                                                            ),
                                                          )
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 15.0),
                                                            child: global.textWidgetWithHeavyFont(x[
                                                                        "type"] ==
                                                                    "sick"
                                                                ? "Sick Leave"
                                                                : (x["type"] ==
                                                                        "duty"
                                                                    ? "On Duty"
                                                                    : "Other type")),
                                                          );
                                                  },
                                                  body: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15.0,
                                                            left: 15,
                                                            right: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0,
                                                                  right: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              global.textDoubleSpanWiget(
                                                                  "Start Date : ",
                                                                  DateFormat(
                                                                          "dd-MM-yyyy")
                                                                      .format(x[
                                                                              "startDate"]
                                                                          .toDate())),
                                                              global.textDoubleSpanWiget(
                                                                  "End Date : ",
                                                                  DateFormat(
                                                                          "dd-MM-yyyy")
                                                                      .format(x[
                                                                              "endDate"]
                                                                          .toDate())),
                                                            ],
                                                          ),
                                                        ),
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                        15.0,
                                                                    right: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                global.textDoubleSpanWiget(
                                                                    "Class Tutor : ",
                                                                    "${x["tutor"]["firstName"]} ${x["tutor"]["lastName"]}"),
                                                                x["tutorApproval"] ==
                                                                        "Not yet"
                                                                    ? Icon(Icons
                                                                        .pending)
                                                                    : Icon(
                                                                        Icons
                                                                            .done_rounded,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                x["tutorApproval"] ==
                                                                        "Not yet"
                                                                    ? global.textWidget(
                                                                        "Not approved yet")
                                                                    : global.textWidget(DateFormat(
                                                                            "dd-MM-yyyy hh:mm")
                                                                        .format(
                                                                            x["tutorApproval"].toDate()))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                        15.0,
                                                                    right: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                global.textDoubleSpanWiget(
                                                                    "Class Advisor : ",
                                                                    "${x["classAdvisor"]["firstName"]} ${x["classAdvisor"]["lastName"]}"),
                                                                x["classAdvisorApproval"] ==
                                                                        "Not yet"
                                                                    ? Icon(Icons
                                                                        .pending)
                                                                    : Icon(
                                                                        Icons
                                                                            .done_rounded,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                x["classAdvisorApproval"] ==
                                                                        "Not yet"
                                                                    ? global.textWidget(
                                                                        "Not approved yet")
                                                                    : global.textWidget(DateFormat(
                                                                            "dd-MM-yyyy hh:mm")
                                                                        .format(
                                                                            x["classAdvisorApproval"].toDate()))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                        15.0,
                                                                    right: 15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                global.textDoubleSpanWiget(
                                                                    "Head of Department : ",
                                                                    "${x["hod"]["firstName"]} ${x["hod"]["lastName"]}"),
                                                                x["hodApproval"] ==
                                                                        "Not yet"
                                                                    ? Icon(Icons
                                                                        .pending)
                                                                    : Icon(
                                                                        Icons
                                                                            .done_rounded,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                x["hodApproval"] ==
                                                                        "Not yet"
                                                                    ? global.textWidget(
                                                                        "Not approved yet")
                                                                    : global.textWidget(
                                                                        "${DateFormat("dd-MM-yyyy hh:mm").format(x["hodApproval"].toDate())}")
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        global
                                                            .textDoubleSpanWiget(
                                                                "Reason : ",
                                                                x["reason"]),
                                                      ],
                                                    ),
                                                  ),
                                                  isExpanded: x["isExpanded"],
                                                )
                                              ],
                                            ),
                                          )
                                          // child: Padding(
                                          //   padding: const EdgeInsets.all(15.0),
                                          //   child: Column(
                                          //     children: [
                                          //       global.textWidgetWithHeavyFont(x["type"] == "sick" ? "Sick Leave" : (x["type"] == "duty" ? "On Duty Request" : "Other type"))
                                          //     ],
                                          //   ),
                                          // ),
                                          )
                                  ],
                                ),
                              )
                      ],
                    )),
              )
            : Center(
                child: SpinKitWave(
                color: Theme.of(context).textSelectionTheme.selectionColor,
              )));
  }
}

class viewLeaveFaculty extends StatefulWidget {
  @override
  State<viewLeaveFaculty> createState() => _viewLeaveFacultyState();
}

class _viewLeaveFacultyState extends State<viewLeaveFaculty> {
  List pending = [];
  List dupPending = [];
  Map accounts = {};
  bool updated = false;

  void update([Function? fn]) {
    setState(() {
      updated = false;
    });

    int i = 0;

    Future.delayed(Duration(), () async {
      if (fn != null) {
        await fn();
      }

      pending = [];
      accounts = {};
      dupPending = [];

      var get = await global.collectionMap["acc"]!.get();
      for (var x in get.docs) {
        if ((x.data() as Map)["phoneNo"] != null) {
          accounts[x.reference.id] = x.data();
        }
      }

      get = await global.Database!
          .addCollection("leaveForms", "/leaveForms")
          .get();
      for (var x in get.docs) {
        debugPrint(x.data().toString());
        var getData = x.data() as Map;
        bool canAdd = false;
        var selfId = global.loggedUID;
        if (getData["tutor"] == selfId &&
            getData["tutorApproval"] == "Not yet") {
          canAdd = true;
          getData["requestingAs"] = "tutor";
        } else if (getData["tutorApproval"] != "Not yet" &&
            getData["classAdvisor"] == selfId &&
            getData["classAdvisorApproval"] == "Not yet") {
          canAdd = true;
          getData["requestingAs"] = "classAdvisor";
        } else if (getData["tutorApproval"] != "Not yet" &&
            getData["classAdvisorApproval"] != "Not yet" &&
            getData["hod"] == selfId &&
            getData["hodApproval"] == "Not yet") {
          canAdd = true;
          getData["requestingAs"] = "hod";
        }

        getData["id"] = x.id;
        getData["initPerson"] = accounts[getData["initPerson"]];
        getData["classAdvisor"] = accounts[getData["classAdvisor"]];
        getData["tutor"] = accounts[getData["tutor"]];
        getData["hod"] = accounts[getData["hod"]];
        getData["isExpanded"] = false;

        if (canAdd) {
          getData["index"] = i++;
          pending.add(getData);
          dupPending.add(x.data());
        }
      }

      setState(() => updated = true);
    });
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          title: global.textWidgetWithHeavyFont("Student Leave Applications"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              global.switchToPrimaryUi();
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
        backgroundColor: Colors.transparent,
        body: (updated == true)
            ? SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                        children: [
                          SizedBox(height: 30),
                          Text(
                            "     PENDING",
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textSelectionTheme
                                    .selectionHandleColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2),
                          ),
                          SizedBox(height: 30),
                          if (pending.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Center(
                                child: Text(
                                  "THERE IS NO PENDING APPLICATIONS.",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .textSelectionTheme
                                          .selectionHandleColor,
                                      //fontWeight: FontWeight.bold,
                                      letterSpacing: 2),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                children: [
                                  for (Map x in pending)
                                    Card(
                                        color: Theme.of(context).focusColor,
                                        shadowColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        elevation: 0,
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          onTap: () {
                                            x["isExpanded"] = !x["isExpanded"];
                                            setState(() {});
                                          },
                                          child: ExpansionPanelList(
                                            elevation: 0,
                                            expansionCallback:
                                                (panelIndex, isExpanded) {
                                              x["isExpanded"] =
                                                  !x["isExpanded"];
                                              setState(() {});
                                            },
                                            dividerColor: Colors.transparent,
                                            children: [
                                              ExpansionPanel(
                                                backgroundColor:
                                                    Colors.transparent,
                                                headerBuilder:
                                                    (context, isExpanded) {
                                                  return isExpanded == false
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              global.textWidgetWithHeavyFont(x[
                                                                          "type"] ==
                                                                      "sick"
                                                                  ? "Sick Leave"
                                                                  : (x["type"] ==
                                                                          "duty"
                                                                      ? "On Duty"
                                                                      : "Other type")),
                                                              global.textWidget(
                                                                  "${DateFormat("dd/MM").format(x["startDate"].toDate())} - ${DateFormat("dd/MM").format(x["endDate"].toDate())}  ${DateFormat("yyyy").format(x["endDate"].toDate())} "),
                                                              global.textWidget(
                                                                  "${x["year"].toString().toUpperCase()} ${x["department"].toString().toUpperCase()} ${x["section"].toString().toUpperCase()}")
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15.0),
                                                          child: global.textWidgetWithHeavyFont(x[
                                                                      "type"] ==
                                                                  "sick"
                                                              ? "Sick Leave"
                                                              : (x["type"] ==
                                                                      "duty"
                                                                  ? "On Duty"
                                                                  : "Other type")),
                                                        );
                                                },
                                                body: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 15.0,
                                                          left: 15,
                                                          right: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      global.textDoubleSpanWiget(
                                                          "Name of student : ",
                                                          x["name"]),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0,
                                                                right: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            global.textDoubleSpanWiget(
                                                                "Department & Year : ",
                                                                "${x["department"].toString().toUpperCase()} - ${x["year"].toString().toUpperCase()}"),
                                                            global.textDoubleSpanWiget(
                                                                "Section : ",
                                                                x["section"]
                                                                    .toString()
                                                                    .toUpperCase()),
                                                          ],
                                                        ),
                                                      ),
                                                      global.textDoubleSpanWiget(
                                                          "Register Number : ",
                                                          x["regNo"]
                                                              .toString()),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      global.textDoubleSpanWiget(
                                                          "Roll Number : ",
                                                          x["rollNo"]
                                                              .toString()
                                                              .toUpperCase()),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 15.0,
                                                                right: 15),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            global.textDoubleSpanWiget(
                                                                "Start Date : ",
                                                                DateFormat(
                                                                        "dd-MM-yyyy")
                                                                    .format(x[
                                                                            "startDate"]
                                                                        .toDate())),
                                                            global.textDoubleSpanWiget(
                                                                "End Date : ",
                                                                DateFormat(
                                                                        "dd-MM-yyyy")
                                                                    .format(x[
                                                                            "endDate"]
                                                                        .toDate())),
                                                          ],
                                                        ),
                                                      ),
                                                      global
                                                          .textDoubleSpanWiget(
                                                              "Reason : ",
                                                              x["reason"]),
                                                      SizedBox(height: 25),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0,
                                                                  right: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              global.textDoubleSpanWiget(
                                                                  "Class Tutor : ",
                                                                  "${x["tutor"]["firstName"]} ${x["tutor"]["lastName"]}"),
                                                              x["tutorApproval"] ==
                                                                      "Not yet"
                                                                  ? Icon(Icons
                                                                      .pending)
                                                                  : Icon(
                                                                      Icons
                                                                          .done_rounded,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                              x["tutorApproval"] ==
                                                                      "Not yet"
                                                                  ? global.textWidget(
                                                                      "Not approved yet")
                                                                  : global.textWidget(DateFormat(
                                                                          "dd-MM-yyyy hh:mm")
                                                                      .format(x[
                                                                              "tutorApproval"]
                                                                          .toDate()))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0,
                                                                  right: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              global.textDoubleSpanWiget(
                                                                  "Class Advisor : ",
                                                                  "${x["classAdvisor"]["firstName"]} ${x["classAdvisor"]["lastName"]}"),
                                                              x["classAdvisorApproval"] ==
                                                                      "Not yet"
                                                                  ? Icon(Icons
                                                                      .pending)
                                                                  : Icon(
                                                                      Icons
                                                                          .done_rounded,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                              x["classAdvisorApproval"] ==
                                                                      "Not yet"
                                                                  ? global.textWidget(
                                                                      "Not approved yet")
                                                                  : global.textWidget(DateFormat(
                                                                          "dd-MM-yyyy hh:mm")
                                                                      .format(x[
                                                                              "classAdvisorApproval"]
                                                                          .toDate()))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0,
                                                                  right: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              global.textDoubleSpanWiget(
                                                                  "Head of Department : ",
                                                                  "${x["hod"]["firstName"]} ${x["hod"]["lastName"]}"),
                                                              x["hodApproval"] ==
                                                                      "Not yet"
                                                                  ? Icon(Icons
                                                                      .pending)
                                                                  : Icon(
                                                                      Icons
                                                                          .done_rounded,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                              x["hodApproval"] ==
                                                                      "Not yet"
                                                                  ? global.textWidget(
                                                                      "Not approved yet")
                                                                  : global.textWidget(DateFormat(
                                                                          "dd-MM-yyyy hh:mm")
                                                                      .format(x[
                                                                              "hodApproval"]
                                                                          .toDate()))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      global.textWidgetWithHeavyFont(
                                                          "Approval will be signed as ${x["requestingAs"].toString().toUpperCase()}"),
                                                      SizedBox(height: 20),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 15.0,
                                                                  right: 15),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    update(
                                                                        () async {
                                                                      dupPending[x["index"]]
                                                                              [
                                                                              "${x['requestingAs'].toString()}Approval"] =
                                                                          Timestamp
                                                                              .now();
                                                                      Map<String,
                                                                              Object>
                                                                          newMap =
                                                                          {};
                                                                      for (var a
                                                                          in (dupPending[x["index"]])
                                                                              .entries) {
                                                                        newMap[a
                                                                            .key
                                                                            .toString()] = a.value;
                                                                      }
                                                                      var update = await global.Database!.update(
                                                                          global
                                                                              .collectionMap["leaveForms"]!,
                                                                          x["id"],
                                                                          newMap);

                                                                      var result =
                                                                          "Successfully updated [approved] the form";
                                                                      if (update
                                                                              .status ==
                                                                          db_fetch_status
                                                                              .success) {
                                                                        debugPrint(
                                                                            "Updated ${x["id"]}");
                                                                      } else {
                                                                        result =
                                                                            "Error occurred, ${update.data.toString()}";
                                                                      }

                                                                      ScaffoldMessenger.of(
                                                                              buildContext)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text(result),
                                                                      ));
                                                                    });
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .done,
                                                                          color:
                                                                              Colors.green,
                                                                        ),
                                                                        Text(
                                                                          "APPROVE",
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.green,
                                                                              letterSpacing: 2,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    update(
                                                                        () async {
                                                                      var delete = await global
                                                                          .Database!
                                                                          .remove(
                                                                              global.collectionMap["leaveForms"]!,
                                                                              x["id"]);

                                                                      var result =
                                                                          "Successfully deleted the form";
                                                                      if (delete
                                                                              .status ==
                                                                          db_fetch_status
                                                                              .success) {
                                                                        debugPrint(
                                                                            "Removed ${x["id"]}");
                                                                      } else {
                                                                        result =
                                                                            "Error occurred, ${delete.data.toString()}";
                                                                      }

                                                                      ScaffoldMessenger.of(
                                                                              buildContext)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text(result),
                                                                      ));
                                                                    });
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                        Text(
                                                                          "DELETE",
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.red,
                                                                              letterSpacing: 2,
                                                                              fontWeight: FontWeight.bold),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ]))
                                                    ],
                                                  ),
                                                ),
                                                isExpanded: x["isExpanded"],
                                              )
                                            ],
                                          ),
                                        ))
                                ],
                              ),
                            )
                        ])))
            : Center(
                child: SpinKitWave(
                color: Theme.of(context).textSelectionTheme.selectionColor,
              )));
  }
}
