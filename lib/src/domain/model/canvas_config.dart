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

  static const CanvasConfig defaultConfig = CanvasConfig(
    gridSize: Size(32.0, 32.0),
    minimumGridSize: Size(16.0, 16.0),
    maximumGridSize: Size(128.0, 128.0),
    dragHandleSize: Size(10, 10),
    minimumNodeSize: Size(32, 32),
    maximumNodeSize: Size(256, 256),
    snapMovementToGrid: false,
    snapResizeToGrid: false,
  );
}
