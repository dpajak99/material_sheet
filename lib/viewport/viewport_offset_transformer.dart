import 'package:flutter/material.dart';

/// [ViewportOffsetTransformer] is responsible for transforming a global offset
/// (from the entire application) into a local offset relative to the visible grid
/// within the viewport.
///
/// This class also limits the local offset to ensure it stays within the
/// boundaries of the visible grid.
class ViewportOffsetTransformer {
  /// The rectangle representing the entire sheet area.
  final Rect globalRect;

  /// Creates a [ViewportOffsetTransformer] that converts global offsets to
  /// local ones, using the provided [globalRect] and [visibleGridRect].
  ViewportOffsetTransformer(this.globalRect);

  /// Transforms the given [globalOffset], which is relative to the entire sheet,
  /// into a local offset relative to the visible grid.
  ///
  /// The resulting local offset is limited to the bounds of the [visibleGridRect].
  Offset globalToLocal(Offset globalOffset) {
    Offset localOffset = Offset(globalOffset.dx - globalRect.left, globalOffset.dy - globalRect.top);

    return Offset(
      localOffset.dx.clamp(0, globalRect.width),
      localOffset.dy.clamp(0, globalRect.height),
    );
  }
}
