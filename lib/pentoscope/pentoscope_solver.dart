// lib/pentoscope/pentoscope_solver.dart
// Modified: 2512301200
// Solveur backtracking OPTIMISÉ avec :
// - Heuristique "Smallest Free Cell First"
// - Détection des zones isolées (pruning)
// - Tri des pièces par contrainte (numOrientations croissant)

import 'dart:async';
import 'package:pentapol/common/pentominos.dart';

/// Solution = liste de placements (pieceId, gridX, gridY, positionIndex)
class SolverPlacement {
  final int pieceId;
  final int gridX;
  final int gridY;
  final int positionIndex;

  const SolverPlacement({
    required this.pieceId,
    required this.gridX,
    required this.gridY,
    required this.positionIndex,
  });

  @override
  String toString() =>
      'Placement(id=$pieceId, grid=($gridX,$gridY), pos=$positionIndex)';
}

typedef Solution = List<SolverPlacement>;

/// Solveur de pentominos optimisé pour Pentoscope
/// 
/// Utilise plusieurs techniques d'optimisation :
/// 1. **Smallest Free Cell First** : Cible toujours la plus petite case libre
/// 2. **Isolated Region Pruning** : Élimine les branches avec des zones impossibles
/// 3. **Piece Ordering** : Essaie d'abord les pièces les plus contraintes
class PentoscopeSolver {
  // Map pieceId → Pento object
  late final Map<int, Pento> _pieceMap;

  PentoscopeSolver() {
    _pieceMap = <int, Pento>{};
    for (final pento in pentominos) {
      _pieceMap[pento.id] = pento;
    }
  }

  // ==========================================================================
  // API PUBLIQUE
  // ==========================================================================

  /// Cherche la PREMIÈRE solution (rapide, arrête dès trouvée)
  /// Retourne true si elle existe
  bool findFirstSolution(
    List<int> pieceIds,
    int width,
    int height,
  ) {
    final plateau = List<List<int>>.generate(
      height,
      (_) => List<int>.filled(width, 0),
    );
    final usedPieces = <int>{}; // Set des IDs utilisés
    final placedPieces = <SolverPlacement>[];

    // Trier les pièces par contrainte (moins d'orientations = plus contraint)
    final sortedPieceIds = _sortByConstraint(pieceIds);

    return _backtrackFirst(
      pieceIds: sortedPieceIds,
      width: width,
      height: height,
      plateau: plateau,
      usedPieces: usedPieces,
      placedPieces: placedPieces,
    );
  }

  /// Cherche TOUTES les solutions avec timeout (2s max)
  /// Retourne {solutionCount, solutions}
  Future<SolverResult> findAllSolutions(
    List<int> pieceIds,
    int width,
    int height, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();
    final solutions = <Solution>[];

    final plateau = List<List<int>>.generate(
      height,
      (_) => List<int>.filled(width, 0),
    );
    final usedPieces = <int>{};
    final placedPieces = <SolverPlacement>[];

    // Trier les pièces par contrainte
    final sortedPieceIds = _sortByConstraint(pieceIds);

    void backtrackAll() {
      // Timeout check
      if (stopwatch.elapsedMilliseconds > timeout.inMilliseconds) {
        return;
      }

      // Toutes les pièces placées → solution trouvée
      if (usedPieces.length == sortedPieceIds.length) {
        solutions.add(List<SolverPlacement>.from(placedPieces));
        return;
      }

      // ✨ OPTIMISATION 1: Trouver la plus petite case libre
      final targetCell = _findSmallestFreeCell(plateau, width, height);
      if (targetCell == null) {
        // Plateau plein mais pas toutes les pièces → impossible
        return;
      }

      final targetX = targetCell % width;
      final targetY = targetCell ~/ width;

      // Essayer chaque pièce non utilisée
      for (final pieceId in sortedPieceIds) {
        if (usedPieces.contains(pieceId)) continue;
        if (stopwatch.elapsedMilliseconds > timeout.inMilliseconds) return;

        final pento = _pieceMap[pieceId]!;

        // Essayer chaque orientation
        for (int posIndex = 0; posIndex < pento.numOrientations; posIndex++) {
          // ✨ OPTIMISATION 1 (suite): Ne tester que les placements qui couvrent targetCell
          final placement = _findPlacementCoveringCell(
            pento,
            posIndex,
            targetX,
            targetY,
            width,
            height,
            plateau,
          );

          if (placement != null) {
            // Placer la pièce
            _placePiece(pento, posIndex, placement.$1, placement.$2, pieceId, plateau);
            usedPieces.add(pieceId);
            placedPieces.add(
              SolverPlacement(
                pieceId: pieceId,
                gridX: placement.$1,
                gridY: placement.$2,
                positionIndex: posIndex,
              ),
            );

            // ✨ OPTIMISATION 2: Vérifier les zones isolées
            if (_areIsolatedRegionsValid(plateau, width, height)) {
              backtrackAll();
            }

            // Backtrack
            _removePiece(pento, posIndex, placement.$1, placement.$2, plateau);
            usedPieces.remove(pieceId);
            placedPieces.removeLast();
          }
        }
      }
    }

    backtrackAll();

    return SolverResult(
      solutionCount: solutions.length,
      solutions: solutions,
    );
  }

