import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:Project_Prism/global.dart' as global;

class StatefulDragArea extends StatefulWidget {
  final Widget child;
  final Function callback;

  const StatefulDragArea(
      {Key? key, required this.child, required this.callback})
      : super(key: key);

  @override
  _DragAreaStateStateful createState() => _DragAreaStateStateful();
}

class _DragAreaStateStateful extends State<StatefulDragArea> {
  Offset position = Offset(0, 0);
  double prevScale = 1;
  double scale = 1;

  void updateScale(double zoom) => setState(() => scale = prevScale * zoom);
  void commitScale() => setState(() => prevScale = scale);
  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) => updateScale(details.scale),
      onScaleEnd: (_) => commitScale(),
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              maxSimultaneousDrags: 1,
              feedback: widget.child,
              childWhenDragging: Opacity(
                opacity: .3,
                child: widget.child,
              ),
              onDragEnd: (details) {
                updatePosition(details.offset);
                global.dragUiPosition = details.offset;
                widget.callback();
              },
              child: Transform.scale(
                scale: scale,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
