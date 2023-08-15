import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Project_Prism/global.dart' as global;
import 'package:Project_Prism/sub_screen/update_ui.dart';
import 'package:Project_Prism/ui/toggleButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../ui/logs.dart';

Map<String, int> isClose = {};

BuildContext? context_;

dynamic refresh;

const url =
    'https://raw.githubusercontent.com/EphemeralSapient/Project-Prism/main/asset/version.txt';

List<int> versionToComponents(String version) {
  return version
      .split('.')
      .map((String component) => int.parse(component))
      .toList();
}

int compareVersions(List<int> version1, List<int> version2) {
  for (int i = 0; i < version1.length; i++) {
    if (i >= version2.length) {
      return 1; // version1 is longer
    }
    if (version1[i] > version2[i]) {
      return 1; // version1 is greater
    } else if (version1[i] < version2[i]) {
      return -1; // version2 is greater
    }
  }
  if (version2.length > version1.length) {
    return -1; // version2 is longer
  }
  return 0; // versions are equal
}

String currVersion = "0.0.0";

class settings extends StatefulWidget {
  static const darkMode = 'dark';

  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _settingsState();
}

bool updateIsAvail = false;

class _settingsState extends State<settings> {
  String fileContent = '';

  void _loadTextAsset() async {
    String content = await rootBundle.loadString('asset/version.txt');
    setState(() {
      fileContent = content;
      currVersion = content;
    });
    updateCheck();
  }

  void updateCheck() async {
    if (global.networkAvailable) {
      HttpClient()
          .getUrl(Uri.parse(url))
          .then((HttpClientRequest request) => request.close())
          .then((HttpClientResponse response) {
        if (response.statusCode == HttpStatus.ok) {
          response.transform(const Utf8Decoder()).listen((contents) {
            List<int> currComponents = versionToComponents(currVersion);
            List<int> fetchedComponents = versionToComponents(contents);

            int comparisonResult =
                compareVersions(currComponents, fetchedComponents);

            if (comparisonResult == 0) {
              debugPrint(
                  "Versions are equal, no update required. $currComponents $fetchedComponents");
            } else if (comparisonResult > 0) {
              debugPrint("Current version is newer | Web result : $contents");
            } else {
              debugPrint("Fetched version is newer | Web result : $contents");
              setState(() {
                updateIsAvail = true;
              });
            }
          });
        } else {
          debugPrint(
              'Request failed for update info with status: ${response.statusCode}');
        }
      }).catchError((error) {
        debugPrint('Error with loading status HTTP client: $error');
      });
    }
  }

  @override
  void initState() {
    if (currVersion == "0.0.0") {
      _loadTextAsset();
    } else {
      updateCheck();
    }
    super.initState();
  }

