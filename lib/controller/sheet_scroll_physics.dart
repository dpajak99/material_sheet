import 'package:flutter/cupertino.dart';
import 'package:sheets/controller/sheet_scroll_controller.dart';

extension OffsetExtension on Offset {
  Offset limit(Offset x, Offset y) {
    return Offset(
      dx.clamp(x.dx, x.dy),
      dy.clamp(y.dx, y.dy),
    );
  }

  Offset limitMin(double x, double y) {
    return Offset(
      dx.clamp(x, double.infinity),
      dy.clamp(y, double.infinity),
    );
  }
}

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

class CellScrollPhysics extends SheetScrollPhysics {
  @override
  Offset parseScrolledOffset(Offset currentOffset, Offset delta) {
    double maxHorizontalScrollExtent = _scrollController.metrics.horizontal.maxScrollExtent;
    double maxVerticalScrollExtent = _scrollController.metrics.vertical.maxScrollExtent;

    Offset updatedDelta = Offset(((delta.dx ~/ 22) * 22), ((delta.dy ~/ 22) * 22));

    Offset limitX = Offset(0, maxHorizontalScrollExtent);
    Offset limitY = Offset(0, maxVerticalScrollExtent);

    Offset newOffset = (currentOffset + updatedDelta).limit(limitX, limitY);
    return newOffset;
  }
}
