import '../common/point.dart';
import 'package:flutter/foundation.dart';

// lib/models/pentominos.dart
// Modified: 2512092000
// Pentominos avec numéros de cases sur grille 5×5
// Numérotation: ligne 1 (bas) = cases 1-5, ligne 2 = cases 6-10, etc.
// Les positions préservent l'ordre géométrique des cellules pour le tracking

final List<Pento> pentominos = [
  // Pièce 1
  Pento(
    id: 1,
    size: 5,
    numPositions: 1,
    baseShape: [2, 6, 7, 8, 12],
    bit6: 7,
    // 0b000111
    positions: [
      [6, 2, 7, 12, 8],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 1],
      ],
    ],
  ),

  // Pièce 2
  Pento(
    id: 2,
    size: 5,
    numPositions: 8,
    baseShape: [1, 2, 6, 7, 12],
    bit6: 11,
    // 0b001011
    positions: [
      [1, 6, 2, 7, 12],
      [3, 2, 8, 7, 6],
      [12, 7, 11, 6, 1],
      [6, 7, 1, 2, 3],
      [2, 7, 1, 6, 11],
      [8, 7, 3, 2, 1],
      [11, 6, 12, 7, 2],
      [1, 2, 6, 7, 8],
    ],
    cartesianCoords: [
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
        [1, 2],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 1],
        [1, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 0],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 1],
      ],
    ],
  ),

  // Pièce 3
  Pento(
    id: 3,
    size: 5,
    numPositions: 4,
    baseShape: [3, 6, 7, 8, 13],
    bit6: 19,
    // 0b010011
    positions: [
      [6, 7, 3, 8, 13],
      [2, 7, 13, 12, 11],
      [8, 7, 11, 6, 1],
      [12, 7, 1, 2, 3],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [1, 1],
        [2, 0],
        [2, 1],
        [2, 2],
      ],
      [
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 1],
        [2, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 0],
      ],
    ],
  ),

  // Pièce 4
  Pento(
    id: 4,
    size: 5,
    numPositions: 8,
    baseShape: [2, 3, 6, 7, 12],
    bit6: 35,
    // 0b100011
    positions: [
      [6, 2, 7, 12, 3],
      [2, 8, 7, 6, 13],
      [8, 12, 7, 2, 11],
      [12, 6, 7, 8, 1],
      [8, 2, 7, 12, 1],
      [12, 8, 7, 6, 3],
      [6, 12, 7, 2, 13],
      [2, 6, 7, 8, 11],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 0],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 1],
        [2, 2],
      ],
      [
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 2],
        [2, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 1],
      ],
      [
        [0, 1],
        [1, 1],
        [1, 2],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 2],
      ],
      [
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 1],
        [2, 1],
      ],
    ],
  ),

  // Pièce 5
  Pento(
    id: 5,
    size: 5,
    numPositions: 8,
    baseShape: [2, 7, 11, 12, 17],
    bit6: 13,
    // 0b001101
    positions: [
      [11, 2, 7, 12, 17],
      [2, 9, 8, 7, 6],
      [7, 16, 11, 6, 1],
      [8, 1, 2, 3, 4],
      [12, 1, 6, 11, 16],
      [7, 4, 3, 2, 1],
      [6, 17, 12, 7, 2],
      [3, 6, 7, 8, 9],
    ],
    cartesianCoords: [
      [
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
        [1, 3],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 1],
        [3, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [2, 0],
        [2, 1],
        [3, 0],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 2],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [2, 0],
        [3, 0],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [1, 2],
        [1, 3],
      ],
      [
        [0, 1],
        [1, 1],
        [2, 0],
        [2, 1],
        [3, 1],
      ],
    ],
  ),

  // Pièce 6
  Pento(
    id: 6,
    size: 5,
    numPositions: 4,
    baseShape: [3, 8, 11, 12, 13],
    bit6: 21,
    // 0b010101
    positions: [
      [11, 12, 3, 8, 13],
      [1, 6, 13, 12, 11],
      [3, 2, 11, 6, 1],
      [13, 8, 1, 2, 3],
    ],
    cartesianCoords: [
      [
        [0, 2],
        [1, 2],
        [2, 0],
        [2, 1],
        [2, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 2],
        [2, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 0],
        [2, 0],
      ],
      [
        [0, 0],
        [1, 0],
        [2, 0],
        [2, 1],
        [2, 2],
      ],
    ],
  ),

  // Pièce 7
  Pento(
    id: 7,
    size: 5,
    numPositions: 4,
    baseShape: [1, 3, 6, 7, 8],
    bit6: 37,
    // 0b100101
    positions: [
      [1, 6, 7, 3, 8],
      [2, 1, 6, 12, 11],
      [8, 3, 2, 6, 1],
      [11, 12, 7, 1, 2],
    ],
    cartesianCoords: [
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 0],
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
      ],
    ],
  ),

  // Pièce 8
  Pento(
    id: 8,
    size: 5,
    numPositions: 8,
    baseShape: [4, 6, 7, 8, 9],
    bit6: 25,
    // 0b011001
    positions: [
      [6, 7, 8, 4, 9],
      [1, 6, 11, 17, 16],
      [4, 3, 2, 6, 1],
      [17, 12, 7, 1, 2],
      [9, 8, 7, 1, 6],
      [16, 11, 6, 2, 1],
      [1, 2, 3, 9, 4],
      [2, 7, 12, 16, 17],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [1, 1],
        [2, 1],
        [3, 0],
        [3, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 3],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [2, 0],
        [3, 0],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [1, 2],
        [1, 3],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [2, 1],
        [3, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 0],
      ],
      [
        [0, 0],
        [1, 0],
        [2, 0],
        [3, 0],
        [3, 1],
      ],
      [
        [0, 3],
        [1, 0],
        [1, 1],
        [1, 2],
        [1, 3],
      ],
    ],
  ),

  // Pièce 9
  Pento(
    id: 9,
    size: 5,
    numPositions: 8,
    baseShape: [3, 4, 6, 7, 8],
    bit6: 41,
    // 0b101001
    positions: [
      [6, 7, 3, 8, 4],
      [1, 6, 12, 11, 17],
      [4, 3, 7, 2, 6],
      [17, 12, 6, 7, 1],
      [9, 8, 2, 7, 1],
      [16, 11, 7, 6, 2],
      [1, 2, 8, 3, 9],
      [2, 7, 11, 12, 16],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [1, 1],
        [2, 0],
        [2, 1],
        [3, 0],
      ],
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 2],
        [1, 3],
      ],
      [
        [0, 1],
        [1, 0],
        [1, 1],
        [2, 0],
        [3, 0],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 2],
        [1, 3],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [2, 1],
        [3, 1],
      ],
      [
        [0, 1],
        [0, 2],
        [0, 3],
        [1, 0],
        [1, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [2, 0],
        [2, 1],
        [3, 1],
      ],
      [
        [0, 2],
        [0, 3],
        [1, 0],
        [1, 1],
        [1, 2],
      ],
    ],
  ),

  // Pièce 10
  Pento(
    id: 10,
    size: 5,
    numPositions: 4,
    baseShape: [3, 6, 7, 8, 11],
    bit6: 49,
    // 0b110001
    positions: [
      [6, 11, 7, 3, 8],
      [2, 1, 7, 13, 12],
      [8, 13, 7, 1, 6],
      [12, 11, 7, 3, 2],
    ],
    cartesianCoords: [
      [
        [0, 1],
        [0, 2],
        [1, 1],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 2],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [2, 1],
        [2, 2],
      ],
      [
        [0, 2],
        [1, 0],
        [1, 1],
        [1, 2],
        [2, 0],
      ],
    ],
  ),

  // Pièce 11
  Pento(
    id: 11,
    size: 5,
    numPositions: 4,
    baseShape: [3, 7, 8, 11, 12],
    bit6: 14,
    // 0b001110
    positions: [
      [11, 7, 12, 3, 8],
      [1, 7, 6, 13, 12],
      [3, 7, 2, 11, 6],
      [13, 7, 8, 1, 2],
    ],
    cartesianCoords: [
      [
        [0, 2],
        [1, 1],
        [1, 2],
        [2, 0],
        [2, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 2],
        [2, 2],
      ],
      [
        [0, 1],
        [0, 2],
        [1, 0],
        [1, 1],
        [2, 0],
      ],
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [2, 1],
        [2, 2],
      ],
    ],
  ),

  // Pièce 12
  Pento(
    id: 12,
    size: 5,
    numPositions: 2,
    baseShape: [1, 6, 11, 16, 21],
    bit6: 22,
    // 0b010110
    positions: [
      [1, 6, 11, 16, 21],
      [5, 4, 3, 2, 1],
    ],
    cartesianCoords: [
      [
        [0, 0],
        [0, 1],
        [0, 2],
        [0, 3],
        [0, 4],
      ],
      [
        [0, 0],
        [1, 0],
        [2, 0],
        [3, 0],
        [4, 0],
      ],
    ],
  ),
];

