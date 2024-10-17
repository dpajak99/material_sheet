import 'package:flutter/cupertino.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/scroll/sheet_scroll_physics.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/core/scroll/sheet_axis_direction.dart';
import 'package:sheets/core/scroll/sheet_scroll_metrics.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';

class SheetScrollController extends ChangeNotifier {
  SheetScrollController({
    SheetScrollPhysics? physics,
  }) {
    position = DirectionalValues<SheetScrollPosition>(
      SheetScrollPosition(),
      SheetScrollPosition(),
    );

    metrics = DirectionalValues<SheetScrollMetrics>(
      SheetScrollMetrics.zero(SheetAxisDirection.vertical),
      SheetScrollMetrics.zero(SheetAxisDirection.horizontal),
    );

    _physics = (physics ?? SmoothScrollPhysics())..applyTo(this);

    position.addListener(notifyListeners);
    metrics.addListener(notifyListeners);
  }

  late final SheetScrollPhysics _physics;
  late final DirectionalValues<SheetScrollPosition> position;
  late final DirectionalValues<SheetScrollMetrics> metrics;

  @override
  void dispose() {
    metrics.dispose();
    position.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void applyProperties(SheetProperties properties) {
    double contentHeight = 0;
    for (int i = 0; i < properties.rowCount; i++) {
      double rowHeight = properties.customRowExtents[i] ?? defaultRowHeight;
      contentHeight += rowHeight;
    }

    double contentWidth = 0;
    for (int i = 0; i < properties.columnCount; i++) {
      double columnWidth = properties.customColumnExtents[i] ?? defaultColumnWidth;
      contentWidth += columnWidth;
    }

    metrics.update(
      horizontal: metrics.horizontal.copyWith(contentSize: contentWidth),
      vertical: metrics.vertical.copyWith(contentSize: contentHeight),
    );
  }

  void scrollBy(Offset delta) {
    Offset currentOffset = Offset(position.horizontal.offset, position.vertical.offset);
    Offset newOffset = _physics.parseScrolledOffset(currentOffset, delta);

    position.horizontal.offset = newOffset.dx;
    position.vertical.offset = newOffset.dy;
  }

  void scrollTo(Offset offset) {
    position.horizontal.offset = offset.dx;
    position.vertical.offset = offset.dy;
  }

  void scrollToVertical(double offset) {
    if (offset < 0) {
      offset = 0;
    }
    position.vertical.offset = offset;
  }

  void scrollToHorizontal(double offset) {
    if (offset < 0) {
      offset = 0;
    }
    position.horizontal.offset = offset;
  }

  void setViewportSize(Size size) {
    metrics.update(
      horizontal: metrics.horizontal.copyWith(viewportDimension: size.width),
      vertical: metrics.vertical.copyWith(viewportDimension: size.height),
    );
  }

  Offset get offset => Offset(position.horizontal.offset, position.vertical.offset);
}
