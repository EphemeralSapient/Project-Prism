import 'package:Project_Prism/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class createClassroomUi extends StatefulWidget {
  @override
  State<createClassroomUi> createState() => _createClassroomUiState();
}

class _createClassroomUiState extends State<createClassroomUi> {
  final TextEditingController _classController = TextEditingController();

  final TextEditingController _yearController = TextEditingController();

  final TextEditingController _classCountController = TextEditingController();

  // final TextEditingController _departmentController = TextEditingController();

  final TextEditingController _sectionController = TextEditingController();

  String departmentStaff = global.accObj!.departmentStaff ?? "Department";

  dynamic infoData;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      global.Database!.addCollection("permissionLevel", "/permissionLevel");

      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.doc('/permissionLevel/info').get();
      infoData = docSnapshot.data();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return infoData == null
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
            appBar: AppBar(
              title: global.textWidgetWithHeavyFont('Classroom Creation Form'),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                onPressed: () {
                  global.switchToPrimaryUi();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0, left: 16, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        global.textField(
                          'Class',
                          controller: _classController,
                          maxLength: 10,
                          keyboardType: TextInputType.text,
                          fit: FlexFit.tight,
                        ),
                        SizedBox(width: 15),
                        global.textField(
                          'Year',
                          controller: _yearController,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          fit: FlexFit.tight,
                        ),
                        SizedBox(width: 15),
                        global.textField(
                          'Section',
                          controller: _sectionController,
                          maxLength: 1,
                          keyboardType: TextInputType.text,
                          fit: FlexFit.tight,
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    global.textField(
                      'Class Count',
                      controller: _classCountController,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    DropdownButton(
                      hint: global.textWidget("Department"),
                      isExpanded: true,
                      dropdownColor:
                          Theme.of(context).focusColor.withOpacity(.85),
                      elevation: 0,
                      value: departmentStaff,
                      items: [
                        for (String val
                            in infoData["departments"] + ["Department"])
                          DropdownMenuItem(
                              child: global.textWidget(val), value: val)
                      ],
                      onChanged: (String? e) {
                        departmentStaff = e ?? "Department";
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
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
                        if (_classController.text == "" ||
                            _yearController.text == "" ||
                            _sectionController.text == "" ||
                            _classCountController.text == "" ||
                            departmentStaff == "Department") {
                          global.alert.quickAlert(
                              context,
                              global.textWidget(
                                  "Please fill the form properly."));
                        } else {
                          CollectionReference<Object?> collection = global
                              .Database!
                              .addCollection("classroom", "/classroom");

                          Future.delayed(Duration.zero, () async {
                            var data = {
                              'class': _classController.text
                                  .toUpperCase(), // Name of the class/program
                              'year': global.convertToRoman(
                                  _yearController.text), // Year of study
                              'students': [
                                'uid1',
                              ], // List of student IDs in the class
                              'section': _sectionController.text
                                  .toUpperCase(), // Section of the class
                              'courses': [
                                'CS1234'
                              ], // List of course codes associated with the class
                              'class_count': int.tryParse(_classCountController
                                  .text), // Total number of students in the class
                              'blacklist': [
                                'uid1'
                              ], // List of student IDs blacklisted from the class
                              'timetable': {
                                'Monday': ['CS1234'],
                                'Tuesday': [],
                                'Wednesday': [],
                                'Thursday': [],
                                'Friday': [],
                                'Saturday': [],
                              }, // Timetable with class schedule for each day
                              'department':
                                  departmentStaff, // Department or discipline of the class
                              'delegate': {
                                'uid1': 'Class representative'
                              }, // Dictionary mapping student ID to class representative role
                              'timetable_timing':
                                  'timing_id', // ID or code for the class timetable timing
                              'tutors': [
                                'uid1'
                              ], // List of tutor IDs associated with the class
                              'tutors_pfp':
                                  [], // List of tutor profile picture URL
                              'advisor':
                                  'uid1', // ID of the advisor for the class
                              'attendance': {
                                'check': Timestamp
                                    .now(), // Timestamp object representing the timestamp of attendance check
                                'absent': [
                                  'uid1'
                                ], // List of student IDs marked as absent
                                'on_duty': [
                                  'uid1'
                                ], // List of student IDs marked as on-duty or excused from attendance
                              }
                            };

                            var check = await global.Database!.get(collection,
                                "${_yearController.text} ${_classController.text}-${_sectionController.text}");

                            if (check.status == db_fetch_status.exists) {
                              global.alert.quickAlert(
                                  global.rootCTX!,
                                  global.textWidget(
                                      "Failed to create classroom, Already class room exists under this name, year and section."));
                              return;
                            }

                            var get = await global.Database!.create(
                                collection,
                                "${_yearController.text} ${_classController.text}-${_sectionController.text}",
                                data);

                            if (get.status == db_fetch_status.success) {
                              global.snackbarText(
                                  "Successfully created the classroom.");
                            } else {
                              global.alert.quickAlert(
                                  global.rootCTX!,
                                  global.textWidget(
                                      "Failed to create classroom | ${get.status} | ${get.data}"));
                            }
                          });
                        }
                      },
                      icon: Icon(Icons.done),
                      label: global.textWidgetWithHeavyFont("Create"),
                    ),
                    SizedBox(height: 30)
                  ],
                ),
              ),
            ),
          );
  }
}
//class, year, classcount, department, section
