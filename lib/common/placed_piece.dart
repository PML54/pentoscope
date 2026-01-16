// lib/common/placed_piece.dart
// Modified: 251213HHMMSS
// Classe commune pour toutes les pièces placées sur un plateau
// Remplace: IsopentoPlacedPiece et PentoscopePlacedPiece

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/point.dart';

/// Pièce placée sur un plateau de jeu
///
/// Utilisée par:
/// - Isopento
/// - Pentoscope
/// - (Extensible pour autres modules)
class PlacedPiece {
  /// La pièce (pentomino)
  final Pento piece;

  /// Index de la position/orientation actuelle (0-7 ou moins selon la pièce)
  final int positionIndex;

  /// Position X sur le plateau (coin supérieur gauche)
  final int gridX;

  /// Position Y sur le plateau (coin supérieur gauche)
  final int gridY;

  /// Nombre d'isométries appliquées pour transformer la pièce
  /// (utile pour tracker la difficulté / complexité)
  final int isometriesUsed;

  const PlacedPiece({
    required this.piece,
    required this.positionIndex,
    required this.gridX,
    required this.gridY,
    this.isometriesUsed = 0,
  });

  /// Coordonnées absolues des cellules occupées (normalisées)
  ///
  /// Exemple: Si piece est en position 2, gridX=5, gridY=3
  /// Retourne les Point(x, y) de chaque cellule occupée
  Iterable<Point> get absoluteCells sync* {
    final position = piece.orientations[positionIndex];

    // Trouver le décalage minimum pour normaliser la forme
    int minLocalX = 5, minLocalY = 5;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      if (localX < minLocalX) minLocalX = localX;
      if (localY < minLocalY) minLocalY = localY;
    }

    // Générer les cellules absolues
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minLocalX;
      final localY = (cellNum - 1) ~/ 5 - minLocalY;
      yield Point(gridX + localX, gridY + localY);
    }
  }

  /// Crée une copie avec champs optionnels modifiés
  PlacedPiece copyWith({
    Pento? piece,
    int? positionIndex,
    int? gridX,
    int? gridY,
    int? isometriesUsed,
  }) {
    return PlacedPiece(
      piece: piece ?? this.piece,
      positionIndex: positionIndex ?? this.positionIndex,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      isometriesUsed: isometriesUsed ?? this.isometriesUsed,
    );
  }

  @override
  String toString() =>
      'PlacedPiece(${piece.id}, pos=$positionIndex, grid=($gridX,$gridY), iso=$isometriesUsed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlacedPiece &&
              runtimeType == other.runtimeType &&
              piece.id == other.piece.id &&
              positionIndex == other.positionIndex &&
              gridX == other.gridX &&
              gridY == other.gridY &&
              isometriesUsed == other.isometriesUsed;

  @override
  int get hashCode =>
      piece.id.hashCode ^
      positionIndex.hashCode ^
      gridX.hashCode ^
      gridY.hashCode ^
      isometriesUsed.hashCode;

  /// Obtient les numéros de cases occupées par cette pièce sur le plateau 6×10.
  ///
  /// Retourne une liste de cellNum (1 à 60) correspondant aux cases occupées.
  /// Les cases hors limites (x < 0, x >= 6, y < 0, y >= 10) sont ignorées.
  List<int> getOccupiedCells() {
    final cells = <int>[];

    for (final point in absoluteCells) {
      // Vérifier que c'est dans les limites du plateau 6×10
      if (point.x >= 0 && point.x < 6 && point.y >= 0 && point.y < 10) {
        cells.add(point.y * 6 + point.x + 1); // cellNum de 1 à 60
      }
    }

    return cells;
  }
}