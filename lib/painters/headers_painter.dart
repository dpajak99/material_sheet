

import 'package:flutter/material.dart';
import 'package:sheets/controller/program_config.dart';
import 'package:sheets/controller/selection/types/sheet_selection.dart';
import 'package:sheets/controller/sheet_controller.dart';
import 'package:sheets/sheet_constants.dart';

abstract class HeadersPainter extends CustomPainter {
  void paintHeadersBackground(Canvas canvas, Rect rect, SelectionStatus selectionStatus) {
    Color backgroundColor = selectionStatus.selectValue(
      fullySelected: const Color(0xff2456cb),
      selected: const Color(0xffd6e2fb),
      notSelected: const Color(0xffffffff),
    );

    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, backgroundPaint);
  }

  void paintHeadersBorder(Canvas canvas, Rect rect, {bool top = true}) {
    Paint borderPaint = Paint()
      ..color = const Color(0xffc4c7c5)
      ..strokeWidth = borderWidth
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;

    if(top) {
      canvas.drawLine(rect.topLeft, rect.topRight, borderPaint);
    }
    canvas.drawLine(rect.topRight, rect.bottomRight, borderPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, borderPaint);
    canvas.drawLine(rect.topLeft, rect.bottomLeft, borderPaint);
  }

  void paintHeadersLabel(Canvas canvas, Rect rect, String value, SelectionStatus selectionStatus) {
    TextStyle textStyle = selectionStatus.selectValue(
      fullySelected: defaultHeaderTextStyleSelectedAll,
      selected: defaultHeaderTextStyleSelected,
      notSelected: defaultHeaderTextStyle,
    );

    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(text: value, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: rect.width, maxWidth: rect.width);
    textPainter.paint(canvas, rect.center - Offset(textPainter.width / 2, textPainter.height / 2));
  }
}

class ColumnHeadersPainter extends HeadersPainter {
  final SheetController sheetController;

  ColumnHeadersPainter({
    required this.sheetController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (ColumnConfig column in sheetController.visibilityController.visibleColumns) {
      SelectionStatus selectionStatus = sheetController.selectionController.selection.isColumnSelected(column.columnIndex);

      paintHeadersBackground(canvas, column.rect, selectionStatus);
      paintHeadersBorder(canvas, column.rect, top: false);
      paintHeadersLabel(canvas, column.rect, column.value, selectionStatus);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RowHeadersPainter extends HeadersPainter {
  final SheetController sheetController;

  RowHeadersPainter({
    required this.sheetController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (RowConfig row in sheetController.visibilityController.visibleRows) {
      SelectionStatus selectionStatus = sheetController.selectionController.selection.isRowSelected(row.rowIndex);

      paintHeadersBackground(canvas, row.rect, selectionStatus);
      paintHeadersBorder(canvas, row.rect);
      paintHeadersLabel(canvas, row.rect, row.value, selectionStatus);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
