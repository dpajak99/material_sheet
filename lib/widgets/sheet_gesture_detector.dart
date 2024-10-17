import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/viewport/viewport_item.dart';
import 'package:sheets/viewport/sheet_viewport.dart';
import 'package:sheets/listeners/mouse_listener.dart';
import 'package:sheets/recognizers/pan_hold_recognizer.dart';

// TODO(dominik): Rename to Selection gesture detector??
class SheetGestureDetector extends StatefulWidget {
  final SheetController sheetController;

  const SheetGestureDetector({
    required this.sheetController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SheetGestureDetectorState();
}

class _SheetGestureDetectorState extends State<SheetGestureDetector> {
  final PanHoldRecognizer _panHoldRecognizer = PanHoldRecognizer();
  bool _pressActive = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SystemMouseCursor>(
      valueListenable: mouseListener.cursor,
      builder: (BuildContext context, SystemMouseCursor cursor, _) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handlePointerDown,
          onPointerHover: _handlePointerHover,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              mouseListener.scroll(event.scrollDelta);
            }
          },
          child: MouseRegion(
            opaque: false,
            hitTestBehavior: HitTestBehavior.translucent,
            cursor: cursor,
          ),
        );
      },
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (mouseListener.customTapHovered) return;

    _pressActive = true;
    mouseListener.setGlobalOffset(event.position);
    _onPanStart();
  }

  void _handlePointerHover(PointerHoverEvent event) {
    mouseListener.setGlobalOffset(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _panHoldRecognizer.reset();

    mouseListener.setGlobalOffset(event.position);

    if (_pressActive) {
      _onPanUpdate();
      _panHoldRecognizer.start(() => _handlePointerMove(event));
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _panHoldRecognizer.reset();

    mouseListener.setGlobalOffset(event.position);

    _pressActive = false;
    _onPanEnd();
  }

  void _onPanStart() {
    ViewportItem? hoveredItem = mouseListener.hoveredItem;
    if (hoveredItem != null) {
      mouseListener.dragStart(hoveredItem);
    }
  }

  void _onPanUpdate() {
    mouseListener.dragUpdate();
  }

  void _onPanEnd() {
    mouseListener.dragEnd();
  }

  SheetMouseListener get mouseListener => widget.sheetController.mouse;

  SheetViewport get viewport => widget.sheetController.viewport;
}

