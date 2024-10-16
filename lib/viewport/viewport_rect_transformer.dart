import 'package:flutter/material.dart';

class ViewportRectTransformer {
  final Rect globalRect;

  ViewportRectTransformer(this.globalRect);

  Rect globalToLocal(Rect rect) {
    return Rect.fromLTWH(rect.left - globalRect.left, rect.top - globalRect.top, rect.width, rect.height);
  }
}
