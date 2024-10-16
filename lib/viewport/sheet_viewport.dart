import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sheets/controller/sheet_scroll_controller.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/viewport/sheet_viewport_content.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/viewport/viewport_offset_transformer.dart';

/// [SheetViewport] is responsible for managing the visible content within the
/// viewport of the sheet and ensuring that content updates when the scroll
/// position or sheet properties change.
///
/// It also provides functionality to convert global offsets to local ones
/// relative to the visible grid within the viewport.
class SheetViewport extends ChangeNotifier {
  /// Manages the content currently visible within the viewport.
  final SheetViewportContent visibleContent = SheetViewportContent();

  /// Stores the properties of the sheet, such as row heights and column widths.
  final SheetProperties _properties;

  /// Controls the scroll position of the sheet and notifies the viewport
  /// when the scroll changes.
  final SheetScrollController _scrollController;

  /// Stores the current scroll position in both horizontal and vertical directions.
  late DirectionalValues<SheetScrollPosition> _scrollPosition;

  /// The rectangle representing the current viewport area.
  Rect _viewportRect = Rect.zero;

  /// Returns the current rectangle defining the viewport area.
  Rect get viewportRect => _viewportRect;

  /// Creates a [SheetViewport] that updates visible content based on the
  /// provided [properties] and [scrollController].
  ///
  /// The content within the viewport is initialized and rebuilt when necessary.
  SheetViewport(SheetProperties properties, SheetScrollController scrollController)
      : _scrollController = scrollController,
        _properties = properties {
    _scrollPosition = _scrollController.position;
    _scrollController.applyProperties(properties);

    visibleContent.applyProperties(_properties);
    visibleContent.rebuild(_viewportRect, _scrollPosition);

    visibleContent.addListener(notifyListeners);
    _properties.addListener(() => _updateSheetProperties(_properties));
    _scrollController.addListener(() => _updateScrollPosition(_scrollController));
  }

  @override
  void dispose() {
    visibleContent.removeListener(notifyListeners);
    _properties.removeListener(() => _updateSheetProperties(_properties));
    _scrollController.removeListener(() => _updateScrollPosition(_scrollController));

    super.dispose();
  }

  /// Returns the rectangle representing the visible portion of the grid within
  /// the viewport.
  ///
  /// This is determined by comparing the viewport's bounds with the visible
  /// rows and columns of the sheet.
  Rect get visibleGridInnerRect {
    return Rect.fromLTRB(
      max(visibleContent.columns.first.viewportRect.left, viewportRect.left),
      min(visibleContent.rows.first.viewportRect.top, viewportRect.top),
      min(visibleContent.columns.last.viewportRect.right, viewportRect.right),
      min(visibleContent.rows.last.viewportRect.bottom, viewportRect.bottom),
    );
  }

  Rect get visibleGridOuterRect {
    return Rect.fromLTRB(
      max(visibleContent.rows.first.viewportRect.left, viewportRect.left),
      min(visibleContent.columns.first.viewportRect.top, viewportRect.top),
      min(visibleContent.columns.last.viewportRect.right, viewportRect.right),
      min(visibleContent.rows.last.viewportRect.bottom, viewportRect.bottom),
    );
  }

  /// Converts the given [globalOffset], which is relative to the entire sheet,
  /// to a local offset relative to the visible grid within the viewport.
  Offset globalOffsetToLocal(Offset globalOffset) {
    ViewportOffsetTransformer transformer = ViewportOffsetTransformer(viewportRect, visibleGridInnerRect);
    return transformer.globalToLocal(globalOffset);
  }

  /// Sets the viewport rectangle to the given [rect], and rebuilds the visible
  /// content if the viewport size has changed.
  void setViewportRect(Rect rect) {
    if (rect == viewportRect) return;
    _viewportRect = rect;
    _scrollController.setViewportSize(rect.size);
    visibleContent.rebuild(_viewportRect, _scrollPosition);
  }

  void ensureIndexFullyVisible(SheetIndex index) {
    ViewportCell viewportCell = visibleContent.findCellOrClosest(index.toCellIndex()).value;
    Offset scrollOffset = _scrollController.offset;

    Rect itemRect = viewportCell.getSheetPosition(scrollOffset);
    Rect sheetRect = visibleGridInnerRect.shift(scrollOffset);

    double leftDelta = sheetRect.left - itemRect.left;
    double rightDelta = itemRect.right - sheetRect.right;
    double topDelta = sheetRect.top - itemRect.top;
    double bottomDelta = itemRect.bottom - sheetRect.bottom;

    if(leftDelta > 0) {
      print('leftDelta: $leftDelta');
    }
    if(rightDelta > 0) {
      print('rightDelta: $rightDelta');
    }
    if(topDelta > 0) {
      print('topDelta: $topDelta');
    }
    if(bottomDelta > 0) {
      print('bottomDelta: $bottomDelta');
    }

    // _scrollController.scrollTo(newOffset);
  }

  /// Updates the scroll position of the viewport when the [scrollController]
  /// notifies a change, and rebuilds the visible content accordingly.
  void _updateScrollPosition(SheetScrollController scrollController) {
    _scrollPosition = scrollController.position;
    visibleContent.rebuild(_viewportRect, _scrollPosition);
  }

  /// Updates the sheet properties and rebuilds the visible content whenever
  /// the [sheetProperties] change.
  void _updateSheetProperties(SheetProperties sheetProperties) {
    _scrollController.applyProperties(sheetProperties);

    visibleContent.applyProperties(sheetProperties);
    visibleContent.rebuild(_viewportRect, _scrollPosition);
  }
}
