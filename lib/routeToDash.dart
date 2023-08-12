// ignore_for_file: file_names, camel_case_types, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:ui';

import 'package:Project_Prism/acc_update.dart';
import 'package:Project_Prism/buildin_transformers.dart';
import 'package:Project_Prism/database.dart';
import 'package:Project_Prism/screens/classroom.dart';
import 'package:Project_Prism/screens/dashboard.dart';
import 'package:Project_Prism/screens/profile.dart';
import 'package:Project_Prism/screens/search.dart';
import 'package:Project_Prism/screens/settings.dart';
import 'package:Project_Prism/sub_screen/infoEdit.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'
    show CurvedNavigationBar;
import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'global.dart' as global;

const image = NetworkImage(
    "https://images.unsplash.com/photo-1540122995631-7c74c671ff8d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8MXx8fGVufDB8fHx8&w=1000&q=80");

class ui extends StatefulWidget {
  const ui({super.key});

  @override
  State<ui> createState() => _uiState();
}

dynamic cacheDashboard = const dashboard();

class _uiState extends State<ui> {
  final IndexController _page = IndexController();
  int index = 0;

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    global.bgRefresh = refresh;
    global.uiPageControl = _page;
  }

  @override
  void dispose() {
    super.dispose();
    _page.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var page_1 = ClipRect(child: cacheDashboard);
    var page_2 = ClipRect(child: global.uiSecondaryWidget());
    return DoubleBackToExitWidget(
      page: _page,
      child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Stack(children: [
            bg(context),
            TransformerPageView(
                scrollDirection: Axis.vertical,
                physics: global.uiSecondaryScrollPhysics,
                duration: const Duration(milliseconds: 500),
                controller: _page,
                itemCount: 2,
                transformer: ZoomOutWithoutOpacPageTransformer(),
                itemBuilder: (context, index) {
                  return index == 0 ? page_1 : page_2;
                } //[
                //dashboard(),
                //global.uiSecondaryWidget(),
                //],
                ),
          ])),
    );
  }
}

class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

int index = 0;

class _dashboardState extends State<dashboard> {
  final PageController _page = PageController();
  bool isTrulyNull = false;

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    global.pageControl = _page;
    global.naviRefresh = refresh;
    global.naviIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _page.jumpToPage(index);
      } catch (e) {
        debugPrint("$e EEEEEEEEEEEEEEEEEEEEEE Dashboard");
      }
    });

    initUpdater(false);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    List<Icon> items = [
      Icon(Icons.dashboard, size: 23, color: Theme.of(context).shadowColor),
      if (global.accountType != 3)
        Icon(Icons.class_rounded,
            size: 23, color: Theme.of(context).shadowColor),
      Icon(Icons.search, size: 23, color: Theme.of(context).shadowColor),
      Icon(Icons.settings, size: 23, color: Theme.of(context).shadowColor),
      if (global.accountType != 3)
        Icon(Icons.person, size: 23, color: Theme.of(context).shadowColor),
    ];
    debugPrint("Building route for nagivation [routeToDash]");

    if (global.accountType != 3 &&
        global.accObj?.phoneNo == null &&
        !isTrulyNull) {
      debugPrint(" >>>> Refreshing the acc obj");
      Future.delayed(Duration.zero, () async {
        if (global.account == null) {
          debugPrint(
              "[WARNING] CRASHED DUE TO LATE INIT ON GLOBAL.ACCOUNT [!]");
          return;
        }
        db_fetch_return fetch = await global.Database!
            .get(global.collectionMap["acc"]!, global.account!.email!);

        if (fetch.status == db_fetch_status.exists) {
          setState(() {
            global.accObj =
                account_obj().fromJSON(fetch.data as Map<String, dynamic>);
            isTrulyNull = true;
          });
        } else {
          debugPrint(
              "[WARNING] ACCOUNT INFO NOT SYNCED DUE TO ERROR [!]\n${fetch.data.toString()}");
        }
      });

      return WillPopScope(
          onWillPop: () async => false,
          child: const SpinKitFadingCube(
            color: Colors.white,
          ));
    }

    bool verified = (global.accountType == 2 &&
            global.accObj != null &&
            global.accObj?.phoneNo != null) ||
        (global.accountType == 1 &&
            global.passcode != null &&
            global.passcode != "") ||
        global.accountType == 3;

    if (!verified && global.accObj != null) {
      debugPrint(
          "Calling prompt informtion form from dashboard | Verified : $verified");
      debugPrint("${global.accountType} | ${global.accObj} | ");
      prompt(context);
    }
    // debugPrint("Passcode : ${global.passcode.toString()}");
    debugPrint("Index value right now : $index");
    return DoubleBackToExitWidget(
      page: _page,
      child: (verified == false)
          ? Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Center(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: DropShadow(
                          offset: const Offset(0, 0),
                          blurRadius: 10,
                          spread: .5,
                          child: Image.asset(
                            "asset/images/logo-without-bg.png",
                          )))))
          : Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Center(
                  child: PageView(
                controller: _page,

                physics: const NeverScrollableScrollPhysics(),
                //onPageChanged: (index) {
                //setState(() => _selectedIndex = index);
                //},
                children: <Widget>[
                  const dash() ?? const SizedBox(),
                  if (global.accountType != 3) const classroom(),
                  const search(),
                  const settings(),
                  if (global.accountType != 3) profile(),
                ],
              )),
              backgroundColor: Colors.transparent,
              bottomNavigationBar: CurvedNavigationBar(
                height: 55,
                backgroundColor: Colors.transparent,
                color: Theme.of(context).focusColor,
                buttonBackgroundColor: Theme.of(context).hintColor,
                index: index,
                onTap: (value) {
                  index = value;
                  _page.animateToPage(index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutExpo);
                  //items[value].color = Theme.of(context).backgroundColor;
                },
                items: items,
              ),
            ),
    );
  }
}

