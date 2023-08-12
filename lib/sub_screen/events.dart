import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;

class eventsUi extends StatelessWidget {
  @override
  Widget build(context) {
    List<Widget> childrens = [];

    if (global.eventsCount == 0) {
      childrens.add(SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 107,
        child: Center(
          child: Text(
            "Currently, there are no announcements. ",
            style: TextStyle(
                color: Theme.of(context).textSelectionTheme.selectionColor,
                fontSize: 11),
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
                debugPrint("Routing to Events page");
              },
              style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  primary: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  onPrimary: Theme.of(context).focusColor),
              child: Row(children: [
                Text(
                  "ANNOUNCEMENT ",
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
          SizedBox(
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
                padding: EdgeInsets.all(10),
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
