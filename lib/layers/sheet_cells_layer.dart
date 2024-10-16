import 'package:flutter/material.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/controller/sheet_controller.dart';

class SheetCellsLayer extends StatefulWidget {
  final SheetController sheetController;

  const SheetCellsLayer({
    required this.sheetController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SheetCellsLayerState();
}

class _SheetCellsLayerState extends State<SheetCellsLayer> {
  late final _SheetCellsPainter _sheetCellsPainter;

  @override
  void initState() {
    super.initState();
    _sheetCellsPainter = _SheetCellsPainter(visibleCells: widget.sheetController.viewport.visibleContent.cells);
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
      child: CustomPaint(painter: _sheetCellsPainter),
    );
  }

  void _updateVisibleCells() {
    _sheetCellsPainter.visibleCells = widget.sheetController.viewport.visibleContent.cells;
  }
}

class _SheetCellsPainter extends _SheetCellsBasePainter {
  _SheetCellsPainter({
    required List<ViewportCell> visibleCells,
  }) : _visibleCells = visibleCells;

  late List<ViewportCell> _visibleCells;

  set visibleCells(List<ViewportCell> value) {
    _visibleCells = value;
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (ViewportCell cell in _visibleCells) {
      paintCellBackground(canvas, cell);
      paintCellBorder(canvas, cell);
      paintCellText(canvas, cell);
    }
  }

  @override
  bool shouldRepaint(covariant _SheetCellsPainter oldDelegate) {
    return _visibleCells != oldDelegate._visibleCells;
  }
}

abstract class _SheetCellsBasePainter extends ChangeNotifier implements CustomPainter {
  void paintCellBackground(Canvas canvas, ViewportCell cell) {
    Paint backgroundPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    canvas.drawRect(cell.rect, backgroundPaint);
  }

  void paintCellBorder(Canvas canvas, ViewportCell cell) {
    Paint borderPaint = Paint()
      ..color = const Color(0xffe1e1e1)
      ..strokeWidth = borderWidth
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cell.rect, borderPaint);
  }

  void paintCellText(Canvas canvas, ViewportCell cell) {
    // TextPainter textPainter = TextPainter(
    //   text: TextSpan(text: cell.value, style: defaultTextStyle),
    //   textDirection: TextDirection.ltr,
    //   maxLines: 3,
    // );
    //
    // textPainter.layout();
    // textPainter.paint(canvas, cell.rect.topLeft + const Offset(5, 5));
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
