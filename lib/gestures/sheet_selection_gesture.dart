import 'package:flutter/services.dart';
import 'package:sheets/behaviors/selection_behaviors.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/selection/sheet_selection.dart';
import 'package:sheets/viewport/viewport_item.dart';

class SheetSelectionStartGesture extends SheetGesture {
  final ViewportItem selectionStart;

  SheetSelectionStartGesture(this.selectionStart);

  @override
  void resolve(SheetController controller) {
    SheetIndex? hoveredIndex = selectionStart.index;

    if (controller.keyboard.areKeysPressed(<LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft])) {
      ModifySelectionRangeBehavior(hoveredIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.controlLeft)) {
      AppendSelectionBehavior(hoveredIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      RangeSelectionBehavior(hoveredIndex).invoke(controller);
    } else {
      SingleSelectionBehavior(hoveredIndex).invoke(controller);
    }

    controller.viewport.ensureIndexFullyVisible(hoveredIndex);
  }

  @override
  List<Object?> get props => <Object?>[selectionStart];
}

class SheetSelectionUpdateGesture extends SheetGesture {
  final ViewportItem selectionStart;
  final ViewportItem selectionEnd;

  SheetSelectionUpdateGesture(this.selectionStart, this.selectionEnd);

  @override
  void resolve(SheetController controller) {
    SheetIndex selectionEndIndex = selectionEnd.index;

    SheetSelection selection = controller.selection.value;
    if (selection.selectionStart is CellIndex) {
      if (selectionEndIndex is ColumnIndex) {
        selectionEndIndex = CellIndex(rowIndex: controller.viewport.visibleContent.rows.first.index, columnIndex: selectionEndIndex).move(-1, 0);
      } else if (selectionEndIndex is RowIndex) {
        selectionEndIndex = CellIndex(rowIndex: selectionEndIndex, columnIndex: controller.viewport.visibleContent.columns.first.index).move(0, -1);
      }
    }

    if (controller.keyboard.areKeysPressed(<LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft])) {
      ModifySelectionRangeBehavior(selectionEndIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.controlLeft)) {
      ModifySelectionRangeBehavior(selectionEndIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      ModifySelectionRangeBehavior(selectionEndIndex).invoke(controller);
    } else {
      RangeSelectionBehavior(selectionEndIndex).invoke(controller);
    }

    controller.viewport.ensureIndexFullyVisible(selectionEndIndex);
  }

  @override
  List<Object?> get props => <Object?>[selectionStart, selectionEnd];
}

class SheetSelectionEndGesture extends SheetGesture {
  SheetSelectionEndGesture();

  @override
  void resolve(SheetController controller) {
    controller.selection.complete();
  }

  @override
  List<Object?> get props => <Object?>[];
}

class SheetSelectionMoveGesture extends SheetGesture {
  final int dx;
  final int dy;

  SheetSelectionMoveGesture(this.dx, this.dy);

  @override
  void resolve(SheetController controller) {
    SheetSelection selection = controller.selection.value;

    CellIndex maxIndex = CellIndex.max.toRealIndex(controller.properties);
    CellIndex newIndex;

    if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      newIndex = selection.cellEnd.move(dx, dy).clamp(maxIndex);
      RangeSelectionBehavior(newIndex).invoke(controller);
    } else {
      newIndex = selection.mainCell.move(dx, dy).clamp(maxIndex);
      SingleSelectionBehavior(newIndex).invoke(controller);
    }

    controller.viewport.ensureIndexFullyVisible(newIndex);
    controller.selection.complete();
  }

  @override
  List<Object?> get props => <Object?>[dx, dy];
}
