import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/controller/sheet_selection_controller.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/gestures/sheet_gesture.dart';
import 'package:sheets/core/sheet_item_config.dart';

class SheetTapGesture extends SheetGesture {
  final SheetTapDetails details;

  SheetTapGesture(this.details);

  @override
  void resolve(SheetController controller) {}

  @override
  List<Object?> get props => [details];
}

class SheetDoubleTapGesture extends SheetGesture {
  final SheetTapDetails details;

  SheetDoubleTapGesture(this.details);

  @override
  void resolve(SheetController controller) {}

  SheetTapGesture get single => SheetTapGesture(details);

  @override
  List<Object?> get props => [details];
}

class SheetTapDetails with EquatableMixin {
  final DateTime tapTime;
  final Offset mousePosition;
  final SheetItemConfig? hoveredItem;

  SheetTapDetails({
    required this.tapTime,
    required this.mousePosition,
    required this.hoveredItem,
  });

  SheetTapDetails.create(Offset mousePosition, [SheetItemConfig? hoveredItem])
      : this(
          tapTime: DateTime.now(),
          mousePosition: mousePosition,
          hoveredItem: hoveredItem,
        );

  bool isDoubleTap(SheetTapDetails other) {
    return tapTime.difference(other.tapTime) < const Duration(milliseconds: 300) && hoveredItem == other.hoveredItem;
  }

  @override
  List<Object?> get props => [tapTime, mousePosition, hoveredItem];
}
