import 'package:flutter_test/flutter_test.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/types/sheet_range_selection.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/selection/types/sheet_single_selection.dart';

void main() {
  group('SheetRangeSelection.isCompleted', () {
    test('Should [return TRUE] for [COMPLETED selection]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(
        CellIndex.raw(1, 1),
        CellIndex.raw(2, 2),
        completed: true,
      );

      // Act
      bool actualIsCompleted = selection.isCompleted;

      // Assert
      bool expectedIsCompleted = true;

      expect(actualIsCompleted, equals(expectedIsCompleted));
    });

    test('Should [return FALSE] for [INCOMPLETE selection]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(
        CellIndex.raw(1, 1),
        CellIndex.raw(2, 2),
        completed: false,
      );

      // Act
      bool actualIsCompleted = selection.isCompleted;

      // Assert
      bool expectedIsCompleted = false;

      expect(actualIsCompleted, equals(expectedIsCompleted));
    });
  });

  group('SheetRangeSelection.rowSelected', () {
    test('Should [return TRUE] for [SELECTED row]', () {
      // Arrange
      SheetRangeSelection<RowIndex> selection = SheetRangeSelection<RowIndex>.single(RowIndex(1), completed: true);

      // Act
      bool actualRowSelected = selection.rowSelected;

      // Assert
      bool expectedRowSelected = true;

      expect(actualRowSelected, equals(expectedRowSelected));
    });

    test('Should [return FALSE] for [SELECTED column]', () {
      // Arrange
      SheetRangeSelection<ColumnIndex> selection = SheetRangeSelection<ColumnIndex>.single(ColumnIndex(1), completed: true);

      // Act
      bool actualRowSelected = selection.rowSelected;

      // Assert
      bool expectedRowSelected = false;

      expect(actualRowSelected, equals(expectedRowSelected));
    });

    test('Should [return FALSE] for [SELECTED cell range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));

      // Act
      bool actualRowSelected = selection.rowSelected;

      // Assert
      bool expectedRowSelected = false;

      expect(actualRowSelected, equals(expectedRowSelected));
    });
  });

  group('SheetRangeSelection.columnSelected', () {
    test('Should [return TRUE] for [SELECTED column]', () {
      // Arrange
      SheetRangeSelection<ColumnIndex> selection = SheetRangeSelection<ColumnIndex>.single(ColumnIndex(1), completed: true);

      // Act
      bool actualColumnSelected = selection.columnSelected;

      // Assert
      bool expectedColumnSelected = true;

      expect(actualColumnSelected, equals(expectedColumnSelected));
    });

    test('Should [return FALSE] for [SELECTED row]', () {
      // Arrange
      SheetRangeSelection<RowIndex> selection = SheetRangeSelection<RowIndex>.single(RowIndex(1), completed: true);

      // Act
      bool actualColumnSelected = selection.columnSelected;

      // Assert
      bool expectedColumnSelected = false;

      expect(actualColumnSelected, equals(expectedColumnSelected));
    });

    test('Should [return FALSE] for [SELECTED cell range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));

      // Act
      bool actualColumnSelected = selection.columnSelected;

      // Assert
      bool expectedColumnSelected = false;

      expect(actualColumnSelected, equals(expectedColumnSelected));
    });
  });

  group('SheetRangeSelection.mainCell', () {
    test('Should [return CellIndex] representing the main cell', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      CellIndex endIndex = CellIndex.raw(2, 2);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex);

      // Act
      CellIndex actualMainCell = selection.mainCell;

      // Assert
      CellIndex expectedMainCell = startIndex;

      expect(actualMainCell, equals(expectedMainCell));
    });
  });

  group('SheetRangeSelection.cellCorners', () {
    test('Should [return SelectionCellCorners] for range selection (BOTTOM-RIGHT direction)', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      CellIndex endIndex = CellIndex.raw(3, 3);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex);

      // Act
      SelectionCellCorners actualCorners = selection.cellCorners;

      // Assert
      SelectionCellCorners expectedCorners = SelectionCellCorners(startIndex, CellIndex.raw(1, 3), CellIndex.raw(3, 1), endIndex);

      expect(actualCorners, equals(expectedCorners));
    });

    test('Should [return SelectionCellCorners] for range selection (TOP-RIGHT direction)', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(3, 1);
      CellIndex endIndex = CellIndex.raw(1, 3);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex);

      // Act
      SelectionCellCorners actualCorners = selection.cellCorners;

      // Assert
      SelectionCellCorners expectedCorners = SelectionCellCorners(CellIndex.raw(1, 1), endIndex, startIndex, CellIndex.raw(3, 3));

      expect(actualCorners, equals(expectedCorners));
    });

    test('Should [return SelectionCellCorners] for range selection (BOTTOM-LEFT direction)', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 3);
      CellIndex endIndex = CellIndex.raw(3, 1);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex);

      // Act
      SelectionCellCorners actualCorners = selection.cellCorners;

      // Assert
      SelectionCellCorners expectedCorners = SelectionCellCorners(CellIndex.raw(1, 1), startIndex, endIndex, CellIndex.raw(3, 3));

      expect(actualCorners, equals(expectedCorners));
    });

    test('Should [return SelectionCellCorners] for range selection (TOP-LEFT direction)', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(3, 3);
      CellIndex endIndex = CellIndex.raw(1, 1);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex);

      // Act
      SelectionCellCorners actualCorners = selection.cellCorners;

      // Assert
      SelectionCellCorners expectedCorners = SelectionCellCorners(endIndex, CellIndex.raw(1, 3), CellIndex.raw(3, 1), startIndex);

      expect(actualCorners, equals(expectedCorners));
    });
  });

  group('SheetRangeSelection.contains()', () {
    test('Should [return TRUE] if [cell WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      CellIndex cellIndex = CellIndex.raw(2, 2);

      // Act
      bool actualContains = selection.contains(cellIndex);

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return TRUE] if [row WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(2);

      // Act
      bool actualContainsRow = selection.contains(rowIndex);

      // Assert
      bool expectedContainsRow = true;

      expect(actualContainsRow, equals(expectedContainsRow));
    });

    test('Should [return TRUE] if [column WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(2);

      // Act
      bool actualContainsColumn = selection.contains(columnIndex);

      // Assert
      bool expectedContainsColumn = true;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });

    test('Should [return FALSE] if [cell OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      CellIndex cellIndex = CellIndex.raw(4, 4);

      // Act
      bool actualContains = selection.contains(cellIndex);

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] if [row OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(4);

      // Act
      bool actualContainsRow = selection.contains(rowIndex);

      // Assert
      bool expectedContainsRow = false;

      expect(actualContainsRow, equals(expectedContainsRow));
    });

    test('Should [return FALSE] if [column OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(4);

      // Act
      bool actualContainsColumn = selection.contains(columnIndex);

      // Assert
      bool expectedContainsColumn = false;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });
  });

  group('SheetRangeSelection.containsCell()', () {
    test('Should [return TRUE] if [cell WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      CellIndex cellIndex = CellIndex.raw(2, 2);

      // Act
      bool actualContainsCell = selection.containsCell(cellIndex);

      // Assert
      bool expectedContainsCell = true;

      expect(actualContainsCell, equals(expectedContainsCell));
    });

    test('Should [return FALSE] if [cell OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      CellIndex cellIndex = CellIndex.raw(4, 4);

      // Act
      bool actualContainsCell = selection.containsCell(cellIndex);

      // Assert
      bool expectedContainsCell = false;

      expect(actualContainsCell, equals(expectedContainsCell));
    });
  });

  group('SheetRangeSelection.containsRow()', () {
    test('Should [return TRUE] if [row WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(2);

      // Act
      bool actualContainsRow = selection.containsRow(rowIndex);

      // Assert
      bool expectedContainsRow = true;

      expect(actualContainsRow, equals(expectedContainsRow));
    });

    test('Should [return FALSE] if [row OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(4);

      // Act
      bool actualContainsRow = selection.containsRow(rowIndex);

      // Assert
      bool expectedContainsRow = false;

      expect(actualContainsRow, equals(expectedContainsRow));
    });
  });

  group('SheetRangeSelection.containsColumn()', () {
    test('Should [return TRUE] if [column WITHIN range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(2);

      // Act
      bool actualContainsColumn = selection.containsColumn(columnIndex);

      // Assert
      bool expectedContainsColumn = true;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });

    test('Should [return FALSE] if [column OUTSIDE range]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(4);

      // Act
      bool actualContainsColumn = selection.containsColumn(columnIndex);

      // Assert
      bool expectedContainsColumn = false;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });
  });

  group('SheetRangeSelection.containsSelection()', () {
    test('Should [return TRUE] for [NESTED selection]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      SheetSingleSelection nestedSelection = SheetSingleSelection(CellIndex.raw(2, 2));

      // Act
      bool actualContains = selection.containsSelection(nestedSelection);

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] for [NON-NESTED selection]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      SheetSingleSelection nonNestedSelection = SheetSingleSelection(CellIndex.raw(4, 4));

      // Act
      bool actualContains = selection.containsSelection(nonNestedSelection);

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });
  });

  group('SheetRangeSelection.isRowSelected()', () {
    test('Should [return SelectionStatus] for [FULLY SELECTED row]', () {
      // Arrange
      RowIndex rowIndex = RowIndex(2);
      SheetRangeSelection<RowIndex> selection = SheetRangeSelection<RowIndex>.single(rowIndex);

      // Act
      SelectionStatus actualStatus = selection.isRowSelected(rowIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, false);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [SELECTED row]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(2);

      // Act
      SelectionStatus actualStatus = selection.isRowSelected(rowIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, false);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [NON-SELECTED row]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      RowIndex rowIndex = RowIndex(4);

      // Act
      SelectionStatus actualStatus = selection.isRowSelected(rowIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(false, false);

      expect(actualStatus, equals(expectedStatus));
    });
  });

  group('SheetRangeSelection.isColumnSelected()', () {
    test('Should [return SelectionStatus] for [FULLY SELECTED column]', () {
      // Arrange
      ColumnIndex columnIndex = ColumnIndex(2);
      SheetRangeSelection<ColumnIndex> selection = SheetRangeSelection<ColumnIndex>.single(columnIndex);

      // Act
      SelectionStatus actualStatus = selection.isColumnSelected(columnIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, true);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [SELECTED column]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(2);

      // Act
      SelectionStatus actualStatus = selection.isColumnSelected(columnIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, false);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [NON-SELECTED column]', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));
      ColumnIndex columnIndex = ColumnIndex(4);

      // Act
      SelectionStatus actualStatus = selection.isColumnSelected(columnIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(false, false);

      expect(actualStatus, equals(expectedStatus));
    });
  });

  group('SheetRangeSelection.modifyEnd()', () {
    test('Should [return SheetRangeSelection] with modified end index', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      CellIndex newEndIndex = CellIndex.raw(4, 4);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, CellIndex.raw(2, 2));

      // Act
      SheetSelection actualSelection = selection.modifyEnd(newEndIndex);

      // Assert
      SheetRangeSelection<CellIndex> expectedSelection =
          SheetRangeSelection<CellIndex>(startIndex, newEndIndex, completed: false);

      expect(actualSelection, equals(expectedSelection));
    });
  });

  group('SheetRangeSelection.complete()', () {
    test('Should [return SheetRangeSelection] with [completed == TRUE]', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      CellIndex endIndex = CellIndex.raw(3, 3);
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(startIndex, endIndex, completed: false);

      // Act
      SheetSelection actualSelection = selection.complete();

      // Assert
      SheetRangeSelection<CellIndex> expectedSelection = SheetRangeSelection<CellIndex>(startIndex, endIndex, completed: true);

      expect(actualSelection, equals(expectedSelection));
    });
  });

  group('SheetRangeSelection.stringifySelection()', () {
    test('Should [return String] representing SheetRangeSelection', () {
      // Arrange
      SheetRangeSelection<CellIndex> selection = SheetRangeSelection<CellIndex>(CellIndex.raw(1, 1), CellIndex.raw(3, 3));

      // Act
      String actualString = selection.stringifySelection();

      // Assert
      String expectedString = 'B2:D4';

      expect(actualString, equals(expectedString));
    });
  });
}
