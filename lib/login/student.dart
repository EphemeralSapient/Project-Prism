// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Project_Prism/global.dart' as global;
import 'validate.dart';

class studentLogin extends StatelessWidget {
  const studentLogin({Key? key}) : super(key: key);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, signing in...');
    return Future.delayed(const Duration(milliseconds: 1000)).then((_) async {
      if (!RegExp("^[a-zA-Z0-9+_.-]+@drngpit.ac.in").hasMatch(data.name)) {
        return "Please enter your college official mail id.";
      }

      try {
        UserCredential response = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: data.name, password: data.password);
        global.account = response.user;
        return validate(2);
      } on FirebaseAuthException catch (e) {
        if (e.message ==
            "There is no user record corresponding to this identifier. The user may have been deleted.") {
          return "User does not exist";
        } else {
          return e.message;
        }
      }
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name forgot password');
    return Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      } on FirebaseAuthException catch (e) {
        return (e.message.toString());
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    global.loginScreenRouteCTX = context;
    return FlutterLogin(
        theme: LoginTheme(
            primaryColor: Colors.orangeAccent,
            pageColorLight: const Color.fromRGBO(255, 94, 203, 1),
            pageColorDark: const Color.fromRGBO(250, 216, 130, 1),
            bodyStyle: TextStyle(color: Theme.of(context).shadowColor),
            accentColor: Theme.of(context).shadowColor,
            textFieldStyle: TextStyle(color: Theme.of(context).shadowColor),
            inputTheme: InputDecorationTheme(
                filled: true,
                labelStyle: TextStyle(color: Theme.of(context).shadowColor),
                hoverColor: Theme.of(context).shadowColor),
            cardTheme: CardTheme(
                color: Theme.of(context).splashColor,
                shadowColor: Colors.black,
                elevation: 20)),
        //title: 'Student',
        onLogin: _authUser,
        //onSignup: _signupUser,
        //onSubmitAnimationCompleted: () {
        //Navigator.of(context).pushReplacement(MaterialPageRoute(
        //builder: (context) => DashboardScreen(),
        //));
        //},
        //hideForgotPasswordButton: true,
        //hideProvidersTitle: true,
        onRecoverPassword: _recoverPassword,
        loginProviders: <LoginProvider>[
          LoginProvider(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            callback: () async {
              debugPrint('start google sign in');

              GoogleSignIn sign_in = GoogleSignIn(
                scopes: [
                  "https://www.googleapis.com/auth/userinfo.profile",
                  "https://www.googleapis.com/auth/userinfo.email"
                ],
                clientId: kIsWeb
                    ? "888144007010-5bt66h2es75mdkpdgtf421u8g4neldga.apps.googleusercontent.com"
                    : null,
              );

              GoogleSignInAccount? acc;

              try {
                acc = await sign_in.signIn();
              } on Exception catch (e) {
                debugPrint(e.toString());
                return e.toString();
              }

              if (acc == null) return "Failed to login in, restart the app";

              // TODO: REMOVE THE COMMENT LINE
              //if(!RegExp("^[a-zA-Z0-9+_.-]+@drProject_Prismit.ac.in").hasMatch(acc.email)) return "Please use your official college email ID";

              final auth = await acc.authentication;

              final cred = GoogleAuthProvider.credential(
                  accessToken: auth.accessToken, idToken: auth.idToken);

              try {
                final Cred =
                    await FirebaseAuth.instance.signInWithCredential(cred);
                global.account = Cred.user;
              } on FirebaseAuthException catch (e) {
                debugPrint(e.toString());
                return e.toString();
              }

              return validate(2);
            },
          ),
        ]);
  }
}
