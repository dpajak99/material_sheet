import 'package:flutter/material.dart';
import 'package:sheets/core/scroll/sheet_scroll_controller.dart';
import 'package:sheets/utils/extensions/offset_extensions.dart';

abstract class SheetScrollPhysics {
  late final SheetScrollController _scrollController;

  void applyTo(SheetScrollController scrollController) {
    _scrollController = scrollController;
  }

  Offset parseScrolledOffset(Offset currentOffset, Offset delta);
}

class SmoothScrollPhysics extends SheetScrollPhysics {
  @override
  Offset parseScrolledOffset(Offset currentOffset, Offset delta) {
    double maxHorizontalScrollExtent = _scrollController.metrics.horizontal.maxScrollExtent;
    double maxVerticalScrollExtent = _scrollController.metrics.vertical.maxScrollExtent;

    Offset limitX = Offset(0, maxHorizontalScrollExtent);
    Offset limitY = Offset(0, maxVerticalScrollExtent);

    Offset newOffset = (currentOffset + delta).limit(limitX, limitY);
    return newOffset;
  }
}