  // ==========================================================================
  // 💡 HINT SYSTEM: Vérifier/trouver solution depuis un état partiel
  // ==========================================================================

  /// Vérifie si au moins une solution existe depuis un état partiel
  /// [pieceIds] : IDs des pièces restantes à placer
  /// [plateau] : État actuel du plateau (0 = vide, sinon ID de la pièce)
  bool canSolveFrom(
    List<int> pieceIds,
    int width,
    int height,
    List<List<int>> plateau,
  ) {
    if (pieceIds.isEmpty) return true;

    final usedPieces = <int>{};
    final placedPieces = <SolverPlacement>[];

    // Copier le plateau pour ne pas modifier l'original
    final tempPlateau = List<List<int>>.generate(
      height,
      (y) => List<int>.from(plateau[y]),
    );

    final sortedPieceIds = _sortByConstraint(pieceIds);

    return _backtrackFirst(
      pieceIds: sortedPieceIds,
      width: width,
      height: height,
      plateau: tempPlateau,
      usedPieces: usedPieces,
      placedPieces: placedPieces,
    );
  }

  /// Trouve une solution depuis un état partiel et retourne les placements
  /// [pieceIds] : IDs des pièces restantes à placer
  /// [plateau] : État actuel du plateau
  /// Retourne la liste des placements pour les pièces restantes, ou null
  Solution? findSolutionFrom(
    List<int> pieceIds,
    int width,
    int height,
    List<List<int>> plateau,
  ) {
    if (pieceIds.isEmpty) return [];

    final usedPieces = <int>{};
    final placedPieces = <SolverPlacement>[];

    // Copier le plateau
    final tempPlateau = List<List<int>>.generate(
      height,
      (y) => List<int>.from(plateau[y]),
    );

    final sortedPieceIds = _sortByConstraint(pieceIds);

    final found = _backtrackFirstWithResult(
      pieceIds: sortedPieceIds,
      width: width,
      height: height,
      plateau: tempPlateau,
      usedPieces: usedPieces,
      placedPieces: placedPieces,
    );

    return found ? placedPieces : null;
  }

  /// Backtrack optimisé qui garde les placements trouvés
  bool _backtrackFirstWithResult({
    required List<int> pieceIds,
    required int width,
    required int height,
    required List<List<int>> plateau,
    required Set<int> usedPieces,
    required List<SolverPlacement> placedPieces,
  }) {
    // Toutes les pièces placées → succès
    if (usedPieces.length == pieceIds.length) {
      return true;
    }

    // Trouver la plus petite case libre
    final targetCell = _findSmallestFreeCell(plateau, width, height);
    if (targetCell == null) return false;

    final targetX = targetCell % width;
    final targetY = targetCell ~/ width;

    // Essayer chaque pièce non utilisée
    for (final pieceId in pieceIds) {
      if (usedPieces.contains(pieceId)) continue;

      final pento = _pieceMap[pieceId]!;

      // Essayer chaque orientation
      for (int posIndex = 0; posIndex < pento.numOrientations; posIndex++) {
        final placement = _findPlacementCoveringCell(
          pento,
          posIndex,
          targetX,
          targetY,
          width,
          height,
          plateau,
        );

        if (placement != null) {
          // Placer la pièce
          _placePiece(pento, posIndex, placement.$1, placement.$2, pieceId, plateau);
          usedPieces.add(pieceId);
          placedPieces.add(
            SolverPlacement(
              pieceId: pieceId,
              gridX: placement.$1,
              gridY: placement.$2,
              positionIndex: posIndex,
            ),
          );

          // Vérifier les régions isolées
          if (_areIsolatedRegionsValid(plateau, width, height)) {
            // Récursion
            if (_backtrackFirstWithResult(
              pieceIds: pieceIds,
              width: width,
              height: height,
              plateau: plateau,
              usedPieces: usedPieces,
              placedPieces: placedPieces,
            )) {
              return true;
            }
          }

          // Backtrack
          _removePiece(pento, posIndex, placement.$1, placement.$2, plateau);
          usedPieces.remove(pieceId);
          placedPieces.removeLast();
        }
      }
    }

    return false;
  }

