import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/gestures/sheet_selection_gesture.dart';
import 'package:sheets/recognizers/mouse_action_recognizer.dart';
import 'package:sheets/selection/selection_state.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/controller/sheet_scroll_controller.dart';
import 'package:sheets/selection/sheet_selection.dart';
import 'package:sheets/viewport/sheet_viewport.dart';
import 'package:sheets/gestures/sheet_resize_gestures.dart';
import 'package:sheets/listeners/keyboard_listener.dart';
import 'package:sheets/widgets/sheet_mouse_gesture_detector.dart';

class SheetController {
  SheetController({
    required this.properties,
  }) {
    scroll = SheetScrollController();
    viewport = SheetViewport(properties, scroll);
    keyboard = SheetKeyboardListener();
    mouse = MouseListener(
      mouseActionRecognizers: <MouseActionRecognizer>[MouseSelectionRecognizer()],
      sheetController: this,
    );
    selection = SelectionState.defaultSelection();

    _setupKeyboardShortcuts();
  }

  final SheetProperties properties;
  late final SheetViewport viewport;
  late final SheetScrollController scroll;
  late final SheetKeyboardListener keyboard;
  late final MouseListener mouse;

  late SelectionState selection;

  void dispose() {
    keyboard.dispose();
  }

  void select(SheetSelection customSelection) {
    selection.update(customSelection);
  }

  void resizeColumnBy(ColumnIndex column, double delta) {
    SheetResizeColumnGesture(column, delta).resolve(this);
  }

  void resizeRowBy(RowIndex row, double delta) {
    SheetResizeRowGesture(row, delta).resolve(this);
  }

  void _setupKeyboardShortcuts() {
    keyboard.onKeysPressed(
      <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyA],
      () => select(SheetSelection.all()),
    );
    // -------------------
    keyboard.onKeyPressed(LogicalKeyboardKey.keyR, () {
      properties.addRows(10);
    });
    keyboard.onKeyPressed(LogicalKeyboardKey.keyC, () {
      properties.addColumns(10);
    });
    // -------------------
    keyboard.onKeyHold(LogicalKeyboardKey.arrowUp, () {
      SheetSelectionMoveGesture(-1, 0).resolve(this);
    });
    keyboard.onKeyHold(LogicalKeyboardKey.arrowDown, () {
      SheetSelectionMoveGesture(1, 0).resolve(this);
    });
    keyboard.onKeyHold(LogicalKeyboardKey.arrowLeft, () {
      SheetSelectionMoveGesture(0, -1).resolve(this);
    });
    keyboard.onKeyHold(LogicalKeyboardKey.arrowRight, () {
      SheetSelectionMoveGesture(0, 1).resolve(this);
    });
  }
}
