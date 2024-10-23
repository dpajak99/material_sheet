import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_controller.dart';
import 'package:sheets/layers/cells/sheet_cells_layer_painter.dart';
import 'package:sheets/layers/mesh/sheet_mesh_layer_painter.dart';

class SheetCellsLayer extends StatefulWidget {
  const SheetCellsLayer({
    required this.sheetController,
    super.key,
  });

  final SheetController sheetController;

  @override
  State<StatefulWidget> createState() => _SheetCellsLayerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheetController>('sheetController', sheetController));
  }
}

class _SheetCellsLayerState extends State<SheetCellsLayer> {
  late final SheetCellsLayerPainter _layerPainter;

  @override
  void initState() {
    super.initState();
    _layerPainter = SheetCellsLayerPainter(
      visibleCells: widget.sheetController.viewport.visibleContent.cells,
    );
    widget.sheetController.viewport.visibleContent.addListener(_updateVisibleCells);
  }

  @override
  void dispose() {
    widget.sheetController.viewport.visibleContent.removeListener(_updateVisibleCells);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: _layerPainter),
    );
  }

  void _updateVisibleCells() {
    _layerPainter.update(widget.sheetController.viewport.visibleContent.cells);
  }
}
