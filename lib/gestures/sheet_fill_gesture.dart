import 'package:sheets/behaviors/selection_behaviors.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/viewport/viewport_item.dart';

abstract class SheetFillGesture extends SheetGesture {}

class SheetFillStartGesture extends SheetFillGesture {
  @override
  void resolve(SheetController controller) {}

  @override
  List<Object?> get props => <Object?>[];
}

class SheetFillUpdateGesture extends SheetFillGesture {
  final ViewportItem selectionEnd;

  SheetFillUpdateGesture(this.selectionEnd);

  @override
  void resolve(SheetController controller) {
    FillSelectionBehavior(selectionEnd.index).invoke(controller);
  }

  @override
  List<Object?> get props => <Object?>[selectionEnd];
}

class SheetFillEndGesture extends SheetFillGesture {
  @override
  void resolve(SheetController controller) {
    controller.selection.complete();
  }

  @override
  List<Object?> get props => <Object?>[];
}
