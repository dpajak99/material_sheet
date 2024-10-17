import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/viewport/sheet_viewport_rect.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';

class VisibleColumnsRenderer {
  final SheetViewportRect viewportRect;
  final SheetProperties properties;
  final DirectionalValues<SheetScrollPosition> scrollPosition;

  VisibleColumnsRenderer({
    required this.viewportRect,
    required this.properties,
    required this.scrollPosition,
  });

  List<ViewportColumn> build() {
    double firstVisibleCoordinate = scrollPosition.horizontal.offset;
    _FirstVisibleColumnInfo firstVisibleColumnInfo = _findColumnByX(firstVisibleCoordinate);

    double maxContentWidth = viewportRect.width - rowHeadersWidth;
    double currentContentWidth = -firstVisibleColumnInfo.hiddenWidth;

    List<ViewportColumn> visibleColumns = <ViewportColumn>[];
    int index = firstVisibleColumnInfo.index.value;

    while (currentContentWidth < maxContentWidth && index < properties.columnCount) {
      ColumnIndex columnIndex = ColumnIndex(index);
      ColumnStyle columnStyle = properties.getColumnStyle(columnIndex);

      ViewportColumn viewportColumn = ViewportColumn(
        index: columnIndex,
        style: columnStyle,
        rect: Rect.fromLTWH(currentContentWidth + rowHeadersWidth, 0, columnStyle.width, columnHeadersHeight),
      );
      visibleColumns.add(viewportColumn);
      currentContentWidth += viewportColumn.style.width;

      index++;
    }

    return visibleColumns;
  }

  _FirstVisibleColumnInfo _findColumnByX(double x) {
    int actualColumnIndex = 0;
    double currentWidthStart = 0;

    _FirstVisibleColumnInfo? firstVisibleColumnInfo;

    while (firstVisibleColumnInfo == null) {
      ColumnIndex columnIndex = ColumnIndex(actualColumnIndex);
      ColumnStyle columnStyle = properties.getColumnStyle(columnIndex);
      double columnWidthEnd = currentWidthStart + columnStyle.width;

      if (x >= currentWidthStart && x < columnWidthEnd) {
        firstVisibleColumnInfo = _FirstVisibleColumnInfo(
          index: columnIndex,
          startCoordinate: currentWidthStart,
          visibleWidth: columnWidthEnd - x,
          hiddenWidth: x - currentWidthStart,
        );
      } else {
        actualColumnIndex++;
        currentWidthStart = columnWidthEnd;
      }
    }

    return firstVisibleColumnInfo;
  }
}

class _FirstVisibleColumnInfo with EquatableMixin {
  final ColumnIndex index;
  final double startCoordinate;
  final double visibleWidth;
  final double hiddenWidth;

  const _FirstVisibleColumnInfo({
    required this.index,
    required this.startCoordinate,
    required this.visibleWidth,
    required this.hiddenWidth,
  });

  @override
  List<Object?> get props => <Object?>[index, startCoordinate, visibleWidth, hiddenWidth];
}
