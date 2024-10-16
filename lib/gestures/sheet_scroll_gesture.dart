import 'dart:math';

import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/utils/extensions/offset_extensions.dart';

class SheetScrollGesture extends SheetGesture {
  final Offset delta;

  SheetScrollGesture(this.delta);

  @override
  void resolve(SheetController controller) {
    if (controller.keyboard.isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      controller.scroll.scrollBy(delta.reverse());
    } else {
      controller.scroll.scrollBy(delta);
    }
  }

  @override
  List<Object?> get props => <Object?>[delta];
}

class SheetMouseBoundsScrollGesture extends SheetGesture {
  final Offset delta;

  SheetMouseBoundsScrollGesture(this.delta);

  @override
  void resolve(SheetController controller) {
    // if(delta.dx != 0) {
    //   int multiplier = delta.dx > 0 ? 1 : -1;
    //   controller.scroll.scrollBy(Offset(defaultColumnWidth * multiplier, 0));
    // } else {
    //   int multiplier = delta.dy > 0 ? 1 : -1;
    //   controller.scroll.scrollBy(Offset(0, defaultRowHeight * multiplier));
    // }
  }

  @override
  Duration get lockdownDuration {
    if(delta.dx != 0) {
      return Duration(milliseconds: max(50, 200 - delta.dx.abs().toInt()));
    } else {
      return Duration(milliseconds: max(10, 200 - delta.dy.abs().toInt()));
    }
  }

  @override
  List<Object?> get props => <Object?>[delta];
}