  @override
  Widget build(context) {
    refresh = setState;
    context_ = context;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: !kIsWeb && updateIsAvail
          ? FloatingActionButton.extended(
              heroTag: 'uniqueTag',
              onPressed: () {
                // Update the app
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => update_ui(),
                        opaque: false,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                        scale: animation.drive(
                                          Tween(begin: 1.5, end: 1.0).chain(
                                              CurveTween(
                                                  curve: Curves.easeOutCubic)),
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: animation.value * 20,
                                              sigmaY: animation.value * 20),
                                          child: child,
                                        ))),
                        transitionDuration: const Duration(seconds: 1)));
              },
              elevation: 10,
              icon: const Icon(
                Icons.new_releases,
                size: 20,
              ),
              label: const Text(
                "Update the app",
                style: TextStyle(fontSize: 11),
              ),
            )
          : null,
      backgroundColor: Theme.of(context).focusColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            // padding: const EdgeInsets.all(24),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                const SizedBox(
                  height: 15,
                ),
                SettingsGroup(
                  "GENERAL",
                  [
                    toggleButton((val) {
                      global.darkMode =
                          (val == true ? ThemeMode.dark : ThemeMode.light);
                      global.rootRefresh!();
                      global.prefs!.setBool("dark mode", val);

                      return val;
                    },
                        "Dark Mode",
                        Icons.dark_mode,
                        Theme.of(context).colorScheme.background,
                        global.darkMode == ThemeMode.dark ? true : false),
                    toggleButton((val) {
                      global.bgImage = val;
                      global.bgRefresh!();
                      global.prefs!.setBool("bg image", val);

                      return val;
                    },
                        "Background as Image",
                        Icons.image_outlined,
                        Theme.of(context).colorScheme.background,
                        global.bgImage),
                    toggleButton((val) {
                      global.customColorEnable = val;
                      global.bgRefresh!();
                      global.prefs!.setBool("customColorEnable", val);

                      return val;
                    },
                        "Use Custom Background Color",
                        Icons.colorize,
                        Theme.of(context).colorScheme.background,
                        global.customColorEnable),
                    InkWell(
                      onTap: () {
                        Color changeColor = Color(global.customColor);
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => Scaffold(
                                      backgroundColor: Colors.transparent,
                                      floatingActionButton:
                                          FloatingActionButton(
                                        onPressed: () {
                                          global.customColor =
                                              changeColor.value;
                                          global.prefs!.setInt(
                                              "customColor", changeColor.value);
                                          global.bgRefresh!();
                                          Navigator.pop(c);
                                        },
                                        child: const Icon(Icons.done),
                                      ),
                                      body: WillPopScope(
                                          onWillPop: () async {
                                            return true;
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            color: Theme.of(context).focusColor,
                                            child: MaterialPicker(
                                              pickerColor:
                                                  Color(global.customColor),
                                              onColorChanged: (value) =>
                                                  changeColor = value,
                                              enableLabel: true,
                                              portraitOnly: true,
                                            ),
                                          )),
                                    ),
                                opaque: false,
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                            scale: animation.drive(
                                              Tween(begin: 1.5, end: 1.0).chain(
                                                  CurveTween(
                                                      curve:
                                                          Curves.easeOutCubic)),
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: animation.value * 20,
                                                  sigmaY: animation.value * 20),
                                              child: child,
                                            ))),
                                transitionDuration:
                                    const Duration(seconds: 1)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Custom Background Color",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textSelectionTheme
                                      .selectionHandleColor,
                                  fontFamily: "Montserrat",
                                  fontSize: 12),
                            ),
                            CircleAvatar(
                              backgroundColor: Color(global.customColor),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     global.accountType == 2 ? promptStudentsInfoEdit() : promptStaffInfoEdit();
                //   },
                //   style:
                //       ElevatedButton.styleFrom(primary: Theme.of(context).focusColor, shadowColor: Colors.transparent),
                //   child: Text("Change your ${global.accountType == 2 ? "Student" : "Faculty"} information data",
                //       style: TextStyle(
                //           fontSize: 12,
                //           color: Theme.of(context).textSelectionTheme.selectionColor
                //     )
                //   ),
                // ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        global.switchToSecondaryUi(const LogScreen());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).focusColor,
                          shadowColor: Colors.transparent),
                      child: Text("PrismLogger",
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor)),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        global.accountType = 0;
                        global.loginValidated = 0;
                        global.updateSettingsFromStorage();
                        global.restartApp();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).focusColor,
                          shadowColor: Colors.transparent),
                      child: Text("Sign out",
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .textSelectionTheme
                                  .selectionColor)),
                    ),
                  ],
                ),
                global.textWidget("Version : $currVersion")
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget SettingsGroup(String title, List<Widget> children) {
  return AnimatedCrossFade(
    firstChild: Column(
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 375),
        childAnimationBuilder: (widget) => SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: widget,
          ),
        ),
        children: [
          ElevatedButton(
              onPressed: () {
                isClose[title] = 1;
                refresh(() {});
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context_!).focusColor,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent),
              child: Row(children: [
                Text(
                  "$title  ",
                  style: TextStyle(
                      color:
                          Theme.of(context_!).textSelectionTheme.selectionColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      fontFamily: "Montserrat",
                      fontSize: 12),
                ),
                Icon(Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context_!).textSelectionTheme.cursorColor,
                    size: 12)
              ])),
          for (var w in children)
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: w,
            )
        ],
      ),
    ),
    secondChild: ElevatedButton(
        onPressed: () {
          isClose[title] = 0;
          refresh(() {});
        },
        style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context_!).focusColor,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent),
        child: Row(children: [
          Text(
            "$title  ",
            style: TextStyle(
                color: Theme.of(context_!).textSelectionTheme.selectionColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                fontFamily: "Montserrat",
                fontSize: 12),
          ),
          Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context_!).textSelectionTheme.cursorColor,
              size: 12)
        ])),
    crossFadeState: isClose[title] == 1
        ? CrossFadeState.showSecond
        : CrossFadeState.showFirst,
    duration: const Duration(milliseconds: 400),
  );
}
