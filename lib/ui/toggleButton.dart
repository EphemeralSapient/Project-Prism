// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class toggle extends StatefulWidget {
  late Function? callback;
  late IconData? icon;
  late Color? color;
  late String? text;
  late bool? enable;

  late String? activeString, inactiveString;

  toggle(
      {Key? key,
      required this.callback,
      this.icon,
      this.color,
      this.text,
      this.enable,
      this.activeString,
      this.inactiveString})
      : super(key: key);

  @override
  State<toggle> createState() => _toggleState(
      callback: callback,
      icon: icon,
      color: color,
      text: text,
      enable: enable,
      activeString: activeString,
      inactiveString: inactiveString);
}

class _toggleState extends State<toggle> {
  late Function? callback;
  late IconData? icon;
  late Color? color;
  late String? text;
  late bool? enable;

  late String? activeString, inactiveString;

  _toggleState(
      {Key? key,
      required this.callback,
      this.icon,
      this.color,
      this.text,
      this.enable,
      this.activeString,
      this.inactiveString});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 75,
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(widget.icon,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                const SizedBox(
                  height: 10,
                  width: 25,
                ),
                Expanded(
                    child: Text(
                  text ?? "Label Text",
                  style: TextStyle(
                      color: Theme.of(context)
                          .textSelectionTheme
                          .selectionHandleColor,
                      fontFamily: "Montserrat",
                      fontSize: 12),
                )),
                FlutterSwitch(
                  value: enable ?? false,
                  activeText: activeString ?? "On",
                  inactiveText: inactiveString ?? "Off",
                  width: 60,
                  height: 35,
                  valueFontSize: 10,
                  toggleSize: 18,
                  showOnOff: true,
                  padding: 10,
                  onToggle: (val) {
                    bool ok = callback!(val);
                    setState(() {
                      enable = ok;
                    });
                  },
                )
              ],
            )));
  }
}

class toggleButton extends StatefulWidget {
  late Function callback;
  late IconData icon;
  late Color color;
  late String text;
  late bool enable;

  late String? activeString, inactiveString;

  toggleButton(this.callback, this.text, this.icon, this.color, this.enable,
      {Key? key, this.activeString, this.inactiveString})
      : super(key: key);

  @override
  State<toggleButton> createState() => _toggleButtonState(enable,
      activeString: activeString, inactiveString: inactiveString);
}

class _toggleButtonState extends State<toggleButton> {
  late bool status;
  final String? activeString, inactiveString;

  _toggleButtonState(this.status, {this.activeString, this.inactiveString})
      : super();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return SizedBox(
        width: double.infinity,
        height: 75,
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(widget.icon,
                    color: Theme.of(context).textSelectionTheme.selectionColor),
                const SizedBox(
                  height: 10,
                  width: 25,
                ),
                Expanded(
                    child: Text(
                  widget.text,
                  style: TextStyle(
                      color: Theme.of(context)
                          .textSelectionTheme
                          .selectionHandleColor,
                      fontFamily: "Montserrat",
                      fontSize: 12),
                )),
                FlutterSwitch(
                  value: status,
                  activeText: activeString ?? "On",
                  width: 60,
                  height: 35,
                  valueFontSize: 10,
                  toggleSize: 18,
                  inactiveText: inactiveString ?? "Off",
                  showOnOff: true,
                  padding: 10,
                  onToggle: (val) {
                    setState(() {
                      status = widget.callback(val);
                    });
                  },
                )
              ],
            )));
  }
}
