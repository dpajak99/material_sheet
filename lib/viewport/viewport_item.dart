import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';

abstract class ViewportItem with EquatableMixin {
  final Rect viewportRect;

  ViewportItem({
    required this.viewportRect,
  });

  String get value;

  SheetIndex get index;

  Rect getSheetPosition(Offset scrollOffset) {
    return Rect.fromLTWH(
      viewportRect.left + scrollOffset.dx,
      viewportRect.top + scrollOffset.dy,
      viewportRect.width,
      viewportRect.height,
    );
  }
}

class ViewportRow extends ViewportItem {
  final RowIndex _index;
  final RowStyle _style;

  ViewportRow({
    required super.viewportRect,
    required RowIndex index,
    required RowStyle style,
  })  : _index = index,
        _style = style;

  @override
  String toString() {
    return 'Row(${_index.value})';
  }

  @override
  String get value => '${_index.value + 1}';

  @override
  RowIndex get index => _index;

  RowStyle get style => _style;

  @override
  List<Object?> get props => <Object?>[_index, _style, viewportRect];
}

class ViewportColumn extends ViewportItem {
  final ColumnIndex _index;
  final ColumnStyle _style;

  ViewportColumn({
    required super.viewportRect,
    required ColumnIndex index,
    required ColumnStyle style,
  })  : _index = index,
        _style = style;

  @override
  String toString() {
    return 'Column(${_index.value})';
  }

  @override
  String get value {
    return numberToExcelColumn(_index.value + 1);
  }

  @override
  ColumnIndex get index => _index;

  ColumnStyle get style => _style;

  String numberToExcelColumn(int number) {
    String result = '';

    while (number > 0) {
      number--; // Excel columns start from 1, not 0, hence this adjustment
      result = String.fromCharCode(65 + (number % 26)) + result;
      number = (number ~/ 26);
    }

    return result;
  }

  @override
  List<Object?> get props => <Object?>[_index, _style, viewportRect];
}

class ViewportCell extends ViewportItem {
  final CellIndex _index;
  final ViewportRow _row;
  final ViewportColumn _column;
  final String _value;

  ViewportCell({
    required super.viewportRect,
    required CellIndex index,
    required ViewportRow row,
    required ViewportColumn column,
    required String value,
  })  : _index = index,
        _row = row,
        _column = column,
        _value = value;

  factory ViewportCell.fromColumnRow(ViewportColumn column, ViewportRow row, {required String value}) {
    return ViewportCell(
      value: value,
      row: row,
      column: column,
      index: CellIndex(rowIndex: row.index, columnIndex: column.index),
      viewportRect: Rect.fromLTWH(
        column.viewportRect.left,
        row.viewportRect.top,
        column.viewportRect.width,
        row.viewportRect.height,
      ),
    );
  }

  @override
  CellIndex get index => _index;

  @override
  String get value {
    return _value.isEmpty ? '${_column.value}${_row.value}' : _value;
  }

  ViewportRow get row => _row;

  ViewportColumn get column => _column;

  @override
  List<Object?> get props => <Object?>[viewportRect, _index, _row, _column, _value];
}
