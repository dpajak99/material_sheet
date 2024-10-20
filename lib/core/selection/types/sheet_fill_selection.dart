import 'package:sheets/core/selection/renderers/sheet_fill_selection_renderer.dart';
import 'package:sheets/core/selection/selection_corners.dart';
import 'package:sheets/core/selection/selection_status.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/types/sheet_range_selection.dart';
import 'package:sheets/core/sheet_index.dart';
import 'package:sheets/core/viewport/sheet_viewport.dart';
import 'package:sheets/utils/direction.dart';

class SheetFillSelection<T extends SheetIndex> extends SheetRangeSelection<T> {
  SheetFillSelection(
    super.start,
    super.end, {
    required this.baseSelection,
    required this.fillDirection,
    required super.completed,
  }) : assert(baseSelection is! SheetFillSelection);

  final SheetSelection baseSelection;
  final Direction fillDirection;

  @override
  SheetFillSelection<T> copyWith({
    T? startIndex,
    T? endIndex,
    bool? completed,
    SheetSelection? baseSelection,
    Direction? fillDirection,
  }) {
    return SheetFillSelection<T>(
      startIndex ?? start.index as T,
      endIndex ?? end.index as T,
      completed: completed ?? isCompleted,
      baseSelection: baseSelection ?? this.baseSelection,
      fillDirection: fillDirection ?? this.fillDirection,
    );
  }

  @override
  SelectionStatus isColumnSelected(ColumnIndex columnIndex) => baseSelection.isColumnSelected(columnIndex);

  @override
  SelectionStatus isRowSelected(RowIndex rowIndex) => baseSelection.isRowSelected(rowIndex);

  @override
  SheetSelection complete() {
    SelectionCellCorners parentCorners = baseSelection.cellCorners!;
    SelectionCellCorners currentCorners = cellCorners;

    switch (fillDirection) {
      case Direction.top:
        return SheetRangeSelection<CellIndex>(currentCorners.topLeft, parentCorners.bottomRight, completed: true);
      case Direction.bottom:
        return SheetRangeSelection<CellIndex>(parentCorners.topLeft, currentCorners.bottomRight, completed: true);
      case Direction.left:
        return SheetRangeSelection<CellIndex>(currentCorners.topLeft, parentCorners.bottomRight, completed: true);
      case Direction.right:
        return SheetRangeSelection<CellIndex>(parentCorners.topLeft, currentCorners.bottomRight, completed: true);
    }
  }

  @override
  SheetFillSelectionRenderer<T> createRenderer(SheetViewport viewport) {
    return SheetFillSelectionRenderer<T>(viewport: viewport, selection: this);
  }
}
