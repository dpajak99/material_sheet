import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_controller.dart';
import 'package:sheets/core/mouse/mouse_gesture_handler.dart';
import 'package:sheets/core/mouse/sheet_draggable.dart';
import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/sheet_selection_renderer.dart';

class SheetFillHandleLayer extends StatefulWidget {
  final SheetController sheetController;

  const SheetFillHandleLayer({
    required this.sheetController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SheetFillHandleLayerState();
}

class SheetFillHandleLayerState extends State<SheetFillHandleLayer> {
  static const double _size = 10;

  late bool _visible;
  Offset? _offset;

  @override
  void initState() {
    super.initState();
    SheetSelectionRenderer<SheetSelection> selectionRenderer =
        widget.sheetController.selection.createRenderer(widget.sheetController.viewport);
    _visible = selectionRenderer.fillHandleVisible;
    _offset = selectionRenderer.fillHandleOffset;

    widget.sheetController.properties.addListener(_updateFillHandle);
    widget.sheetController.selection.addListener(_updateFillHandle);
    widget.sheetController.scroll.addListener(_updateFillHandle);
  }

  @override
  void dispose() {
    widget.sheetController.properties.removeListener(_updateFillHandle);
    widget.sheetController.selection.removeListener(_updateFillHandle);
    widget.sheetController.scroll.removeListener(_updateFillHandle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (_visible && _offset != null)
          Builder(
            builder: (BuildContext context) {
              Rect draggableAreaRect = Rect.fromLTWH(_offset!.dx - _size / 2, _offset!.dy - _size / 2, _size, _size);

              return Positioned(
                left: draggableAreaRect.left,
                top: draggableAreaRect.top,
                child: SheetDraggable(
                  handler: MouseFillGestureHandler(),
                  draggableAreaRect: draggableAreaRect,
                  mouseListener: widget.sheetController.mouse,
                  child: const _FillHandle(size: _size),
                ),
              );
            },
          ),
      ],
    );
  }

  void _updateFillHandle() {
    SheetSelectionRenderer<SheetSelection> selectionRenderer =
        widget.sheetController.selection.createRenderer(widget.sheetController.viewport);

    setState(() {
      _visible = selectionRenderer.fillHandleVisible;
      _offset = selectionRenderer.fillHandleOffset;
    });
  }
}

class _FillHandle extends StatelessWidget {
  final double size;

  const _FillHandle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff3572e3),
        border: Border.all(color: const Color(0xffffffff), width: 1),
      ),
    );
  }
}
