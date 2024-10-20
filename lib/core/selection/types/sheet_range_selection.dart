import 'package:sheets/core/selection/renderers/sheet_range_selection_renderer.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_direction.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/sheet_selection_factory.dart';
import 'package:sheets/core/selection/types/sheet_single_selection.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/viewport/sheet_viewport.dart';

class SheetRangeSelection<T extends SheetIndex> extends SheetSelectionBase {
  SheetRangeSelection(
    T startIndex,
    T endIndex, {
    super.completed = true,
  }) : super(startIndex: startIndex, endIndex: endIndex);

  factory SheetRangeSelection.single(T index, {bool completed = true}) {
    return SheetRangeSelection<T>(index, index, completed: completed);
  }

  @override
  SheetRangeSelection<T> copyWith({T? startIndex, T? endIndex, bool? completed}) {
    return SheetRangeSelection<T>(
      startIndex ?? start.index as T,
      endIndex ?? end.index as T,
      completed: completed ?? isCompleted,
    );
  }

  @override
  CellIndex get mainCell => start.cell;

  @override
  SelectionCellCorners get cellCorners {
    return SelectionCellCorners.fromDirection(
      topLeft: start.cell,
      topRight: CellIndex(row: start.row, column: end.column),
      bottomLeft: CellIndex(row: end.row, column: start.column),
      bottomRight: end.cell,
      direction: direction,
    );
  }

  @override
  bool containsSelection(SheetSelection nestedSelection) {
    SelectionCellCorners? nestedCorners = nestedSelection.cellCorners;
    if (nestedCorners == null) return false;

    SelectionCellCorners currentCorners = cellCorners;
    return nestedCorners.isNestedIn(currentCorners);
  }

  @override
  SelectionStatus isRowSelected(RowIndex rowIndex) {
    bool selected = containsRow(rowIndex);
    return SelectionStatus(selected, _allSelected || selected && T == RowIndex);
  }

  @override
  SelectionStatus isColumnSelected(ColumnIndex columnIndex) {
    bool selected = containsColumn(columnIndex);
    return SelectionStatus(selected, _allSelected || selected && T == ColumnIndex);
  }

  @override
  SheetSelection modifyEnd(SheetIndex itemIndex) {
    return SheetSelectionFactory.range(start: start.index, end: itemIndex);
  }

  @override
  SheetSelection complete() {
    return copyWith(completed: true)._simplify();
  }

  @override
  List<SheetSelection> subtract(SheetSelection subtractedSelection) {
    List<SheetRangeSelection<CellIndex>> newSelections = <SheetRangeSelection<CellIndex>>[];

    SelectionCellCorners currentCorners = cellCorners;
    SelectionCellCorners? subtractedCorners = subtractedSelection.cellCorners;
    if (subtractedCorners == null) {
      return <SheetSelection>[this];
    }

    CellIndex currentStart = currentCorners.topLeft;
    CellIndex subtractionStart = subtractedCorners.topLeft;

    CellIndex currentEnd = currentCorners.bottomRight;
    CellIndex subtractionEnd = subtractedCorners.bottomRight;

    if (currentStart.row != subtractionStart.row) {
      newSelections.add(SheetRangeSelection<CellIndex>(
        currentStart,
        CellIndex(row: subtractionStart.row.move(-1), column: currentEnd.column),
        completed: true,
      ));
    }

    if (currentStart.column != subtractionStart.column) {
      newSelections.add(SheetRangeSelection<CellIndex>(
        CellIndex(row: subtractionStart.row, column: currentStart.column),
        CellIndex(row: subtractionEnd.row, column: subtractionStart.column.move(-1)),
        completed: true,
      ));
    }

    if (currentEnd.row != subtractionEnd.row) {
      newSelections.add(SheetRangeSelection<CellIndex>(
        CellIndex(row: subtractionEnd.row.move(1), column: currentStart.column),
        currentEnd,
        completed: true,
      ));
    }

    if (currentEnd.column != subtractionEnd.column) {
      newSelections.add(SheetRangeSelection<CellIndex>(
        CellIndex(row: subtractionStart.row, column: subtractionEnd.column.move(1)),
        CellIndex(row: subtractionEnd.row, column: currentEnd.column),
        completed: true,
      ));
    }

    return newSelections;
  }

  @override
  SheetRangeSelectionRenderer<T> createRenderer(SheetViewport viewport) {
    return SheetRangeSelectionRenderer<T>(viewport: viewport, selection: this);
  }

  @override
  String stringifySelection() {
    return '${start.index.stringifyPosition()}:${end.index.stringifyPosition()}';
  }

  SelectionDirection get direction {
    bool rowStartBeforeEnd = start.row.value <= end.row.value;
    bool columnStartBeforeEndC = start.column.value <= end.column.value;

    if (rowStartBeforeEnd) {
      return columnStartBeforeEndC ? SelectionDirection.bottomRight : SelectionDirection.bottomLeft;
    } else {
      return columnStartBeforeEndC ? SelectionDirection.topRight : SelectionDirection.topLeft;
    }
  }

  SheetSelection _simplify() {
    if (T == CellIndex && start.index == end.index) {
      return SheetSingleSelection(start.cell, completed: isCompleted);
    } else {
      return this;
    }
  }

  bool get _allSelected {
    bool startIsZero = start.index == CellIndex(row: RowIndex.zero, column: ColumnIndex.zero);
    bool endIsMax = end.index == CellIndex(row: RowIndex.max, column: ColumnIndex.max);

    return startIsZero && endIsMax;
  }

  @override
  List<Object?> get props => <Object?>[start, end, isCompleted];
}
