// lib/common/pentomino_symmetry_api.dart
//
// API dédiée aux symétries à partir des coordonnées absolues.
// Objectif: partir de cases absolues + mastercase absolue + type de symétrie
// et obtenir des coordonnées absolues transformées, puis normalisées,
// puis retrouver l'orientation correspondante d'une pièce.

import 'package:pentapol/common/point.dart';
import 'package:pentapol/common/pentominos.dart';

/// Type de symétrie demandée.
enum SymmetryType {
  /// Axe horizontal: droite y = masterY.
  horizontal,

  /// Axe vertical: droite x = masterX.
  vertical,
}

/// Applique une rotation en coordonnées ABSOLUES autour de la mastercase.
///
/// - [cellsAbs]: liste de cellules absolues (plateau).
/// - [masterAbs]: mastercase absolue (centre de rotation).
/// - [clockwise]: true = rotation horaire, false = anti-horaire.
///
/// Retourne les nouvelles coordonnées ABSOLUES (peuvent être négatives).
List<Point> applyRotationAbs({
  required List<Point> cellsAbs,
  required Point masterAbs,
  required bool clockwise,
}) {
  final xm = masterAbs.x;
  final ym = masterAbs.y;

  return cellsAbs.map((p) {
    final dx = p.x - xm;
    final dy = p.y - ym;
    if (clockwise) {
      // (x',y') = (xm + dy, ym - dx)
      return Point(xm + dy, ym - dx);
    } else {
      // (x',y') = (xm - dy, ym + dx)
      return Point(xm - dy, ym + dx);
    }
  }).toList();
}

/// Applique une symétrie en coordonnées ABSOLUES.
///
/// - [cellsAbs]: liste de cellules absolues (plateau).
/// - [masterAbs]: mastercase absolue (point fixe de l'axe).
/// - [type]: horizontal ou vertical.
///
/// Retourne les nouvelles coordonnées ABSOLUES (peuvent être négatives).
List<Point> applySymmetryAbs({
  required List<Point> cellsAbs,
  required Point masterAbs,
  required SymmetryType type,
}) {
  final xm = masterAbs.x;
  final ym = masterAbs.y;

  return cellsAbs.map((p) {
    if (type == SymmetryType.horizontal) {
      // Axe horizontal: y = ym
      return Point(p.x, 2 * ym - p.y);
    } else {
      // Axe vertical: x = xm
      return Point(2 * xm - p.x, p.y);
    }
  }).toList();
}

/// Normalise une liste de coordonnées en décalant le min vers (0,0).
///
/// Utile pour comparer une forme à des coordonnées normalisées d'orientation.
List<Point> normalizeCoords(List<Point> coords) {
  if (coords.isEmpty) return [];

  final minX = coords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
  final minY = coords.map((p) => p.y).reduce((a, b) => a < b ? a : b);

  return coords.map((p) => Point(p.x - minX, p.y - minY)).toList();
}

/// Trie des coords pour comparaison stable.
List<List<int>> _sortedIntCoords(List<Point> coords) {
  final sorted = coords.map((p) => [p.x, p.y]).toList();
  sorted.sort((a, b) => a[0] != b[0] ? a[0] - b[0] : a[1] - b[1]);
  return sorted;
}

bool _coordsEqual(List<List<int>> a, List<List<int>> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i][0] != b[i][0] || a[i][1] != b[i][1]) return false;
  }
  return true;
}

/// Retrouve l'index d'orientation correspondant à des coordonnées normalisées.
///
/// Retourne null si aucune orientation ne correspond.
int? findOrientationIndexFromNormalized({
  required Pento piece,
  required List<Point> normalizedCoords,
}) {
  final target = _sortedIntCoords(normalizedCoords);

  for (int i = 0; i < piece.cartesianCoords.length; i++) {
    final coords = piece.cartesianCoords[i]
        .map((c) => Point(c[0], c[1]))
        .toList();
    final sorted = _sortedIntCoords(coords);
    if (_coordsEqual(target, sorted)) return i;
  }

  return null;
}

/// Pipeline complet: symétrie ABS -> normalisation -> orientation.
///
/// Retourne l'index d'orientation ou null si non trouvée.
int? symmetrizeAndFindOrientation({
  required Pento piece,
  required List<Point> cellsAbs,
  required Point masterAbs,
  required SymmetryType type,
}) {
  final symAbs = applySymmetryAbs(
    cellsAbs: cellsAbs,
    masterAbs: masterAbs,
    type: type,
  );
  final normalized = normalizeCoords(symAbs);
  return findOrientationIndexFromNormalized(
    piece: piece,
    normalizedCoords: normalized,
  );
}
