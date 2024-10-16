import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/listeners/mouse_listener.dart';
import 'package:sheets/recognizers/pan_hold_recognizer.dart';
import 'package:sheets/sheet.dart';

class SheetDraggable extends StatefulWidget {
  final Size actionSize;
  final SystemMouseCursor cursor;
  final SystemMouseCursor? dragCursor;
  final ValueChanged<Offset>? onDragStart;
  final ValueChanged<Offset>? onDragDeltaChanged;
  final ValueChanged<Offset>? onDragEnd;
  final Positioned? Function(bool hovered, bool dragged)? builder;
  final Widget? child;
  final Offset? dragBarrierStart;
  final bool limitDragToBounds;

  const SheetDraggable({
    required this.actionSize,
    required this.cursor,
    this.onDragStart,
    this.onDragDeltaChanged,
    this.onDragEnd,
    SystemMouseCursor? dragCursor,
    this.builder,
    this.child,
    this.dragBarrierStart,
    this.limitDragToBounds = false,
    super.key,
  }) : dragCursor = dragCursor ?? cursor;

  @override
  State<StatefulWidget> createState() => _SheetDraggableState();
}

class _SheetDraggableState extends State<SheetDraggable> {
  final PanHoldRecognizer _panHoldRecognizer = PanHoldRecognizer();
  late final SheetMouseListener mouse = Sheet.of(context).mouseListener;

  Offset _dragDelta = Offset.zero;
  bool _hoverInProgress = false;
  bool _dragInProgress = false;

  @override
  Widget build(BuildContext context) {
    Widget? child = widget.child ?? widget.builder!.call(_hoverInProgress, _dragInProgress);

    return Stack(
      children: <Widget>[
        if (child != null) child,
        Positioned(
          width: widget.actionSize.width,
          height: widget.actionSize.height,
          child: MouseRegion(
            opaque: false,
            hitTestBehavior: HitTestBehavior.translucent,
            onHover: _handlePointerHover,
            onExit: (_) {
              if (_dragInProgress) return;
              _resetCursor();
            },
            child: Listener(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePointerHover(PointerHoverEvent event) {
    _setHovered();
  }

  void _handlePointerDown(PointerDownEvent event) {
    mouse.disable();
    mouse.setCursor(widget.cursor);
    mouse.setGlobalOffset(event.position);

    _onPanStart(event);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_dragInProgress == false) return;

    _panHoldRecognizer.reset();

    _onPanUpdate(event);

    _panHoldRecognizer.start(() => _handlePointerMove(event));
  }

  void _handlePointerUp(PointerUpEvent details) {
    _onPanEnd();
    _resetCursor();
  }

  void _onPanStart(PointerDownEvent event) {
    _dragInProgress = true;
    widget.onDragStart?.call(event.position);
  }

  void _onPanUpdate(PointerMoveEvent event) {
    bool barrierStartReached =
        widget.dragBarrierStart != null && (event.position.dy < widget.dragBarrierStart!.dy || event.position.dx < widget.dragBarrierStart!.dx);
    bool barrierEndReached = false;

    if (widget.limitDragToBounds) {
      Offset dragBarrierEnd = Offset(mouse.viewport.innerRectLocal.right, mouse.viewport.innerRectLocal.bottom);
      barrierEndReached = event.position.dy > dragBarrierEnd.dy || event.position.dx > dragBarrierEnd.dx;
    }

    if (barrierStartReached || barrierEndReached) {
      mouse.resetCursor();
      return;
    } else {
      mouse.setCursor(widget.cursor);
    }

    _dragDelta += event.delta;
    widget.onDragDeltaChanged?.call(_dragDelta);
  }

  void _onPanEnd() {
    widget.onDragEnd?.call(_dragDelta);
    _dragDelta = Offset.zero;
  }

  void _setHovered() {
    if (_dragInProgress) return;
    if (mouse.nativeDragging) return;
    if (mouse.disabled) return;

    mouse.customTapHovered = true;
    if (_hoverInProgress == false) {
      setState(() {
        _hoverInProgress = true;
        _dragInProgress = false;
      });
      mouse.setCursor(widget.cursor);
    }
  }

  void _resetCursor() {
    mouse.enable();
    mouse.customTapHovered = false;
    mouse.resetCursor();

    _hoverInProgress = false;
    _dragInProgress = false;

    if (mounted) {
      setState(() {});
    }
  }
}
