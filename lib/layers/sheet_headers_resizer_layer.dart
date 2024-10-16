import 'package:flutter/material.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/widgets/sheet_draggable.dart';

double _kGapSize = 5;
double _kWeight = 3;
double _kLength = 16;

class HeadersResizerLayer extends StatelessWidget {
  final SheetController sheetController;

  const HeadersResizerLayer({
    required this.sheetController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: _VerticalHeadersResizerLayer(sheetController: sheetController)),
        Positioned.fill(child: _HorizontalHeadersResizerLayer(sheetController: sheetController)),
      ],
    );
  }
}

class _VerticalHeadersResizerLayer extends StatefulWidget {
  final SheetController sheetController;

  const _VerticalHeadersResizerLayer({required this.sheetController});

  @override
  State<StatefulWidget> createState() => _VerticalHeadersResizerLayerState();
}

class _VerticalHeadersResizerLayerState extends State<_VerticalHeadersResizerLayer> {
  List<ViewportColumn> _visibleColumns = <ViewportColumn>[];

  @override
  void initState() {
    super.initState();
    _updateVisibleColumns();
    widget.sheetController.viewport.visibleContent.addListener(_updateVisibleColumns);
  }

  @override
  void dispose() {
    widget.sheetController.viewport.visibleContent.removeListener(_updateVisibleColumns);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: _visibleColumns.map((ViewportColumn column) {
        return _VerticalHeaderResizer(
          height: widget.sheetController.viewport.visibleGridOuterRect.height,
          column: column,
          onResize: (Offset delta) => widget.sheetController.resizeColumnBy(column.index, delta.dx),
        );
      }).toList(),
    );
  }

  void _updateVisibleColumns() {
    setState(() => _visibleColumns = widget.sheetController.viewport.visibleContent.columns);
  }
}

class _VerticalHeaderResizer extends StatefulWidget {
  final double height;
  final ViewportColumn column;
  final ValueChanged<Offset> onResize;

  const _VerticalHeaderResizer({
    required this.height,
    required this.column,
    required this.onResize,
  });

  @override
  State<StatefulWidget> createState() => _VerticalHeaderResizerState();
}

class _VerticalHeaderResizerState extends State<_VerticalHeaderResizer> {
  double _dragDelta = 0;

  @override
  Widget build(BuildContext context) {
    Rect columnRect = widget.column.viewportRect;
    double marginTop = columnRect.top + (columnRect.height - _kLength) / 2;
    double dividerWidth = _kGapSize + _kWeight * 2;

    return Positioned(
      top: widget.column.viewportRect.top,
      left: widget.column.viewportRect.right - (_kGapSize / 2) - _kWeight + _dragDelta,
      bottom: 0,
      width: dividerWidth,
      child: SheetDraggable(
        scrollOnDrag: false,
        limitDragToBounds: true,
        dragBarrierStart: Offset(widget.column.viewportRect.left + 20, 0),
        onDragDeltaChanged: _handleDragDeltaChanged,
        onDragEnd: (Offset offset) {
          widget.onResize(offset);
          _dragDelta = 0;
        },
        cursor: SystemMouseCursors.resizeColumn,
        actionSize: Size(dividerWidth, columnRect.height),
        builder: (bool hovered, bool dragged) {
          if (hovered == false) return null;

          return Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(width: _kWeight, height: _kLength, margin: EdgeInsets.only(top: marginTop), color: Colors.black),
                if (dragged) ...<Widget>[
                  Container(width: _kGapSize, height: widget.height, color: const Color(0xffc4c7c5)),
                ] else ...<Widget>[
                  SizedBox(width: _kGapSize),
                ],
                Container(width: _kWeight, height: _kLength, margin: EdgeInsets.only(top: marginTop), color: Colors.black),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleDragDeltaChanged(Offset value) {
    setState(() => _dragDelta = value.dx);
  }
}

class _HorizontalHeadersResizerLayer extends StatefulWidget {
  final SheetController sheetController;

  const _HorizontalHeadersResizerLayer({required this.sheetController});

  @override
  State<StatefulWidget> createState() => _HorizontalHeadersResizerLayerState();
}

class _HorizontalHeadersResizerLayerState extends State<_HorizontalHeadersResizerLayer> {
  List<ViewportRow> _visibleRows = <ViewportRow>[];

  @override
  void initState() {
    super.initState();
    _updateVisibleRows();
    widget.sheetController.viewport.visibleContent.addListener(_updateVisibleRows);
  }

  @override
  void dispose() {
    widget.sheetController.viewport.visibleContent.removeListener(_updateVisibleRows);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: _visibleRows.map((ViewportRow row) {
        return _HorizontalHeaderResizer(
          width: widget.sheetController.viewport.visibleGridOuterRect.width,
          row: row,
          onResize: (Offset delta) => widget.sheetController.resizeRowBy(row.index, delta.dy),
        );
      }).toList(),
    );
  }

  void _updateVisibleRows() {
    setState(() => _visibleRows = widget.sheetController.viewport.visibleContent.rows);
  }
}

class _HorizontalHeaderResizer extends StatefulWidget {
  final double width;
  final ViewportRow row;
  final ValueChanged<Offset> onResize;

  const _HorizontalHeaderResizer({
    required this.width,
    required this.row,
    required this.onResize,
  });

  @override
  State<StatefulWidget> createState() => _HorizontalHeaderResizerState();
}

class _HorizontalHeaderResizerState extends State<_HorizontalHeaderResizer> {
  double _dragDelta = 0;

  @override
  Widget build(BuildContext context) {
    Rect rowRect = widget.row.viewportRect;
    double marginLeft = rowRect.left + (rowRect.width - _kLength) / 2;
    double dividerHeight = _kGapSize + _kWeight * 2;

    return Positioned(
      top: widget.row.viewportRect.bottom - (_kGapSize / 2) - _kWeight + _dragDelta,
      left: 0,
      right: 0,
      height: dividerHeight,
      child: SheetDraggable(
        scrollOnDrag: false,
        limitDragToBounds: true,
        dragBarrierStart: Offset(0, widget.row.viewportRect.top + 20),
        onDragDeltaChanged: _handleDragDeltaChanged,
        onDragEnd: (Offset offset) {
          widget.onResize(offset);
          _dragDelta = 0;
        },
        cursor: SystemMouseCursors.resizeRow,
        actionSize: Size(rowRect.width, dividerHeight),
        builder: (bool hovered, bool dragged) {
          if (hovered == false) return null;

          return Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(width: _kLength, height: _kWeight, margin: EdgeInsets.only(left: marginLeft), color: Colors.black),
                if (dragged) ...<Widget>[
                  Container(height: _kGapSize, width: widget.width, color: const Color(0xffc4c7c5)),
                ] else ...<Widget>[
                  SizedBox(height: _kGapSize),
                ],
                Container(width: _kLength, height: _kWeight, margin: EdgeInsets.only(left: marginLeft), color: Colors.black),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleDragDeltaChanged(Offset value) {
    setState(() => _dragDelta = value.dy);
  }
}
