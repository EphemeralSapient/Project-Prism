import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/modules/errors.dart';
import 'package:Project_Prism/ui/toggleButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

void promptStaffInfoEdit() {
  global.switchToSecondaryUi(const staffs_info());
  global.temp = () {
    global.switchToPrimaryUi();
  };
}

class staffs_info extends StatefulWidget {
  const staffs_info({super.key});

  @override
  State<staffs_info> createState() => _staffs_infoState();
}

class _staffs_infoState extends State<staffs_info> {
  TextEditingController firstName =
      TextEditingController(text: global.accObj?.firstName);

  TextEditingController lastName =
      TextEditingController(text: global.accObj?.lastName);
  TextEditingController phoneNo = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.phoneNo));
  TextEditingController facultyCode = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.facultyCode));
  TextEditingController passwordController =
      TextEditingController(text: global.passcode);

  Map<String, dynamic> choices = {};

  String title = global.accObj!.title ?? "Mr.";
  String departmentStaff = global.accObj!.departmentStaff ?? "Department";
  String designation = global.accObj!.designation ?? "Designation";
  String position = global.accObj!.position ?? "Job Position";

  dynamic infoData;

  bool ob = true;

  @override
  void initState() {
    for (var x in global.departmentWithClasses.entries) {
      choices[x.key] = [false, x.value["full"]];
    }
    super.initState();
    Future.delayed(Duration.zero, () async {
      global.Database!.addCollection("permissionLevel", "/permissionLevel");

      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.doc('/permissionLevel/info').get();
      infoData = docSnapshot.data();
      setState(() {});
    });
  }

  InputDecoration dec(IconData? icon, String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
      prefixIconColor: Colors.red,
      prefixStyle: const TextStyle(color: Colors.deepPurpleAccent),
      suffix: SizedBox(
          height: 20,
          width: 20,
          child: InkWell(
            onTap: () {
              setState(() => ob = !ob);
            },
            child: Icon(
              ob == true ? Icons.visibility_off : Icons.visibility_rounded,
              color: Colors.grey,
            ),
          )),
      hintText: hint,
      isDense: true,
      border: OutlineInputBorder(
        borderSide:
            const BorderSide(color: Colors.deepPurpleAccent, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(
          width: 0.0,
          color: Colors.blueAccent,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: Colors.deepPurpleAccent,
          width: 0.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(color: Colors.redAccent, width: 5)),
      hintStyle: const TextStyle(color: Colors.deepPurpleAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return infoData == null
        ? const Scaffold(
            body: Center(
            child: SpinKitThreeBounce(
              color: Colors.blue, // set the color of the spinner
              size: 50.0, // set the size of the spinner
            ),
          ))
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Future.delayed(const Duration(), () async {
                  if (firstName.text == "" ||
                      position == "Job Title" ||
                      designation == "Designation" ||
                      lastName.text == "" ||
                      phoneNo.text == "" ||
                      passwordController.text == "") {
                    global.alert.quickAlert(context,
                        global.textWidget_ns("Please fill the following form"));
                  } else {
                    bool success = true;

                    try {
                      var newAcc = global.accObj!;
                      newAcc.firstName = firstName.text;
                      newAcc.lastName = lastName.text;
                      newAcc.lastSeen = Timestamp.now();
                      newAcc.updatedAt = Timestamp.now();
                      newAcc.avatarUrl = global.account?.photoURL;
                      newAcc.phoneNo = int.parse(phoneNo.text);
                      newAcc.isStudent = false;
                      newAcc.title = title;
                      newAcc.handlingDepartment = [];
                      newAcc.position = position;
                      newAcc.permissionLevel = (infoData["orderByNum"] as List)
                              .indexOf(infoData["map"][position]) +
                          1;
                      newAcc.designation = designation;
                      newAcc.positionEncoded = infoData["map"][position];
                      newAcc.departmentStaff = departmentStaff;
                      newAcc.parentDepartment = departmentStaff;
                      newAcc.facultyCode = int.parse(facultyCode.text);
                      newAcc.email = global.account?.email;

                      for (var x in choices.entries) {
                        if (x.value == true) {
                          newAcc.handlingDepartment!.add(x.key);
                        }
                      }
                      global.accObj = newAcc;

                      db_fetch_return updateInfo = await global.Database!
                          .update(global.Database!.addCollection("acc", "/acc"),
                              global.account!.email!, newAcc.toJson());

                      if (updateInfo.status != db_fetch_status.success) {
                        throw AccountUpdateFailedError(updateInfo.toString());
                      }

                      // Adding the user to authority level or permission level.
                      await FirebaseFirestore.instance
                          .collection(
                              "/permissionLevel/${infoData["map"][position]}/permitted_emails")
                          .doc(newAcc.email)
                          .set({
                        "updated": Timestamp.now(),
                        "uid": global.loggedUID,
                        "passcode": passwordController.text,
                      });

                      global.passcode = passwordController.text;
                      global.prefs!
                          .setString("passcode", passwordController.text);
                    } catch (e) {
                      debugPrint(e.toString());
                      success = false;
                      global.alert.quickAlert(
                          context,
                          global.textWidget_ns(
                              "Invalid password, try again | ${e.toString()}"));
                    }

                    if (success) {
                      await global.prefs!.setInt("accountType", 1);
                      global.accountType = 1;
                      global.restartApp();
                    } else {
                      global.temp();
                    }
                  }
                });
              },
              backgroundColor:
                  Theme.of(context).textSelectionTheme.selectionHandleColor,
              child: Icon(Icons.done,
                  color: Theme.of(context).colorScheme.background),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            backgroundColor: Theme.of(context).focusColor,
            appBar: AppBar(
              title: global.textWidgetWithHeavyFont("Staff Information Form"),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  global.switchToPrimaryUi();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      Theme.of(context).textSelectionTheme.selectionHandleColor,
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              //reverse: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 300),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    //horizontalOffset: -50.0,
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    // Name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton(
                          elevation: 0,
                          items: [
                            for (var x in [
                              ["dr", "Dr."],
                              ["mr", "Mr."],
                              ["mrs", "Mrs."],
                              ["miss", "Miss."]
                            ])
                              DropdownMenuItem(
                                value: x[1],
                                child: global.textWidget_ns(x[1]),
                              ),
                          ],
                          value: title,
                          dropdownColor:
                              Theme.of(context).focusColor.withOpacity(0.75),
                          onChanged: (value) {
                            setState(() {
                              title = value.toString();
                            });
                          },
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        global.textField("First Name",
                            controller: firstName, initialText: firstName.text),
                        const SizedBox(
                          width: 15,
                        ),
                        global.textField("Last Name",
                            controller: lastName, initialText: lastName.text),
                      ],
                    ),
                    const SizedBox(height: 25),

                    Row(children: [
                      global.textField("Phone Number",
                          preText: "+91 ",
                          controller: phoneNo,
                          initialText: phoneNo.text,
                          keyboardType: TextInputType.number,
                          inputFormats: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 10),
                      const SizedBox(width: 10),
                      global.textField("Faculty Code Number",
                          controller: facultyCode,
                          initialText: facultyCode.text,
                          keyboardType: TextInputType.number,
                          inputFormats: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 5),
                    ]),
                    const SizedBox(height: 25),

                    DropdownButton(
                        hint: global.textWidget_ns("Job Title"),
                        isExpanded: true,
                        dropdownColor:
                            Theme.of(context).focusColor.withOpacity(.85),
                        elevation: 0,
                        value: position,
                        items: [
                          for (String val
                              in infoData["titles"].toSet().toList() +
                                  ["Job Position"])
                            DropdownMenuItem(
                                value: val, child: global.textWidget_ns(val))
                        ],
                        onChanged: (String? e) {
                          position = e ?? "Job Position";
                          designation = "Designation";
                          setState(() {});
                        }),

                    if (position != "Job Position" &&
                        infoData["designation"].containsKey(position))
                      DropdownButton(
                          hint: global.textWidget_ns("Designation"),
                          isExpanded: true,
                          dropdownColor:
                              Theme.of(context).focusColor.withOpacity(.85),
                          elevation: 0,
                          value: designation,
                          items: [
                            for (String val in infoData["designation"][position]
                                    .toSet()
                                    .toList() +
                                ["Designation"])
                              DropdownMenuItem(
                                  value: val, child: global.textWidget_ns(val))
                          ],
                          onChanged: (String? e) {
                            designation = e ?? "Designation";
                            setState(() {});
                          }),

                    if (position != "Job Position")
                      DropdownButton(
                        hint: global.textWidget_ns("Department"),
                        isExpanded: true,
                        dropdownColor:
                            Theme.of(context).focusColor.withOpacity(.85),
                        elevation: 0,
                        value: departmentStaff,
                        items: [
                          for (String val
                              in infoData["departments"] + ["Department"])
                            DropdownMenuItem(
                                value: val, child: global.textWidget_ns(val))
                        ],
                        onChanged: (String? e) {
                          departmentStaff = e ?? "Department";
                          setState(() {});
                        },
                      ),
                    //if (designation != "Designation" && )
                    // DropdownButton(
                    //     hint: global.textWidget_ns("Designation"),
                    //     dropdownColor:
                    //         Theme.of(context).focusColor.withOpacity(0.8),
                    //     isExpanded: true,
                    //     value: position.text,
                    //     items: [
                    //       for (String val in [
                    //         "Designation",
                    //         "Head of the Department",
                    //         "Professor",
                    //         "Associate Professor",
                    //         "Assistant Professor (SG)",
                    //         "Assistant Professor"
                    //       ])
                    //         DropdownMenuItem(
                    //             value: val, child: global.textWidget_ns(val))
                    //     ],
                    //     onChanged: (val) {
                    //       setState(() {});
                    //     }),

                    const SizedBox(height: 25),

                    TextFormField(
                      obscureText: ob,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.deepPurpleAccent,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Passcode is required.");
                        }
                        return null;
                      },
                      decoration: dec(Icons.password_rounded, "Passcode"),
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 45),

                    if (position != "Job Position" &&
                        departmentStaff != "General" &&
                        departmentStaff != "Department" &&
                        infoData["departmentAppliedTitles"].contains(position))
                      global.textWidget_ns("Choose the department[s]"),
                    if (position != "Job Position" &&
                        departmentStaff != "General" &&
                        departmentStaff != "Department" &&
                        infoData["departmentAppliedTitles"].contains(position))
                      const SizedBox(height: 10),
                    if (position != "Job Position" &&
                        departmentStaff != "General" &&
                        departmentStaff != "Department" &&
                        infoData["departmentAppliedTitles"].contains(position))
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 3.0,
                        children: [
                          for (MapEntry x
                              in infoData["departmentChoices"].entries)
                            if (x.value[1] == departmentStaff)
                              FilterChip(
                                label: Text(
                                    (choices[x.value[0]] == false ||
                                            choices[x.value[0]] == null)
                                        ? x.key.toUpperCase()
                                        : "${x.key.toUpperCase()} - ${x.value[0]}",
                                    style: TextStyle(
                                        backgroundColor: Colors.transparent,
                                        color: Theme.of(context)
                                            .textSelectionTheme
                                            .cursorColor)),
                                selected: choices[x.value[0]] ?? false,
                                onSelected: (value) =>
                                    setState(() => choices[x.value[0]] = value),
                                shadowColor:
                                    Theme.of(context).colorScheme.background,
                                //disabledColor: Colors.blue,
                                selectedColor: Colors.blue,
                                backgroundColor: Theme.of(context).focusColor,
                                checkmarkColor: Theme.of(context).focusColor,
                                surfaceTintColor: Colors.transparent,
                                selectedShadowColor: Theme.of(context)
                                    .textSelectionTheme
                                    .cursorColor,
                                pressElevation: 10,
                              )
                        ],
                      )
                  ],
                ),
              ),
            ),
          );
  }
}

