import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/selection/types/sheet_range_selection.dart';
import 'package:sheets/selection/types/sheet_selection.dart';
import 'package:sheets/selection/types/sheet_single_selection.dart';

class SelectionFactory {
  static SheetSelection getSingleSelection(CellIndex cellIndex, {bool completed = true}) {
    return SheetSingleSelection(cellIndex: cellIndex, completed: completed);
  }

  static SheetSelection getColumnSelection(ColumnIndex columnIndex, {bool completed = true}) {
    return SheetRangeSelection(
      start: CellIndex(rowIndex: RowIndex(0), columnIndex: columnIndex),
      end: CellIndex(rowIndex: RowIndex(defaultRowCount - 1), columnIndex: columnIndex),
      completed: completed,
    );
  }

  static SheetSelection getRowSelection(RowIndex rowIndex, {bool completed = true}) {
    return SheetRangeSelection(
      start: CellIndex(rowIndex: rowIndex, columnIndex: ColumnIndex(0)),
      end: CellIndex(rowIndex: rowIndex, columnIndex: ColumnIndex(defaultColumnCount - 1)),
      completed: completed,
    );
  }

  static SheetSelection? getRangeSelection({required SheetItemIndex start, required SheetItemIndex end, bool completed = false}) {
    SheetSelection? sheetSelection = switch (start) {
      CellIndex start => _getCellDynamicRangeSelection(start, end, completed: completed),
      ColumnIndex start => _getColumnDynamicRangeSelection(start, end, completed:  completed),
      RowIndex start => _getRowRangeDynamicSelection(start, end, completed: completed),
      (_) => null,
    };

    return sheetSelection;
  }

  static SheetSelection getColumnRangeSelection({required ColumnIndex start, required ColumnIndex end, bool completed = false}) {
    return SheetRangeSelection(
      start: CellIndex(rowIndex: RowIndex(0), columnIndex: start),
      end: CellIndex(rowIndex: RowIndex(defaultRowCount - 1), columnIndex: end),
      completed: completed,
    );
  }

  static SheetSelection getRowRangeSelection({required RowIndex start, required RowIndex end, bool completed = false}) {
    return SheetRangeSelection(
      start: CellIndex(rowIndex: start, columnIndex: ColumnIndex(0)),
      end: CellIndex(rowIndex: end, columnIndex: ColumnIndex(defaultColumnCount - 1)),
      completed: completed,
    );
  }

  static SheetSelection getAllSelection() {
    return SheetRangeSelection(
      start: CellIndex(rowIndex: RowIndex(0), columnIndex: ColumnIndex(0)),
      end: CellIndex(rowIndex: RowIndex(defaultRowCount - 1), columnIndex: ColumnIndex(defaultColumnCount - 1)),
      completed: true,
    );
  }

  static SheetSelection? _getCellDynamicRangeSelection(CellIndex start, SheetItemIndex end, {bool completed = false}) {
    return switch (end) {
      CellIndex end => SheetRangeSelection(start: start, end: end, completed: completed),
      ColumnIndex end => SelectionFactory.getColumnRangeSelection(start: start.columnIndex, end: end, completed: completed),
      RowIndex end => SelectionFactory.getRowRangeSelection(start: start.rowIndex, end: end, completed: completed),
      (_) => null,
    };
  }

  static SheetSelection? _getColumnDynamicRangeSelection(ColumnIndex start, SheetItemIndex end, {bool completed = false}) {
    return switch (end) {
      CellIndex end => SelectionFactory.getColumnRangeSelection(start: start, end: end.columnIndex, completed: completed),
      ColumnIndex end => SelectionFactory.getColumnRangeSelection(start: start, end: end, completed: completed),
      (_) => null,
    };
  }

  static SheetSelection? _getRowRangeDynamicSelection(RowIndex start, SheetItemIndex end, {bool completed = false}) {
    return switch (end) {
      CellIndex end => SelectionFactory.getRowRangeSelection(start: start, end: end.rowIndex, completed: completed),
      RowIndex end => SelectionFactory.getRowRangeSelection(start: start, end: end, completed: completed),
      (_) => null,
    };
  }
}