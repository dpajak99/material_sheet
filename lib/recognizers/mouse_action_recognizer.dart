import 'dart:ui';

import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/gestures/sheet_fill_gesture.dart';
import 'package:sheets/gestures/sheet_selection_gesture.dart';
import 'package:sheets/viewport/sheet_viewport_content.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/widgets/sheet_mouse_cursor.dart';

abstract class MouseActionRecognizer {
  late SheetMouseCursorState _context;
  late SheetController _sheetController;

  void setContext(SheetMouseCursorState context, SheetController sheetController) {
    _context = context;
    _sheetController = sheetController;
  }

  SheetMouseCursorState get context => _context;

  SheetController get sheetController => _sheetController;
}

class SheetSelectionGestureRecognizer extends MouseActionRecognizer {
  late SheetViewportContent visibleContent;

  SheetSelectionGestureRecognizer() {
    sheetController.viewport.addListener(() {
      refreshHoveredItem();
    });
  }

  @override
  void setContext(SheetMouseCursorState context, SheetController sheetController) {
    super.setContext(context, sheetController);

    visibleContent = sheetController.viewport.visibleContent;
    visibleContent.addListener(() {
      refreshHoveredItem();
    });

    context.offset.stream.listen((Offset offset) {
      refreshHoveredItem();
    });
  }

  ViewportItem? draggedItem;
  ViewportItem? hoveredItem;

  void refreshHoveredItem() {
    hoveredItem = visibleContent.findAnyByOffset(context.offset.value);
  }

  void startSelection() {
    if (hoveredItem == null) return;

    ViewportItem selectionStart = hoveredItem!;
    SheetSelectionStartGesture(selectionStart).resolve(sheetController);

    draggedItem = selectionStart;
  }

  void updateSelection() {
    if (draggedItem == null || hoveredItem == null) return;

    ViewportItem selectionStart = draggedItem!;
    ViewportItem selectionEnd = hoveredItem!;
    SheetSelectionUpdateGesture(selectionStart, selectionEnd).resolve(sheetController);
  }

  void endSelection() {
    draggedItem = null;
    hoveredItem = null;

    SheetDragEndGesture().resolve(sheetController);
  }
}

class SheetFillGestureRecognizer extends SheetSelectionGestureRecognizer {
  @override
  void startSelection() {
    if (hoveredItem == null) return;

    SheetFillStartGesture().resolve(sheetController);
    draggedItem = hoveredItem!;
  }

  @override
  void updateSelection() {
    if (draggedItem == null || hoveredItem == null) return;

    ViewportItem selectionEnd = hoveredItem!;
    SheetFillUpdateGesture(selectionEnd).resolve(sheetController);
  }

  @override
  void endSelection() {
    draggedItem = null;
    hoveredItem = null;

    SheetFillEndGesture().resolve(sheetController);
  }
}
