import 'package:sheets/core/selection/sheet_selection.dart';
import 'package:sheets/core/selection/strategies/gesture_selection_strategy.dart';
import 'package:sheets/core/sheet_index.dart';

class GestureSelectionBuilder {
  final SheetSelection _previousSelection;
  late GestureSelectionStrategy _selectionStrategy;

  GestureSelectionBuilder(
    SheetSelection previousSelection,
  ) : _previousSelection = previousSelection;

  void setStrategy(GestureSelectionStrategy selectionStrategy) {
    _selectionStrategy = selectionStrategy;
  }

  SheetSelection build(SheetIndex selectedIndex) {
    return _selectionStrategy.execute(_previousSelection, selectedIndex);
  }
}
