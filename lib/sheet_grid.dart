import 'package:flutter/material.dart';
import 'package:sheets/controller/program_config.dart';
import 'package:sheets/controller/sheet_cursor_controller.dart';
import 'package:sheets/multi_listenable_builder.dart';
import 'package:sheets/painters/headers_painter.dart';
import 'package:sheets/painters/selection_painter.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/painters/sheet_painter.dart';
import 'package:sheets/sheet_constants.dart';

class FillHandleOffset extends StatelessWidget {
  final SheetCursorController cursorController;

  const FillHandleOffset({
    required this.cursorController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        cursorController.isFilling = true;
        cursorController.dragStart(details, subtract: const Offset(4, 4));
        cursorController.setCursor(SystemMouseCursors.basic, SystemMouseCursors.precise);
      },
      onPanUpdate: (DragUpdateDetails details) {
        cursorController.dragUpdate(details, subtract: const Offset(4, 4));
      },
      onPanEnd: (DragEndDetails details) {
        cursorController.isFilling = false;
        cursorController.dragEnd(details);
        cursorController.setCursor(SystemMouseCursors.precise, SystemMouseCursors.basic);
      },
      child: MouseRegion(
        onEnter: (_) {
          cursorController.setCursor(SystemMouseCursors.basic, SystemMouseCursors.precise);
        },
        onExit: (_) {
          cursorController.setCursor(SystemMouseCursors.precise, SystemMouseCursors.basic);
        },
        child: const SizedBox(height: 8, width: 8),
      ),
    );
  }
}

class HorizontalResizeDivider extends StatefulWidget {
  final RowConfig rowConfig;
  final SheetCursorController cursorController;

  const HorizontalResizeDivider({
    required this.rowConfig,
    required this.cursorController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _HorizontalResizeDividerState();
}

class _HorizontalResizeDividerState extends State<HorizontalResizeDivider> {
  bool hoverVisible = false;
  bool hovered = false;
  double delta = 0;
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.rowConfig.rect.bottom - 5.5 + delta,
      left: widget.rowConfig.rect.left,
      right: 0,
      child: Stack(
        children: [
          if (hoverVisible) ...<Widget>[
            SizedBox(
              width: widget.rowConfig.rect.width,
              height: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: 16,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 3,
                    width: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            if (dragging) Container(height: 5, width: double.infinity, color: const Color(0xffc4c7c5), margin: const EdgeInsets.symmetric(vertical: 3)),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              if (widget.cursorController.hasActiveAction == false) {
                setState(() {
                  dragging = true;
                  hoverVisible = true;
                });
                delta = 0;
                widget.cursorController.resizedRow = widget.rowConfig;
              }
            },
            onPanUpdate: (details) {
              if (details.globalPosition.dy >= widget.rowConfig.rect.top + 10 + columnHeadersHeight) {
                widget.cursorController.cursorListener.value = SystemMouseCursors.resizeRow;
                setState(() => delta += details.delta.dy);
              } else {
                widget.cursorController.cursorListener.value = SystemMouseCursors.basic;
              }
            },
            onPanEnd: (_) {
              widget.cursorController.resizedRow = null;
              widget.cursorController.sheetController.resizeRowBy(widget.rowConfig, delta);
              setState(() {
                dragging = false;
                hoverVisible = hovered;
                delta = 0;
              });
              widget.cursorController.cursorListener.value = hovered ? SystemMouseCursors.resizeRow : SystemMouseCursors.basic;
            },
            child: MouseRegion(
              opaque: true,
              onEnter: (_) {
                hovered = true;
                if (widget.cursorController.hasActiveAction == false) {
                  setState(() => hoverVisible = true);
                  widget.cursorController.setCursor(SystemMouseCursors.basic, SystemMouseCursors.resizeRow);
                }
              },
              onExit: (_) {
                hovered = false;
                if (widget.cursorController.hasActiveAction == false) {
                  setState(() => hoverVisible = false);
                  widget.cursorController.setCursor(SystemMouseCursors.resizeRow, SystemMouseCursors.basic);
                }
              },
              child: SizedBox(
                width: widget.rowConfig.rect.width,
                height: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalResizeDivider extends StatefulWidget {
  final ColumnConfig columnConfig;
  final SheetCursorController cursorController;

  const VerticalResizeDivider({
    required this.columnConfig,
    required this.cursorController,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _VerticalResizeDividerState();
}

class _VerticalResizeDividerState extends State<VerticalResizeDivider> {
  bool hoverVisible = false;
  bool hovered = false;
  double delta = 0;
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.columnConfig.rect.top,
      left: widget.columnConfig.rect.right - 5.5 + delta,
      bottom: 0,
      child: Stack(
        children: [
          if (hoverVisible) ...<Widget>[
            SizedBox(
              width: 11,
              height: widget.columnConfig.rect.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: 3,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 16,
                    width: 3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            if (dragging) Container(width: 5, height: double.infinity, color: const Color(0xffc4c7c5), margin: const EdgeInsets.symmetric(horizontal: 3)),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              if (widget.cursorController.hasActiveAction == false) {
                setState(() {
                  dragging = true;
                  hoverVisible = true;
                });
                delta = 0;
                widget.cursorController.resizedColumn = widget.columnConfig;
              }
            },
            onPanUpdate: (details) {
              if (details.globalPosition.dx >= widget.columnConfig.rect.left + 10) {
                widget.cursorController.cursorListener.value = SystemMouseCursors.resizeColumn;
                setState(() => delta += details.delta.dx);
              } else {
                widget.cursorController.cursorListener.value = SystemMouseCursors.basic;
              }
            },
            onPanEnd: (_) {
              widget.cursorController.resizedColumn = null;
              widget.cursorController.sheetController.resizeColumnBy(widget.columnConfig, delta);
              setState(() {
                dragging = false;
                hoverVisible = hovered;
                delta = 0;
              });
              widget.cursorController.cursorListener.value = hovered ? SystemMouseCursors.resizeColumn : SystemMouseCursors.basic;
            },
            child: MouseRegion(
              opaque: true,
              onEnter: (_) {
                hovered = true;
                if (widget.cursorController.hasActiveAction == false) {
                  setState(() => hoverVisible = true);
                  widget.cursorController.setCursor(SystemMouseCursors.basic, SystemMouseCursors.resizeColumn);
                }
              },
              onExit: (_) {
                hovered = false;
                if (widget.cursorController.hasActiveAction == false) {
                  setState(() => hoverVisible = false);
                  widget.cursorController.setCursor(SystemMouseCursors.resizeColumn, SystemMouseCursors.basic);
                }
              },
              child: SizedBox(
                width: 11,
                height: widget.columnConfig.rect.height,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SheetTextField extends StatelessWidget {
  final CellConfig cellConfig;

  const SheetTextField({super.key, required this.cellConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffa8c7fa), width: 2, strokeAlign: BorderSide.strokeAlignOutside),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xff3572e3), width: 2),
        ),
        child: IntrinsicWidth(
          child: TextField(
            autofocus: true,
            controller: TextEditingController(text: cellConfig.value),
            style: defaultTextStyle,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            ),
          ),
        ),
      ),
    );
  }
}
