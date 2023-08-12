import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class notifyUi extends StatelessWidget {
  const notifyUi({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    debugPrint("building notification centre");

    List<Widget> childrens = [];

    if (global.notificationCount == 0) {
      childrens.add(ListTile(
          title: Text("No new notifications!",
              style: TextStyle(
                  color: Theme.of(context).textSelectionTheme.selectionColor,
                  fontSize: 12))));
    } else {
      debugPrint("HOW?");
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        leading: const Icon(
          FontAwesomeIcons.message,
        ),
        backgroundColor: Theme.of(context).focusColor,
        collapsedBackgroundColor: Theme.of(context).focusColor.withOpacity(0.3),
        collapsedTextColor: Theme.of(context).textSelectionTheme.selectionColor,
        collapsedIconColor: Theme.of(context).textSelectionTheme.cursorColor,
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 12),
        ),
        children: childrens,
      ),
    );
  }
}