class Pento {
  final int id;
  final int size;
  final List<List<int>> positions;
  final List<List<List<int>>>
  cartesianCoords; // Coordonnées (x,y) normalisées et triées
  final int numPositions;
  final List<int> baseShape;
  final int bit6; // code binaire 6 bits unique pour la pièce (0..63)

  const Pento({
    required this.id,
    required this.size,
    required this.positions,
    required this.cartesianCoords,
    required this.numPositions,
    required this.baseShape,
    required this.bit6,
  });

  /// Ancien nom : rotation 90° anti-horaire (trigo)
  int findRotation90(int currentPositionIndex) =>
      rotationTW(currentPositionIndex);

  /// Ancien nom : symétrie horizontale
  int findSymmetryH(int currentPositionIndex) =>
      symmetryH(currentPositionIndex);

  // ------------------------------------------------------------------
  // Aliases de compatibilité (ancien code Duel / autres modules)
  // ------------------------------------------------------------------

  /// Ancien nom : symétrie verticale
  int findSymmetryV(int currentPositionIndex) =>
      symmetryV(currentPositionIndex);

  // ----------------------------
  // Lettres (inchangé)
  // ----------------------------

  String getLetter(int cellNum) {
    const letters = ['A', 'B', 'C', 'D', 'E'];
    final index = baseShape.indexOf(cellNum);
    if (index == -1) return '?';
    return letters[index];
  }

