import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/selection/selection_rect.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/selection/paints/sheet_range_selection_paint.dart';
import 'package:sheets/selection/sheet_selection_paint.dart';
import 'package:sheets/selection/sheet_selection_renderer.dart';
import 'package:sheets/selection/types/sheet_range_selection.dart';
import 'package:sheets/utils/cached_value.dart';
import 'package:sheets/utils/closest_visible.dart';
import 'package:sheets/utils/direction.dart';

class SheetRangeSelectionRenderer<T extends SheetIndex> extends SheetSelectionRenderer<SheetRangeSelection<T>> {
  late final CachedValue<SelectionRect?> _selectionRect;

  SheetRangeSelectionRenderer({
    required super.selection,
    required super.viewport,
  }) {
    _selectionRect = CachedValue<SelectionRect?>(_calculateSelectionBounds);
  }

  @override
  bool get fillHandleVisible => selection.isCompleted;

  @override
  Offset? get fillHandleOffset => selectionRect?.bottomRight;

  @override
  SheetSelectionPaint getPaint({bool? mainCellVisible, bool? backgroundVisible}) {
    return SheetRangeSelectionPaint<T>(this, mainCellVisible, backgroundVisible);
  }

  SelectionRect? get selectionRect => _selectionRect.value;

  ViewportCell? get mainCell => viewport.visibleContent.findCell(selection.mainCell);

  SelectionRect? _calculateSelectionBounds() {
    if (isSelectionVisible) {
      ClosestVisible<ViewportCell> startCell = viewport.visibleContent.findCellOrClosest(selection.cellStart);
      ClosestVisible<ViewportCell> endCell = viewport.visibleContent.findCellOrClosest(selection.cellEnd);
      
      List<Direction> hiddenBorders = <Direction>[...startCell.hiddenBorders, ...endCell.hiddenBorders];
      return SelectionRect(startCell.value.rect, endCell.value.rect, selection.direction, hiddenBorders: hiddenBorders);
    } else {
      return null;
    }
  }
}
