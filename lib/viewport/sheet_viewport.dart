import 'package:flutter/material.dart';
import 'package:sheets/controller/sheet_scroll_controller.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/viewport/sheet_viewport_content.dart';
import 'package:sheets/viewport/sheet_viewport_rect.dart';

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

  late SheetViewportRect viewportRect;

  /// Creates a [SheetViewport] that updates visible content based on the
  /// provided [properties] and [scrollController].
  ///
  /// The content within the viewport is initialized and rebuilt when necessary.
  SheetViewport(SheetProperties properties, SheetScrollController scrollController)
      : _scrollController = scrollController,
        _properties = properties {
    _scrollPosition = _scrollController.position;
    _scrollController.applyProperties(properties);

    viewportRect = SheetViewportRect(Rect.zero);

    visibleContent.applyProperties(_properties);
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

  double get width => viewportRect.width;

  double get height => viewportRect.height;

  Rect get innerRectLocal {
    return viewportRect.innerRectLocal;
  }

  Rect get outerRectLocal {
    return viewportRect.local;
  }

  Offset globalOffsetToLocal(Offset globalOffset) {
    return viewportRect.globalOffsetToLocal(globalOffset);
  }

  /// Sets the viewport rectangle to the given [rect], and rebuilds the visible
  /// content if the viewport size has changed.
  void setViewportRect(Rect rect) {
    if (viewportRect.isEquivalent(rect)) return;

    viewportRect = SheetViewportRect(rect);
    visibleContent.rebuild(viewportRect, _scrollPosition);

    _scrollController.setViewportSize(rect.size);
  }

  void ensureIndexFullyVisible(SheetIndex index) {
    Offset scrollOffset = _scrollController.offset;

    Rect sheetCoords = index.getSheetCoordinates(_properties);
    double sheetHeight = viewportRect.innerRectLocal.height;
    double sheetWidth = viewportRect.innerRectLocal.width;

    double topMargin = sheetCoords.top;
    double bottomMargin = sheetCoords.bottom;
    double leftMargin = sheetCoords.left;
    double rightMargin = sheetCoords.right;

    if(topMargin < scrollOffset.dy) {
      _scrollController.scrollToVertical(sheetCoords.top - 1);
    } else if(bottomMargin > scrollOffset.dy + sheetHeight) {
      _scrollController.scrollToVertical(sheetCoords.bottom - sheetHeight + 1);
    } else if(leftMargin < scrollOffset.dx) {
      _scrollController.scrollToHorizontal(sheetCoords.left - 1);
    } else if(rightMargin > scrollOffset.dx + sheetWidth) {
      _scrollController.scrollToHorizontal(sheetCoords.right - sheetWidth + 1);
    }
  }

  /// Updates the scroll position of the viewport when the [scrollController]
  /// notifies a change, and rebuilds the visible content accordingly.
  void _updateScrollPosition(SheetScrollController scrollController) {
    _scrollPosition = scrollController.position;
    visibleContent.rebuild(viewportRect, _scrollPosition);
  }

  /// Updates the sheet properties and rebuilds the visible content whenever
  /// the [sheetProperties] change.
  void _updateSheetProperties(SheetProperties sheetProperties) {
    _scrollController.applyProperties(sheetProperties);

    visibleContent.applyProperties(sheetProperties);
    visibleContent.rebuild(viewportRect, _scrollPosition);
  }
}