void promptStudentsInfoEdit() {
  global.switchToSecondaryUi(const students_info());
  global.temp = () {
    global.switchToPrimaryUi();
  };
}

class students_info extends StatefulWidget {
  const students_info({super.key});

  @override
  State<students_info> createState() => _stuents_infoState();
}

class _stuents_infoState extends State<students_info> {
  dynamic infoData;
  Map<String, dynamic> branchMapping = {};

  TextEditingController firstName =
      TextEditingController(text: global.accObj?.firstName);
  TextEditingController lastName =
      TextEditingController(text: global.accObj?.lastName);
  TextEditingController phoneNo = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.phoneNo));
  TextEditingController regNo = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.registerNum));
  TextEditingController rollNo = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.rollNo));

  String? parentDepartment = global.accObj?.parentDepartment == '-'
      ? null
      : global.accObj?.parentDepartment;
  String? programme =
      global.accObj?.programme == '-' ? null : global.accObj?.programme;
  String? branch = global.accObj?.branch == '-' ? null : global.accObj?.branch;
  String? branchCode =
      global.accObj?.branchCode == '-' ? null : global.accObj?.branchCode;

  String? year = global.accObj?.year == '-' ? null : global.accObj?.year;
  String? section =
      global.accObj?.section == '-' ? null : global.accObj?.section;

  bool? daysSholar = global.accObj?.isDayscholar ?? true;
  bool? busStudent = global.accObj?.collegeBus ?? false;
  TextEditingController busNo = TextEditingController(
      text: global.nullIfNullElseString(global.accObj?.collegeBusId));

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      var collection =
          global.Database!.addCollection("department", "/department");
      infoData = [];
      // Get all documents in the collection.
      QuerySnapshot documents = await collection.get();

      // Loop through the documents and print their data.
      for (DocumentSnapshot departmentNames in documents.docs) {
        dynamic departData = departmentNames.data();

        var dsc = await collection
            .doc(departData["name"])
            .collection("subdepartments")
            .get();

        for (DocumentSnapshot subDepartment in dsc.docs) {
          var temp = [];
          dynamic subDepart = subDepartment.data();
          String? subDepartCode = subDepartment.id;
          if ((subDepart as Map<String, dynamic>).containsKey("name")) {
            temp.add(subDepart["name"]);
            temp.add(subDepartCode);
            temp.add(subDepart["parent_department"]);
            temp.add(departData["maxYear"]);
            temp.add(departData["programme"]);

            branchMapping["${departData["programme"]} ${subDepart["name"]}"] =
                temp;
          }
          if (temp.isNotEmpty) {
            infoData.add(temp);
          }
        }
      }
      if (branchMapping.containsKey(branch) == false) {
        branch = null;
      }
      //debugPrint("Department info : $infoData\nBranches info : $branchMapping");
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Rebuilding students info form");

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
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (firstName.text == "" ||
                    lastName.text == "" ||
                    phoneNo.text == "" ||
                    regNo.text == "" ||
                    rollNo.text == "" ||
                    (busStudent == true && busNo.text == "" ||
                        year == null ||
                        branch == null ||
                        section == null)) {
                  global.alert.quickAlert(
                    context,
                    global.textWidget_ns(
                        "Field values can't be empty; fill available box to proceed."),
                    title: global.textWidgetWithHeavyFont("Error"),
                    dismissible: true,
                    popable: true,
                  );
                } else {
                  bool success = true;
                  try {
                    // Checking if already joined any other class before.
                    var accObj = (await global.Database!.get(
                            global.collectionMap["acc"]!,
                            global.account!.email!))
                        .data as Map<String, dynamic>;

                    account_obj acc = global.accObj!.fromJSON(accObj);

                    // Checking if enrolled in any classroom
                    String checkPath =
                        "/department/${acc.parentDepartment}/subdepartments/${acc.branchCode}/year_section/${acc.year?.toUpperCase()}_${acc.section?.toUpperCase()}/students";
                    var exists = true;
                    Object fetch;
                    final db = FirebaseFirestore.instance;

                    try {
                      fetch = await db
                          .doc("$checkPath/${global.account?.email}")
                          .get();
                    } catch (e) {
                      exists = false;
                      fetch = e;
                    }

                    debugPrint(fetch.toString());

                    // Removes the existing one
                    if (exists) {
                      (fetch as DocumentSnapshot).reference.delete();
                      debugPrint("[!] Deleted previous link on classroom");
                    }

                    // Updating the account on /acc
                    var newAccObj = global.accObj!;
                    newAccObj.updatedAt = Timestamp.now();
                    newAccObj.firstName = firstName.text;
                    newAccObj.lastName = lastName.text;
                    newAccObj.avatarUrl = global.account?.photoURL;
                    newAccObj.phoneNo = int.parse(phoneNo.text);
                    newAccObj.collegeBus = busStudent;
                    newAccObj.collegeBusId =
                        int.parse(busNo.text != "" ? busNo.text : "0");
                    newAccObj.registerNum = int.parse(regNo.text);
                    newAccObj.rollNo = rollNo.text;
                    newAccObj.isDayscholar = daysSholar;
                    newAccObj.parentDepartment = branchMapping[branch][2];
                    newAccObj.branch = branch;
                    newAccObj.branchCode = branchMapping[branch][1];
                    newAccObj.programme = branchMapping[branch][4];
                    newAccObj.isStudent = true;
                    newAccObj.year = year;
                    newAccObj.section = section;
                    newAccObj.email = global.account?.email;

                    global.accObj = newAccObj;
                    // Creates a new link to the classroom
                    fetch = db.collection(
                        "/department/${newAccObj.parentDepartment}/subdepartments/${newAccObj.branchCode}/year_section/${year?.toUpperCase()}_${section?.toUpperCase()}/students");
                    debugPrint(
                        "/department/${newAccObj.parentDepartment}/subdepartments/${newAccObj.branchCode}/year_section/${year?.toUpperCase()}_${section?.toUpperCase()}/students");
                    fetch = (fetch as CollectionReference)
                        .doc(global.account?.email);
                    await (fetch as DocumentReference)
                        .set({"student": "yes lol", "uid": global.loggedUID});
                    global.Database!.update(
                        global.Database!.addCollection("acc", "/acc"),
                        global.account!.email!,
                        newAccObj.toJson());

                    debugPrint("Created link to new classroom");
                  } catch (e) {
                    debugPrint(e.toString());
                    global.alert.quickAlert(
                      context,
                      global.textWidget_ns(e.toString()),
                      title: global.textWidgetWithHeavyFont("Error"),
                      dismissible: true,
                      popable: true,
                    );
                    success = false;
                  }

                  if (success == true) {
                    await global.prefs!.setInt("accountType", 2);
                    global.accountType = 2;
                    global.restartApp();
                  } else {
                    global.temp();
                  }
                }
              },
              backgroundColor:
                  Theme.of(context).textSelectionTheme.selectionHandleColor,
              child: Icon(Icons.done,
                  color: Theme.of(context).colorScheme.background),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            backgroundColor: Theme.of(context).focusColor,
            appBar: AppBar(
              title: global.textWidgetWithHeavyFont("Student Information Form"),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  global.switchToPrimaryUi();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      Theme.of(context).textSelectionTheme.selectionHandleColor,
                ),
              ),
              backgroundColor: Theme.of(context).focusColor.withOpacity(0.7),
              shadowColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(35),
                    bottomLeft: Radius.circular(35)),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              //reverse: true,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 300),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      //horizontalOffset: -50.0,
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      // Name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          global.textField("First Name",
                              controller: firstName,
                              initialText: firstName.text),
                          const SizedBox(
                            width: 15,
                          ),
                          global.textField("Last Name",
                              controller: lastName, initialText: lastName.text),
                        ],
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          global.textField("Register Number",
                              controller: regNo,
                              initialText: regNo.text,
                              keyboardType: TextInputType.number,
                              inputFormats: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 12),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          global.textField("Roll Number",
                              controller: rollNo,
                              initialText: rollNo.text,
                              maxLength: 8),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          global.textField("Phone Number",
                              preText: "+91 ",
                              controller: phoneNo,
                              initialText: phoneNo.text,
                              keyboardType: TextInputType.number,
                              inputFormats: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 10),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: DropdownButton(
                                hint: global.textWidget_ns("Select the branch"),
                                dropdownColor: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.8),
                                isExpanded: true,
                                value: branch,
                                items: [
                                  for (var item in branchMapping.keys)
                                    DropdownMenuItem(
                                      value: item,
                                      child: global.textWidget_ns(item),
                                    )
                                ],
                                // items: [
                                //   for (MapEntry<String, dynamic> item
                                //       in global.departmentWithClasses.entries)
                                //     DropdownMenuItem(
                                //         value: item.key,
                                //         child: global.textWidget_ns(item.value["full"]))
                                // ],
                                onChanged: (val) {
                                  setState(() => branch = val.toString());
                                  year = null;
                                }),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      if (branch != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: DropdownButton(
                                  dropdownColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.8),
                                  hint: global.textWidget_ns("Select the year"),
                                  isExpanded: true,
                                  value: year,
                                  items: [
                                    for (int i in List.generate(
                                        branch != null
                                            ? branchMapping[branch][3]
                                            : 0,
                                        (index) => index + 1))
                                      DropdownMenuItem(
                                        value: global
                                            .convertToRoman(i.toString())
                                            .toLowerCase(),
                                        child: global.textWidget_ns(
                                            global.n2w_year[global
                                                    .convertToRoman(
                                                        i.toString())
                                                    .toLowerCase()] ??
                                                "NULL"),
                                      )
                                  ],
                                  onChanged: (val) {
                                    setState(() => year = val.toString());
                                  }),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DropdownButton(
                                  hint: global
                                      .textWidget_ns("Select the section"),
                                  dropdownColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.8),
                                  isExpanded: true,
                                  value: section,
                                  items: (branch == null
                                      ? [
                                          for (var i = 0; i < 0; i++)
                                            const DropdownMenuItem(
                                              value: "test",
                                              child: Text(""),
                                            )
                                        ]
                                      : [
                                          DropdownMenuItem(
                                              value: "a",
                                              child: global.textWidget_ns("A")),
                                          DropdownMenuItem(
                                              value: "b",
                                              child: global.textWidget_ns("B"))
                                        ]),
                                  onChanged: (val) {
                                    setState(() => section = val.toString());
                                  }),
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 240,
                              child: toggle(
                                callback: (val) {
                                  setState(() {
                                    busStudent = val;
                                  });
                                  return busStudent;
                                },
                                text: "College Bus?",
                                icon: Icons.bus_alert_rounded,
                                color: Theme.of(context).colorScheme.background,
                                activeString: "Yes",
                                inactiveString: "No",
                              )),
                          const SizedBox(width: 20),
                          global.textField("Bus number",
                              controller: busNo,
                              initialText: busNo.text,
                              fit: FlexFit.tight,
                              enable: busStudent,
                              keyboardType: TextInputType.number,
                              inputFormats: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 2)
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      toggle(
                        callback: (val) {
                          setState(() {
                            daysSholar = val;
                          });
                          return daysSholar;
                        },
                        text: "Hosteller?",
                        icon: Icons.local_hotel,
                        color: Theme.of(context).colorScheme.background,
                        activeString: "Yes",
                        inactiveString: "No",
                      ),
                    ],
                  )),
            ),
          );
  }
}
