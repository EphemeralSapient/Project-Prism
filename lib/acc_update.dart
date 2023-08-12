import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import './global.dart' as global;

bool isLock = false;
bool isNew = false;
int rev = 0;

void releaseLockAccUpdate() {
  isLock = false;
  rev++;
}

// Function gets invoked when dashboard gets started
void initUpdater(bool? override) async {
  // TODO : Add support for staff account type
  if ((isLock == true || global.accountType == 3) && override != true) {
    return;
  } else {
    isLock = true;
  }

  int lockRev = rev;

  if (global.accObj == null) {
    while (global.accObj == null) {
      await Future.delayed(const Duration(milliseconds: 250));
      debugPrint("Account object is not created yet??");
    }
  }

  // // If the student haven't chose the class yet.
  // if (global.accountType == 2 && global.accObj!.classBelong == "pending") {
  //   while (global.accObj!.classBelong == "pending") {
  //     await Future.delayed(const Duration(milliseconds: 250));
  //   }
  //   debugPrint("Class value got assigned | ${global.accObj!.classBelong}");

  //   // Class value is not assigned?
  //   if ((global.accObj!.classBelong ?? "pending") == "pending") {
  //     isLock = false;
  //     return;
  //   }
  //   isNew = true;
  // }

  // if (global.prefs!.getBool("classPending") == true) {
  //   debugPrint("Automatic sign in verified");
  //   global.prefs!.setBool("classPending", false);
  // }

  // var classroomCollection = global.Database!.addCollection("class", "/class");
  // StreamSubscription<dynamic>? classroomSub;
  // // Classroom data fetching
  // if (global.accountType == 2) {
  //   // Student account requires only specified classroom updates
  //   Future.delayed(Duration(), () async {
  //     while (global.accObj!.classBelong == "None") {
  //       await Future.delayed(const Duration(milliseconds: 250));
  //     }
  //     debugPrint(">>>>>>>>>>> test : ${global.accObj!.classBelong.toString()}");
  //     var get = await global.Database!
  //         .get(classroomCollection, global.accObj!.classBelong!);
  //     Map info = global.classroom_data;

  //     if (get.status == db_fetch_status.nodata) {
  //       debugPrint("Creating new class data on database");
  //       var data = {
  //         "department": global.accObj!.department,
  //         "classCode": global.accObj!.classBelong,
  //         "year": global.accObj!.year,
  //         "section": global.accObj!.section
  //       };
  //       await global.Database!
  //           .create(classroomCollection, global.accObj!.classBelong!, data);
  //       info = data;
  //     } else {
  //       debugPrint("Classroom data exists already | ${get.data}");
  //       info = get.data as Map;
  //     }

  //     if (global.classroom_data == {}) {
  //       global.classroom_data = Map.from(info);
  //     }

  //     global.classroomEventLoaded = true;
  //     classroomSub = classroomCollection
  //         .doc(global.accObj!.classBelong!)
  //         .snapshots()
  //         .listen((event) async {
  //       if (rev != lockRev) {
  //         debugPrint("Canceling /class update event");
  //         classroomSub?.cancel();
  //         return;
  //       }

  //       dynamic data = event.data();

  //       if (data == null)
  //         return debugPrint(
  //             "Data was not supplied in /class collection stream event listener");

  //       var oldData = Map.from(global.classroom_data);
  //       var newData = data as Map<String, dynamic>;

  //       //if(newData.toString() == oldData.toString()) {
  //       //debugPrint("No updates found from /class update event");
  //       //return;
  //       //}

  //       if (newData.isEmpty) {
  //         debugPrint("New data is empty from /class update event");
  //         return;
  //       }

  //       for (var x in global.classroom_updateFns) {
  //         await x.call(newData);
  //       }

  //       global.classroom_data = newData;
  //       global.updateMapToStorage("classroom", newData);
  //       //debugPrint("/class Update : ${newData.toString()}}");
  //     });
  //   });
  // } else {
  //   var get = await classroomCollection.get();
  //   var getData = get.docs;
  //   Map<String, dynamic> mapping = {};

  //   for (var x in getData) {
  //     mapping[x.reference.id] = x.data();
  //   }

  //   global.classroom_data = mapping;

  //   Future.delayed(Duration(seconds: 3), () async {
  //     global.classroomEventLoaded = true;
  //   });

  //   classroomSub = classroomCollection.snapshots().listen((event) async {
  //     var get = await classroomCollection.get();
  //     var getData = get.docs;
  //     Map<String, dynamic> mapping = {};

  //     for (var x in getData) {
  //       mapping[x.reference.id] = x.data();
  //     }

  //     for (var x in global.classroom_updateFns) {
  //       await x.call(mapping);
  //     }

  //     global.classroom_data = mapping;
  //     global.updateMapToStorage("classroom", mapping);
  //   });
  // }

  debugPrint("Creating /acc update event listener");
  var getInfo = await global.Database!.addCollection("acc", "/acc").get();
  Map<String, dynamic> getInfoData = {};
  for (var x in getInfo.docs.asMap().entries) {
    getInfoData[x.value.reference.id.toString()] = x.value.data();
  }
  global.accountsInDatabase = getInfoData;

  // Upate occurred on user database
  StreamSubscription<DocumentSnapshot<Object?>>? sub;
  debugPrint("Started AAAAAAAAAAAAAAAAAAAAAAAAAAAA");
  sub = global.Database!
      .addCollection("acc", "/acc")
      .doc(global.account?.email)
      .snapshots()
      .listen((event) async {
    debugPrint(" >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> " + event.toString());
    if (rev != lockRev) {
      sub?.cancel();
      return;
    }
    debugPrint("AAAAAAAAAAAAAAAAAAAAAAAAAAA");
    dynamic data = event.data();

    if (data == null)
      return debugPrint(
          "Data was not supplied in /acc collection stream event listener");

    var newData = global.accObj!.fromJSON(data as Map<String, dynamic>);

    //Self init the hash since there's no value in hash map yet.
    if (newData.hashes.isEmpty == true) {
      var s = "Self init hash value ${DateTime.now().toString()}";
      global.Database!.update(global.Database!.addCollection("acc", "/acc"),
          global.account!.email!, {
        "hashes": {"timetable_timing": s, "timetable_subject": s}
      });
    }

    // if (oldData.hashes.toString().compareTo(newData.hashes.toString()) != 0) {
    //   final oh = oldData.hashes;
    //   final nh = newData.hashes;
    //   bool canUpdate = true;
    //   if (oh["timetable_timing"] != nh["timetable_timing"]) {
    //     // Accessing the /timetable from the database; contains Reference to document -> List<String>
    //     var ttCollectRef =
    //         global.Database!.addCollection("timetable", "/timetable");

    //     var get = await global.Database!
    //         .get(ttCollectRef, newData.classBelong ?? "??");
    //     debugPrint(
    //         "Updating time table Timing for ${newData.classBelong ?? "??"} class.");

    //     if (get.status == db_fetch_status.exists) {
    //       dynamic fetchedData = get.data;
    //       fetchedData = await fetchedData["timing"].get();
    //       fetchedData = fetchedData.data();

    //       debugPrint(
    //           "Successfully fetched the time table timing data! | ${fetchedData.toString()}");
    //       global.timetable_timing = fetchedData["time"];
    //       global.updateListToStorage(
    //           "timetable_timing", jsonEncode(fetchedData["time"]));
    //     } else {
    //       canUpdate = false;
    //       debugPrint("${get.status} | ${get.data.toString()}");
    //     }

    //     // } if(oh["timetable_subject"] != nh["timetable_subject"]){
    //     //    debugPrint("Updating time table subject data");
    //     //   // Time table subjects contains Map<String, Map<String, dynamic>>
    //     //   var ttCollectRef = global.Database!.addCollection("course", "/course");

    //     //   var get = await global.Database!.get(ttCollectRef, newData.classBelong ?? "??");
    //     //   debugPrint("Updating time table subjects [/course] for ${newData.classBelong ?? "??"} class.");

    //     //   if(get.status == db_fetch_status.exists) {
    //     //     dynamic fetchedData = get.data;
    //     //     fetchedData = fetchedData["courseMap"];

    //     //     debugPrint("Successfully fetched the time table subject data! | ${fetchedData.toString()}");
    //     //     global.timetable_subject = fetchedData;
    //     //     global.updateListToStorage("timetable_subject", jsonEncode(fetchedData));
    //     //   } else { canUpdate = false; debugPrint("${get.status} | ${get.data.toString()}");}
    //   }
    //   if (oh["course_data"] != nh["course_data"]) {
    //     debugPrint("Updating course data");
    //     // Contains course info such as subject full details
    //     var ttCollectRef = global.Database!.addCollection("course", "/course");

    //     var get = await global.Database!
    //         .get(ttCollectRef, newData.classBelong ?? "??");

    //     if (get.status == db_fetch_status.exists) {
    //       dynamic fetchedData = get.data;

    //       debugPrint(
    //           "Successfully fetched the time course data! | $fetchedData");
    //       global.course_data = jsonDecode(fetchedData["courseInfo"] ?? "{}");
    //       global.updateListToStorage("course_data", fetchedData);
    //     } else {
    //       canUpdate = false;
    //     }
    //   }

    //   if (canUpdate == true) global.updateMapToStorage("hashes", nh);
    // } else if (oldData.toString() != newData.toString()) {
    //   debugPrint("something inside the class changed!");
    // } else {
    //   debugPrint(
    //       "Stream on /acc event got recived with no changes between new and old account data");
    // }

    global.accObj = newData;
    debugPrint("Updated! - Acc update");
    global.naviRefresh(); // Updating dashboard.
  }, onError: (e) {
    debugPrint("What, error? $e");
  });
}

void oneTimeCheckAndUpdate() async {}
