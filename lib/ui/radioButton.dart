import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;

class GreenRadio extends StatefulWidget {
  final String initalValue;
  final List<String> stringList; // List of strings as parameter
  final Function(String) callback; // Function callback as parameter

  GreenRadio(
      {super.key,
      required this.stringList,
      required this.callback,
      required this.initalValue});

  @override
  _GreenRadioState createState() => _GreenRadioState();
}

class _GreenRadioState extends State<GreenRadio> {
  int _selectedValue = 0;

  @override
  void initState() {
    _selectedValue = widget.stringList.indexOf(widget.initalValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (String x in widget.stringList)
          RadioListTile<int>(
              value: widget.stringList.indexOf(x),
              title: global.textWidgetWithHeavyFont(x),
              groupValue: _selectedValue,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value ?? 0;
                  debugPrint(_selectedValue.toString());
                  widget.callback(widget.stringList[_selectedValue]);
                });
              }),
      ],
    );
  }
}
