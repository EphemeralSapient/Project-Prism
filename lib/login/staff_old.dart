import 'package:flutter/material.dart';

// ignore: camel_case_types
class staffLogin extends StatefulWidget {
  const staffLogin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StaffLoginImpl();
  }
}

class StaffLoginImpl extends State<staffLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  InputDecoration dec(IconData? icon, String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
      prefixIconColor: Colors.red,
      prefixStyle: const TextStyle(color: Colors.deepPurpleAccent),
      hintText: hint,
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
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    pinController.dispose();
  }

  @override
  void initState() {
    super.initState();
    //emailController.text = "@drProject_Prismit.ac.in";
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            //const SizedBox(height: 75),

            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, -100, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'asset/images/empty_room.png',
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            //const SizedBox(height: 40,),

            Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context)
                            .textSelectionTheme
                            .selectionHandleColor,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        // reg expression for email validation
                        if (value != null &&
                            !RegExp("^[a-zA-Z0-9+_.-]+@drProject_Prismit.ac.in")
                                .hasMatch(value)) {
                          return ("Please Enter a valid gmail suffix to @drProject_Prismit.ac.in");
                        }
                        return null;
                      },
                      decoration: dec(Icons.email_rounded, "Email ID"),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        if (value != null) {
                          emailController.text = value;
                        }
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.deepPurpleAccent,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Password is required.");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password (Min. 6 Character)");
                        }
                        return null;
                      },
                      decoration: dec(Icons.password_rounded, "Password"),
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      onSaved: (value) {
                        if (value != null) {
                          passwordController.text = value;
                        }
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.deepPurpleAccent,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        RegExp regex = RegExp(r'^-?[0-9]+$');
                        if (value!.isEmpty) {
                          return ("PIN is required.");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Enter PIN.");
                        }
                        int length = value.length; // 7
                        if (length != 5) {
                          return ("PIN length is not valid.");
                        }
                        return null;
                      },
                      decoration: dec(Icons.pin, "PIN Code"),
                      controller: pinController,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) {
                        if (value != null) {
                          pinController.text = value;
                        }
                      },
                      textInputAction: TextInputAction.done,
                    )
                  ],
                ))
          ],
        ));
  }
}
