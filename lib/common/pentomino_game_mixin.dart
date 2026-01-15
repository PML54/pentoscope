// lib/common/pentomino_game_mixin.dart
// Mixin contenant les fonctions communes aux providers Classical et Pentoscope
// Factorise la logique partagée pour éviter la duplication de code

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/point.dart';
import 'package:pentapol/common/plateau.dart';

/// Mixin contenant les fonctions communes aux providers Classical et Pentoscope
/// 
/// Ce mixin factorise la logique partagée pour :
/// - Les transformations isométriques (remapping de mastercase)
/// - La gestion des coordonnées (normalisées, brutes, absolues)
/// - Le calcul de la mastercase par défaut
/// - La conversion entre coordonnées normalisées et brutes
mixin PentominoGameMixin {
  // ============================================================================
  // MÉTHODES ABSTRAITES À IMPLÉMENTER PAR LES CLASSES UTILISATRICES
  // ============================================================================
  
  /// Retourne le plateau actuel
  Plateau get currentPlateau;
  
  /// Retourne la pièce sélectionnée (peut être null)
  Pento? get selectedPiece;
  
  /// Retourne l'index de position actuel
  int get selectedPositionIndex;
  
  /// Retourne la mastercase sélectionnée (peut être null)
  Point? get selectedCellInPiece;
  
  /// Vérifie si une pièce peut être placée à une position donnée
  bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY);
  
  // ============================================================================
  // FONCTIONS COMMUNES - TRANSFORMATIONS ET COORDONNÉES
  // ============================================================================
  
  /// Remapping de la cellule de référence (mastercase) lors d'une isométrie
  /// 
  /// Utilise la version robuste de Pentoscope qui préserve l'identité géométrique
  /// en utilisant les coordonnées normalisées dans l'ordre stable des cellules.
  /// 
  /// Cette méthode est IDENTIQUE dans les deux providers (version Pentoscope).
  Point? remapSelectedCell({
    required Pento piece,
    required int oldIndex,
    required int newIndex,
    required Point? oldCell,
  }) {
    if (oldCell == null) return null;

    // Coordonnées normalisées dans l'ordre STABLE des cellules (positions)
    List<Point> coordsInPositionOrder(int posIdx) {
      final cellNums = piece.positions[posIdx];

      final raw = cellNums.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();

      final minX = raw.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minY = raw.map((p) => p.y).reduce((a, b) => a < b ? a : b);

      // normalisation SANS trier (on garde l'identité géométrique)
      return raw.map((p) => Point(p.x - minX, p.y - minY)).toList();
    }

    final oldCoords = coordsInPositionOrder(oldIndex);

    // retrouve l'indice géométrique stable (0..4)
    final k = oldCoords.indexWhere((p) => p.x == oldCell.x && p.y == oldCell.y);
    if (k < 0) return oldCell; // sécurité

    final newCoords = coordsInPositionOrder(newIndex);
    return newCoords[k];
  }
  
  /// Convertit les coordonnées normalisées de la mastercase en coordonnées brutes
  /// pour la position actuelle de la pièce (grille 5×5)
  /// 
  /// Cette méthode est IDENTIQUE dans Pentoscope et peut être utilisée dans Classical.
  Point getRawMastercaseCoords(
    Pento piece,
    int positionIndex,
    Point normalizedMastercase,
  ) {
    final position = piece.positions[positionIndex];
    final coords = position.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return Point(x, y);
    }).toList();

    final minX = coords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = coords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final normalizedCoords = coords.map((p) => Point(p.x - minX, p.y - minY)).toList();

    // Trouver l'index de la mastercase normalisée
    final index = normalizedCoords.indexWhere(
      (p) => p.x == normalizedMastercase.x && p.y == normalizedMastercase.y
    );

    if (index == -1) {
      // Fallback : utiliser les coordonnées normalisées directement
      debugPrint('Warning: Mastercase normalisée non trouvée, utilisation directe');
      return normalizedMastercase;
    }

    // Retourner les coordonnées brutes correspondantes
    return coords[index];
  }
  
  /// Calcule la mastercase par défaut (première cellule normalisée)
  /// 
  /// Cette méthode est IDENTIQUE dans Pentoscope et peut être utilisée dans Classical.
  Point? calculateDefaultCell(Pento piece, int positionIndex) {
    final position = piece.positions[positionIndex];
    if (position.isEmpty) return null;

    int minX = 5, minY = 5;
    for (final cellNum in position) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
    }
    final firstCellNum = position[0];
    final rawX = (firstCellNum - 1) % 5;
    final rawY = (firstCellNum - 1) ~/ 5;
    return Point(rawX - minX, rawY - minY);
  }
  
  /// Calcule la position d'ancrage en tenant compte de la mastercase
  /// 
  /// Si une mastercase est définie, calcule où doit être l'ancre (gridX, gridY)
  /// pour que la mastercase soit à la position (gridX, gridY) du doigt.
  Point calculateAnchorPosition(int gridX, int gridY) {
    if (selectedCellInPiece == null || selectedPiece == null) {
      return Point(gridX, gridY);
    }
    
    final rawMastercase = getRawMastercaseCoords(
      selectedPiece!,
      selectedPositionIndex,
      selectedCellInPiece!,
    );
    
    return Point(gridX - rawMastercase.x, gridY - rawMastercase.y);
  }
  
  /// Cherche la position valide la plus proche dans un rayon donné
  /// 
  /// Version commune basique utilisée par Classical.
  /// Pentoscope peut surcharger cette méthode pour sa recherche en spirale.
  /// 
  /// Utilise la distance euclidienne pour trouver vraiment la plus proche.
  Point? findNearestValidPosition({
    required Pento piece,
    required int positionIndex,
    required int anchorX,
    required int anchorY,
    int snapRadius = 2,
  }) {
    Point? best;
    double bestDistanceSquared = double.infinity;

    for (int dx = -snapRadius; dx <= snapRadius; dx++) {
      for (int dy = -snapRadius; dy <= snapRadius; dy++) {
        if (dx == 0 && dy == 0) continue; // Position exacte déjà testée

        final testX = anchorX + dx;
        final testY = anchorY + dy;

        if (canPlacePiece(piece, positionIndex, testX, testY)) {
          // Distance euclidienne au carré (évite sqrt pour la perf)
          final distanceSquared = (dx * dx + dy * dy).toDouble();

          if (distanceSquared < bestDistanceSquared) {
            bestDistanceSquared = distanceSquared;
            best = Point(testX, testY);
          }
        }
      }
    }

    return best;
  }
}
