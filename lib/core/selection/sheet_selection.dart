import 'package:equatable/equatable.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_details.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/selection/sheet_selection_renderer.dart';
import 'package:sheets/core/selection/types/sheet_multi_selection.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/viewport/sheet_viewport.dart';

abstract interface class SheetSelection {
  SheetSelection copyWith({bool? completed});

  bool get isCompleted;

  bool get rowSelected;

  bool get columnSelected;

  CellIndex get mainCell;

  SelectionStartDetails get start;

  SelectionEndDetails get end;

  SelectionCellCorners? get cellCorners;

  bool contains(SheetIndex index);

  bool containsCell(CellIndex index);

  bool containsRow(RowIndex index);

  bool containsColumn(ColumnIndex index);

  bool containsSelection(SheetSelection nestedSelection);

  SelectionStatus isRowSelected(RowIndex rowIndex);

  SelectionStatus isColumnSelected(ColumnIndex columnIndex);

  SheetMultiSelection append(SheetSelection appendedSelection);

  SheetSelection modifyEnd(SheetIndex itemIndex);

  SheetSelection complete();

  List<SheetSelection> subtract(SheetSelection subtractedSelection);

  SheetSelectionRenderer<SheetSelection> createRenderer(SheetViewport viewport);

  String stringifySelection();
}

abstract class SheetSelectionBase with EquatableMixin implements SheetSelection {
  SheetSelectionBase({
    required bool completed,
    required SheetIndex startIndex,
    required SheetIndex endIndex,
  })  : _completed = completed,
        _startDetails = SelectionStartDetails(startIndex),
        _endDetails = SelectionEndDetails(endIndex);

  final bool _completed;
  final SelectionStartDetails _startDetails;
  final SelectionEndDetails _endDetails;

  @override
  bool get isCompleted => _completed;

  @override
  bool get rowSelected => start.index is RowIndex && end.index is RowIndex;

  @override
  bool get columnSelected => start.index is ColumnIndex && end.index is ColumnIndex;

  @override
  SelectionStartDetails get start => _startDetails;

  @override
  SelectionEndDetails get end => _endDetails;
  
  @override
  bool contains(SheetIndex index) {
    return switch (index) {
      CellIndex cellIndex => containsCell(cellIndex),
      ColumnIndex columnIndex => containsColumn(columnIndex),
      RowIndex rowIndex => containsRow(rowIndex),
    };
  }

  @override
  bool containsCell(CellIndex index) {
    bool rowSelected = containsRow(index.row);
    bool columnSelected = containsColumn(index.column);

    return rowSelected && columnSelected;
  }

  @override
  bool containsRow(RowIndex index) {
    if (columnSelected) return true;

    RowIndex topRow = start.row < end.row ? start.row : end.row;
    RowIndex bottomRow = start.row < end.row ? end.row : start.row;

    return index.value >= topRow.value && index.value <= bottomRow.value;
  }

  @override
  bool containsColumn(ColumnIndex index) {
    if (rowSelected) return true;

    ColumnIndex leftColumn = start.column < end.column ? start.column : end.column;
    ColumnIndex rightColumn = start.column < end.column ? end.column : start.column;

    return index.value >= leftColumn.value && index.value <= rightColumn.value;
  }

  @override
  SheetMultiSelection append(SheetSelection appendedSelection) {
    return SheetMultiSelection(selections: <SheetSelection>[this, appendedSelection]);
  }
}
