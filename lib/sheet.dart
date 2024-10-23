import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/sheet_controller.dart';
import 'package:sheets/layers/cells/sheet_cells_layer.dart';
import 'package:sheets/layers/fill_handle/sheet_fill_handle_layer.dart';
import 'package:sheets/layers/headers/sheet_headers_layer.dart';
import 'package:sheets/layers/headers_resizer/sheet_headers_resizer_layer.dart';
import 'package:sheets/layers/mesh/sheet_mesh_layer.dart';
import 'package:sheets/layers/selection/sheet_selection_layer.dart';
import 'package:sheets/widgets/sheet_mouse_gesture_detector.dart';
import 'package:sheets/widgets/sheet_scrollable.dart';

class Sheet extends StatefulWidget {
  const Sheet({
    required this.sheetController,
    super.key,
  });

  final SheetController sheetController;

  @override
  State<StatefulWidget> createState() => _SheetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheetController>('sheetController', sheetController));
  }
}

class _SheetState extends State<Sheet> {
  SheetController get sheetController => widget.sheetController;

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKeyboardKeyPressed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xfff8faf8),
        ),
        child: SheetScrollable(
          scrollController: sheetController.scroll,
          child: SheetMouseGestureDetector(
            mouseListener: sheetController.mouse,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SheetContent(sheetController: sheetController);
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _onKeyboardKeyPressed(KeyEvent event) {
    if (event is KeyDownEvent) {
      sheetController.keyboard.addKey(event.logicalKey);
    } else if (event is KeyUpEvent) {
      sheetController.keyboard.removeKey(event.logicalKey);
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheetController>('sheetController', sheetController));
  }
}

class SheetContent extends StatefulWidget {
  const SheetContent({
    required this.sheetController,
    super.key,
  });

  final SheetController sheetController;

  @override
  State<StatefulWidget> createState() => SheetContentState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheetController>('sheetController', sheetController));
  }
}

class SheetContentState extends State<SheetContent> {
  final GlobalKey _sheetViewportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySheetViewportChanged());
  }

  @override
  void didUpdateWidget(covariant SheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySheetViewportChanged());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _sheetViewportKey,
      child: SheetGrid(sheetController: widget.sheetController),
    );
  }

  void _notifySheetViewportChanged() {
    RenderBox? renderBox = _sheetViewportKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    Offset position = renderBox.localToGlobal(Offset.zero);
    widget.sheetController.viewport.setViewportRect(Rect.fromLTRB(
      position.dx,
      position.dy,
      renderBox.size.width + position.dx,
      renderBox.size.height + position.dy,
    ));
  }
}

class SheetGrid extends StatelessWidget {
  const SheetGrid({
    required this.sheetController,
    super.key,
  });

  final SheetController sheetController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned(
          bottom: 0,
          left: 50,
          height: 50,
          child: Row(
            children: <Widget>[
              Text('Add more'),
            ],
          ),
        ),
        Positioned.fill(child: SheetMeshLayer(sheetController: sheetController)),
        Positioned.fill(child: SheetCellsLayer(sheetController: sheetController)),
        Positioned.fill(child: SheetHeadersLayer(sheetController: sheetController)),
        Positioned.fill(child: HeadersResizerLayer(sheetController: sheetController)),
        Positioned.fill(child: SheetSelectionLayer(sheetController: sheetController)),
        Positioned.fill(child: SheetFillHandleLayer(sheetController: sheetController)),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: rowHeadersWidth,
            height: columnHeadersHeight,
            decoration: const BoxDecoration(
              color: Color(0xfff8f9fa),
              border: Border(
                right: BorderSide(color: Color(0xffc7c7c7), width: 4),
                bottom: BorderSide(color: Color(0xffc7c7c7), width: 4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SheetController>('sheetController', sheetController));
  }
}
