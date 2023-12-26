import 'package:Project_Prism/global.dart' as global;
import 'package:flutter/material.dart';

class assignmentUi extends StatelessWidget {
  const assignmentUi({super.key});

  @override
  Widget build(context) {
    List<Widget> childrens = [];

    if (global.assignmentCount == 0) {
      childrens.add(SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 107,
        child: Center(
          child: Text(
            "No pending assignments!",
            style: TextStyle(
                color: Theme.of(context).textSelectionTheme.selectionColor,
                fontSize: 10),
          ),
        ),
      ));
    } else {
      debugPrint("HOW??");
    }

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                debugPrint("Routing to assignment page");
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).focusColor,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent),
              child: Row(children: [
                Text(
                  "ASSIGNMENTS ",
                  style: TextStyle(
                      color:
                          Theme.of(context).textSelectionTheme.selectionColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      fontFamily: "Montserrat",
                      fontSize: 12),
                ),
                Icon(Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context).textSelectionTheme.cursorColor,
                    size: 12)
              ])),
          const SizedBox(
            height: 5,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              //padding: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: childrens,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
