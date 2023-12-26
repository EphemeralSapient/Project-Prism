import 'dart:async' show Future;
import 'dart:ui';

import 'package:Project_Prism/intro_screen.dart' show IntroPage;
import 'package:Project_Prism/restartWidget.dart';
import 'package:Project_Prism/routeToDash.dart';
import 'package:drop_shadow/drop_shadow.dart' show DropShadow;
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider, User;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:timetable/timetable.dart';

import 'database.dart';
import 'firebase_options.dart' show DefaultFirebaseOptions;
import 'global.dart' as globals;
import 'login/options.dart' show Choice;
// ignore: duplicate_import
import 'routeToDash.dart';

SharedPreferences? pref;
int introRan = 0;
Future main() async {
  debugPrint = (String? message, {int? wrapWidth}) {
    String timestamp = "[${DateTime.now().toString().split(" ")[1]}]";

    // Extract file name and line number from the stack trace
    var stackTrace = StackTrace.current;
    var lineNumber = stackTrace.toString().split("\n")[1].split(":")[1];
    var fileName =
        stackTrace.toString().split("\n")[1].split("(")[1].split(":")[0];

    // Format the message with the timestamp, file name, line number, and color tag
    String coloredMessage =
        '<font color="#FF5733">$timestamp</font> $message \n <small><font color="#888888">$fileName:$lineNumber</font></small>';

    // Add the formatted message to the logs list
    globals.logs.add(coloredMessage);

    if (kDebugMode) {
      print(message); // Print the message without the color tag for console
    }
  };
  debugPrint("initializing required modules...");
  MediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();
  introRan = pref!.getInt("introPlayed") ?? 0;
  debugPrint("running the app now");
  ErrorWidget.builder = (details) {
    var style = const TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
    return Scaffold(
      backgroundColor: Colors.red.withOpacity(0.6),
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 300),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 50),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Oops! An error occurred, please restart the app",
                    style: style,
                  ),
                  const SizedBox(height: 30),
                  Text(details.toStringShort(), style: style),
                  const SizedBox(height: 15),
                  SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                          child: Text(details.stack.toString(), style: style)))
                ],
              )),
        ),
      ),
    );
  };
  runApp(RestartWidget(
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void refreshRoot() {
    setState(() {
      debugPrint("Called!");
    });
  }

  @override
  void initState() {
    globals.rootRefresh = refreshRoot;
    globals.MyAppCTX = context;
    globals.updateSettingsFromStorage();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint(globals.darkMode.toString());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (introRan == 0) {
      Future.delayed(const Duration(seconds: 9, milliseconds: 500), () async {
        introRan = 1;
        pref!.setInt("introPlayed", 1);
        setState(() {});
      });
    }

    //return introRan == 0
    //  ? MaterialApp(home: introPage())
    return MaterialApp(
      localizationsDelegates: const [
        TimetableLocalizationsDelegate(),
        // Other delegates, e.g., `GlobalMaterialLocalizations.delegate`
      ],
      theme: ThemeData(
        splashColor: Colors.grey.shade100,
        shadowColor: const Color.fromARGB(132, 0, 0, 0),
        hintColor: Colors.grey.shade200,
        canvasColor: Colors.white,
        focusColor: const Color.fromARGB(127, 255, 255, 255),
        useMaterial3: true,
        textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Color.fromARGB(160, 0, 0, 0),
            selectionHandleColor: Color.fromARGB(120, 0, 0, 0),
            cursorColor: Color.fromARGB(255, 0, 0, 0)),
        secondaryHeaderColor: Colors.grey,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(background: Colors.white),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        splashColor: Colors.grey.shade800,
        shadowColor: Colors.grey.shade300,
        hintColor: Colors.grey.shade800,
        canvasColor: Colors.grey.shade300,
        focusColor: const Color.fromARGB(158, 0, 0, 0),
        textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Color.fromARGB(192, 255, 255, 255),
            selectionHandleColor: Color.fromARGB(120, 255, 255, 255),
            cursorColor: Color.fromARGB(255, 255, 255, 255)),
        secondaryHeaderColor: Colors.white38,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue)
            .copyWith(background: Colors.grey.shade900),
      ),
      themeMode: globals.darkMode,
      initialRoute: '/',
      routes: {
        '/': (context) => introRan == 0 ? const IntroPage() : const home(),
//      '/choice': (context) => const Choice()
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/choice") {
          debugPrint("Choice route was called | ${StackTrace.current}");
          return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            pageBuilder: (c, a1, a2) => const Choice(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(seconds: 1),
          );
        } else if (settings.name == "/dashboard") {
          return PageRouteBuilder(
              settings: settings,
              pageBuilder: (c, a1, a2) => const ui(),
              transitionsBuilder: (context, animation, secondaryAnimation,
                      child) =>
                  FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                          scale: animation.drive(Tween(begin: 1.5, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOutCubic))),
                          child: child)),
              transitionDuration: const Duration(seconds: 1));
        }
        return null;
        // Unknown route
        //return MaterialPageRoute(builder: (_) => UnknownPage());
      },
    );
  }
}

