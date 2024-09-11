import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheets/controller/custom_scroll_controller.dart';
import 'package:sheets/controller/index.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/controller/style.dart';
import 'package:sheets/painters/paint/sheet_paint_config.dart';
import 'package:sheets/scroll_wrapper.dart';
import 'package:sheets/sheet_footer.dart';
import 'package:sheets/sheet_grid.dart';

class SheetWidget extends StatefulWidget {
  const SheetWidget({super.key});

  @override
  State<SheetWidget> createState() => SheetWidgetState();
}

class SheetWidgetState extends State<SheetWidget> {
  final SheetController sheetController = SheetController(
    scrollController: SheetScrollController(),
    sheetProperties: SheetProperties(
      customColumnProperties: {
        // ColumnIndex(3): ColumnStyle(width: 200),
      },
      customRowProperties: {
        RowIndex(8): RowStyle(height: 100),
      },
    ),
  );

  CellIndex? dragStart;

  bool shiftPressed = false;

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollWrapper(
            sheetController: sheetController,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      sheetController.mouseListener.dragStart(details);
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      sheetController.mouseListener.dragUpdate(details);
                    },
                    onPanEnd: (DragEndDetails details) {
                      sheetController.mouseListener.dragEnd(details);
                    },
                    onTap: () {
                      sheetController.mouseListener.tap();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerSignal: (PointerSignalEvent event) {
                        if (event is PointerScrollEvent) {
                          if (shiftPressed) {
                            sheetController.mouseListener.scrollBy(Offset(event.scrollDelta.dy, event.scrollDelta.dx));
                          } else {
                            sheetController.mouseListener.scrollBy(event.scrollDelta);
                          }
                        }
                      },
                      child: SheetGrid(sheetController: sheetController, mouseListener: sheetController.mouseListener),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: sheetController.mouseListener.cursorListener,
                  builder: (BuildContext context, SystemMouseCursor cursor, _) {
                    return Positioned.fill(
                      child: MouseRegion(
                        opaque: false,
                        cursor: cursor,
                        onHover: (event) => sheetController.mouseListener.updateOffset(event.localPosition),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SheetFooter(sheetController: sheetController, mouseListener: sheetController.mouseListener),
      ],
    );
  }

  bool _onKey(KeyEvent event) {
    int key = event.logicalKey.keyId;

    if (event is KeyDownEvent) {
      if (key == 8589934850) {
        shiftPressed = true;
      }
    } else if (event is KeyUpEvent) {
      if (key == 8589934850) {
        shiftPressed = false;
      }
    } else if (event is KeyRepeatEvent) {
      if (key == 8589934850) {
        shiftPressed = true;
      }
    }

    return false;
  }
}
