import 'package:flutter/material.dart';

class DragHandleAlignment {
  final Alignment alignment;

  const DragHandleAlignment(this.alignment);

  bool get isLeft => alignment.x < 0;
  bool get isRight => alignment.x > 0;
  bool get isTop => alignment.y < 0;
  bool get isBottom => alignment.y > 0;
  bool get isHorizontalCenter => alignment.x == 0;
  bool get isVerticalCenter => alignment.y == 0;
}
