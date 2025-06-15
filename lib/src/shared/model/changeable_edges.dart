import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'changeable_edges.freezed.dart';

@freezed
class ChangeableEdges with _$ChangeableEdges {
  const factory ChangeableEdges({
    required bool left,
    required bool top,
    required bool right,
    required bool bottom,
  }) = _ChangeableEdges;

  factory ChangeableEdges.fromAlignment(Alignment alignment) => ChangeableEdges(
      left: alignment.x < 0,
      top: alignment.y < 0,
      right: alignment.x > 0,
      bottom: alignment.y > 0);

  static const all = ChangeableEdges(
    left: true,
    top: true,
    right: true,
    bottom: true,
  );

  static const none = ChangeableEdges(
    left: false,
    top: false,
    right: false,
    bottom: false,
  );
}
