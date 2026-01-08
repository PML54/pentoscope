// lib/utils/pentomino_geometry.dart
// Utilitaires géométriques pour les pentominos

import 'dart:ui';
import 'package:pentapol/common/pentominos.dart';

/// Représente un point avec coordonnées flottantes
class Point2D {
  final double x;
  final double y;

  const Point2D(this.x, this.y);

  @override
  String toString() => '($x, $y)';
}

/// Convertit un numéro de case (1-25) en coordonnées (x, y) sur grille 5×5
/// Numérotation: ligne 1 (bas) = cases 1-5, ligne 2 = cases 6-10, etc.
Point2D cellNumberToCoords(int cellNumber) {
  final x = (cellNumber - 1) % 5;
  final y = (cellNumber - 1) ~/ 5;
  return Point2D(x.toDouble(), y.toDouble());
}

/// Calcule le barycentre (centre géométrique) d'une forme de pentomino
/// donnée par une liste de numéros de cases
Point2D calculateBarycenter(List<int> shape) {
  if (shape.isEmpty) return const Point2D(0, 0);

  double sumX = 0;
  double sumY = 0;

  for (var cellNumber in shape) {
    final coord = cellNumberToCoords(cellNumber);
    sumX += coord.x;
    sumY += coord.y;
  }

  return Point2D(sumX / shape.length, sumY / shape.length);
}

/// Calcule le centre de rotation pour toutes les positions d'un pentomino
/// Retourne le barycentre de la forme de base
Point2D getPieceRotationCenter(Pento piece) {
  return calculateBarycenter(piece.baseShape);
}

/// Analyse géométrique complète d'un pentomino
class PentominoGeometry {
  final Pento piece;
  final Point2D rotationCenter;
  final List<Point2D> positionCenters; // Centre de chaque position

  PentominoGeometry({
    required this.piece,
    required this.rotationCenter,
    required this.positionCenters,
  });

  factory PentominoGeometry.analyze(Pento piece) {
    final rotationCenter = getPieceRotationCenter(piece);
    final positionCenters = piece.positions
        .map((pos) => calculateBarycenter(pos))
        .toList();

    return PentominoGeometry(
      piece: piece,
      rotationCenter: rotationCenter,
      positionCenters: positionCenters,
    );
  }

  /// Décrit la transformation entre la position de base et une autre position
  String describeTransformation(int positionIndex) {
    if (positionIndex == 0) return 'Position de référence';

    // Pour l'instant, description simple basée sur le nombre de positions
    // On peut affiner avec une vraie détection de rotation/symétrie
    final numPos = piece.numPositions;

    if (numPos == 1) return 'Unique (symétrie complète)';
    if (numPos == 2) return positionIndex == 1 ? 'Rotation 90°' : 'Position $positionIndex';
    if (numPos == 4) {
      switch (positionIndex) {
        case 1: return 'Rotation 90°';
        case 2: return 'Rotation 180°';
        case 3: return 'Rotation 270°';
        default: return 'Position $positionIndex';
      }
    }
    if (numPos == 8) {
      // 4 rotations + 4 symétries
      if (positionIndex <= 3) {
        return 'Rotation ${positionIndex * 90}°';
      } else {
        return 'Symétrie + Rotation ${(positionIndex - 4) * 90}°';
      }
    }

    return 'Position $positionIndex';
  }
}

/// Extension pour Offset (utilisé par Flutter)
extension Point2DToOffset on Point2D {
  Offset toOffset() => Offset(x, y);
}

/// Extension pour faciliter l'analyse géométrique
extension PentoGeometryExtension on Pento {
  PentominoGeometry get geometry => PentominoGeometry.analyze(this);
  Point2D get rotationCenter => getPieceRotationCenter(this);
}