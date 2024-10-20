import 'package:flutter_test/flutter_test.dart';
import 'package:sheets/core/selection/selection_details.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/types/sheet_single_selection.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/selection/types/sheet_multi_selection.dart';
import 'package:sheets/core/selection/types/sheet_range_selection.dart';

void main() {
  group('SheetSingleSelection.isCompleted', () {
    test('Should [return FALSE] for [INCOMPLETE selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualIsCompleted = selection.isCompleted;

      // Assert
      bool expectedIsCompleted = false;

      expect(actualIsCompleted, equals(expectedIsCompleted));
    });

    test('Should [return TRUE] for [COMPLETED selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: true);

      // Act
      bool actualIsCompleted = selection.isCompleted;

      // Assert
      bool expectedIsCompleted = true;

      expect(actualIsCompleted, equals(expectedIsCompleted));
    });
  });

  group('SheetSingleSelection.rowSelected', () {
    test('Should [return FALSE] for a SheetSingleSelection selection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualRowSelected = selection.rowSelected;

      // Assert
      bool expectedRowSelected = false;

      expect(actualRowSelected, equals(expectedRowSelected));
    });
  });

  group('SheetSingleSelection.columnSelected', () {
    test('Should [return FALSE] for a SheetSingleSelection selection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualRowSelected = selection.columnSelected;

      // Assert
      bool expectedRowSelected = false;

      expect(actualRowSelected, equals(expectedRowSelected));
    });
  });

  group('SheetSingleSelection.mainCell', () {
    test('Should [return CellIndex] representing the main cell', () {
      // Arrange
      CellIndex mainCell = CellIndex.raw(1, 1);
      SheetSingleSelection selection = SheetSingleSelection(mainCell, completed: false);

      // Act
      CellIndex actualMainCell = selection.mainCell;

      // Assert
      CellIndex expectedMainCell = CellIndex.raw(1, 1);

      expect(actualMainCell, equals(expectedMainCell));
    });
  });

  group('SheetSingleSelection.cellCorners', () {
    test('Should [return SelectionCellCorners] for a single cell selection', () {
      // Arrange
      CellIndex selectedCell = CellIndex.raw(1, 1);
      SheetSingleSelection selection = SheetSingleSelection(selectedCell, completed: false);

      // Act
      SelectionCellCorners actualCorners = selection.cellCorners;

      // Assert
      SelectionCellCorners expectedCorners = SelectionCellCorners(selectedCell, selectedCell, selectedCell, selectedCell);

      expect(actualCorners, equals(expectedCorners));
    });
  });

  group('SheetSingleSelection.contains()', () {
    test('Should [return TRUE] if [cell WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(CellIndex.raw(5, 5));

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return TRUE] if [row WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(RowIndex(5));

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return TRUE] if [column WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(ColumnIndex(5));

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] if [cell OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(CellIndex.raw(2, 2));

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] if [row OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(RowIndex(2));

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] if [column OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.contains(ColumnIndex(2));

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });
  });

  group('SheetSingleSelection.containsCell()', () {
    test('Should [return TRUE] if [cell WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.containsCell(CellIndex.raw(5, 5));

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] if [cell OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);

      // Act
      bool actualContains = selection.containsCell(CellIndex.raw(2, 2));

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });
  });

  group('SheetSingleSelection.containsRow()', () {
    test('Should [return TRUE] if [row WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      RowIndex rowIndex = RowIndex(1);

      // Act
      bool actualContainsRow = selection.containsRow(rowIndex);

      // Assert
      bool expectedContainsRow = true;

      expect(actualContainsRow, equals(expectedContainsRow));
    });

    test('Should [return FALSE] if [row OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      RowIndex rowIndex = RowIndex(999);

      // Act
      bool actualContainsRow = selection.containsRow(rowIndex);

      // Assert
      bool expectedContainsRow = false;

      expect(actualContainsRow, equals(expectedContainsRow));
    });
  });

  group('SheetSingleSelection.containsColumn()', () {
    test('Should [return TRUE] if [column WITHIN range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      ColumnIndex columnIndex = ColumnIndex(1);

      // Act
      bool actualContainsColumn = selection.containsColumn(columnIndex);

      // Assert
      bool expectedContainsColumn = true;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });

    test('Should [return FALSE] if [column OUTSIDE range]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      ColumnIndex columnIndex = ColumnIndex(999);

      // Act
      bool actualContainsColumn = selection.containsColumn(columnIndex);

      // Assert
      bool expectedContainsColumn = false;

      expect(actualContainsColumn, equals(expectedContainsColumn));
    });
  });

  group('SheetSingleSelection.containsSelection()', () {
    test('Should [return TRUE] for [IDENTICAL single selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      SheetSingleSelection identicalSelection = SheetSingleSelection(CellIndex.raw(1, 1));

      // Act
      bool actualContains = selection.containsSelection(identicalSelection);

      // Assert
      bool expectedContains = true;

      expect(actualContains, equals(expectedContains));
    });

    test('Should [return FALSE] for [DIFFERENT single selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      SheetSingleSelection differentSelection = SheetSingleSelection(CellIndex.raw(2, 2));

      // Act
      bool actualContains = selection.containsSelection(differentSelection);

      // Assert
      bool expectedContains = false;

      expect(actualContains, equals(expectedContains));
    });
  });

  group('SheetSingleSelection.isRowSelected()', () {
    test('Should [return SelectionStatus] for [SELECTED row]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      RowIndex rowIndex = RowIndex(1);

      // Act
      SelectionStatus actualStatus = selection.isRowSelected(rowIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, false);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [DIFFERENT row]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      RowIndex rowIndex = RowIndex(2);

      // Act
      SelectionStatus actualStatus = selection.isRowSelected(rowIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(false, false);

      expect(actualStatus, equals(expectedStatus));
    });
  });

  group('SheetSingleSelection.isColumnSelected()', () {
    test('Should [return SelectionStatus] for [SELECTED column]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      ColumnIndex columnIndex = ColumnIndex(1);

      // Act
      SelectionStatus actualStatus = selection.isColumnSelected(columnIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(true, false);

      expect(actualStatus, equals(expectedStatus));
    });

    test('Should [return SelectionStatus] for [DIFFERENT column]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      ColumnIndex columnIndex = ColumnIndex(2);

      // Act
      SelectionStatus actualStatus = selection.isColumnSelected(columnIndex);

      // Assert
      SelectionStatus expectedStatus = SelectionStatus(false, false);

      expect(actualStatus, equals(expectedStatus));
    });
  });

  group('SheetSingleSelection.append()', () {
    test('Should [return SheetMultiSelection] when appending SheetSingleSelection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      SheetSingleSelection appendedSelection = SheetSingleSelection(CellIndex.raw(8, 8));

      // Act
      SheetMultiSelection actualSelection = selection.append(appendedSelection);

      // Assert
      SheetMultiSelection expectedSelection = SheetMultiSelection(selections: <SheetSelection>[selection, appendedSelection]);

      expect(actualSelection, equals(expectedSelection));
    });

    test('Should [return SheetMultiSelection] when appending SheetRangeSelection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      SheetRangeSelection<CellIndex> appendedSelection = SheetRangeSelection<CellIndex>(
        CellIndex.raw(8, 8),
        CellIndex.raw(10, 10),
      );

      // Act
      SheetMultiSelection actualSelection = selection.append(appendedSelection);

      // Assert
      SheetMultiSelection expectedSelection = SheetMultiSelection(selections: <SheetSelection>[selection, appendedSelection]);

      expect(actualSelection, equals(expectedSelection));
    });

    test('Should [return SheetMultiSelection] when appending SheetMultiSelection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      SheetMultiSelection appendedSelection = SheetMultiSelection(selections: <SheetSelection>[
        SheetSingleSelection(CellIndex.raw(8, 8)),
        SheetRangeSelection<CellIndex>(CellIndex.raw(10, 10), CellIndex.raw(12, 12)),
      ]);

      // Act
      SheetMultiSelection actualSelection = selection.append(appendedSelection);

      // Assert
      SheetMultiSelection expectedSelection = SheetMultiSelection(selections: <SheetSelection>[selection, ...appendedSelection.selections]);

      expect(actualSelection, equals(expectedSelection));
    });
  });

  group('SheetSingleSelection.modifyEnd()', () {
    test('Should [return SheetRangeSelection] if [CellIndex DIFFERENT]', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      CellIndex endIndex = CellIndex.raw(2, 2);
      SheetSingleSelection selection = SheetSingleSelection(startIndex, completed: false);

      // Act
      SheetSelection actualSelection = selection.modifyEnd(endIndex);

      // Assert
      SheetRangeSelection<CellIndex> expectedSelection = SheetRangeSelection<CellIndex>(startIndex, endIndex, completed: false);

      expect(actualSelection, equals(expectedSelection));
    });

    test('Should [return SheetSingleSelection] if [CellIndex IDENTICAL]', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      SheetSingleSelection selection = SheetSingleSelection(startIndex, completed: false);

      // Act
      SheetSelection actualSelection = selection.modifyEnd(startIndex);

      // Assert
      SheetSingleSelection expectedSelection = SheetSingleSelection(startIndex, completed: false);

      expect(actualSelection, equals(expectedSelection));
    });
  });

  group('SheetSingleSelection.complete()', () {
    test('Should [return SheetSingleSelection] with [completed == TRUE]', () {
      // Arrange
      CellIndex startIndex = CellIndex.raw(1, 1);
      SheetSingleSelection selection = SheetSingleSelection(startIndex, completed: false);

      // Act
      SheetSelection actualSelection = selection.complete();

      // Assert
      SheetSingleSelection expectedSelection = SheetSingleSelection(startIndex, completed: true);

      expect(actualSelection, equals(expectedSelection));
    });
  });

  group('SheetSingleSelection.subtract()', () {
    test('Should [return EMPTY list] when subtracting [IDENTICAL selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);
      SheetSingleSelection identicalSelection = SheetSingleSelection(CellIndex.raw(1, 1));

      // Act
      List<SheetSelection> actualSelections = selection.subtract(identicalSelection);

      // Assert
      List<SheetSelection> expectedSelections = <SheetSelection>[];

      expect(actualSelections, equals(expectedSelections));
    });

    test('Should [return ORIGINAL selection] when subtracting [DIFFERENT selection]', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(5, 5), completed: false);
      SheetSingleSelection differentSelection = SheetSingleSelection(CellIndex.raw(2, 2));

      // Act
      List<SheetSelection> actualSelections = selection.subtract(differentSelection);

      // Assert
      List<SheetSingleSelection> expectedSelections = <SheetSingleSelection>[selection];

      expect(actualSelections, equals(expectedSelections));
    });
  });

  group('SheetSingleSelection.stringifySelection()', () {
    test('Should [return String] representing SheetSingleSelection', () {
      // Arrange
      SheetSingleSelection selection = SheetSingleSelection(CellIndex.raw(1, 1), completed: false);

      // Act
      String actualString = selection.stringifySelection();

      // Assert
      String expectedString = 'B2';

      expect(actualString, equals(expectedString));
    });
  });
}
