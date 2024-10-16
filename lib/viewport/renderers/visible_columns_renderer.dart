import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/utils/first_visible.dart';

/// [VisibleColumnsRenderer] is responsible for determining and building the
/// list of visible columns in the sheet based on the current viewport size,
/// sheet properties, and scroll position.
///
/// It calculates the first visible column and iterates through the columns to
/// add them to the list of visible columns until the viewport width is filled.
class VisibleColumnsRenderer {
  /// The rectangle representing the current viewport area.
  final Rect viewportRect;

  /// The properties of the sheet, which include details like column count and styles.
  final SheetProperties properties;

  /// The current scroll position in both horizontal and vertical directions.
  final DirectionalValues<SheetScrollPosition> scrollPosition;

  /// Creates a [VisibleColumnsRenderer] that calculates which columns are
  /// visible within the viewport based on the provided [viewportRect],
  /// [properties], and [scrollPosition].
  VisibleColumnsRenderer({
    required this.viewportRect,
    required this.properties,
    required this.scrollPosition,
  });

  /// Builds and returns a list of [ViewportColumn] objects representing
  /// the columns visible in the current viewport.
  ///
  /// It calculates the first visible column and iterates through the columns
  /// to create their viewport configurations, stopping when the viewport width
  /// is filled or there are no more columns.
  List<ViewportColumn> build() {
    List<ViewportColumn> visibleColumns = <ViewportColumn>[];

    FirstVisible<ColumnIndex> firstColumn = _calculateFirstVisible();

    double currentWidth = firstColumn.hiddenSize;
    int index = 0;

    while (currentWidth < viewportRect.width && firstColumn.index.value + index < properties.columnCount) {
      ColumnIndex columnIndex = ColumnIndex(firstColumn.index.value + index);
      ColumnStyle columnStyle = properties.getColumnStyle(columnIndex);

      ViewportColumn viewportColumn = ViewportColumn(
        index: columnIndex,
        style: columnStyle,
        viewportRect: Rect.fromLTWH(currentWidth + rowHeadersWidth, 0, columnStyle.width, columnHeadersHeight),
      );

      visibleColumns.add(viewportColumn);

      currentWidth += viewportColumn.style.width;
      index++;
    }

    return visibleColumns;
  }

  /// Calculates and returns the first visible column based on the current
  /// horizontal scroll position.
  ///
  /// It also calculates how much of the first visible column is hidden due to
  /// overscroll.
  FirstVisible<ColumnIndex> _calculateFirstVisible() {
    double contentWidth = 0;
    int hiddenColumns = 0;

    while (contentWidth < scrollPosition.horizontal.offset) {
      hiddenColumns++;
      contentWidth += properties.getColumnWidth(ColumnIndex(hiddenColumns));
    }

    double columnWidth = properties.getColumnWidth(ColumnIndex(hiddenColumns));
    double horizontalOverscroll = scrollPosition.horizontal.offset - contentWidth;

    double hiddenWidth = (horizontalOverscroll != 0) ? (-columnWidth - horizontalOverscroll) : 0;

    return FirstVisible<ColumnIndex>(ColumnIndex(hiddenColumns), hiddenWidth);
  }
}
