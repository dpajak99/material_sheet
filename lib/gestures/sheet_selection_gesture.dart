import 'package:flutter/services.dart';
import 'package:sheets/behaviors/selection_behaviors.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/selection/sheet_selection.dart';

class SheetSelectionStartGesture extends SheetDragGesture {
  final SheetDragDetails startDetails;

  SheetSelectionStartGesture(this.startDetails);

  factory SheetSelectionStartGesture.from(SheetDragStartGesture dragGesture) {
    return SheetSelectionStartGesture(dragGesture.startDetails);
  }

  @override
  void resolve(SheetController controller) {
    SheetIndex? hoveredIndex = startDetails.hoveredItem?.index;
    if (hoveredIndex == null) return;


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
}

class SheetSelectionUpdateGesture extends SheetDragUpdateGesture {
  SheetSelectionUpdateGesture(super.endDetails, {required super.startDetails});

  factory SheetSelectionUpdateGesture.from(SheetDragUpdateGesture dragGesture) {
    return SheetSelectionUpdateGesture(dragGesture.endDetails, startDetails: dragGesture.startDetails);
  }

  @override
  List<Object?> get props => <Object?>[endDetails, startDetails];

  @override
  void resolve(SheetController controller) {
    SheetIndex? hoveredIndex = endDetails.hoveredItem?.index;
    if (hoveredIndex == null) return;

    if (controller.keyboard.areKeysPressed(<LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft])) {
      ModifySelectionRangeBehavior(hoveredIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.controlLeft)) {
      ModifySelectionRangeBehavior(hoveredIndex).invoke(controller);
    } else if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      ModifySelectionRangeBehavior(hoveredIndex).invoke(controller);
    } else {
      RangeSelectionBehavior(hoveredIndex).invoke(controller);
    }

    controller.viewport.ensureIndexFullyVisible(hoveredIndex);
  }
}

class SheetSelectionEndGesture extends SheetDragGesture {
  SheetSelectionEndGesture();

  @override
  void resolve(SheetController controller) {
    controller.selection.complete();
  }

  @override
  List<Object?> get props => <Object?>[];
}

class SheetSelectionMoveGesture extends SheetDragGesture {
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
