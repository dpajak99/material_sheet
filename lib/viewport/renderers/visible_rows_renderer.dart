import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/viewport/sheet_viewport_rect.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';

/// [VisibleRowsRenderer] is responsible for determining and building the list
/// of visible rows in the sheet based on the current viewport size, sheet properties,
/// and scroll position.
///
/// It calculates the first visible row and iterates through the rows to add them
/// to the list of visible rows until the viewport height is filled.
class VisibleRowsRenderer {
  /// The rectangle representing the current viewport area.
  final SheetViewportRect viewportRect;

  /// The properties of the sheet, such as row heights, row count, and styles.
  final SheetProperties properties;

  /// The current scroll position in both horizontal and vertical directions.
  final DirectionalValues<SheetScrollPosition> scrollPosition;

  /// Creates a [VisibleRowsRenderer] that calculates which rows are visible
  /// within the viewport based on the provided [viewportRect], [properties],
  /// and [scrollPosition].
  VisibleRowsRenderer({
    required this.viewportRect,
    required this.properties,
    required this.scrollPosition,
  });

  /// Builds and returns a list of [ViewportRow] objects representing the
  /// rows visible in the current viewport.
  ///
  /// It calculates the first visible row and iterates through the rows, creating
  /// their viewport configurations, stopping when the viewport height is filled
  /// or there are no more rows.
  List<ViewportRow> build() {
    double firstVisibleCoordinate = scrollPosition.vertical.offset;
    _FirstVisibleRowInfo firstVisibleRowInfo = _findRowByY(firstVisibleCoordinate);

    double maxContentHeight = viewportRect.height - columnHeadersHeight;
    double currentContentHeight = -firstVisibleRowInfo.hiddenHeight;

    List<ViewportRow> visibleRows = <ViewportRow>[];
    int index = firstVisibleRowInfo.index.value;

    while (currentContentHeight < maxContentHeight && index < properties.rowCount) {
      RowIndex rowIndex = RowIndex(index);
      RowStyle rowStyle = properties.getRowStyle(rowIndex);

      ViewportRow viewportRow = ViewportRow(
        index: rowIndex,
        style: rowStyle,
        rect: Rect.fromLTWH(0, currentContentHeight + columnHeadersHeight, rowHeadersWidth, rowStyle.height),
      );
      visibleRows.add(viewportRow);
      currentContentHeight += viewportRow.style.height;

      index++;
    }

    return visibleRows;
  }

  _FirstVisibleRowInfo _findRowByY(double y) {
    int actualRowIndex = 0;
    double currentHeightStart = 0;

    _FirstVisibleRowInfo? firstVisibleRowInfo;

    while (firstVisibleRowInfo == null) {
      RowIndex rowIndex = RowIndex(actualRowIndex);
      RowStyle rowStyle = properties.getRowStyle(rowIndex);
      double rowHeightEnd = currentHeightStart + rowStyle.height;

      if (y >= currentHeightStart && y < rowHeightEnd) {
        firstVisibleRowInfo = _FirstVisibleRowInfo(
          index: rowIndex,
          startCoordinate: currentHeightStart,
          visibleHeight: rowHeightEnd - y,
          hiddenHeight: y - currentHeightStart,
        );
      } else {
        actualRowIndex++;
        currentHeightStart = rowHeightEnd;
      }
    }

    return firstVisibleRowInfo;
  }
}

class _FirstVisibleRowInfo with EquatableMixin {
  final RowIndex index;
  final double startCoordinate;
  final double visibleHeight;
  final double hiddenHeight;

  const _FirstVisibleRowInfo({
    required this.index,
    required this.startCoordinate,
    required this.visibleHeight,
    required this.hiddenHeight,
  });

  @override
  List<Object?> get props => <Object?>[index, startCoordinate, visibleHeight, hiddenHeight];
}