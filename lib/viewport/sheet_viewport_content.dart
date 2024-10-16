import 'package:flutter/material.dart';
import 'package:sheets/core/scroll/sheet_scroll_position.dart';
import 'package:sheets/viewport/sheet_viewport_rect.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/closest_visible.dart';
import 'package:sheets/utils/directional_values.dart';
import 'package:sheets/viewport/renderers/visible_cells_renderer.dart';
import 'package:sheets/viewport/renderers/visible_columns_renderer.dart';
import 'package:sheets/viewport/renderers/visible_rows_renderer.dart';
import 'package:sheets/viewport/sheet_viewport_content_data.dart';

/// [SheetViewportContent] is responsible for managing the visible content
/// within the viewport of the sheet. It calculates and updates the rows,
/// columns, and cells that should be rendered based on the provided viewport
/// rectangle and scroll positions.
///
/// This class also exposes methods to query the visible cells and interact
/// with the viewport content.
class SheetViewportContent extends ChangeNotifier {
  final SheetViewportContentData _data = SheetViewportContentData();
  late SheetProperties _properties;

  /// Applies the provided [SheetProperties] to this viewport content manager.
  ///
  /// The properties determine configuration details such as row heights,
  /// column widths, and other layout settings for the viewport.
  void applyProperties(SheetProperties properties) {
    _properties = properties;
  }

  /// Rebuilds the visible content within the viewport based on the provided
  /// [viewportRect] and [scrollPosition].
  ///
  /// This method calculates the visible rows, columns, and cells, updating
  /// the internal state, and then notifies any listeners of the changes.
  void rebuild(SheetViewportRect viewportRect, DirectionalValues<SheetScrollPosition> scrollPosition) {
    List<ViewportRow> rows = _calculateRows(viewportRect, scrollPosition);
    List<ViewportColumn> columns = _calculateColumns(viewportRect, scrollPosition);
    List<ViewportCell> cells = _calculateCells(rows, columns);

    _data.update(rows, columns, cells);
    notifyListeners();
  }

  /// Returns the list of currently visible rows in the viewport.
  List<ViewportRow> get rows => _data.rows;

  /// Returns the list of currently visible columns in the viewport.
  List<ViewportColumn> get columns => _data.columns;

  /// Returns the list of currently visible cells in the viewport.
  List<ViewportCell> get cells => _data.cells;

  /// Returns all visible sheet items (rows, columns, cells) in the viewport.
  List<ViewportItem> get all => _data.all;

  bool containsCell(CellIndex cellIndex) => _data.containsCell(cellIndex.toRealIndex(_properties));

  ClosestVisible<ViewportCell> findCellOrClosest(CellIndex cellIndex) {
    return _data.findCellOrClosest(cellIndex.toRealIndex(_properties));
  }

  ViewportCell? findCell(CellIndex cellIndex) => _data.findCell(cellIndex.toRealIndex(_properties));

  ViewportItem? findAnyByOffset(Offset mousePosition) => _data.findAnyByOffset(mousePosition);

  ClosestVisible<ViewportCell> findClosestCell(CellIndex cellIndex) => _data.findClosestCell(cellIndex.toRealIndex(_properties));

  List<ViewportRow> _calculateRows(SheetViewportRect viewportRect, DirectionalValues<SheetScrollPosition> scrollPosition) {
    return VisibleRowsRenderer(properties: _properties, viewportRect: viewportRect, scrollPosition: scrollPosition).build();
  }

  List<ViewportColumn> _calculateColumns(SheetViewportRect viewportRect, DirectionalValues<SheetScrollPosition> scrollPosition) {
    return VisibleColumnsRenderer(properties: _properties, viewportRect: viewportRect, scrollPosition: scrollPosition).build();
  }

  List<ViewportCell> _calculateCells(List<ViewportRow> visibleRows, List<ViewportColumn> visibleColumns) {
    return VisibleCellsRenderer(visibleRows: visibleRows, visibleColumns: visibleColumns).build();
  }
}
