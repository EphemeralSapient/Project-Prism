import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/global.dart' as global;
import 'terminate.dart';

/*
  Future.delayed(const Duration(milliseconds : 1500),() async {
    Navigator.pop(global.loginScreenRouteCTX!);
    await Future.delayed(const Duration(milliseconds: 500));
*/

bool lock = false;
Future<String?> validate(int typo) async {
  if (lock == true) return "Already in process.";
  lock = true;
  Future.delayed(const Duration(seconds: 5), () async {
    lock = false;
  });

  //Verification process ----------------------------------------------
  // Adding the collection information to the map
  debugPrint("Validating the account info...");
  global.loggedUID = global.account!.uid;
  debugPrint("Validating the email [${global.account!.email.toString()}]");

  // Adds
  db_fetch_return check; // Temp variable for checking operation status
  db_fetch_return get = await global.Database!.get(
      global.Database!.addCollection("acc", "/acc"), global.account!.email!);

  if (get.status == db_fetch_status.error) return "Error : ${get.data}";

  //global.accObj!.timeStamp = DateTime.now().toUtc().toIso8601String();

  if (get.status == db_fetch_status.nodata) {
    // Create the data
    global.accObj!.isStudent = global.accountType == 2;
    global.accObj!.classBelong = "pending";
    global.accObj!.createdAt = Timestamp.now();
    global.accObj!.firstName = global.account?.displayName;

    debugPrint("Creating the data");

    // Updating
    check = await global.Database!.create(global.collectionMap["acc"]!,
        global.account!.email!, global.accObj!.toJson());

    if (check.status == db_fetch_status.error) {
      return "Account creation failed : ${check.data.toString()}";
    }
  } else {
    debugPrint(get.data!.toString());
    Map<String, dynamic> getData = get.data! as Map<String, dynamic>;

    global.accObj = global.accObj!.fromJSON(getData);
    global.accObj!.hashes = {};
    debugPrint(
        "Okay, validation success and account already exists, proceeding . . .");
  }

  // Updating the existing
  check = await global.Database!.update(
      global.Database!.addCollection("acc", "/acc"),
      global.account!.email!,
      global.accObj!.toJson());

  debugPrint(
      "After updating the account info upon validation : ${check.status}");
  if (check.status == db_fetch_status.error) {
    return "Account update failed : ${check.data.toString()}";
  }

  // // Verification and creation stage over ---------------------------------
  global.accountType = typo;
  await global.prefs!.setInt("accountType", typo);
  // if(staffIds.contains(global.account!.email) == true) {
  //   global.accountType = 1;

  //   // Pass code is required here to proceed

  // } else {
  //   global.accountType =2;

  if (typo == 2) {
    await global.prefs!.setBool("classPending", true);
  }

  // }
  global.updateSettingsFromStorage();
  global.loginValidated = 1;

  Future.delayed(const Duration(milliseconds: 500), () async {
    Navigator.pop(global.loginScreenRouteCTX!);
    await Future.delayed(const Duration(milliseconds: 100));
    terminateFn();
    lock = false;
  });

  return null;
  //});
}
