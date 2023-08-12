import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/widgets.dart';
import 'package:Project_Prism/ui/viewLeave.dart';
import 'package:intl/intl.dart';

void leaveFormPrompt(BuildContext buildContext) {
  showModalBottomSheet(
      context: buildContext,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                blendMode: BlendMode.srcIn,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  //color: Theme.of(buildContext).focusColor,
                  decoration: BoxDecoration(
                      color: Theme.of(buildContext).focusColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5),
                      Container(
                        height: 5,
                        width: 125,
                        decoration: BoxDecoration(
                            color: Theme.of(buildContext)
                                .textSelectionTheme
                                .selectionHandleColor!
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      SizedBox(height: 20),
                      ListTile(
                        leading: Icon(
                          Icons.view_compact,
                          color: Theme.of(buildContext)
                              .textSelectionTheme
                              .selectionHandleColor,
                        ),
                        title: Text(
                          "View the leave applications",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(buildContext)
                                .textSelectionTheme
                                .cursorColor,
                          ),
                        ),
                        onTap: () {
                          promptViewLeaveForms();
                          Navigator.of(buildContext).pop();
                          debugPrint("Prompt view leave form pages");
                        },
                      ),
                      global.accountType == 2
                          ? ListTile(
                              leading: Icon(Icons.add_circle,
                                  color: Theme.of(buildContext)
                                      .textSelectionTheme
                                      .selectionHandleColor),
                              title: Text(
                                "Apply for new leave application",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(buildContext)
                                      .textSelectionTheme
                                      .cursorColor,
                                ),
                              ),
                              onTap: () {
                                global.switchToSecondaryUi(leaveFormApply());
                                Navigator.of(buildContext).pop();
                                debugPrint(
                                    "paging to APPLY a new Leave Applicaitons");
                              },
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ));
}

class leaveFormApply extends StatefulWidget {
  @override
  State<leaveFormApply> createState() => _leaveFormApplyState();
}

class _leaveFormApplyState extends State<leaveFormApply> {
  DateTime startDate = DateTime.now();

  DateTime endDate = DateTime.now().add(const Duration(days: 1));

  final myController = TextEditingController();

  Map facultyList = {};

