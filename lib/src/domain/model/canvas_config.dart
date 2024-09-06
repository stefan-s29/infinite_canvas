import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'canvas_config.freezed.dart';

@freezed
class CanvasConfig with _$CanvasConfig {
  const factory CanvasConfig({
    required Size gridSize,
    required Size minimumGridSize,
    required Size maximumGridSize,
    required Size dragHandleSize,
    required Size minimumNodeSize,
    required Size maximumNodeSize,
    required bool snapMovementToGrid,
    required bool snapResizeToGrid,
  }) = _CanvasConfig;
}
