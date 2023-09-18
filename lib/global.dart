// ignore_for_file: non_constant_identifier_names

library globals;

import 'dart:convert';
import 'dart:io';

import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/ui/alert.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

SharedPreferences? prefs;
ThemeMode darkMode = ThemeMode.system;

// ignore: constant_identifier_names
enum AdminPermRank {
  Staff,
  BusStaff,
  TransportInCharge,
  FoodInCharge,
  HostelStaff,
  HostelWarden,
  SecurityStaff,
  SecurityOfficer,
  Faculty,
  LibraryStaff,
  TimetableInCharge,
  YearCoordinator,
  HeadOfDepartment,
  CO_unsure_whatever_the_hell_is_this,
  AdministrationStaff,
  Principal,
  SuperAdmin
}

List<String> possibleStaffIds = [
  // Temp, don't mind it
];

List<dynamic> logs = [];

db? Database;
Map<String, CollectionReference> collectionMap = {};
Map<String, dynamic> hashes = {};
Map<String, dynamic> departmentWithClasses = {
  "cse": {
    "full": "Computer Science and Engineering",
    "sections": ["a", "b"],
  },
  "mech": {
    "full": "Mechanical Engineering",
    "sections": ["a", "b"],
  },
  "ece": {
    "full": "Electronics and Communication Engineering",
    "sections": ["a", "b"]
  }
};
Map<String, dynamic> year = {
  "i": {"full": "First Year"},
  "ii": {"full": "Second Year"},
  "iii": {"full": "Third Year"},
  "iv": {"full": "Fourth Year"}
};

Map<String, String> n2w_year = {
  "i": "First Year",
  "ii": "Second Year",
  "iii": "Third Year",
  "iv": "Fourth Year",
  "v": "Fiveth Year"
}; // This is for reference, in actual usage it's sync-ed with database.

Map<String, dynamic> course_data = {};
Map<String, dynamic> classroom_data = {};
Map<String, dynamic> accountsInDatabase = {};
List<Function> classroom_updateFns = [];
Map<dynamic, dynamic> timetable_subject =
    {}; // Weekend days : int | Subject list : List<String> aka dynamic here
List<dynamic> timetable_timing = []; // List of timing in string : List<String>
User? account;
account_obj? accObj;
String? loggedUID;
String? passcode;
int accountType = -1;
int eventsCount = 0;
int notificationCount = 0;
int assignmentCount = 0;
int test = 0;
int naviIndex = 0;
int loginValidated = 0;
bool networkAvailable = false;
bool isLoggedIn = false;
bool loaded = false;
bool classroomEventLoaded = false;
bool loginScreenRoute = false;
bool choiceRoute = false;
bool loginRoute = false;
bool bgImage = false;
bool dashboardReached = false;
bool customColorEnable = false;
bool haveSignedInBefore = false;
int customColor = Colors.lightBlue.value;
void Function()? loginRouteCloseFn;
void Function()? rootRefresh;
void Function()? bgRefresh;
void Function(dynamic)? cameraShotFn;
Alert alert = Alert();
BuildContext? loginRouteCTX;
BuildContext? loginScreenRouteCTX;
BuildContext? choiceRouteCTX;
BuildContext? rootCTX;
BuildContext? timetableCTX;
BuildContext? MyAppCTX;
PageController? pageControl;
IndexController? uiPageControl;
dynamic temp;
dynamic quickAlertGlobalVar;
dynamic uiSecondaryScrollPhysics = const NeverScrollableScrollPhysics();
dynamic restartApp;
dynamic naviRefresh;
Offset? dragUiPosition;
Widget? uiSecondaryWidgetFn;
Color uiBackgroundColor = Colors.lightBlueAccent;

int tmpNaviIndex = 0;

void switchToSecondaryUi(Widget w) {
  debugPrint("Secondary screen now");
  uiSecondaryWidgetFn = w;
  uiSecondaryScrollPhysics = null;
  uiPageControl!.move(1);
  if (bgRefresh != null) bgRefresh!();
  //duration: const Duration(seconds: 1), curve: Curves.easeOutExpo);
}

