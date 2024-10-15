import 'package:flutter/material.dart';
import 'package:sheets/selection/sheet_selection.dart';
import 'package:sheets/selection/sheet_selection_renderer.dart';
import 'package:sheets/selection/types/sheet_single_selection.dart';
import 'package:sheets/viewport/sheet_viewport.dart';

class SelectionState extends ChangeNotifier {
  late SheetSelection value;

  SelectionState.defaultSelection() {
    value = SheetSingleSelection.defaultSelection();
  }

  void complete() {
    value = value.complete();
    notifyListeners();
  }

  void update(SheetSelection selection) {
    value = selection;
    notifyListeners();
  }

  SheetSelectionRenderer<SheetSelection> createRenderer(SheetViewport viewport) {
    return value.createRenderer(viewport);
  }
  
  String stringify() {
    return value.stringifySelection();
  }
}