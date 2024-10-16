import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/utils/first_visible.dart';

/// [VisibleRowsRenderer] is responsible for determining and building the list
/// of visible rows in the sheet based on the current viewport size, sheet properties,
/// and scroll position.
///
/// It calculates the first visible row and iterates through the rows to add them
/// to the list of visible rows until the viewport height is filled.
class VisibleRowsRenderer {
  /// The rectangle representing the current viewport area.
  final Rect viewportRect;

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
    List<ViewportRow> visibleRows = <ViewportRow>[];

    FirstVisible<RowIndex> firstVisibleRowInfo = _calculateFirstVisible();

    double currentHeight = firstVisibleRowInfo.hiddenSize;
    int index = 0;

    while (currentHeight < viewportRect.height && firstVisibleRowInfo.index.value + index < properties.rowCount) {
      RowIndex rowIndex = RowIndex(firstVisibleRowInfo.index.value + index);
      RowStyle rowStyle = properties.getRowStyle(rowIndex);

      ViewportRow viewportRow = ViewportRow(
        index: rowIndex,
        style: rowStyle,
        viewportRect:  Rect.fromLTWH(0, currentHeight + columnHeadersHeight, rowHeadersWidth, rowStyle.height),
      );
      visibleRows.add(viewportRow);

      index++;
      currentHeight += viewportRow.style.height;
    }
    return visibleRows;
  }

  /// Calculates and returns the first visible row based on the current
  /// vertical scroll position.
  ///
  /// It also calculates how much of the first visible row is hidden due to
  /// overscroll.
  FirstVisible<RowIndex> _calculateFirstVisible() {
    double contentHeight = 0;
    int hiddenRows = 0;

    while (contentHeight < scrollPosition.vertical.offset) {
      hiddenRows++;
      contentHeight += properties.getRowHeight(RowIndex(hiddenRows));
    }

    double rowHeight = properties.getRowHeight(RowIndex(hiddenRows));
    double verticalOverscroll = scrollPosition.vertical.offset - contentHeight;

    double hiddenHeight = (verticalOverscroll != 0) ? (-rowHeight - verticalOverscroll) : 0;

    return FirstVisible<RowIndex>(RowIndex(hiddenRows), hiddenHeight);
  }
}
