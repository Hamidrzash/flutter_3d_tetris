import 'dart:ui';

enum TetrominoType { I, J, L, O, S, T, Z }

enum Direction { down, right, left, up }

extension TetrisCubeColor on TetrominoType {
  Color get color => switch (this) {
        TetrominoType.I => const Color(0xff0341AE),
        TetrominoType.J => const Color(0xff72CB3B),
        TetrominoType.L => const Color(0xff72CB3B),
        TetrominoType.O => const Color(0xffFFD500),
        TetrominoType.S => const Color(0xffFF971C),
        TetrominoType.T => const Color(0xffFF3213),
        TetrominoType.Z => const Color(0xffFF971C),
      };

  List<List<bool>> getShape(int rotation) {
    List<List<bool>> shape;
    switch (this) {
      case TetrominoType.I:
        shape = [
          [true, true, true, true],
        ];
        break;
      case TetrominoType.J:
        shape = [
          [true, false, false],
          [true, true, true],
        ];
        break;
      case TetrominoType.L:
        shape = [
          [false, false, true],
          [true, true, true],
        ];
        break;
      case TetrominoType.O:
        shape = [
          [true, true],
          [true, true],
        ];
        break;
      case TetrominoType.S:
        shape = [
          [false, true, true],
          [true, true, false],
        ];
        break;
      case TetrominoType.T:
        shape = [
          [false, true, false],
          [true, true, true],
        ];
        break;
      case TetrominoType.Z:
        shape = [
          [true, true, false],
          [false, true, true],
        ];
        break;
    }
    final fixedRotation = rotation % 4;
    for (int i = 0; i < fixedRotation; i++) {
      shape = _rotate90Degrees(shape);
    }
    return shape;
  }

  List<List<bool>> _rotate90Degrees(List<List<bool>> shape) {
    int rows = shape.length;
    int cols = shape[0].length;
    List<List<bool>> rotatedShape = List.generate(cols, (_) => List.filled(rows, false));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotatedShape[j][i] = shape[i][cols - 1 - j];
      }
    }

    return rotatedShape;
  }
}