  String getLetterForPosition(int positionIndex, int cellNum) {
    const letters = ['A', 'B', 'C', 'D', 'E'];
    final position = positions[positionIndex];
    final indexInPosition = position.indexOf(cellNum);
    if (indexInPosition == -1) return '?';
    return letters[indexInPosition];
  }

  /// Rotation 180° (optionnel)
  int rotate180(int currentPositionIndex) =>
      rotationTW(rotationTW(currentPositionIndex));

  // ----------------------------
  // Isométries robustes (lookup)
  // ----------------------------

  // Rotation 90° horaire (CW) en repère écran (y vers le bas)
  int rotationCW(int currentPositionIndex) =>
      _applyIso(currentPositionIndex, _rotate90TWCoords); // (-y, x)

  // Rotation 90° anti-horaire (TW) en repère écran (y vers le bas)
  int rotationTW(int currentPositionIndex) =>
      _applyIso(currentPositionIndex, _rotate90CWCoords); // (y, -x)

  // Symétrie axe horizontal (haut ↔ bas) : y -> -y
  int symmetryH(int currentPositionIndex) =>
      _applyIso(currentPositionIndex, _flipVCoords);

  // Symétrie axe vertical (gauche ↔ droite) : x -> -x
  int symmetryV(int currentPositionIndex) =>
      _applyIso(currentPositionIndex, _flipHCoords);

  // Symétrie par rapport à une droite horizontale passant par la mastercase
  int symmetryHRelativeToMastercase(int currentPositionIndex, Point mastercase) =>
      _applySymmetryRelativeToPoint(currentPositionIndex, mastercase, isHorizontal: true);

  // Symétrie par rapport à une droite verticale passant par la mastercase
  int symmetryVRelativeToMastercase(int currentPositionIndex, Point mastercase) =>
      _applySymmetryRelativeToPoint(currentPositionIndex, mastercase, isHorizontal: false);

  /// Retourne le nombre MIN d'isométries pour aller de startPos à endPos
  int minIsometriesToReach(int startPos, int endPos) {
    if (startPos == endPos) return 0;

    // BFS
    final visited = Set<int>();
    final queue = [(pos: startPos, cost: 0)];

    while (queue.isNotEmpty) {
      final (pos: current, cost: steps) = queue.removeAt(0);

      if (current == endPos) return steps;
      if (visited.contains(current)) continue;
      visited.add(current);

      // Ajouter les 4 voisins (les 4 isométries)
      queue.add((pos: rotationCW(current), cost: steps + 1));
      queue.add((pos: rotationTW(current), cost: steps + 1));
      queue.add((pos: symmetryH(current), cost: steps + 1));
      queue.add((pos: symmetryV(current), cost: steps + 1));
    }

    return numPositions; // Pas trouvé (shouldn't happen)
  }
  // ----------------------------
  // Core lookup
  // ----------------------------

