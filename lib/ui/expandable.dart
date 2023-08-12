import 'package:flutter/material.dart';

class CustomExpansionWidget extends StatefulWidget {
  final String header;
  final Widget body;
  final double? maxWidth;
  final bool? expandWidth;

  CustomExpansionWidget(
      {required this.header,
      required this.body,
      this.maxWidth,
      this.expandWidth});

  @override
  _CustomExpansionWidgetState createState() => _CustomExpansionWidgetState();
}

class _CustomExpansionWidgetState extends State<CustomExpansionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10.0), // Adjust border radius as needed
              ),
              shadowColor: Colors.transparent,
              backgroundColor: Theme.of(context).focusColor,
              surfaceTintColor: Colors.transparent),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: widget.expandWidth ?? true
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.header,
                  style: TextStyle(
                      color:
                          Theme.of(context).textSelectionTheme.selectionColor,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color:
                    Theme.of(context).textSelectionTheme.selectionHandleColor,
              ),
            ],
          ),
        ),
        AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          height: _isExpanded ? null : 0,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).focusColor,
          ),
          child: widget.body,
        ),
      ],
    );
  }
}