  // ==========================================================================
  // OPTIMISATION 1: Smallest Free Cell First
  // ==========================================================================

  /// Trouve la plus petite case libre (parcours ligne par ligne)
  /// Retourne l'index linéaire (y * width + x) ou null si plateau plein
  int? _findSmallestFreeCell(List<List<int>> plateau, int width, int height) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (plateau[y][x] == 0) {
          return y * width + x;
        }
      }
    }
    return null;
  }

  /// Trouve un placement valide pour la pièce qui couvre la case cible
  /// Retourne (gridX, gridY) ou null si impossible
  (int, int)? _findPlacementCoveringCell(
    Pento pento,
    int positionIndex,
    int targetX,
    int targetY,
    int width,
    int height,
    List<List<int>> plateau,
  ) {
    final coords = pento.cartesianCoords[positionIndex];

    // Pour chaque cellule de la pièce, essayer de la placer sur targetCell
    for (final coord in coords) {
      final gridX = targetX - coord[0];
      final gridY = targetY - coord[1];

      if (_canPlace(pento, positionIndex, gridX, gridY, width, height, plateau)) {
        return (gridX, gridY);
      }
    }

    return null;
  }

  // ==========================================================================
  // OPTIMISATION 2: Détection des zones isolées (Pruning)
  // ==========================================================================

  /// Vérifie que toutes les zones vides sont valides :
  /// - Pas de zone < 5 cases (impossible à remplir)
  /// - Pas de zone avec un nombre de cases non-multiple de 5
  bool _areIsolatedRegionsValid(List<List<int>> plateau, int width, int height) {
    final visited = List.generate(height, (_) => List.filled(width, false));

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (plateau[y][x] == 0 && !visited[y][x]) {
          final regionSize = _floodFill(x, y, plateau, visited, width, height);

          // Règle 1: Région < 5 → impossible à remplir
          if (regionSize < 5) {
            return false;
          }

          // Règle 2: Non multiple de 5 → impossible
          if (regionSize % 5 != 0) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Flood fill pour compter la taille d'une région connexe
  int _floodFill(
    int x,
    int y,
    List<List<int>> plateau,
    List<List<bool>> visited,
    int width,
    int height,
  ) {
    if (x < 0 || x >= width || y < 0 || y >= height) return 0;
    if (visited[y][x]) return 0;
    if (plateau[y][x] != 0) return 0;

    visited[y][x] = true;
    int size = 1;

    size += _floodFill(x - 1, y, plateau, visited, width, height);
    size += _floodFill(x + 1, y, plateau, visited, width, height);
    size += _floodFill(x, y - 1, plateau, visited, width, height);
    size += _floodFill(x, y + 1, plateau, visited, width, height);

    return size;
  }

  // ==========================================================================
  // OPTIMISATION 3: Tri des pièces par contrainte
  // ==========================================================================

  /// Trie les pièces par nombre d'orientations (croissant)
  /// Les pièces avec moins d'orientations sont plus contraintes → à placer d'abord
  List<int> _sortByConstraint(List<int> pieceIds) {
    final sorted = List<int>.from(pieceIds);
    sorted.sort((a, b) {
      final pentoA = _pieceMap[a]!;
      final pentoB = _pieceMap[b]!;
      return pentoA.numOrientations.compareTo(pentoB.numOrientations);
    });
    return sorted;
  }

  // ==========================================================================
  // BACKTRACKING OPTIMISÉ (findFirstSolution)
  // ==========================================================================

  bool _backtrackFirst({
    required List<int> pieceIds,
    required int width,
    required int height,
    required List<List<int>> plateau,
    required Set<int> usedPieces,
    required List<SolverPlacement> placedPieces,
  }) {
    // Toutes les pièces placées → solution trouvée
    if (usedPieces.length == pieceIds.length) {
      return true;
    }

    // ✨ OPTIMISATION 1: Trouver la plus petite case libre
    final targetCell = _findSmallestFreeCell(plateau, width, height);
    if (targetCell == null) {
      return false; // Plateau plein mais pas toutes les pièces
    }

    final targetX = targetCell % width;
    final targetY = targetCell ~/ width;

    // Essayer chaque pièce non utilisée
    for (final pieceId in pieceIds) {
      if (usedPieces.contains(pieceId)) continue;

      final pento = _pieceMap[pieceId]!;

      // Essayer chaque orientation
      for (int posIndex = 0; posIndex < pento.numOrientations; posIndex++) {
        // ✨ Ne tester que les placements qui couvrent targetCell
        final placement = _findPlacementCoveringCell(
          pento,
          posIndex,
          targetX,
          targetY,
          width,
          height,
          plateau,
        );

        if (placement != null) {
          // Placer la pièce
          _placePiece(pento, posIndex, placement.$1, placement.$2, pieceId, plateau);
          usedPieces.add(pieceId);
          placedPieces.add(
            SolverPlacement(
              pieceId: pieceId,
              gridX: placement.$1,
              gridY: placement.$2,
              positionIndex: posIndex,
            ),
          );

          // ✨ OPTIMISATION 2: Vérifier les zones isolées
          if (_areIsolatedRegionsValid(plateau, width, height)) {
            if (_backtrackFirst(
              pieceIds: pieceIds,
              width: width,
              height: height,
              plateau: plateau,
              usedPieces: usedPieces,
              placedPieces: placedPieces,
            )) {
              return true;
            }
          }

          // Backtrack
          _removePiece(pento, posIndex, placement.$1, placement.$2, plateau);
          usedPieces.remove(pieceId);
          placedPieces.removeLast();
        }
      }
    }

    return false;
  }

  // ==========================================================================
  // HELPERS DE BASE
  // ==========================================================================

  /// Vérifier si placement possible (pas collision, dans limites)
  bool _canPlace(
    Pento pento,
    int positionIndex,
    int gridX,
    int gridY,
    int width,
    int height,
    List<List<int>> plateau,
  ) {
    final coords = pento.cartesianCoords[positionIndex];

    for (final coord in coords) {
      final absX = gridX + coord[0];
      final absY = gridY + coord[1];

      // Hors limites
      if (absX < 0 || absX >= width || absY < 0 || absY >= height) {
        return false;
      }

      // Collision
      if (plateau[absY][absX] != 0) {
        return false;
      }
    }

    return true;
  }

  /// Placer une pièce sur le plateau
  void _placePiece(
    Pento pento,
    int positionIndex,
    int gridX,
    int gridY,
    int pieceId,
    List<List<int>> plateau,
  ) {
    final coords = pento.cartesianCoords[positionIndex];

    for (final coord in coords) {
      final absX = gridX + coord[0];
      final absY = gridY + coord[1];
      plateau[absY][absX] = pieceId;
    }
  }

  /// Retirer une pièce du plateau
  void _removePiece(
    Pento pento,
    int positionIndex,
    int gridX,
    int gridY,
    List<List<int>> plateau,
  ) {
    final coords = pento.cartesianCoords[positionIndex];

    for (final coord in coords) {
      final absX = gridX + coord[0];
      final absY = gridY + coord[1];
      plateau[absY][absX] = 0;
    }
  }
}

/// Résultat du solveur complet (avec timeout)
class SolverResult {
  final int solutionCount;
  final List<Solution> solutions;

  const SolverResult({
    required this.solutionCount,
    required this.solutions,
  });

  @override
  String toString() =>
      'SolverResult(count=$solutionCount, solutions=${solutions.length})';
}
