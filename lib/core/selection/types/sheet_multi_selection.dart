import 'package:sheets/core/selection/renderers/sheet_multi_selection_renderer.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/sheet_selection_renderer.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/viewport/sheet_viewport.dart';
import 'package:sheets/utils/extensions/iterable_extensions.dart';

class SheetMultiSelection extends SheetSelection {
  final List<SheetSelection> selections;

  SheetMultiSelection({
    required Iterable<SheetSelection> selections,
  })  : selections = selections.toSet().toList(),
        assert(selections.isNotEmpty, 'Merged selections cannot be empty'),
        super(completed: true);

  @override
  SheetMultiSelection copyWith({
    bool? completed,
    Iterable<SheetSelection>? selections,
  }) {
    return SheetMultiSelection(selections: selections ?? this.selections);
  }

  @override
  CellIndex get mainCell => selections.last.mainCell;

  @override
  SheetIndex get selectionStart => selections.last.selectionStart;

  @override
  SheetIndex get selectionEnd => selections.last.selectionEnd;

  @override
  bool containsRow(RowIndex index) {
    return selections.any((SheetSelection selection) => selection.containsRow(index));
  }

  @override
  bool containsColumn(ColumnIndex index) {
    return selections.any((SheetSelection selection) => selection.containsColumn(index));
  }

  @override
  SelectionCellCorners? get cellCorners => null;

  @override
  SelectionStatus isColumnSelected(ColumnIndex columnIndex) {
    return selections.fold(SelectionStatus(false, false), (SelectionStatus acc, SheetSelection selection) {
      SelectionStatus columnStatus = selection.isColumnSelected(columnIndex);
      return SelectionStatus(acc.isSelected || columnStatus.isSelected, acc.isFullySelected || columnStatus.isFullySelected);
    });
  }

  @override
  SelectionStatus isRowSelected(RowIndex rowIndex) {
    return selections.fold(SelectionStatus(false, false), (SelectionStatus acc, SheetSelection selection) {
      SelectionStatus rowStatus = selection.isRowSelected(rowIndex);
      return SelectionStatus(acc.isSelected || rowStatus.isSelected, acc.isFullySelected || rowStatus.isFullySelected);
    });
  }

  @override
  String stringifySelection() {
    return selections.last.stringifySelection();
  }

  @override
  SheetSelectionRenderer<SheetMultiSelection> createRenderer(SheetViewport viewport) {
    return SheetMultiSelectionRenderer(viewport: viewport, selection: this);
  }

  @override
  SheetSelection modifyEnd(SheetIndex itemIndex) {
    List<SheetSelection> newMergedSelections = selections.sublist(0, selections.length - 1);
    SheetSelection modifiedSelection = selections.last.modifyEnd(itemIndex);
    newMergedSelections.add(modifiedSelection);

    return SheetMultiSelection(selections: newMergedSelections);
  }

  @override
  SheetSelection append(SheetSelection appendedSelection) {
    return copyWith(selections: <SheetSelection>{...selections, appendedSelection});
  }

  SheetMultiSelection replaceLast(SheetSelection sheetSelection) {
    List<SheetSelection> newMergedSelections = selections.sublist(0, selections.length - 1);
    newMergedSelections.add(sheetSelection);

    return copyWith(selections: newMergedSelections);
  }

  @override
  bool containsSelection(SheetSelection nestedSelection) {
    return selections.any((SheetSelection selection) => selection.containsSelection(nestedSelection));
  }

  @override
  SheetSelection complete() {
    SheetSelection lastSelection = selections.last;
    List<SheetSelection> previousSelections = selections.sublist(0, selections.length - 1);
    List<SheetSelection> updatedSelections = <SheetSelection>[];

    bool subtracted = false;
    for (SheetSelection selection in previousSelections) {
      if (subtracted == false && selection.containsSelection(lastSelection)) {
        subtracted = true;
        List<SheetSelection> subtractedSelection = selection.subtract(lastSelection);
        if (subtractedSelection.isNotEmpty) {
          updatedSelections.addAll(subtractedSelection);
        }
      } else {
        updatedSelections.add(selection);
      }
    }

    if (subtracted && updatedSelections.isNotEmpty) {
      return copyWith(selections: updatedSelections.complete(), completed: true).simplify();
    } else {
      return copyWith(selections: selections.complete(), completed: true).simplify();
    }
  }

  SheetSelection simplify() {
    if (selections.length == 1) {
      return selections.first.complete();
    } else {
      return this;
    }
  }

  @override
  List<SheetSelection> subtract(SheetSelection subtractedSelection) {
    List<SheetSelection> updatedSelections = selections.map((SheetSelection selection) => selection.subtract(subtractedSelection)).whereNotNull().cast();
    if (updatedSelections.isEmpty) {
      return <SheetSelection>[];
    } else {
      return updatedSelections;
    }
  }

  @override
  List<Object?> get props => <Object?>[selections];
}