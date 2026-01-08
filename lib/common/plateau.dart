// lib/models/plateau.dart
// Modified: 2512091506

class Plateau {
  final int width;
  final int height;
  final List<List<int>> grid;

  const Plateau({
    required this.width,
    required this.height,
    required this.grid,
  });

  factory Plateau.empty(int width, int height) {
    return Plateau(
      width: width,
      height: height,
      grid: List.generate(
        height,
            (_) => List.filled(width, -1),
      ),
    );
  }

  factory Plateau.allVisible(int width, int height) {
    return Plateau(
      width: width,
      height: height,
      grid: List.generate(
        height,
            (_) => List.filled(width, 0),
      ),
    );
  }

  int get numVisibleCells {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell >= 0) count++;
      }
    }
    return count;
  }

  int get numFreeCells {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell == 0) count++;
      }
    }
    return count;
  }

  bool isInBounds(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  int getCell(int x, int y) {
    if (!isInBounds(x, y)) return -1;
    return grid[y][x];
  }

  void setCell(int x, int y, int value) {
    if (isInBounds(x, y)) {
      grid[y][x] = value;
    }
  }

  Plateau copy() {
    return Plateau(
      width: width,
      height: height,
      grid: grid.map((row) => List<int>.from(row)).toList(),
    );
  }
}