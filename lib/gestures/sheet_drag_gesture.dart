import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/viewport/viewport_item.dart';

abstract class SheetMouseGesture extends SheetGesture {
  Offset get startOffset;
  Offset get currentOffset;

  @override
  List<Object?> get props => <Object?>[];
}

class SheetMouseMoveGesture extends SheetMouseGesture {
  final Offset localOffset;

  SheetMouseMoveGesture(this.localOffset);

  @override
  void resolve(SheetController controller) {}

  @override
  Offset get startOffset => localOffset;

  @override
  Offset get currentOffset => localOffset;
}

class SheetDragStartGesture extends SheetMouseGesture {
  final MouseCursorDetails startDetails;

  SheetDragStartGesture(this.startDetails);

  @override
  void resolve(SheetController controller) {}

  @override
  Offset get startOffset => startDetails.localOffset;

  @override
  Offset get currentOffset => startDetails.localOffset;

  @override
  List<Object?> get props => <Object?>[startDetails];
}

class SheetDragUpdateGesture extends SheetMouseGesture {
  final MouseCursorDetails startDetails;
  final MouseCursorDetails updateDetails;

  SheetDragUpdateGesture({ required this.startDetails, required this.updateDetails});

  @override
  void resolve(SheetController controller) {}

  @override
  Offset get startOffset => startDetails.localOffset;

  @override
  Offset get currentOffset => updateDetails.localOffset;

  @override
  List<Object?> get props => <Object?>[updateDetails, startDetails];
}

class SheetDragEndGesture extends SheetMouseGesture {
  final MouseCursorDetails startDetails;
  final MouseCursorDetails endDetails;
  
  SheetDragEndGesture({ required this.startDetails, required this.endDetails});
  
  @override
  void resolve(SheetController controller) {}

  @override
  Offset get startOffset => startDetails.localOffset;

  @override
  Offset get currentOffset => endDetails.localOffset;

  @override
  List<Object?> get props => <Object?>[];
}

class MouseCursorDetails with EquatableMixin {
  final Offset localOffset;
  final Offset scrollPosition;
  final ViewportItem? hoveredItem;

  MouseCursorDetails({
    required this.localOffset,
    required this.scrollPosition,
    required this.hoveredItem,
  });

  @override
  List<Object?> get props => <Object?>[localOffset, scrollPosition, hoveredItem];
}
