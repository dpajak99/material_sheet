import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/viewport/viewport_offset_transformer.dart';
import 'package:sheets/viewport/viewport_rect_transformer.dart';

class SheetViewportRect with EquatableMixin {
  late Rect global;
  late Rect local;

  SheetViewportRect(this.global) {
    _updateLocalRect();
  }

  double get width => global.width;

  double get height => global.height;

  Size get size => global.size;

  Rect get innerRectLocal {
    return Rect.fromLTRB(
      0,
      0,
      width - rowHeadersWidth,
      height - columnHeadersHeight,
    );
  }

  /// Converts the given [globalOffset], which is relative to the entire sheet,
  /// to a local offset relative to the visible grid within the viewport.
  Offset globalOffsetToLocal(Offset globalOffset) {
    ViewportOffsetTransformer transformer = ViewportOffsetTransformer(global);
    return transformer.globalToLocal(globalOffset);
  }
  
  Rect globalRectToLocal(Rect rect) {
    ViewportRectTransformer transformer = ViewportRectTransformer(global);
    return transformer.globalToLocal(rect);
  }

  void _updateLocalRect() {
    local = Rect.fromLTWH(0, 0, global.width, global.height);
  }

  bool isEquivalent(Rect rect) {
    return global == rect;
  }

  @override
  List<Object?> get props => <Object?>[global];
}