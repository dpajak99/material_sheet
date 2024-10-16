import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/sheet_item_index.dart';
import 'package:sheets/core/sheet_properties.dart';

abstract class ViewportItem with EquatableMixin {
  final Rect rect;

  ViewportItem({
    required this.rect,
  });

  String get value;

  SheetIndex get index;

  Rect getSheetRect(Offset scrollOffset) {
    return Rect.fromLTWH(
      rect.left + scrollOffset.dx,
      rect.top + scrollOffset.dy,
      rect.width,
      rect.height,
    );
  }
}

class ViewportRow extends ViewportItem {
  final RowIndex _index;
  final RowStyle _style;

  ViewportRow({
    required super.rect,
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
  List<Object?> get props => <Object?>[_index, _style, rect];
}

class ViewportColumn extends ViewportItem {
  final ColumnIndex _index;
  final ColumnStyle _style;

  ViewportColumn({
    required super.rect,
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
  List<Object?> get props => <Object?>[_index, _style, rect];
}

class ViewportCell extends ViewportItem {
  final CellIndex _index;
  final ViewportRow _row;
  final ViewportColumn _column;
  final String _value;

  ViewportCell({
    required super.rect,
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
      rect: Rect.fromLTWH(
        column.rect.left,
        row.rect.top,
        column.rect.width,
        row.rect.height,
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
  List<Object?> get props => <Object?>[rect, _index, _row, _column, _value];
}
