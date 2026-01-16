// Modified: 2025-11-15 06:45:00
// lib/models/game_piece.dart

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/point.dart';

class GamePiece {
  final Pento pento;
  final int currentOrientation;
  final bool isPlaced;
  final int? placedX;
  final int? placedY;

  const GamePiece({
    required this.pento,
    this.currentOrientation = 0,
    this.isPlaced = false,
    this.placedX,
    this.placedY,
  });

  List<int> get currentShape {
    return pento.orientations[currentOrientation];
  }

  static List<Point> shapeToCoordinates(List<int> shape) {
    return shape.map((cellNum) {
      int index = cellNum - 1;
      int row = index ~/ 5;
      int col = index % 5;
      return Point(col, row);
    }).toList();
  }

  List<Point> get currentCoordinates {
    return shapeToCoordinates(currentShape);
  }

  List<Point>? get absoluteCoordinates {
    if (!isPlaced || placedX == null || placedY == null) return null;

    return currentCoordinates.map((p) {
      return Point(placedX! + p.x, placedY! + p.y);
    }).toList();
  }

  GamePiece rotate() {
    return GamePiece(
      pento: pento,
      currentOrientation: (currentOrientation + 1) % pento.numOrientations,
      isPlaced: isPlaced,
      placedX: placedX,
      placedY: placedY,
    );
  }

  GamePiece place(int x, int y) {
    return GamePiece(
      pento: pento,
      currentOrientation: currentOrientation,
      isPlaced: true,
      placedX: x,
      placedY: y,
    );
  }

  GamePiece unplace() {
    return GamePiece(
      pento: pento,
      currentOrientation: currentOrientation,
      isPlaced: false,
      placedX: null,
      placedY: null,
    );
  }
}