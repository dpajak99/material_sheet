import 'package:flutter/material.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/utils/closest_visible.dart';
import 'package:sheets/utils/extensions/rect_extensions.dart';
import 'package:sheets/viewport/calculators/closest_visible_cell_index_calculator.dart';

/// [SheetViewportContentData] holds and manages the lists of visible rows,
/// columns, and cells in the viewport.
///
/// It also provides methods to update these lists and query them for
/// specific items, such as finding a cell by its index or finding the
/// closest visible cell.
class SheetViewportContentData {
  List<ViewportRow> rows = <ViewportRow>[];
  List<ViewportColumn> columns = <ViewportColumn>[];
  List<ViewportCell> cells = <ViewportCell>[];

  /// Returns a combined list of all visible sheet items (rows, columns, cells).
  List<ViewportItem> get all {
    return <ViewportItem>[...rows, ...columns, ...cells];
  }

  /// Updates the lists of visible rows, columns, and cells with the provided
  /// [newRows], [newColumns], and [newCells].
  void update(List<ViewportRow> newRows, List<ViewportColumn> newColumns, List<ViewportCell> newCells) {
    rows = newRows;
    columns = newColumns;
    cells = newCells;
  }

  /// Checks if the list of visible cells contains a cell with the given
  /// [cellIndex].
  ///
  /// Returns `true` if the cell is visible, otherwise returns `false`.
  bool containsCell(CellIndex cellIndex) {
    return cells.any((ViewportCell cell) => cell.index == cellIndex);
  }

  ClosestVisible<ViewportCell> findCellOrClosest(CellIndex cellIndex) {
    if (containsCell(cellIndex)) {
      return ClosestVisible<ViewportCell>.fullyVisible(findCell(cellIndex)!);
    }
    return findClosestCell(cellIndex);
  }

  /// Finds and returns the visible cell with the given [cellIndex],
  /// or `null` if the cell is not found.
  ViewportCell? findCell(CellIndex cellIndex) {
    return cells.where((ViewportCell cell) => cell.index == cellIndex).firstOrNull;
  }

  /// Finds and returns the sheet item at the given [mousePosition],
  /// or `null` if no item is found.
  ViewportItem? findAnyByOffset(Offset mousePosition) {
    try {
      return all.firstWhere((ViewportItem element) => element.rect.within(mousePosition));
    } catch (e) {
      return null;
    }
  }

  /// Finds and returns the closest visible cell to the given [cellIndex].
  ///
  /// The closest cell may be partially visible depending on the viewport.
  ClosestVisible<ViewportCell> findClosestCell(CellIndex cellIndex) {
    ClosestVisibleCellIndexCalculator calculator = ClosestVisibleCellIndexCalculator(visibleRows: rows, visibleColumns: columns);
    ClosestVisible<CellIndex> closestVisibleCellIndex = calculator.findFor(cellIndex);

    return ClosestVisible<ViewportCell>.partiallyVisible(
      value: findCell(closestVisibleCellIndex.value)!,
      hiddenBorders: closestVisibleCellIndex.hiddenBorders,
    );
  }
}
