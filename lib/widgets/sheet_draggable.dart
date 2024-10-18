import 'package:flutter/material.dart';
import 'package:sheets/recognizers/mouse_action_recognizer.dart';
import 'package:sheets/widgets/sheet_mouse_gesture_detector.dart';

class SheetDraggable extends StatefulWidget {
  final Rect draggableAreaRect;
  final MouseListener mouseListener;
  final CustomDragAction action;
  final Widget child;

  const SheetDraggable({
    required this.draggableAreaRect,
    required this.mouseListener,
    required this.action,
    required this.child,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SheetDraggableState();
}

class _SheetDraggableState extends State<SheetDraggable> {
  late final CustomDragRecognizer recognizer;

  @override
  void initState() {
    super.initState();
    recognizer = CustomDragRecognizer(widget.action);
    recognizer.setDraggableArea(widget.draggableAreaRect);

    widget.mouseListener.insertRecognizer(recognizer);
  }

  @override
  void didUpdateWidget(covariant SheetDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.draggableAreaRect != widget.draggableAreaRect) {
      recognizer.setDraggableArea(widget.draggableAreaRect);
    }
  }

  @override
  void dispose() {
    widget.mouseListener.removeRecognizer(recognizer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
