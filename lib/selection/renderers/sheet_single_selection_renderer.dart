import 'package:flutter/material.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/selection/paints/sheet_single_selection_paint.dart';
import 'package:sheets/selection/sheet_selection_paint.dart';
import 'package:sheets/selection/sheet_selection_renderer.dart';
import 'package:sheets/selection/types/sheet_single_selection.dart';
import 'package:sheets/utils/cached_value.dart';

class SheetSingleSelectionRenderer extends SheetSelectionRenderer<SheetSingleSelection> {
  late final CachedValue<ViewportCell?> _selectedCell;

  SheetSingleSelectionRenderer({
    required super.selection,
    required super.viewport,
  }) {
    _selectedCell = CachedValue<ViewportCell?>(() => viewport.visibleContent.findCell(selection.cellStart));
  }

  @override
  bool get fillHandleVisible => selection.isCompleted == true;

  @override
  Offset? get fillHandleOffset => selectedCell?.rect.bottomRight;

  @override
  SheetSelectionPaint getPaint({bool? mainCellVisible, bool? backgroundVisible}) {
    return SheetSingleSelectionPaint(this, mainCellVisible, backgroundVisible);
  }

  ViewportCell? get selectedCell => _selectedCell.value;
}

