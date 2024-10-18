import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/gestures/sheet_fill_gesture.dart';
import 'package:sheets/gestures/sheet_selection_gesture.dart';
import 'package:sheets/viewport/viewport_item.dart';

abstract class MouseActionRecognizer {
  MouseAction? recognize(SheetController controller, SheetMouseGesture gesture);
}

class MouseSelectionRecognizer extends MouseActionRecognizer {
  @override
  MouseAction? recognize(SheetController controller, SheetMouseGesture gesture) => MouseSelectionAction();
}

class CustomDragRecognizer extends MouseActionRecognizer {
  final CustomDragAction action;
  Rect draggableArea = Rect.zero;
  bool _previousHovered = false;

  CustomDragRecognizer(this.action);

  @override
  MouseAction? recognize(SheetController controller, SheetMouseGesture gesture) {
    bool currentHovered = draggableArea.contains(gesture.currentOffset);
    _setHovered(controller, currentHovered);

    if (currentHovered) {
      return action;
    } else {
      return null;
    }
  }

  void setDraggableArea(Rect area) {
    draggableArea = area;
  }

  void _setHovered(SheetController controller, bool currentHovered) {
    if (_previousHovered == false && currentHovered) {
      controller.mouse.setCursor(action.hoverCursor);
    } else if (_previousHovered && currentHovered == false) {
      controller.mouse.resetCursor();
    }
    _previousHovered = currentHovered;
  }
}

abstract class CustomDragAction extends MouseAction {
  bool _active = false;
  
  SystemMouseCursor get hoverCursor;
  
  bool get isActive => _active;
  
  void setActive(bool active) {
    _active = active;
  }
}

abstract class MouseAction {
  void resolve(SheetController controller, SheetMouseGesture gesture);
}

class MouseSelectionAction extends MouseAction {
  @override
  void resolve(SheetController controller, SheetMouseGesture gesture) {
    return switch (gesture) {
      SheetDragStartGesture gesture => _startSelection(controller, gesture),
      SheetDragUpdateGesture gesture => _updateSelection(controller, gesture),
      SheetDragEndGesture gesture => _endSelection(controller, gesture),
      _ => null,
    };
  }

  void _startSelection(SheetController controller, SheetDragStartGesture gesture) {
    print('Selection start');
    ViewportItem? selectionStart = gesture.startDetails.hoveredItem;
    if (selectionStart == null) return;

    SheetSelectionStartGesture(selectionStart).resolve(controller);
  }

  void _updateSelection(SheetController controller, SheetDragUpdateGesture gesture) {
    print('Selection update');
    ViewportItem? selectionStart = gesture.startDetails.hoveredItem;
    ViewportItem? selectionUpdate = gesture.updateDetails.hoveredItem;
    if (selectionStart == null || selectionUpdate == null) return;

    SheetSelectionUpdateGesture(selectionStart, selectionUpdate).resolve(controller);
  }

  void _endSelection(SheetController controller, SheetDragEndGesture gesture) {
    print('Selection end');
    SheetSelectionEndGesture().resolve(controller);
  }
}

class MouseFillAction extends CustomDragAction {
  @override
  SystemMouseCursor get hoverCursor => SystemMouseCursors.precise;

  @override
  void resolve(SheetController controller, SheetMouseGesture gesture) {
    return switch (gesture) {
      SheetDragStartGesture gesture => _startFill(controller, gesture),
      SheetDragUpdateGesture gesture => _updateFill(controller, gesture),
      SheetDragEndGesture gesture => _endFill(controller, gesture),
      _ => null,
    };
  }

  void _startFill(SheetController controller, SheetDragStartGesture gesture) {
    setActive(true);
    print('Fill start');
    ViewportItem? selectionStart = gesture.startDetails.hoveredItem;
    if (selectionStart == null) return;

    SheetFillStartGesture().resolve(controller);
    controller.mouse.setCursor(SystemMouseCursors.precise);
  }

  void _updateFill(SheetController controller, SheetDragUpdateGesture gesture) {
    print('Fill update');
    ViewportItem? selectionStart = gesture.startDetails.hoveredItem;
    ViewportItem? selectionUpdate = gesture.updateDetails.hoveredItem;
    if (selectionStart == null || selectionUpdate == null) return;

    SheetFillUpdateGesture(selectionStart, selectionUpdate).resolve(controller);
  }

  void _endFill(SheetController controller, SheetDragEndGesture gesture) {
    setActive(false);
    print('Fill end');
    SheetFillEndGesture().resolve(controller);
    controller.mouse.resetCursor();
  }
}
