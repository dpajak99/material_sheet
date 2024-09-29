import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sheets/controller/index.dart';
import 'package:sheets/controller/program_config.dart';
import 'package:sheets/utils/direction.dart';

enum SelectionDirection { topRight, topLeft, bottomRight, bottomLeft }

class SelectionCorners<T> with EquatableMixin {
  final T topLeft;
  final T topRight;
  final T bottomLeft;
  final T bottomRight;

  SelectionCorners(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);

  factory SelectionCorners.fromDirection({
    required T topLeft,
    required T topRight,
    required T bottomLeft,
    required T bottomRight,
    required SelectionDirection direction,
  }) {
    switch (direction) {
      case SelectionDirection.bottomRight:
        return SelectionCorners(topLeft, topRight, bottomLeft, bottomRight);
      case SelectionDirection.bottomLeft:
        return SelectionCorners(topRight, topLeft, bottomRight, bottomLeft);
      case SelectionDirection.topRight:
        return SelectionCorners(bottomLeft, bottomRight, topLeft, topRight);
      case SelectionDirection.topLeft:
        return SelectionCorners(bottomRight, bottomLeft, topRight, topLeft);
    }
  }

  @override
  List<Object?> get props => <Object?>[topLeft, topRight, bottomLeft, bottomRight];
}

class SelectionCellCorners extends SelectionCorners<CellIndex> {
  SelectionCellCorners(super.topLeft, super.topRight, super.bottomLeft, super.bottomRight);

  factory SelectionCellCorners.fromDirection({
    required CellIndex topLeft,
    required CellIndex topRight,
    required CellIndex bottomLeft,
    required CellIndex bottomRight,
    required SelectionDirection direction,
  }) {
    switch (direction) {
      case SelectionDirection.bottomRight:
        return SelectionCellCorners(topLeft, topRight, bottomLeft, bottomRight);
      case SelectionDirection.bottomLeft:
        return SelectionCellCorners(topRight, topLeft, bottomRight, bottomLeft);
      case SelectionDirection.topRight:
        return SelectionCellCorners(bottomLeft, bottomRight, topLeft, topRight);
      case SelectionDirection.topLeft:
        return SelectionCellCorners(bottomRight, bottomLeft, topRight, topLeft);
    }
  }

  Direction getRelativePosition(CellIndex cellIndex) {
    Map<Direction, int> directionSpaces = {
      Direction.top: cellIndex.rowIndex.value - topLeft.rowIndex.value,
      Direction.left: cellIndex.columnIndex.value - topLeft.columnIndex.value,
      Direction.bottom: bottomRight.rowIndex.value - cellIndex.rowIndex.value,
      Direction.right: bottomRight.columnIndex.value - cellIndex.columnIndex.value,
    };

    print('Direction Spaces: $directionSpaces');
    return directionSpaces.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  int get topIndex => topLeft.rowIndex.value;

  int get bottomIndex => bottomLeft.rowIndex.value;

  int get leftIndex => topLeft.columnIndex.value;

  int get rightIndex => topRight.columnIndex.value;

  @override
  List<Object?> get props => <Object?>[topLeft, topRight, bottomLeft, bottomRight];
}

class SelectionBounds {
  final SelectionCorners<Rect> _corners;
  final CellConfig startCell;
  final bool _startCellVisible;
  final List<Direction> _hiddenBorders;

  SelectionBounds._({
    required SelectionCorners<Rect> corners,
    required this.startCell,
    required bool startCellVisible,
    required List<Direction> hiddenBorders,
  })  : _corners = corners,
        _startCellVisible = startCellVisible,
        _hiddenBorders = hiddenBorders;

  factory SelectionBounds(
    CellConfig startCell,
    CellConfig endCell,
    SelectionDirection direction, {
    List<Direction>? hiddenBorders,
    bool startCellVisible = true,
    bool lastCellVisible = true,
  }) {
    SelectionCorners<Rect> corners = SelectionCorners<Rect>.fromDirection(
      topLeft: startCell.rect,
      bottomRight: endCell.rect,
      topRight: Rect.fromPoints(
        Offset(endCell.rect.left, startCell.rect.top),
        Offset(endCell.rect.right, startCell.rect.bottom),
      ),
      bottomLeft: Rect.fromPoints(
        Offset(startCell.rect.left, endCell.rect.top),
        Offset(startCell.rect.right, endCell.rect.bottom),
      ),
      direction: direction,
    );

    return SelectionBounds._(
      corners: corners,
      startCell: startCell,
      startCellVisible: startCellVisible,
      hiddenBorders: hiddenBorders ?? [],
    );
  }

  bool get isStartCellVisible => _startCellVisible;

  Rect get mainCellRect => startCell.rect;

  Rect get selectionRect {
    return Rect.fromPoints(_corners.topLeft.topLeft, _corners.bottomRight.bottomRight);
  }

  bool get isLeftBorderVisible => !_hiddenBorders.contains(Direction.left);

  bool get isTopBorderVisible => !_hiddenBorders.contains(Direction.top);

  bool get isRightBorderVisible => !_hiddenBorders.contains(Direction.right);

  bool get isBottomBorderVisible => !_hiddenBorders.contains(Direction.bottom);
}
