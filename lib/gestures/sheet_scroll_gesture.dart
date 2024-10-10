import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/utils/extensions/offset_extensions.dart';

class SheetScrollGesture extends SheetGesture {
  final Offset delta;

  SheetScrollGesture(this.delta);

  @override
  void resolve(SheetController controller) {
    if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      controller.scrollController.scrollBy(delta.reverse());
    } else {
      controller.scrollController.scrollBy(delta);
    }
  }

  @override
  List<Object?> get props => [delta];
}
