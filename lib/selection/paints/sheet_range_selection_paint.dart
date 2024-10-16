import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/selection/selection_rect.dart';
import 'package:sheets/viewport/sheet_viewport.dart';
import 'package:sheets/selection/renderers/sheet_range_selection_renderer.dart';
import 'package:sheets/selection/sheet_selection_paint.dart';

class SheetRangeSelectionPaint<T extends SheetIndex> extends SheetSelectionPaint {
  final SheetRangeSelectionRenderer<T> renderer;

  SheetRangeSelectionPaint(
      this.renderer,
      bool? mainCellVisible,
      bool? backgroundVisible,
      ) : super(mainCellVisible: mainCellVisible ?? true, backgroundVisible: backgroundVisible ?? true);

  @override
  void paint(SheetViewport viewport, Canvas canvas, Size size) {
    SelectionRect? selectionRect = renderer.selectionRect;
    if (selectionRect == null) return;

    if (mainCellVisible && renderer.mainCell != null) paintMainCell(canvas, renderer.mainCell!.rect);
    if (backgroundVisible) paintSelectionBackground(canvas, selectionRect);

    if (renderer.selection.isCompleted) {
      paintSelectionBorder(
        canvas,
        selectionRect,
        top: selectionRect.isTopBorderVisible,
        right: selectionRect.isRightBorderVisible,
        bottom: selectionRect.isBottomBorderVisible,
        left: selectionRect.isLeftBorderVisible,
      );
    }
  }
}
