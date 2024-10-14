import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/core/sheet_viewport.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/gestures/sheet_fill_gesture.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/gestures/sheet_scroll_gesture.dart';
import 'package:sheets/core/sheet_item_config.dart';

class SheetMouseListener {
  final SheetViewport viewport;

  SheetMouseListener(this.viewport);

  final StreamController<SheetGesture> _gesturesStream = StreamController<SheetGesture>();

  Stream<SheetGesture> get stream => _gesturesStream.stream;

  final ValueNotifier<Offset> localPosition = ValueNotifier(Offset.zero);
  final ValueNotifier<Offset> globalPosition = ValueNotifier(Offset.zero);
  final ValueNotifier<SheetItemConfig?> hoveredItem = ValueNotifier(null);
  final ValueNotifier<SystemMouseCursor> cursor = ValueNotifier(SystemMouseCursors.basic);

  bool _enabled = true;

  void disable() => _enabled = false;

  void enable() => _enabled = true;

  bool get enabled => _enabled;
  bool get disabled => !_enabled;

  bool nativeDragging = false;
  bool customTapHovered = false;

  void dispose() {
    _gesturesStream.close();
  }

  void setGlobalOffset(Offset globalOffset) {
    Offset localOffset = viewport.globalOffsetToLocal(globalOffset);

    localPosition.value = localOffset;
    globalPosition.value = globalOffset;

    refreshHoveredItem();
    
    Offset mouseOutOffset = this.mouseOutOffset;

    if (mouseOutOffset != Offset.zero) {
      _addGesture(SheetMouseBoundsScrollGesture(mouseOutOffset), force: true);
    }
  }

  void refreshHoveredItem() {
    hoveredItem.value = viewport.findByOffset(localPosition.value);
  }

  Offset get mouseOutOffset {
    double globalY = globalPosition.value.dy;
    double globalX = globalPosition.value.dx;

    double viewportTop = viewport.sheetRect.top;
    double viewportBottom = viewport.sheetRect.bottom;
    double viewportLeft = viewport.sheetRect.left;
    double viewportRight = viewport.sheetRect.right;

    double outX = 0;
    double outY = 0;

    if (globalY < viewportTop) {
      outY = globalY - viewportTop;
    } else if (globalY > viewportBottom) {
      outY = globalY - viewportBottom;
    }

    if (globalX < viewportLeft) {
      outX = globalX - viewportLeft;
    } else if (globalX > viewportRight) {
      outX = globalX - viewportRight;
    }

    return Offset(outX, outY);
  }

  void setCursor(SystemMouseCursor systemMouseCursor) {
    cursor.value = systemMouseCursor;
  }

  void resetCursor() {
    print('reset cursor');
    cursor.value = SystemMouseCursors.basic;
  }

  SheetDragDetails? _activeStartDragDetails;

  void dragStart(SheetItemConfig draggedItem) {
    nativeDragging = true;
    _activeStartDragDetails = SheetDragDetails.create(globalPosition.value, draggedItem);
    _addGesture(SheetDragStartGesture(_activeStartDragDetails!));
  }

  void dragUpdate() {
    if (nativeDragging && _activeStartDragDetails != null) {
      _addGesture(SheetDragUpdateGesture(
        SheetDragDetails.create(globalPosition.value, hoveredItem.value),
        startDetails: _activeStartDragDetails!,
      ));
    }
  }

  void dragEnd() {
    nativeDragging = false;
    _activeStartDragDetails = null;

    _addGesture(SheetDragEndGesture());
  }

  void fillStart() {
    SheetFillStartGesture fillStartGesture = SheetFillStartGesture();
    _addGesture(fillStartGesture, force: true);
  }

  void fillUpdate() {
    SheetGesture fillUpdateGesture = SheetFillUpdateGesture(endDetails: SheetDragDetails.create(globalPosition.value, hoveredItem.value));
    _addGesture(fillUpdateGesture, force: true);
  }

  void fillEnd() {
    SheetFillEndGesture fillEndGesture = SheetFillEndGesture();
    _addGesture(fillEndGesture, force: true);
  }

  void scroll(Offset delta) {
    _addGesture(SheetScrollGesture(delta), force: true);
  }

  void _addGesture(SheetGesture gesture, {bool force = false}) {
    if (_enabled == false && force == false) return;
    _gesturesStream.add(gesture);
  }
}