void toDashbaord() async {
  for (; global.account == null;) {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Account not found, waiting...");
  }
  index = 0;
  global.dashboardReached = true;
  global.prefs!.setBool("dashboardReached", true);
  if (global.accountType != 3) {
    global.prefs!.setBool("haveSignedInBefore", true);
    global.haveSignedInBefore = true;
  }

  debugPrint("Pushed /dashboard");

  Navigator.pushNamed(global.rootCTX!, "/dashboard");
}

InputDecoration dec(IconData? icon, String hint) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
    prefixIconColor: Colors.red,
    prefixStyle: const TextStyle(color: Colors.deepPurpleAccent),
    hintText: hint,
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.0),
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

bool onPrompt = false;
void prompt(BuildContext context) async {
  if (onPrompt == true || global.temp == true) return;
  onPrompt = true;
  context = global.rootCTX!;
  global.temp = onPrompt;

  await Future.delayed(const Duration(milliseconds: 1500));

  if (global.accountType == 1) {
    // staff
    global.temp = () {
      // What to addd here hmm
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => staffs_info()),
    );
  } else {
    // student
    global.temp = () {
      global.restartApp();
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => students_info()),
    );
  }
}

Widget bg(BuildContext context) {
  return AnimatedCrossFade(
      firstChild: Stack(
        children: [
          // ignore: prefer_const_constructors
          FadeInImage(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            placeholder: const AssetImage(
                "asset/images/logo_192.png"), // Placeholder GIF image
            image: const NetworkImage(
                "https://mobimg.b-cdn.net/v3/fetch/a0/a029a96e19a248e75762a4be139d3d36.jpeg"),
            fit: BoxFit.cover, // Image fit
          ),
          Container(
            color: Colors.black.withOpacity(0.1), // Overlay color
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
      secondChild: AnimatedContainer(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          duration: const Duration(milliseconds: 150),
          color: global.customColorEnable
              ? Color(global.customColor)
              : global.uiBackgroundColor),
      crossFadeState: global.bgImage == true
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(seconds: 1));
}

class DoubleBackToExitWidget extends StatefulWidget {
  final Widget child;
  final dynamic page;

  const DoubleBackToExitWidget(
      {super.key, required this.child, required this.page});

  @override
  _DoubleBackToExitWidgetState createState() => _DoubleBackToExitWidgetState();
}

class _DoubleBackToExitWidgetState extends State<DoubleBackToExitWidget> {
  bool _doubleBackToExitPressed = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: widget.child,
    );
  }

  Future<bool> _handleWillPop() async {
    dynamic page = widget.page;
    if (page.index == 1) {
      page.move(
          0); // (0, duration: Duration(seconds: 1), curve: Curves.easeInOutExpo);
      return false;
    } else {
      if (_doubleBackToExitPressed) {
        // If double back pressed, close the app
        SystemNavigator.pop();
        return true;
      }

      // Show a snackbar with message
      _doubleBackToExitPressed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );

      // Reset _doubleBackToExitPressed after 2 seconds
      Timer(const Duration(seconds: 2), () {
        _doubleBackToExitPressed = false;
      });

      return false;
    }
  }
}
