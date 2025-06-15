enum EdgeType {
  left,
  top,
  right,
  bottom;

  bool get isHorizontal => this == EdgeType.left || this == EdgeType.right;
  bool get isLeftOrTop => this == EdgeType.left || this == EdgeType.top;
}