  int _applyIso(
    int currentPositionIndex,
    List<List<int>> Function(List<List<int>>) transform,
  ) {
    final current = cartesianCoords[currentPositionIndex];
    final transformed = transform(current);

    for (int i = 0; i < cartesianCoords.length; i++) {
      if (_coordsEqual(transformed, cartesianCoords[i])) return i;
    }

    // Si non trouvé (pièce très symétrique / positions redondantes / données incomplètes),
    // on ne change pas l'index (comportement sûr).
    return currentPositionIndex;
  }

  bool _coordsEqual(List<List<int>> a, List<List<int>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i][0] != b[i][0] || a[i][1] != b[i][1]) return false;
    }
    return true;
  }

  List<List<int>> _flipHCoords(List<List<int>> coords) {
    // H: (x,y) -> (-x, y)
    final flipped = coords.map((c) => [-c[0], c[1]]).toList();
    return _normalizeAndSort(flipped);
  }

  List<List<int>> _flipVCoords(List<List<int>> coords) {
    // V: (x,y) -> (x, -y)
    final flipped = coords.map((c) => [c[0], -c[1]]).toList();
    return _normalizeAndSort(flipped);
  }

  // Retourne les coordonnées cartésiennes pour une position donnée
  List<List<int>> _getCoordsForPosition(int positionIndex) {
    return cartesianCoords[positionIndex];
  }

  // Applique une symétrie par rapport à une droite passant par un point donné
  int _applySymmetryRelativeToPoint(int currentPositionIndex, Point mastercase, {required bool isHorizontal}) {
    final currentCoords = _getCoordsForPosition(currentPositionIndex);

    List<List<int>> transformedCoords;
    if (isHorizontal) {
      // Symétrie horizontale : (x,y) -> (x, 2*mastercaseY - y)
      transformedCoords = currentCoords.map((coord) {
        final x = coord[0];
        final y = coord[1];
        return [x, 2 * mastercase.y - y];
      }).toList();
    } else {
      // Symétrie verticale : (x,y) -> (2*mastercaseX - x, y)
      transformedCoords = currentCoords.map((coord) {
        final x = coord[0];
        final y = coord[1];
        return [2 * mastercase.x - x, y];
      }).toList();
    }

    return _findOrCreatePosition(_normalizeAndSort(transformedCoords));
  }

  // Trouve une position existante ou en crée une nouvelle
  int _findOrCreatePosition(List<List<int>> coords) {
    // Chercher d'abord dans les positions existantes
    for (int i = 0; i < cartesianCoords.length; i++) {
      if (_coordsEqual(coords, cartesianCoords[i])) {
        return i;
      }
    }

    // Si pas trouvé et qu'on a de la place, on pourrait ajouter (mais pour l'instant on garde simple)
    // Pour les symétries relatives, il se peut qu'on obtienne une position qui n'existe pas
    // dans la liste pré-calculée. Dans ce cas, on essaie de trouver la plus proche ou on garde l'index actuel.
    debugPrint('Warning: Symmetry resulted in unknown position, keeping current position');
    return 0; // Retourner la position de base
  }

  List<List<int>> _normalizeAndSort(List<List<int>> coords) {
    if (coords.isEmpty) return [];

    final minX = coords.map((c) => c[0]).reduce((a, b) => a < b ? a : b);
    final minY = coords.map((c) => c[1]).reduce((a, b) => a < b ? a : b);

    final normalized = coords.map((c) => [c[0] - minX, c[1] - minY]).toList();

    normalized.sort((a, b) => a[0] != b[0] ? a[0] - b[0] : a[1] - b[1]);
    return normalized;
  }

  List<List<int>> _rotate90CWCoords(List<List<int>> coords) {
    // CW: (x,y) -> (y, -x)
    final rotated = coords.map((c) => [c[1], -c[0]]).toList();
    return _normalizeAndSort(rotated);
  }

  // ----------------------------
  // Transformations (toutes normalisées + triées)
  // ----------------------------

  List<List<int>> _rotate90TWCoords(List<List<int>> coords) {
    // TW: (x,y) -> (-y, x)
    final rotated = coords.map((c) => [-c[1], c[0]]).toList();
    return _normalizeAndSort(rotated);
  }
}