void switchToPrimaryUi() {
  uiSecondaryScrollPhysics = const NeverScrollableScrollPhysics();
  debugPrint("Primary screen now");
  uiPageControl!.move(0);
  if (bgRefresh != null) bgRefresh!();
  //if (naviRefresh != null) naviRefresh();

  //duration: const Duration(seconds: 1), curve: Curves.easeInExpo);
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

void updateSettingsFromStorage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  prefs = pref;
  haveSignedInBefore = prefs!.getBool("haveSignedInBefore") ?? false;
  darkMode = prefs!.getBool("dark mode") != null
      ? (prefs!.getBool("dark mode") == true ? ThemeMode.dark : ThemeMode.light)
      : ThemeMode.light;
  bgImage =
      prefs!.getBool("bg image") != null ? prefs!.getBool("bg image")! : false;
  accountType = prefs!.getInt("accountType") ?? -1;
  passcode = prefs!.getString("passcode");
  dashboardReached = prefs!.getBool("dashboardReached") ?? false;
  customColorEnable = prefs!.getBool("customColorEnable") ?? false;
  customColor = prefs!.getInt("customColor") ?? Colors.lightBlue.value;
  hashes = jsonDecode(prefs!.getString("hashes") ?? "{}");
  //debugPrint(jsonDecode(jsonDecode(prefs!.getString("timetable_timing") ?? "lol" ))[0]);     This crap wasted my 1 hour time on debugging; damnit
  timetable_timing =
      jsonDecode(jsonDecode(prefs!.getString("timetable_timing") ?? "\"[]\""));
  timetable_subject =
      jsonDecode(jsonDecode(prefs!.getString("timetable_subject") ?? "\"{}\""));
  course_data =
      jsonDecode(jsonDecode(prefs!.getString("course_data") ?? "\"{}\""));

  classroom_data = jsonDecode(prefs!.getString("classroom") ?? "{}");
  rootRefresh!();
}

void updateMapToStorage(String id, dynamic x) async {
  await prefs!.setString(id, jsonEncode(x));
}

void updateListToStorage(String id, dynamic x) async {
  await prefs!.setString(id, jsonEncode(x));
}

Future<bool> checkNetwork() async {
  if (kIsWeb) return true;
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      networkAvailable = true;
    }
  } on SocketException catch (_) {
    networkAvailable = false;
  }
  return networkAvailable;
}

void initGlobalVar() async {
  accObj = account_obj();
}

Widget padHeight([double p = 5]) {
  return SizedBox(height: p);
}

dynamic nullIfNullElseString(dynamic n) {
  return n?.toString();
}

Widget classicTextField(
  String name,
  String? hint,
  TextEditingController controller,
  Icon? prefixIcon, {
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormats,
  FlexFit fit = FlexFit.loose,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: TextStyle(
        fontSize: 16.0,
        color: Theme.of(rootCTX!).textSelectionTheme.cursorColor),
    decoration: InputDecoration(
      labelText: name,
      hintText: hint,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(color: Colors.blue, width: 1.0),
      ),
      labelStyle: const TextStyle(
        color: Colors.blue,
      ),
      hintStyle: TextStyle(
        color: Theme.of(rootCTX!)
            .textSelectionTheme
            .selectionHandleColor, // Hint text color
      ),
    ),
  );
}

