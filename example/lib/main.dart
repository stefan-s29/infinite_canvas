import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

import 'generated_nodes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GeneratedNodes(
          initialCanvasConfig: CanvasConfig(
        gridSize: Size(32.0, 32.0),
        minimumGridSize: Size(16.0, 16.0),
        maximumGridSize: Size(128.0, 128.0),
        dragHandleSize: Size(10, 10),
        minimumNodeSize: Size(32, 32),
        maximumNodeSize: Size(256, 256),
        snapMovementToGrid: true,
        snapResizeToGrid: true,
      )),
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
    );
  }
}
