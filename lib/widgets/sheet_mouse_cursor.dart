import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/recognizers/mouse_action_recognizer.dart';
import 'package:sheets/recognizers/pan_hold_recognizer.dart';
import 'package:sheets/utils/streamable.dart';
import 'package:uuid/uuid.dart';

class SheetMouseCursor extends StatefulWidget {
  final Widget child;
  final ValueNotifier<SystemMouseCursor> cursor;
  final List<MouseActionRecognizer> mouseActionRecognizers;
  final SheetController sheetController;

  const SheetMouseCursor({
    required this.child,
    required this.cursor,
    required this.mouseActionRecognizers,
    required this.sheetController,
    super.key,
  });

  static SheetMouseCursorState of(BuildContext context) {
    return context.findAncestorStateOfType<SheetMouseCursorState>()!;
  }

  @override
  State<StatefulWidget> createState() => SheetMouseCursorState();
}

class SheetMouseCursorState extends State<SheetMouseCursor> {
  final PanHoldRecognizer _panHoldRecognizer = PanHoldRecognizer();
  final Streamable<Offset> offset = Streamable<Offset>(Offset.zero);
  final Streamable<Offset> dragStartOffset = Streamable<Offset>();
  final Streamable<Offset> dragUpdateOffset = Streamable<Offset>();
  final Streamable<Offset> dragEndOffset = Streamable<Offset>();

  set globalOffset(Offset globalOffset) {
    Offset localOffset = widget.sheetController.viewport.globalOffsetToLocal(globalOffset);
    if(offset.value == localOffset) return;

    offset.add(localOffset);
  }

  String? globalPressId;
  String? childPressId;

  @override
  void initState() {
    super.initState();
    for (MouseActionRecognizer recognizer in widget.mouseActionRecognizers) {
      recognizer.setContext(this, widget.sheetController);
    }
  }

  @override
  void dispose() {
    offset.dispose();
    dragStartOffset.dispose();
    dragUpdateOffset.dispose();
    dragEndOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(child: widget.child),
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown,
            onPointerHover: _handlePointerHover,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: ValueListenableBuilder<SystemMouseCursor>(
              valueListenable: widget.cursor,
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

  void setCursor(SystemMouseCursor cursor) {
    widget.cursor.value = cursor;
  }

  void _handlePointerDown(PointerDownEvent event) {
    globalOffset = event.position;
    globalPressId ??= const Uuid().v4();
  }

  void _handlePointerHover(PointerHoverEvent event) {
    globalOffset = event.position;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    globalOffset = event.position;

    if(globalPressId != null) {
      _panHoldRecognizer.reset();
      _panHoldRecognizer.start(() => _handlePointerMove(event));
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    globalOffset = event.position;
    globalPressId = null;
    _panHoldRecognizer.reset();
  }
}