// ignore: camel_case_types
class home extends StatefulWidget {
  const home({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeImpl();
  }
}

class HomeImpl extends State<home> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () async {
      //WidgetsFlutterBinding.ensureInitialized();

      debugPrint("Starting...");
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      // In case of user loggined as admin but didn't enter passcode
      if ((globals.accountType == 1 && globals.passcode == null)) {
        debugPrint("Passcode / class data is not completed, signing out.");
        await FirebaseAuth.instance.signOut();
      }

      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      // Website version requires persistance
      if (kIsWeb && user == null) {
        user = await FirebaseAuth.instance.authStateChanges().first;
      }

      debugPrint("Firebase loaded");
      globals.updateSettingsFromStorage();
      debugPrint("User info : $user");

      try {
        if (user != null) await user.reload();
      } on FirebaseAuthException catch (e) {
        //user = null;
        debugPrint("Failed to login; $e");
      }

      //TODO : Fix this; It's not working properly; temp disabled it
      //Retry and await till user data is not empty
      if (user == null && globals.haveSignedInBefore) {
        for (int i = 0; i <= 3 && user == null; i++) {
          debugPrint("Awaited for $i seconds...");
          await Future.delayed(const Duration(seconds: 0));
        }

        // if (user == null) {
        //   globals.alert.quickAlert(
        //       context,
        //       globals.textWidget(
        //           "Previous account login were detected but unable to find the user data, please re-login"));
        // }
      }

      if (user != null) {
        bool network = await globals.checkNetwork();

        //Checking if user data exists in cloud or banned[or removed]
        if (user.photoURL != null && network == true) {
          globals.Database = db();
          db_fetch_return checkAccountStatus = await globals.Database!
              .get(globals.Database!.addCollection("acc", "/acc"), user.email!);
          if (checkAccountStatus.status == db_fetch_status.nodata ||
              checkAccountStatus.status == db_fetch_status.error) {
            try {
              auth.signOut();
            } on Exception catch (e) {
              debugPrint(
                  "$e error occurred while signing out on non-existent account.");
            }
            user = null;
            globals.accountType = 0;
            globals.initGlobalVar();
            debugPrint("Account is empty??");
            Navigator.pushNamed(context, "/choice");
            return null;
            // Add if something needs to be removed on removed account

            //
          }
        }

        // ignore: unnecessary_null_comparison
        if (user != null && user.photoURL == null && network == true) {
          GoogleSignIn signIn = GoogleSignIn();
          debugPrint("Slient sign-in on process");
          final acc = await signIn.signInSilently();

          if (acc != null) {
            final auth = await acc.authentication;

            final cred = GoogleAuthProvider.credential(
                accessToken: auth.accessToken, idToken: auth.idToken);

            try {
              final Cred =
                  await FirebaseAuth.instance.signInWithCredential(cred);
              user = Cred.user;
            } on FirebaseAuthException catch (e) {
              debugPrint(e.toString());
              return e.toString();
            }
          } else {
            debugPrint("Something went very wrong with sign in process! ");
          }
        }

        globals.isLoggedIn = true;
        globals.loggedUID = user!.uid;
        globals.account = user;
        if (user.isAnonymous != true) {
          //if(globals.dashboardReached == false) debugPrint(await validate(2) ?? "Validation completed" );
          //globals.accountType = 2;
        } else {
          globals.accountType = 3;
        }
        Future.delayed(const Duration(seconds: 2), () => toDashbaord());
      } else if (globals.choiceRoute != true) {
        // ignore: use_build_context_synchronously
        debugPrint("choiceRoute is not true");
        Navigator.pushNamed(context, "/choice");
      }

      globals.Database = db();
      globals.initGlobalVar();
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.rootCTX = context;
    return Scaffold(
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
            ),
          ),
        ),
      ),
    );
  }
}
