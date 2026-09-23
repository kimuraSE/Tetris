/// 標準テトロミノ7種と各向きの相対セル。
enum TetrominoType { I, J, L, O, S, T, Z }

class Cell {
  const Cell(this.x, this.y);
  final int x;
  final int y;

  Cell translate(int dx, int dy) => Cell(x + dx, y + dy);
}

/// 原点はピースのバウンディング寄りの基準。各回転は 0..3。
class TetrominoShapes {
  TetrominoShapes._();

  static const Map<TetrominoType, List<List<Cell>>> shapes = {
    TetrominoType.I: [
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(3, 1)],
      [Cell(2, 0), Cell(2, 1), Cell(2, 2), Cell(2, 3)],
      [Cell(0, 2), Cell(1, 2), Cell(2, 2), Cell(3, 2)],
      [Cell(1, 0), Cell(1, 1), Cell(1, 2), Cell(1, 3)],
    ],
    TetrominoType.J: [
      [Cell(0, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(2, 2)],
      [Cell(1, 0), Cell(1, 1), Cell(0, 2), Cell(1, 2)],
    ],
    TetrominoType.L: [
      [Cell(2, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(1, 2), Cell(2, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(0, 2)],
      [Cell(0, 0), Cell(1, 0), Cell(1, 1), Cell(1, 2)],
    ],
    TetrominoType.O: [
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(2, 1)],
    ],
    TetrominoType.S: [
      [Cell(1, 0), Cell(2, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(2, 1), Cell(2, 2)],
      [Cell(1, 1), Cell(2, 1), Cell(0, 2), Cell(1, 2)],
      [Cell(0, 0), Cell(0, 1), Cell(1, 1), Cell(1, 2)],
    ],
    TetrominoType.T: [
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(1, 2)],
    ],
    TetrominoType.Z: [
      [Cell(0, 0), Cell(1, 0), Cell(1, 1), Cell(2, 1)],
      [Cell(2, 0), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(1, 2), Cell(2, 2)],
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(0, 2)],
    ],
  };

  static List<Cell> cells(TetrominoType type, int rotation) {
    final variants = shapes[type]!;
    return variants[rotation % 4];
  }
}

class ActivePiece {
  ActivePiece({
    required this.type,
    required this.x,
    required this.y,
    this.rotation = 0,
  });

  final TetrominoType type;
  int x;
  int y;
  int rotation;

  List<Cell> absoluteCells() {
    return TetrominoShapes.cells(type, rotation)
        .map((c) => Cell(c.x + x, c.y + y))
        .toList();
  }

  ActivePiece copy() =>
      ActivePiece(type: type, x: x, y: y, rotation: rotation);
}
