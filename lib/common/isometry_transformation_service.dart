// lib/common/isometry_transformation_service.dart
// Modified: 251213HHMMSS
// Service de transformation pour isométries (rotations, symétries)
// CHANGEMENTS: (1) Service réutilisable pour Isopento et Pentoscope


import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/plateau.dart';


/// Service de transformation des isométries (rotations, symétries)
///
/// Logique COMMUNE utilisée par:
/// - IsopentoNotifier
/// - PentoscopeNotifier
///
/// Les Notifiers implémentent les méthodes privées spécifiques:
/// - _applyPlacedPieceIsometry()
/// - _applySliderPieceIsometry()
/// - _extractAbsoluteCoords()
/// - _canPlacePieceAt()
/// - recognizeShape()
/// - _calculateDefaultCell()
///
/// Ce service déléguera au Notifier pour les opérations.
class IsometryTransformationService {

  /// Applique une rotation CCW (Trigonometric Wise) à la pièce sélectionnée
  ///
  /// Paramètres:
  /// - rotateFunc: fonction appelée avec (coords, cx, cy) → coords transformées
  /// - onSuccess: callback appelé si transformation réussie
  /// - onFailure: callback appelé si transformation échoue
  Future<bool> applyRotationTW({
    required List<List<int>> Function(List<List<int>>, int, int) rotateFunc,
    required Future<bool> Function() onApply,
  }) async {
    try {
      return await onApply();
    } catch (e) {
      print('Erreur rotation TW: $e');
      return false;
    }
  }

  /// Applique une rotation CW (Clockwise) à la pièce sélectionnée
  Future<bool> applyRotationCW({
    required List<List<int>> Function(List<List<int>>, int, int) rotateFunc,
    required Future<bool> Function() onApply,
  }) async {
    try {
      return await onApply();
    } catch (e) {
      print('Erreur rotation CW: $e');
      return false;
    }
  }

  /// Applique une symétrie horizontale
  Future<bool> applySymmetryH({
    required Future<bool> Function() onApply,
  }) async {
    try {
      return await onApply();
    } catch (e) {
      print('Erreur symétrie H: $e');
      return false;
    }
  }

  /// Applique une symétrie verticale
  Future<bool> applySymmetryV({
    required Future<bool> Function() onApply,
  }) async {
    try {
      return await onApply();
    } catch (e) {
      print('Erreur symétrie V: $e');
      return false;
    }
  }

  /// Valide le placement d'une pièce sur le plateau
  ///
  /// Paramètres:
  /// - plateau: le plateau actuel
  /// - piece: la pièce à placer
  /// - positionIndex: l'orientation
  /// - gridX, gridY: position de placement
  ///
  /// Retourne: true si placement valide
  bool canPlacePiece(
      Plateau plateau,
      Pento piece,
      int positionIndex,
      int gridX,
      int gridY,
      ) {
    final position = piece.positions[positionIndex];

    // Trouver le décalage minimum pour normaliser la forme
    int minLocalX = 5, minLocalY = 5;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      if (localX < minLocalX) minLocalX = localX;
      if (localY < minLocalY) minLocalY = localY;
    }

    // Vérifier chaque cellule
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minLocalX; // Normalisé
      final localY = (cellNum - 1) ~/ 5 - minLocalY; // Normalisé
      final x = gridX + localX;
      final y = gridY + localY;

      // Hors limites?
      if (x < 0 || x >= plateau.width || y < 0 || y >= plateau.height) {
        return false;
      }

      // Cellule occupée?
      final cellValue = plateau.getCell(x, y);
      if (cellValue != 0) {
        return false;
      }
    }

    return true;
  }
}


/// Extensions helper pour les transformations géométriques
///
/// Note: Ces fonctions pourraient être dans isometry_transforms.dart
/// mais on les remet ici pour la complétude du service
extension IsometryHelpers on List<List<int>> {

  /// Rotation autour d'un point avec nombre d'étapes
  ///
  /// steps: nombre de rotations de 90°
  /// - 1 = CCW (trigonométrique)
  /// - 3 = CW (horaire)
  /// - Utilisé internement, pas appelé directement
  List<List<int>> rotateAroundPoint(int cx, int cy, int steps) {
    // Implémentation déléguée au fichier isometry_transforms.dart
    throw UnimplementedError(
        'Utilise rotateAroundPoint() de isometry_transforms.dart'
    );
  }
}