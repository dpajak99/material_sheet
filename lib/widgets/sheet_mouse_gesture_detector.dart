import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/gestures/sheet_drag_gesture.dart';
import 'package:sheets/recognizers/mouse_action_recognizer.dart';
import 'package:sheets/recognizers/pan_hold_recognizer.dart';
import 'package:sheets/utils/streamable.dart';
import 'package:sheets/viewport/viewport_item.dart';

class SheetMouseGestureDetector extends StatefulWidget {
  final MouseListener mouseListener;
  final Widget child;

  const SheetMouseGestureDetector({
    required this.mouseListener,
    required this.child,
    super.key,
  });

  static SheetMouseGestureDetectorState of(BuildContext context) {
    return context.findAncestorStateOfType<SheetMouseGestureDetectorState>()!;
  }

  @override
  State<StatefulWidget> createState() => SheetMouseGestureDetectorState();
}

class SheetMouseGestureDetectorState extends State<SheetMouseGestureDetector> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: widget.child),
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerHover: widget.mouseListener._onHover,
            onPointerDown: widget.mouseListener._onDragStart,
            onPointerMove: widget.mouseListener._onDragUpdate,
            onPointerUp: widget.mouseListener._onDragEnd,
            child: ValueListenableBuilder<SystemMouseCursor>(
              valueListenable: widget.mouseListener.cursor,
              builder: (BuildContext context, SystemMouseCursor cursor, Widget? child) {
                return MouseRegion(
                  opaque: false,
                  hitTestBehavior: HitTestBehavior.translucent,
                  cursor: cursor,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MouseListener extends Streamable<SheetMouseGesture> {
  MouseListener({
    required this.mouseActionRecognizers,
    required this.sheetController,
  }) {
    cursor = ValueNotifier<SystemMouseCursor>(SystemMouseCursors.basic);
  }

  late final ValueNotifier<SystemMouseCursor> cursor;
  final PanHoldRecognizer _panHoldRecognizer = PanHoldRecognizer();
  final List<MouseActionRecognizer> mouseActionRecognizers;
  final SheetController sheetController;

  Offset _localOffset = Offset.zero;

  MouseCursorDetails? _dragStartDetails;

  @override
  void add(SheetMouseGesture event) {
    super.add(event);
    _resolveGesture(event);
  }

  void insertRecognizer(MouseActionRecognizer recognizer) {
    mouseActionRecognizers.insert(0, recognizer);
  }

  Future<void> removeRecognizer(MouseActionRecognizer recognizer) async {
    if(recognizer is CustomDragRecognizer && recognizer.action.isActive) {
      await recognizer.action.future;
      mouseActionRecognizers.remove(recognizer);
    } else {
      mouseActionRecognizers.remove(recognizer);
    }
  }

  void setCursor(SystemMouseCursor systemMouseCursor) {
    cursor.value = systemMouseCursor;
  }

  void resetCursor() {
    cursor.value = SystemMouseCursors.basic;
  }

  set globalOffset(Offset globalOffset) {
    Offset localOffset = sheetController.viewport.globalOffsetToLocal(globalOffset);
    if (_localOffset == localOffset) return;

    _localOffset = localOffset;
  }

  void _onHover(PointerHoverEvent event) {
    globalOffset = event.position;

    add(SheetMouseMoveGesture(_localOffset));
  }

  void _onDragStart(PointerDownEvent event) {
    globalOffset = event.position;
    MouseCursorDetails dragStartDetails = cursorDetails;

    _dragStartDetails = dragStartDetails;
    add(SheetDragStartGesture(dragStartDetails));
  }

  void _onDragUpdate(PointerMoveEvent event) {
    globalOffset = event.position;

    if (_dragStartDetails != null) {
      _panHoldRecognizer.reset();
      _panHoldRecognizer.start(() => _onDragUpdate(event));

      add(SheetDragUpdateGesture(startDetails: _dragStartDetails!, updateDetails: cursorDetails));
    }
  }

  void _onDragEnd(PointerUpEvent event) {
    globalOffset = event.position;
    _panHoldRecognizer.reset();

    if (_dragStartDetails != null) {
      add(SheetDragEndGesture(startDetails: _dragStartDetails!, endDetails: cursorDetails));
    }
  }

  MouseCursorDetails get cursorDetails {
    ViewportItem? hoveredItem = sheetController.viewport.visibleContent.findAnyByOffset(_localOffset);

    return MouseCursorDetails(
      localOffset: _localOffset,
      scrollPosition: sheetController.scroll.offset,
      hoveredItem: hoveredItem,
    );
  }

  void _resolveGesture(SheetMouseGesture gesture) {
    List<CustomDragRecognizer> customDragRecognizers = mouseActionRecognizers.whereType<CustomDragRecognizer>().toList();
    for(CustomDragRecognizer recognizer in customDragRecognizers) {
      if(recognizer.action.isActive) {
        recognizer.action.resolve(sheetController, gesture);
        return;
      }
    }

    for(MouseActionRecognizer recognizer in mouseActionRecognizers) {
      MouseAction? action = recognizer.recognize(sheetController, gesture);
      if (action != null) {
        action.resolve(sheetController, gesture);
        return;
      }
    }
  }
}
