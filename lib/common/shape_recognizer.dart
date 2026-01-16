// lib/services/shape_recognizer.dart
// Modified: 2512092105

import 'package:pentapol/common/pentominos.dart';

/// Résultat de la reconnaissance d'une forme
class ShapeMatch {
  final Pento piece;
  final int positionIndex;
  final int gridX;
  final int gridY;

  const ShapeMatch({
    required this.piece,
    required this.positionIndex,
    required this.gridX,
    required this.gridY,
  });

  @override
  String toString() =>
      'Pièce ${piece.id}, position $positionIndex, à placer en ($gridX, $gridY)';
}

/// Reconnaît une forme à partir de 5 coordonnées cartésiennes
///
/// [coords] : Liste de 5 coordonnées [[x1,y1], [x2,y2], ...]
///
/// Retourne un [ShapeMatch] si la forme correspond à une position de pentomino,
/// null sinon
ShapeMatch? recognizeShape(List<List<int>> coords) {
  // Validation
  if (coords.length != 5) return null;

  // Calculer les minima pour déterminer l'ancre
  final minX = coords.map((c) => c[0]).reduce((a, b) => a < b ? a : b);
  final minY = coords.map((c) => c[1]).reduce((a, b) => a < b ? a : b);

  // Normaliser : décaler pour que min(x)=0 et min(y)=0
  final normalized = coords.map((c) => [c[0] - minX, c[1] - minY]).toList();

  // Trier pour comparaison
  normalized.sort((a, b) => a[0] != b[0] ? a[0] - b[0] : a[1] - b[1]);

  // Chercher dans toutes les pièces
  for (final pento in pentominos) {
    for (int posIdx = 0; posIdx < pento.numOrientations; posIdx++) {
      final candidateCoords = pento.cartesianCoords[posIdx];

      if (_coordsEqual(normalized, candidateCoords)) {
        return ShapeMatch(
          piece: pento,
          positionIndex: posIdx,
          gridX: minX,
          gridY: minY,
        );
      }
    }
  }

  return null; // Aucune correspondance trouvée
}

/// Compare deux listes de coordonnées
bool _coordsEqual(List<List<int>> coords1, List<List<int>> coords2) {
  if (coords1.length != coords2.length) return false;

  for (int i = 0; i < coords1.length; i++) {
    if (coords1[i][0] != coords2[i][0] || coords1[i][1] != coords2[i][1]) {
      return false;
    }
  }

  return true;
}