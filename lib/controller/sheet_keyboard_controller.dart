import 'package:flutter/services.dart';

class SheetKeyboardController {
  List<LogicalKeyboardKey> activeKeys = [];

  void addKey(LogicalKeyboardKey logicalKeyboardKey) {
    activeKeys.add(logicalKeyboardKey);
  }

  void removeKey(LogicalKeyboardKey logicalKeyboardKey) {
    activeKeys.remove(logicalKeyboardKey);
  }

  bool isKeyPressed(LogicalKeyboardKey logicalKeyboardKey) {
    return activeKeys.contains(logicalKeyboardKey);
  }

  bool get anyKeyActive => activeKeys.isNotEmpty;
}