Widget textField(String labelName,
    {int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormats,
    FlexFit fit = FlexFit.loose,
    TextEditingController? controller,
    bool? enable = true,
    bool readOnly = false,
    String? initialText,
    String? sufText,
    String? preText,
    int? maxLines}) {
  BuildContext context = rootCTX!;
  return Flexible(
    fit: fit,
    child: TextFormField(
        maxLines: maxLines,
        minLines: 1,
        enabled: enable,
        readOnly: readOnly,
        initialValue: controller == null ? initialText : null,
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormats,
        style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textSelectionTheme.selectionColor),
        decoration: InputDecoration(
          labelText: labelName,
          prefixText: preText,
          suffixText: sufText,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .textSelectionTheme
                      .selectionHandleColor!)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).textSelectionTheme.selectionColor!)),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .textSelectionTheme
                      .selectionColor!
                      .withOpacity(0.5))),
          isDense: true,
          fillColor: Theme.of(context).textSelectionTheme.cursorColor,
          focusColor: Theme.of(context).textSelectionTheme.selectionHandleColor,
          hoverColor: Theme.of(context).textSelectionTheme.selectionHandleColor,
          prefixStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textSelectionTheme.selectionHandleColor),
          labelStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textSelectionTheme.selectionHandleColor),
          counterStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textSelectionTheme.cursorColor),
          floatingLabelStyle: const TextStyle(color: Colors.lightBlue),
        )),
  );
}

Widget textWidget(String text) {
  return SelectableText(
    text,
    style: TextStyle(
        color: Theme.of(rootCTX!).textSelectionTheme.selectionColor,
        fontSize: 12),
  );
}

Widget textWidget_ns(String text) {
  return Text(
    text,
    style: TextStyle(
        color: Theme.of(rootCTX!).textSelectionTheme.selectionColor,
        fontSize: 12),
  );
}

Widget textDoubleSpanWiget(String a, String b) {
  return Text.rich(TextSpan(children: [
    TextSpan(
        text: a,
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(rootCTX!).textSelectionTheme.cursorColor,
            fontWeight: FontWeight.bold)),
    TextSpan(
      text: b,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(rootCTX!).textSelectionTheme.selectionColor,
      ),
    )
  ]));
}

Widget textWidgetWithHeavyFont(String text) {
  return Text(
    text,
    style: TextStyle(
        color: Theme.of(rootCTX!).textSelectionTheme.selectionColor,
        fontSize: 17),
  );
}

Widget textWidgetWithBool(String text, bool enable) {
  return Text(
    text,
    style: TextStyle(
        fontSize: 13,
        color: (enable == true)
            ? Theme.of(rootCTX!).textSelectionTheme.cursorColor
            : Theme.of(rootCTX!).textSelectionTheme.selectionColor),
  );
}

Widget textWidgetWithTransparency(String text, double trans) {
  return Text(
    text,
    style: TextStyle(
      color: Theme.of(rootCTX!)
          .textSelectionTheme
          .selectionColor!
          .withOpacity(trans),
    ),
  );
}

class uiSecondaryWidget extends StatelessWidget {
  const uiSecondaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).focusColor.withOpacity(0.8),
        body: uiSecondaryWidgetFn ?? const SizedBox());
  }
}

void snackbarText(String text) {
  ScaffoldMessenger.of(rootCTX!).showSnackBar(SnackBar(
    content: Text(text),
  ));
}

Map<String, dynamic> convertDynamicToMap(dynamic x) {
  Map<String, dynamic> ret = {};

  for (var a in (x as Map).entries) {
    ret[a.key.toString()] = a.value;
  }

  return ret;
}

String convertToRoman(dynamic input) {
  if (input is int) {
    if (input < 1 || input > 5) {
      throw ArgumentError('Input number must be between 1 and 5');
    }

    switch (input) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      default:
        return '';
    }
  } else if (input is String) {
    switch (input) {
      case '1':
        return 'I';
      case '2':
        return 'II';
      case '3':
        return 'III';
      case '4':
        return 'IV';
      case '5':
        return 'V';
      default:
        throw ArgumentError('Input string must be one of: "1", "2", "3", "4"');
    }
  } else {
    throw ArgumentError('Input must be either an int or a String');
  }
}

int convertToNumeric(String roman) {
  if (roman.isEmpty ||
      roman.length > 2 ||
      !['I', 'II', 'III', 'IV'].contains(roman)) {
    throw ArgumentError('Input Roman numeral must be one of: I, II, III, IV');
  }

  switch (roman) {
    case 'I':
      return 1;
    case 'II':
      return 2;
    case 'III':
      return 3;
    case 'IV':
      return 4;
    default:
      return 0;
  }
}
