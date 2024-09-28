import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/program_config.dart';
import 'package:sheets/controller/selection/gestures/sheet_drag_gesture.dart';
import 'package:sheets/controller/selection/gestures/sheet_gesture.dart';
import 'package:sheets/controller/selection/gestures/sheet_scroll_gesture.dart';
import 'package:sheets/controller/selection/gestures/sheet_tap_gesture.dart';
import 'package:sheets/controller/selection/recognizers/sheet_tap_recognizer.dart';

class SheetCursorController {
  final StreamController<SheetGesture> _gesturesStream = StreamController<SheetGesture>();

  Stream<SheetGesture> get stream => _gesturesStream.stream;

  final ValueNotifier<Offset> mousePosition = ValueNotifier(Offset.zero);
  final ValueNotifier<SheetItemConfig?> hoveredItem = ValueNotifier(null);
  final ValueNotifier<SystemMouseCursor> cursor = ValueNotifier(SystemMouseCursors.basic);

  final SheetTapRecognizer tapRecognizer = SheetTapRecognizer();

  bool _enabled = true;

  void disable() => _enabled = false;

  void enable() => _enabled = true;

  bool get enabled => _enabled;

  bool nativeDragging = false;
  SheetItemConfig? _dragStartElement;

  void updateOffset(Offset offset, SheetItemConfig? element) {
    mousePosition.value = offset;
    hoveredItem.value = element;
  }

  void setCursor(SystemMouseCursor cursor) {
    this.cursor.value = cursor;
  }

  void tap() {
    SheetGesture tapGesture = tapRecognizer.onTap(SheetTapDetails.create(mousePosition.value, hoveredItem.value));
    _addGesture(tapGesture);
  }

  SheetDragDetails? _activeStartDragDetails;

  void dragStart() {
    nativeDragging = true;
    _dragStartElement = hoveredItem.value;
    SheetDragDetails sheetDragDetails = SheetDragDetails.create(mousePosition.value, hoveredItem.value);
    _activeStartDragDetails = sheetDragDetails;
    _addGesture(SheetDragStartGesture(sheetDragDetails));
  }

  void dragUpdate() {
    if (_activeStartDragDetails == null) return;
    if (_dragStartElement == hoveredItem.value) return;

    SheetGesture dragUpdateGesture = SheetDragUpdateGesture(
      SheetDragDetails.create(mousePosition.value, hoveredItem.value),
      startDetails: _activeStartDragDetails!,
    );
    _addGesture(dragUpdateGesture);
  }

  void fillUpdate() {
    SheetGesture fillUpdateGesture = SheetFillUpdateGesture(SheetDragDetails.create(mousePosition.value, hoveredItem.value));
    _gesturesStream.add(fillUpdateGesture);
  }

  void dragEnd() {
    nativeDragging = false;
    if (_activeStartDragDetails == null) return;

    SheetGesture dragEndGesture = SheetDragEndGesture(
      SheetDragDetails.create(mousePosition.value, hoveredItem.value),
      startDetails: _activeStartDragDetails!,
    );
    _addGesture(dragEndGesture);
  }

  void scroll(Offset delta) {
    _addGesture(SheetScrollGesture(delta));
  }

  void _addGesture(SheetGesture gesture) {
    if (!_enabled) return;
    _gesturesStream.add(gesture);
  }

// void dragStart(DragStartDetails details, {Offset subtract = Offset.zero}) {
//   // print('Drag start');
//   // position = details.globalPosition;
//   // SheetItemConfig? dragHoveredElement = sheetController.getHoveredElement(position - subtract);
//   // hoveredElement = dragHoveredElement;
//   // if (isResizing) {
//   // } else if (dragHoveredElement != null) {
//   //   if (sheetController.cursorController.isFilling) {
//   //     selectionDragRecognizer = SelectionFillRecognizer(sheetController, dragHoveredElement);
//   //   } else {
//   //     selectionDragRecognizer = SelectionDragRecognizer(sheetController, dragHoveredElement);
//   //   }
//   // }
//   //
//   // notifyListeners();
// }
//
// void dragUpdate(DragUpdateDetails details, {Offset subtract = Offset.zero}) {
//   // position = details.globalPosition;
//   // SheetItemConfig? dragHoveredElement = sheetController.getHoveredElement(position - subtract);
//   // hoveredElement = dragHoveredElement;
//   //
//   // if (isResizing) {
//   // } else if (dragHoveredElement != null) {
//   //   selectionDragRecognizer?.handle(dragHoveredElement);
//   // }
//   //
//   // notifyListeners();
// }
//
// void dragEnd(DragEndDetails details) {
//   position = details.globalPosition;
//
//   if (isResizing) {
//   } else {
//     selectionDragRecognizer?.complete();
//     selectionDragRecognizer = null;
//   }
//   notifyListeners();
// }
}
