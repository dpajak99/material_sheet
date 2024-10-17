import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/core/config/sheet_constants.dart';
import 'package:sheets/core/sheet_properties.dart';
import 'package:sheets/utils/extensions/int.dart';
import 'package:sheets/utils/numeric_index_mixin.dart';

sealed class SheetIndex with EquatableMixin {
  String stringifyPosition();

  static SheetIndex matchType(SheetIndex base, SheetIndex other) {
    switch (base) {
      case CellIndex _:
        return switch (other) {
          CellIndex other => other,
          ColumnIndex other => CellIndex(columnIndex: other, rowIndex: RowIndex.zero),
          RowIndex other => CellIndex(rowIndex: other, columnIndex: ColumnIndex.zero),
        };
      case ColumnIndex _:
        return switch (other) {
          CellIndex other => other.columnIndex,
          ColumnIndex other => other,
          RowIndex _ => ColumnIndex.zero,
        };
      case RowIndex _:
        return switch (other) {
          CellIndex other => other.rowIndex,
          ColumnIndex _ => RowIndex.zero,
          RowIndex other => other,
        };
    }
  }

  SheetIndex toRealIndex(SheetProperties properties);

  Rect getSheetCoordinates(SheetProperties properties);

  CellIndex toCellIndex() {
    return switch (this) {
      CellIndex cellIndex => cellIndex,
      ColumnIndex columnIndex => CellIndex.fromColumnMin(columnIndex),
      RowIndex rowIndex => CellIndex.fromRowMin(rowIndex),
    };
  }

  @override
  String toString() {
    return stringifyPosition();
  }
}

class CellIndex extends SheetIndex {
  final RowIndex rowIndex;
  final ColumnIndex columnIndex;

  CellIndex({
    required this.rowIndex,
    required this.columnIndex,
  });

  factory CellIndex.fromColumnMin(ColumnIndex columnIndex) {
    return CellIndex(rowIndex: RowIndex.zero, columnIndex: columnIndex);
  }

  factory CellIndex.fromColumnMax(ColumnIndex columnIndex) {
    return CellIndex(rowIndex: RowIndex.max, columnIndex: columnIndex);
  }

  factory CellIndex.fromRowMin(RowIndex rowIndex) {
    return CellIndex(rowIndex: rowIndex, columnIndex: ColumnIndex.zero);
  }

  factory CellIndex.fromRowMax(RowIndex rowIndex) {
    return CellIndex(rowIndex: rowIndex, columnIndex: ColumnIndex.max);
  }

  static CellIndex zero = CellIndex(rowIndex: RowIndex(0), columnIndex: ColumnIndex(0));

  static CellIndex max = CellIndex(rowIndex: RowIndex.max, columnIndex: ColumnIndex.max);

  @override
  CellIndex toRealIndex(SheetProperties properties) {
    ColumnIndex realColumnIndex = columnIndex.toRealIndex(properties);
    RowIndex realRowIndex = rowIndex.toRealIndex(properties);

    return CellIndex(rowIndex: realRowIndex, columnIndex: realColumnIndex);
  }

  @override
  Rect getSheetCoordinates(SheetProperties properties) {
    double x = 0;
    for (int i = 0; i < columnIndex.value; i++) {
      double columnWidth = properties.getColumnWidth(ColumnIndex(i));
      x += columnWidth;
    }

    double width = properties.getColumnWidth(columnIndex);

    double y = 0;
    for (int i = 0; i < rowIndex.value; i++) {
      double rowHeight = properties.getRowHeight(RowIndex(i));
      y += rowHeight;
    }

    double height = properties.getRowHeight(rowIndex);

    return Rect.fromLTWH(x, y, width, height);
  }

  CellIndex move(int rowOffset, int columnOffset) {
    int movedRow = rowIndex.value + rowOffset;
    int movedColumn = columnIndex.value + columnOffset;

    return CellIndex(
      rowIndex: RowIndex(movedRow < 0 ? 0 : movedRow),
      columnIndex: ColumnIndex(movedColumn < 0 ? 0 : movedColumn),
    );
  }

  CellIndex clamp(CellIndex max) {
    return CellIndex(rowIndex: rowIndex.clamp(max.rowIndex), columnIndex: columnIndex.clamp(max.columnIndex));
  }

  @override
  String stringifyPosition() {
    return '${columnIndex.stringifyPosition()}${rowIndex.stringifyPosition()}';
  }

  @override
  List<Object?> get props => <Object?>[rowIndex, columnIndex];
}

class ColumnIndex extends SheetIndex with NumericIndexMixin implements Comparable<ColumnIndex> {
  final int _value;

  ColumnIndex(this._value);

  static ColumnIndex zero = ColumnIndex(0);

  static ColumnIndex max = ColumnIndex(Int.max);

  @override
  ColumnIndex toRealIndex(SheetProperties properties) {
    if (this == max) {
      return ColumnIndex(properties.columnCount - 1);
    } else {
      return this;
    }
  }

  @override
  Rect getSheetCoordinates(SheetProperties properties) {
    double x = 0;
    for (int i = 0; i < value; i++) {
      double columnWidth = properties.getColumnWidth(ColumnIndex(i));
      x += columnWidth;
    }

    double width = properties.getColumnWidth(this);

    return Rect.fromLTWH(x, 0, width, columnHeadersHeight);
  }

  ColumnIndex operator -(int number) {
    return ColumnIndex(value - number);
  }

  ColumnIndex move(int number) {
    return ColumnIndex(value + number);
  }

  @override
  int get value => _value;

  @override
  String stringifyPosition() {
    return numberToExcelColumn(value + 1);
  }

  String numberToExcelColumn(int number) {
    String result = '';

    while (number > 0) {
      number--;
      result = String.fromCharCode(65 + (number % 26)) + result;
      number = (number ~/ 26);
    }

    return result;
  }

  ColumnIndex clamp(ColumnIndex max) {
    return ColumnIndex(value.clamp(0, max.value));
  }

  @override
  int compareTo(NumericIndexMixin other) {
    if (other is ColumnIndex) {
      return value.compareTo(other.value);
    } else {
      return -1;
    }
  }

  @override
  List<Object?> get props => <Object?>[value];
}

class RowIndex extends SheetIndex with NumericIndexMixin implements Comparable<RowIndex> {
  final int _value;

  RowIndex(this._value);

  static RowIndex zero = RowIndex(0);

  static RowIndex max = RowIndex(Int.max);

  @override
  RowIndex toRealIndex(SheetProperties properties) {
    if (this == max) {
      return RowIndex(properties.rowCount - 1);
    } else {
      return this;
    }
  }

  @override
  int get value => _value;

  @override
  Rect getSheetCoordinates(SheetProperties properties) {
    double y = 0;
    for (int i = 0; i < value; i++) {
      double rowHeight = properties.getRowHeight(RowIndex(i));
      y += rowHeight;
    }

    double height = properties.getRowHeight(this);

    return Rect.fromLTWH(0, y, rowHeadersWidth, height);
  }

  RowIndex move(int number) {
    return RowIndex(value + number);
  }

  RowIndex clamp(RowIndex max) {
    return RowIndex(value.clamp(0, max.value));
  }

  @override
  String stringifyPosition() {
    return (value + 1).toString();
  }

  RowIndex operator +(int number) {
    return RowIndex(value + number);
  }

  @override
  int compareTo(NumericIndexMixin other) {
    if (other is RowIndex) {
      return value.compareTo(other.value);
    } else {
      return -1;
    }
  }

  @override
  List<Object?> get props => <Object?>[_value];
}
