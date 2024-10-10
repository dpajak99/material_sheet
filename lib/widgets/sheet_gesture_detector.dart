import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/core/sheet_item_config.dart';
import 'package:sheets/listeners/mouse_listener.dart';
import 'package:sheets/utils/extensions/offset_extension.dart';

class SheetGestureDetector extends StatefulWidget {
  final SheetMouseListener mouseListener;
  final ValueChanged<Offset> onMouseOffsetChanged;

  const SheetGestureDetector({
    required this.mouseListener,
    required this.onMouseOffsetChanged,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SheetGestureDetectorState();
}

class _SheetGestureDetectorState extends State<SheetGestureDetector> {
  bool _pressActive = false;
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.mouseListener.cursor,
      builder: (BuildContext context, SystemMouseCursor cursor, _) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handlePointerDown,
          onPointerHover: _handlePointerHover,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              widget.mouseListener.scroll(event.scrollDelta);
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
    if(widget.mouseListener.customTapHovered) return;
    _notifyOffsetChanged(event.localPosition);
    _pressActive = true;
    _onPanStart();
  }

  void _handlePointerHover(PointerHoverEvent event) {
    _notifyOffsetChanged(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _notifyOffsetChanged(event.localPosition);
    if(_pressActive) {
      _onPanUpdate();
    }
  }
  
  void _handlePointerUp(PointerUpEvent event) {
    _notifyOffsetChanged(event.localPosition);
    _pressActive = false;
    _onPanEnd();
  }
  

  void _onPanStart() {
    SheetItemConfig? hoveredItem = widget.mouseListener.hoveredItem.value;
    if (hoveredItem != null) {
      widget.mouseListener.dragStart(hoveredItem);
    }
  }

  void _onPanUpdate() {
    widget.mouseListener.dragUpdate();
  }

  void _onPanEnd() {
    widget.mouseListener.dragEnd();
  }

  void _notifyOffsetChanged(Offset value) {
    widget.onMouseOffsetChanged(value.limitMin(0, 0));
  }
}
