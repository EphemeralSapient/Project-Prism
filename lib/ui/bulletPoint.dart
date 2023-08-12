import 'package:flutter/material.dart';

class BulletPoints extends StatelessWidget {
  BulletPoints(this.texts, this.textStyle);
  final List<String> texts;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(BulletPointsItem(text, textStyle));
      // Add space between items
      widgetList.add(SizedBox(height: 5.0));
    }

    return Column(children: widgetList);
  }
}

class BulletPointsItem extends StatelessWidget {
  BulletPointsItem(this.text, this.textStyle);
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "• ",
          style: TextStyle(
              color: Theme.of(context).textSelectionTheme.selectionColor),
        ),
        Expanded(
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