  @override
  void initState() {
    super.initState();
    facultyList["No one"] = {"firstName": "No", "lastName": "one"};
    Future.delayed(Duration(), () async {
      var get = await global.collectionMap["acc"]!
          .where("isStudent", isEqualTo: false)
          .where("phoneNo", isNotEqualTo: null)
          .get();
      for (var x in get.docs) {
        if ((x.data() as Map)["phoneNo"] != null) {
          facultyList[x.reference.id] = x.data();
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  String leaveType = "sick";
  String classTutor = "No one";
  String classAdvisor = "No one";
  String hod = "No one";

  @override
  Widget build(BuildContext context) {
    debugPrint("Rebuilding students leave form");
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(1),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          global.switchToPrimaryUi();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2.0,
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.close_outlined,
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                      ),
                      Text(
                        "APPLY FOR NEW LEAVE",
                        style: TextStyle(
                            color: Theme.of(context)
                                .textSelectionTheme
                                .cursorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          if (myController.text == "" ||
                              classAdvisor == "No one" ||
                              classTutor == "No one" ||
                              hod == "No one") {
                            global.alert.quickAlert(
                                context,
                                global.textWidget(
                                    "Please fill the reason and faculty field properly"));
                          } else {
                            global.alert.quickAlert(
                                context,
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    global.textWidget(
                                        "Your application will be submitted under these information :"),
                                    SizedBox(height: 20),
                                    global.textWidgetWithHeavyFont(
                                        "${"${global.accObj!.firstName!} ${global.accObj!.lastName!}"} of ${global.accObj!.department!.toUpperCase()} department,"),
                                    global.textWidgetWithHeavyFont(
                                        "Register number : ${global.accObj!.registerNum}"),
                                    global.textWidgetWithHeavyFont(
                                        "Roll number : ${global.accObj!.rollNo!.toUpperCase()}"),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    global.textWidget(
                                        "If you find any of these information incorrect, please change it by editing your information on Settings->Change Student data"),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    global
                                        .textWidget("Are you sure to proceed?")
                                  ],
                                ),
                                action: [
                                  FloatingActionButton(
                                      mini: true,
                                      onPressed: () {
                                        Future.delayed(Duration(), () async {
                                          var create = await global.Database!
                                              .create(
                                                  global.Database!
                                                      .addCollection(
                                                          "leaveForms",
                                                          "/leaveForms"),
                                                  DateFormat(
                                                          "dd-MM-yyyy hh:mm:ss:ms")
                                                      .format(DateTime.now())
                                                      .toString(),
                                                  {
                                                "regNo": global
                                                    .accObj!.registerNum
                                                    .toString(),
                                                "rollNo": global.accObj!.rollNo
                                                    .toString(),
                                                "department": global
                                                    .accObj!.department
                                                    .toString(),
                                                "section": global
                                                    .accObj!.section
                                                    .toString(),
                                                "year": global.accObj!.year
                                                    .toString(),
                                                "name":
                                                    "${global.accObj!.firstName} ${global.accObj!.lastName}",
                                                "initPerson": global.loggedUID,
                                                "startDate": Timestamp.fromDate(
                                                    startDate),
                                                "endDate":
                                                    Timestamp.fromDate(endDate),
                                                "reason": myController.text,
                                                "type": leaveType,
                                                "tutor": classTutor,
                                                "classAdvisor": classAdvisor,
                                                "hod": hod,
                                                "tutorApproval": "Not yet",
                                                "classAdvisorApproval":
                                                    "Not yet",
                                                "hodApproval": "Not yet",
                                              });
                                          var result =
                                              "Successfully created a new leave form";
                                          if (create.status ==
                                              db_fetch_status.success) {
                                            debugPrint("oki");
                                          } else {
                                            result =
                                                "Failed to create, ${create.data.toString()}";
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(result)));
                                        });

                                        Navigator.of(context).pop();
                                        global.switchToPrimaryUi();
                                      },
                                      child: Text("Yes")),
                                  FloatingActionButton(
                                      child: Text("No"),
                                      mini: true,
                                      onPressed: () =>
                                          Navigator.of(context).pop())
                                ]);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(13))),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.done, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Card(
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                    elevation: 20,
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TYPE",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: false,
                                      underline: SizedBox(),
                                      icon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          CupertinoIcons.arrowtriangle_down,
                                          size: 17,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onChanged: (val) => setState(() {
                                        leaveType = val.toString();
                                      }),
                                      value: leaveType,
                                      dropdownColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.9),
                                      elevation: 0,
                                      items: [
                                        for (var x in {
                                          "sick": [Colors.blue, "Sick Leave"],
                                          "duty": [
                                            Colors.yellowAccent,
                                            "On Duty"
                                          ],
                                          "what": [Colors.amber, "Others"]
                                        }.entries)
                                          DropdownMenuItem(
                                            value: x.key,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18.0),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            x.value[0] as Color,
                                                      )),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Text(
                                                      x.value[1] as String,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .textSelectionTheme
                                                              .selectionColor,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                    elevation: 20,
                    child: SizedBox(
                      height: 235,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "START DATE",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: InkWell(
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: DateTimeField(
                                              initialEntryMode:
                                                  DatePickerEntryMode
                                                      .calendarOnly,
                                              mode:
                                                  DateTimeFieldPickerMode.date,
                                              dateTextStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                              ),
                                              selectedDate: startDate,
                                              onDateSelected: (DateTime value) {
                                                setState(() {
                                                  startDate = value;
                                                });
                                              }),
                                        ),
                                      ),
                                      Container(
                                        color: Theme.of(context).hintColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(
                                            Icons.date_range,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "END DATE",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Flexible(
                              child: InkWell(
                                child: Container(
                                  height: 35,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8))),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: DateTimeField(
                                              initialEntryMode:
                                                  DatePickerEntryMode
                                                      .calendarOnly,
                                              mode:
                                                  DateTimeFieldPickerMode.date,
                                              dateTextStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                              ),
                                              selectedDate: endDate,
                                              onDateSelected: (DateTime value) {
                                                setState(() {
                                                  endDate = value;
                                                });
                                              }),
                                        ),
                                      ),
                                      Container(
                                        color: Theme.of(context).hintColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(
                                            Icons.date_range,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                    elevation: 20,
                    child: SizedBox(
                      height: 370,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CLASS TUTOR",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: false,
                                      underline: SizedBox(),
                                      icon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          CupertinoIcons.arrowtriangle_down,
                                          size: 17,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onChanged: (val) => setState(() {
                                        classTutor = val.toString();
                                      }),
                                      value: classTutor,
                                      dropdownColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.9),
                                      elevation: 0,
                                      items: [
                                        for (var x in facultyList.entries)
                                          DropdownMenuItem(
                                            value: x.key,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Text(
                                                "${x.value["title"] ?? ""} ${x.value["firstName"]} ${x.value["lastName"]}",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textSelectionTheme
                                                        .selectionColor,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "CLASS ADVISOR",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: false,
                                      underline: SizedBox(),
                                      icon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          CupertinoIcons.arrowtriangle_down,
                                          size: 17,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onChanged: (val) => setState(() {
                                        classAdvisor = val.toString();
                                      }),
                                      value: classAdvisor,
                                      dropdownColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.9),
                                      elevation: 0,
                                      items: [
                                        for (var x in facultyList.entries)
                                          DropdownMenuItem(
                                            value: x.key,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Text(
                                                "${x.value["title"] ?? ""} ${x.value["firstName"]} ${x.value["lastName"]}",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textSelectionTheme
                                                        .selectionColor,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "HEAD OF DEPARTMENT",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      elevation: 0,
                                      isDense: false,
                                      underline: SizedBox(),
                                      icon: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          CupertinoIcons.arrowtriangle_down,
                                          size: 17,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onChanged: (val) => setState(() {
                                        hod = val.toString();
                                      }),
                                      value: hod,
                                      focusColor: Colors.transparent,
                                      dropdownColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.9),
                                      items: [
                                        for (var x in facultyList.entries)
                                          DropdownMenuItem(
                                            value: x.key,
                                            child: Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Text(
                                                "${x.value["title"] ?? ""} ${x.value["firstName"]} ${x.value["lastName"]}",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textSelectionTheme
                                                        .selectionColor,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                    elevation: 20,
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "REASON",
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            global.textField("", controller: myController)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
